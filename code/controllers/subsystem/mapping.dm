var/datum/subsystem/mapping/SSmapping

/datum/subsystem/mapping
	name = "Mapping"
	init_order = 12
	flags = SS_NO_FIRE
	display_order = 50

	var/list/nuke_tiles = list()
	var/list/nuke_threats = list()

	var/datum/map_config/previous_map_config
	var/datum/map_config/config
	var/datum/map_config/next_map_config

	var/list/map_templates = list()

	var/list/ruins_templates = list()
	var/list/space_ruins_templates = list()
	var/list/lava_ruins_templates = list()

	var/list/shuttle_templates = list()
	var/list/shelter_templates = list()

/datum/subsystem/mapping/New()
	NEW_SS_GLOBAL(SSmapping)
	if(!previous_map_config)
		previous_map_config = new("previous_map.json")
		if(previous_map_config.defaulted)
			previous_map_config = null
	if(!config)
		config = new
	return ..()


/datum/subsystem/mapping/Initialize(timeofday)
	if(config.defaulted)
		world << "<span class='boldannounce'>Unable to load next map config, defaulting to Box Station</span>"
	loadWorld()
	preloadTemplates()
	// Pick a random away mission.
	createRandomZlevel()
	// Generate mining.

	var/mining_type = config.minetype
	if (mining_type == "lavaland")
		seedRuins(list(5), global.config.lavaland_budget, /area/lavaland/surface/outdoors, lava_ruins_templates)
		spawn_rivers()

	// deep space ruins
	var/space_zlevels = list()
	for(var/i in ZLEVEL_SPACEMIN to ZLEVEL_SPACEMAX)
		switch(i)
			if(ZLEVEL_MINING, ZLEVEL_LAVALAND, ZLEVEL_EMPTY_SPACE)
				continue
			else
				space_zlevels += i

	seedRuins(space_zlevels, global.config.space_budget, /area/space, space_ruins_templates)

	// Set up Z-level transistions.
	setup_map_transitions()
	..()

/* Nuke threats, for making the blue tiles on the station go RED
   Used by the AI doomsday and the self destruct nuke.
*/

/datum/subsystem/mapping/proc/add_nuke_threat(datum/nuke)
	nuke_threats[nuke] = TRUE
	check_nuke_threats()

/datum/subsystem/mapping/proc/remove_nuke_threat(datum/nuke)
	nuke_threats -= nuke
	check_nuke_threats()

/datum/subsystem/mapping/proc/check_nuke_threats()
	for(var/datum/d in nuke_threats)
		if(!istype(d) || QDELETED(d))
			nuke_threats -= d

	var/threats = nuke_threats.len

	for(var/N in nuke_tiles)
		var/turf/open/floor/T = N
		T.icon_state = (threats ? "rcircuitanim" : T.icon_regular_floor)

/datum/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
	map_templates = SSmapping.map_templates
	ruins_templates = SSmapping.ruins_templates
	space_ruins_templates = SSmapping.space_ruins_templates
	lava_ruins_templates = SSmapping.lava_ruins_templates
	shuttle_templates = SSmapping.shuttle_templates
	shelter_templates = SSmapping.shelter_templates

	previous_map_config = SSmapping.previous_map_config
	config = SSmapping.config
	next_map_config = SSmapping.next_map_config

#define INIT_ANNOUNCE(X) world << "<span class='boldannounce'>[X]</span>"; log_world(X)
/datum/subsystem/mapping/proc/loadWorld()
	var/dmm_suite/loader = new
	//TODO: FUCKING ERROR CHECKING YOU SCRUB
	INIT_ANNOUNCE("Loading Map '[config.map_name]'...")
	loader.load_map(file(config.GetFullMapPath()), 0, 0, 1, no_afterchange = TRUE)
	INIT_ANNOUNCE("Loaded station!")
	loader.load_map(file("_maps/map_files/generic/SpaceDock.dmm"), no_afterchange = TRUE)
	loader.load_map(file("_maps/map_files/generic/Space.dmm"), no_afterchange = TRUE)
	INIT_ANNOUNCE("Loading mining level...")
	loader.load_map(file("_maps/map_files/generic/[config.minetype].dmm"), no_afterchange = TRUE)
	INIT_ANNOUNCE("Loaded mining level!")
	for(var/I in 1 to 6)
		loader.load_map(file("_maps/map_files/generic/Space.dmm"), no_afterchange = TRUE)
	SortAreas()
	INIT_ANNOUNCE("Done loading map!") //can't think of anywhere better to put it
