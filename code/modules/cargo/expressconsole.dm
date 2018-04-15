#define MAX_EMAG_ROCKETS 8
#define POD_STANDARD 0
#define POD_BLUESPACE 1
#define BEACON_COST 5000
#define SP_LINKED 1
#define SP_READY 2 
#define SP_LAUNCH 3
#define SP_UNLINK 4 
#define SP_UNREADY 5
#define POD_STANDARD 0
#define POD_BLUESPACE 1

/obj/machinery/computer/cargo/express
	name = "express supply console"
	desc = "This console allows the user to purchase a package \
		with 1/40th of the delivery time: made possible by NanoTrasen's new \"1500mm Orbital Railgun\".\
		All sales are near instantaneous - please choose carefully"
	icon_screen = "supply_express"
	circuit = /obj/item/circuitboard/computer/cargo/express
	blockade_warning = "Bluespace instability detected. Delivery impossible."
	req_access = list(ACCESS_QM)
	var/message
	var/printed_beacons = 0 //number of beacons printed. Used to determine beacon names.
	var/list/meme_pack_data
	var/obj/item/supplypod_beacon/beacon //the linked supplypod beacon
	var/area/landingzone = /area/quartermaster/storage //where we droppin boys
	var/podID = POD_STANDARD //0 is your standard supply supplypod (requires dissassembly after landing), 1 is the bluespace supply pod (teleports out after landing)
	var/cooldown = 0 //cooldown to prevent printing supplypod beacon spam
	var/locked = TRUE //is the console locked? unlock with ID
	var/usingBeacon = FALSE //is the console in beacon mode? exists to let beacon know when a pod may come in

/obj/machinery/computer/cargo/express/Initialize()
	. = ..()
	packin_up()
	
/obj/machinery/computer/cargo/express/Destroy()
	if(beacon)
		beacon.unlink_console()
	return ..()

/obj/machinery/computer/cargo/express/attackby(obj/item/W, mob/living/user, params)
	if((istype(W, /obj/item/card/id) || istype(W, /obj/item/pda)) && allowed(user))
		locked = !locked
		to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the interface.</span>")
		return
	else if(istype(W, /obj/item/disk/cargo/bluespace_pod))
		podID = POD_BLUESPACE//doesnt effect circuit board, making reversal possible
		to_chat(user, "<span class='notice'>You insert the disk into [src], allowing for advanced supply delivery vehicles.</span>")
		qdel(W)
		return TRUE
	..()

/obj/machinery/computer/cargo/express/emag_act(mob/living/user)
	if(obj_flags & EMAGGED)
		return
	user.visible_message("<span class='warning'>[user] swipes a suspicious card through [src]!</span>",
	"<span class='notice'>You change the routing protocols, allowing the Supply Pod to land anywhere on the station.</span>")
	obj_flags |= EMAGGED
	// This also sets this on the circuit board
	var/obj/item/circuitboard/computer/cargo/board = circuit
	board.obj_flags |= EMAGGED
	packin_up()

/obj/machinery/computer/cargo/express/proc/packin_up() // oh shit, I'm sorry
	meme_pack_data = list() // sorry for what?
	for(var/pack in SSshuttle.supply_packs) // our quartermaster taught us not to be ashamed of our supply packs
		var/datum/supply_pack/P = SSshuttle.supply_packs[pack]  // specially since they're such a good price and all
		if(!meme_pack_data[P.group]) // yeah, I see that, your quartermaster gave you good advice
			meme_pack_data[P.group] = list( // it gets cheaper when I return it
				"name" = P.group, // mmhm
				"packs" = list()  // sometimes, I return it so much, I rip the manifest
			) // see, my quartermaster taught me a few things too
		if((P.hidden) || (P.special)) // like, how not to rip the manifest
			continue// by using someone else's crate
		if(!(obj_flags & EMAGGED) && P.contraband) // will you show me?
			continue // i'd be right happy to
		meme_pack_data[P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.cost,
			"id" = pack,
			"desc" = P.desc || P.name // If there is a description, use it. Otherwise use the pack's name.
		))

