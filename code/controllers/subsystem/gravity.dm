var/datum/subsystem/gravity/SSgravity
var/global/legacy_gravity = FALSE

/datum/subsystem/gravity
	name = "Gravity"
	priority = 75
	wait = 1
	init_order = -100
	flags = SS_KEEP_TIMING | SS_BACKGROUND

	var/list/currentrun = list()
	var/list/currentrun_manual = list()
	var/list/areas = list()
	var/recalculation_cost = 0
	var/do_purge = FALSE
	var/purge_interval = 600
	var/purge_tick = 0
	var/purging = FALSE
	var/list/purging_atoms = list()
	var/list/area_blacklist_typecache
	var/list/area_blacklist = list(/area/lavaland, /area/mine, /area/centcom)

/datum/subsystem/gravity/New()
	NEW_SS_GLOBAL(SSgravity)

/datum/subsystem/gravity/Initialize()
	area_blacklist_typecache = typecacheof(area_blacklist)
	for(var/area/A in world)
		areas += A
	. = ..()

/proc/set_legacy_gravity(yes)	//ADMINS: This is an emergency killswitch for when things go out of control.
	legacy_gravity = yes

/proc/emergency_reset_gravity_force_processing()
	var/count = 0
	for(var/atom/movable/AM in atoms_forced_gravity_processing)
		AM.force_gravity_processing = FALSE
		count++
		CHECK_TICK
	atoms_forced_gravity_processing = list()
	return "[count] atoms purged from forced processing!"

/datum/subsystem/gravity/proc/recalculate_atoms()
	currentrun = list()
	currentrun_manual = list()
	var/tempcost = world.timeofday
	for(var/area/A in areas)
		if(!A.has_gravity && !A.gravity_generator && !A.gravity_overriding)
			continue
		if(!A.gravity_direction)
			continue
		if(is_type_in_typecache(A, area_blacklist_typecache))
			continue
		for(var/atom/movable/AM in A.contents_affected_by_gravity)
			if(AM.force_gravity_processing)
				continue
			currentrun += AM
	for(var/atom/movable/AM in atoms_forced_gravity_processing)
		currentrun_manual += AM
	recalculation_cost = world.timeofday - tempcost

/datum/subsystem/gravity/fire(resumed = FALSE)
	if(!resumed)
		if(legacy_gravity)
			can_fire = FALSE
			return FALSE
		recalculate_atoms()
		if(do_purge)
			purging = FALSE
			purge_tick++
			if(purge_tick >= purge_interval)
				purging_atoms = list()
				purging = TRUE
				purge_tick = 0
	while(currentrun.len)
		var/atom/movable/AM = currentrun[currentrun.len]
		if(AM)
			AM.gravity_tick++
			if(AM.gravity_tick >= AM.gravity_speed)
				AM.gravity_act()
				AM.gravity_tick = 0
		if(purging && do_purge)	//Only do laggy shit occasionally.
			purging_atoms += AM
		currentrun.len--
		if(MC_TICK_CHECK)
			return
	while(currentrun_manual.len)
		var/atom/movable/AM = currentrun_manual[currentrun_manual.len]
		if(AM)
			AM.gravity_tick++
			if(AM.gravity_tick >= AM.gravity_speed)
				AM.manual_gravity_process()
				AM.gravity_tick = 0
		if(purging && do_purge)
			purging_atoms += AM
		currentrun_manual.len--
		if(MC_TICK_CHECK)
			return
	if(purging && do_purge)
		while(purging_atoms.len)
			var/atom/movable/AM = purging_atoms[purging_atoms.len]
			purging_atoms.len--
			if(AM.gravity_ignores_turfcheck || isturf(AM.loc))
				var/current_area = get_area(AM)
				if(AM.current_gravity_area)
					if(AM.current_gravity_area != current_area)
						stack_trace("[AM] AT [AM.x] [AM.y] [AM.z] IN [current_area] INSTEAD OF CURRENT_GRAVITY_AREA [AM.current_gravity_area]!")
						AM.sync_gravity()
				else
					stack_trace("[AM] AT [AM.x] [AM.y] [AM.z] WITHOUT CURRENT GRAVITY AREA SET!")
					AM.sync_gravity()
			else
				stack_trace("[AM] AT [AM.x] [AM.y] [AM.z] IN [AM.current_gravity_area] STILL TICKING WITHOUT BEING IN TURF WITHOUT TURF CHECK OVERRIDE!")
				if(AM.current_gravity_area)
					AM.current_gravity_area.update_gravity(AM, FALSE)
				AM.sync_gravity()