#undef INIT_ANNOUNCE

/datum/subsystem/mapping/proc/maprotate()
	var/players = clients.len
	var/list/mapvotes = list()
	//count votes
	for (var/client/c in clients)
		var/vote = c.prefs.preferred_map
		if (!vote)
			if (global.config.defaultmap)
				mapvotes[global.config.defaultmap.map_name] += 1
			continue
		mapvotes[vote] += 1

	//filter votes
	for (var/map in mapvotes)
		if (!map)
			mapvotes.Remove(map)
		if (!(map in global.config.maplist))
			mapvotes.Remove(map)
			continue
		var/datum/map_config/VM = global.config.maplist[map]
		if (!VM)
			mapvotes.Remove(map)
			continue
		if (VM.voteweight <= 0)
			mapvotes.Remove(map)
			continue
		if (VM.config_min_users > 0 && players < VM.config_min_users)
			mapvotes.Remove(map)
			continue
		if (VM.config_max_users > 0 && players > VM.config_max_users)
			mapvotes.Remove(map)
			continue

		mapvotes[map] = mapvotes[map]*VM.voteweight

	var/pickedmap = pickweight(mapvotes)
	if (!pickedmap)
		return
	var/datum/map_config/VM = global.config.maplist[pickedmap]
	message_admins("Randomly rotating map to [VM.map_name]")
	. = changemap(VM)
	if (.)
		world << "<span class='boldannounce'>Map rotation has chosen [VM.map_name] for next round!</span>"

/datum/subsystem/mapping/proc/changemap(var/datum/map_config/VM)	
	if(!VM.MakeNextMap())
		next_map_config = new(default_to_box = TRUE)
		message_admins("Failed to set new map with next_map.json for [VM.map_name]! Using default as backup!")
		return

	next_map_config = VM
	return TRUE

/datum/subsystem/mapping/Shutdown()
	if(config)
		config.MakePreviousMap()

/datum/subsystem/mapping/proc/preloadTemplates(path = "_maps/templates/") //see master controller setup
	var/list/filelist = flist(path)
	for(var/map in filelist)
		var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
		map_templates[T.name] = T

	preloadRuinTemplates()
	preloadShuttleTemplates()
	preloadShelterTemplates()

/datum/subsystem/mapping/proc/preloadRuinTemplates()
	// Still supporting bans by filename
	var/list/banned = generateMapList("config/lavaruinblacklist.txt")
	banned += generateMapList("config/spaceruinblacklist.txt")

	for(var/item in subtypesof(/datum/map_template/ruin))
		var/datum/map_template/ruin/ruin_type = item
		// screen out the abstract subtypes
		if(!initial(ruin_type.id))
			continue
		var/datum/map_template/ruin/R = new ruin_type()

		if(banned.Find(R.mappath))
			continue

		map_templates[R.name] = R
		ruins_templates[R.name] = R

		if(istype(R, /datum/map_template/ruin/lavaland))
			lava_ruins_templates[R.name] = R
		else if(istype(R, /datum/map_template/ruin/space))
			space_ruins_templates[R.name] = R

/datum/subsystem/mapping/proc/preloadShuttleTemplates()
	var/list/unbuyable = generateMapList("config/unbuyableshuttles.txt")

	for(var/item in subtypesof(/datum/map_template/shuttle))
		var/datum/map_template/shuttle/shuttle_type = item
		if(!(initial(shuttle_type.suffix)))
			continue

		var/datum/map_template/shuttle/S = new shuttle_type()
		if(unbuyable.Find(S.mappath))
			S.can_be_bought = FALSE

		shuttle_templates[S.shuttle_id] = S
		map_templates[S.shuttle_id] = S

/datum/subsystem/mapping/proc/preloadShelterTemplates()
	for(var/item in subtypesof(/datum/map_template/shelter))
		var/datum/map_template/shelter/shelter_type = item
		if(!(initial(shelter_type.mappath)))
			continue
		var/datum/map_template/shelter/S = new shelter_type()

		shelter_templates[S.shelter_id] = S
		map_templates[S.shelter_id] = S