/obj/machinery/computer/cargo/express/ui_interact(mob/living/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cargo_express", name, 1000, 800, master_ui, state)
		ui.open()


/obj/machinery/computer/cargo/express/ui_data(mob/user)
	var/canBeacon = beacon && (isturf(beacon.loc) || ismob(beacon.loc))
	//if (beacon)
		//message_admins("alright so: usingbeacon = [usingBeacon] and beacon = [beacon] and isturf(b) = [(beacon) ? isturf(beacon.loc) : 5] and ismob(b) = [(beacon) ? ismob(beacon.loc) : 5] okay? and ifnally, : canBeacon is[canBeacon]")
	var/list/data = list()
	data["locked"] = locked
	data["siliconUser"] = user.has_unlimited_silicon_privilege
	data["beaconzone"] = beacon ? get_area(beacon) : ""
	data["usingBeacon"] = usingBeacon
	data["canBeacon"] = !usingBeacon || canBeacon
	data["canBuyBeacon"] = cooldown <= 0 && SSshuttle.points >= BEACON_COST
	data["beaconError"] = usingBeacon && !canBeacon ? "(BEACON ERROR)" : ""
	data["hasBeacon"] = beacon != null
	data["beaconName"] = beacon ? beacon.name : "No Beacon Found"
	data["printMsg"] = cooldown > 0 ? "Print Beacon for [BEACON_COST] credits ([cooldown])" : "Print Beacon for [BEACON_COST] credits"
	data["points"] = SSshuttle.points
	data["supplies"] = list()
	message = "Sales are near-instantaneous - please choose carefully."
	if(SSshuttle.supplyBlocked)
		message = blockade_warning
	if(usingBeacon && !beacon)
		message = "BEACON ERROR: BEACON MISSING"//beacon was destroyed
	else if (usingBeacon && !canBeacon)
		message = "BEACON ERROR: MUST BE EXPOSED"//beacon's loc/user's loc must be a turf
	if(obj_flags & EMAGGED)
		message = "(&!#@ERROR: ROUTING_#PROTOCOL MALF(*CT#ON. $UG%ESTE@ ACT#0N: !^/PULS3-%E)ET CIR*)ITB%ARD."

	data["message"] = message
	if(!meme_pack_data)
		packin_up()
		stack_trace("You didn't give the cargo tech good advice, and he ripped the manifest. As a result, there was no pack data for [src]")
	data["supplies"] = meme_pack_data
	if (cooldown > 0)
		cooldown--
	return data

/obj/machinery/computer/cargo/express/ui_act(action, params, datum/tgui/ui)
	switch(action)
		if("LZCargo")	
			usingBeacon = FALSE
			if (beacon)
				beacon.update_status(SP_UNREADY) //ready light on beacon will turn off
		if("LZBeacon")
			usingBeacon = TRUE
			if (beacon)
				beacon.update_status(SP_READY) //turns on the beacon's ready light
		if("printBeacon")//cooldown conditional is located in cargo_express.ract
			cooldown = 10//a ~ten second cooldown for printing beacons to prevent spam
			var/obj/item/supplypod_beacon/C = new /obj/item/supplypod_beacon(loc)
			C.link_console(src)//rather than in beacon's Initialize(), we can assign the computer to the beacon by reusing this proc)
			printed_beacons++//printed_beacons starts at 0
			beacon.name = "Supply Pod Beacon #[printed_beacons]"
			SSshuttle.points -= BEACON_COST

		if("add")//Generate Supply Order first
			var/id = text2path(params["id"])
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
			if(!istype(pack))
				return
			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = usr.ckey
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				name = H.get_authentification_name()
				rank = H.get_assignment()
			else if(issilicon(usr))
				name = usr.real_name
				rank = "Silicon"
			var/reason = ""
			var/list/empty_turfs
			var/datum/supply_order/SO = new(pack, name, rank, ckey, reason)
			if(!(obj_flags & EMAGGED))
				if(SO.pack.cost <= SSshuttle.points)
					landingzone = locate(/area/quartermaster/storage) in GLOB.sortedAreas
					for(var/turf/open/floor/T in landingzone.contents)//uses default landing zone
						if(is_blocked_turf(T))
							continue
						LAZYADD(empty_turfs, T)
						CHECK_TICK
					if(empty_turfs && empty_turfs.len)
						var/LZ = empty_turfs[rand(empty_turfs.len-1)]
						if (istype(beacon) && usingBeacon)
							LZ = get_turf(beacon)
							beacon.update_status(SP_LAUNCH)
						SSshuttle.points -= SO.pack.cost
						
						new /obj/effect/DPtarget(LZ, SO, podID)
						. = TRUE
						update_icon()
			else
				if(SO.pack.cost * (0.72*MAX_EMAG_ROCKETS) <= SSshuttle.points) // bulk discount :^)
					landingzone = locate(pick(GLOB.the_station_areas)) in GLOB.sortedAreas //override default landing zone
					for(var/turf/open/floor/T in landingzone.contents)
						if(is_blocked_turf(T))
							continue
						LAZYADD(empty_turfs, T)
						CHECK_TICK
					if(empty_turfs && empty_turfs.len)
						SSshuttle.points -= SO.pack.cost * (1.2*MAX_EMAG_ROCKETS)
						SO.generateRequisition(get_turf(src))
						for(var/i in 1 to MAX_EMAG_ROCKETS)
							var/LZ = empty_turfs[rand(empty_turfs.len-1)]
							LAZYREMOVE(empty_turfs, LZ)
							new /obj/effect/DPtarget(LZ, SO, podID)
							. = TRUE
							update_icon()
							CHECK_TICK
