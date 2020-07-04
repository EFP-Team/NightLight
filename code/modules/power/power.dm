//////////////////////////////
// POWER MACHINERY BASE CLASS
//////////////////////////////

/// Power Machine bit flags
#define POWER_MACHINE_CONSUMER 1
#define POWER_MACHINE_PRODUCER 2
#define POWER_MACHINE_NEEDS_TERMINAL 4

/////////////////////////////
// Definitions
/////////////////////////////

/obj/machinery/power
	name = null
	icon = 'icons/obj/power.dmi'
	anchored = TRUE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	var/datum/powernet/powernet = null
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	var/machinery_layer = MACHINERY_LAYER_1 //cable layer to which the machine is connected
	var/power_flags = POWER_CONSUMER
	// We need a POWER_MACHINE_NEEDS_TERMINAL to use
	// this is also not a /power/terminal because we resue it
	// in terminal
	var/obj/machinery/power/terminal = null


/obj/machinery/power/Initialize(mapload)
	. = ..()
	if(mapload && (power_flags & POWER_MACHINE_NEEDS_TERMINAL))
		return INITIALIZE_HINT_LATELOAD

// called on map load to connect to the machine
/obj/machinery/power/LateInitialize()


/obj/machinery/power/Destroy()
	QDEL_NULL(edge)
	disconnect_from_network()
	addtimer(CALLBACK(GLOBAL_PROC, .proc/update_cable_icons_on_turf, get_turf(src)), 3)
	return ..()

///////////////////////////////
// General procedures
//////////////////////////////

// common helper procs for all power machines
// All power generation handled in add_avail()
// Machines should use add_load(), surplus(), avail()
// Non-machines should use add_delayedload(), delayed_surplus(), newavail()

//override this if the machine needs special functionality for making wire nodes appear, ie emitters, generators, etc.
/obj/machinery/power/proc/should_have_node()
	return power_flags & POWER_MACHINE_CONSUMER

/obj/machinery/power/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount
		return TRUE
	else
		return FALSE

/obj/machinery/power/proc/add_load(amount)
	if(powernet)
		powernet.load += amount

/obj/machinery/power/proc/surplus()
	if(powernet)
		return clamp(powernet.avail-powernet.load, 0, powernet.avail)
	else
		return 0

/obj/machinery/power/proc/avail(amount)
	if(powernet)
		return amount ? powernet.avail >= amount : powernet.avail
	else
		return 0

/obj/machinery/power/proc/add_delayedload(amount)
	if(powernet)
		powernet.delayedload += amount

/obj/machinery/power/proc/delayed_surplus()
	if(powernet)
		return clamp(powernet.newavail - powernet.delayedload, 0, powernet.newavail)
	else
		return 0

/obj/machinery/power/proc/newavail()
	if(powernet)
		return powernet.newavail
	else
		return 0

// should not run this except in lateInit during mapload
// crash if not found because the map maker forgot it?

/obj/machinery/power/proc/find_terminal(clear_master = TRUE)
	if(clear_master)
		disconnect_terminal()
	for(var/check_dir in GLOB.cardinals)
		var/turf/TB = get_step(src, check_dir)
		var/obj/machinery/power/terminal/term = locate(/obj/machinery/power/terminal) in TB
		if(term)
			terminal = term
			ASSERT(!terminal.master) // should be null on map load
			terminal.terminal = src
			terminal.setDir(get_dir(TB,src)) // set the direction
			break
	ASSERT(terminal)	// should of found one


/obj/machinery/power/proc/disconnect_terminal() // machines without a terminal will just return, no harm no fowl.
	ASSERT(power_flags & POWER_MACHINE_NEEDS_TERMINAL)
	if((power_flags & POWER_MACHINE_NEEDS_TERMINAL) && terminal)
		terminal.terminal = null
		terminal = null

// create a terminal object pointing towards the device
// wires will attach to this
/obj/machinery/power/smes/proc/make_terminal(turf/T)
	ASSERT(power_flags & POWER_MACHINE_NEEDS_TERMINAL)
	if(power_flags & POWER_MACHINE_NEEDS_TERMINAL)
		terminal = new/obj/machinery/power/terminal(T)
		terminal.setDir(get_dir(T,src))
		terminal.terminal = src

// returns true if the area has power on given channel (or doesn't require power).
// defaults to power_channel
/obj/machinery/proc/powered(var/chan = -1) // defaults to power_channel
	if(!loc)
		return FALSE
	if(!use_power)
		return TRUE

	var/area/A = get_area(src)		// make sure it's in an area
	if(!A)
		return FALSE					// if not, then not powered
	if(chan == -1)
		chan = power_channel
	return A.powered(chan)	// return power status of the area

// increment the power usage stats for an area
/obj/machinery/proc/use_power(amount, chan = -1) // defaults to power_channel
	var/area/A = get_area(src)		// make sure it's in an area
	if(!A)
		return
	if(chan == -1)
		chan = power_channel
	A.use_power(amount, chan)

/obj/machinery/proc/addStaticPower(value, powerchannel)
	var/area/A = get_area(src)
	if(!A)
		return
	A.addStaticPower(value, powerchannel)

/obj/machinery/proc/removeStaticPower(value, powerchannel)
	addStaticPower(-value, powerchannel)

/**
  * Called whenever the power settings of the containing area change
  *
  * by default, check equipment channel & set flag, can override if needed
  *
  * Returns TRUE if the NOPOWER flag was toggled
  */
/obj/machinery/proc/power_change()
	SHOULD_CALL_PARENT(1)
	if(machine_stat & BROKEN)
		return
	if(powered(power_channel))
		if(machine_stat & NOPOWER)
			SEND_SIGNAL(src, COMSIG_MACHINERY_POWER_RESTORED)
			. = TRUE
		machine_stat &= ~NOPOWER
	else
		if(!(machine_stat & NOPOWER))
			SEND_SIGNAL(src, COMSIG_MACHINERY_POWER_LOST)
			. = TRUE
		machine_stat |= NOPOWER
	update_icon()

// connect the machine to a powernet if a node cable or a terminal is present on the turf
/obj/machinery/power/proc/connect_to_network()
	var/turf/T = src.loc
	if(!T || !istype(T))
		return FALSE

	var/obj/structure/cable/C = T.get_cable_node(machinery_layer) //check if we have a node cable on the machine turf, the first found is picked
	if(!C)
		return FALSE  // no cable means no connection
	C.connect_machine(src)



	if(!C || !C.powernet)

		var/obj/machinery/power/terminal/term = locate(/obj/machinery/power/terminal) in T
		if(!term || !term.powernet)
			return FALSE
		else
			term.powernet.add_machine(src)
			return TRUE

	C.powernet.add_machine(src)
	return TRUE

// remove and disconnect the machine from its current powernet
/obj/machinery/power/proc/disconnect_from_network()
	if(!powernet)
		return FALSE
	powernet.remove_machine(src)
	return TRUE

// attach a wire to a power machine - leads from the turf you are standing on
//almost never called, overwritten by all power machines but terminal and generator
/obj/machinery/power/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		var/turf/T = user.loc
		if(T.intact || !isfloorturf(T))
			return
		if(get_dist(src, user) > 1)
			return
		coil.place_turf(T, user)
	else
		return ..()


///////////////////////////////////////////
// Powernet handling helpers
//////////////////////////////////////////

//returns all the cables WITHOUT a powernet in neighbors turfs,
//pointing towards the turf the machine is located at
/obj/machinery/power/proc/get_connections()
	. = list()
	var/turf/T

	for(var/card in GLOB.cardinals)
		T = get_step(loc,card)

		for(var/obj/structure/cable/C in T)
			if(C.powernet)
				continue
			. += C
	return .

//returns all the cables in neighbors turfs,
//pointing towards the turf the machine is located at
/obj/machinery/power/proc/get_marked_connections()
	. = list()
	var/turf/T

	for(var/card in GLOB.cardinals)
		T = get_step(loc,card)

		for(var/obj/structure/cable/C in T)
			. += C
	return .

//returns all the NODES (O-X) cables WITHOUT a powernet in the turf the machine is located at
/obj/machinery/power/proc/get_indirect_connections()
	. = list()
	for(var/obj/structure/cable/C in loc)
		if(C.powernet)
			continue
		. += C
	return .

/proc/update_cable_icons_on_turf(var/turf/T)
	for(var/obj/structure/cable/C in T.contents)
		C.update_icon()

///////////////////////////////////////////
// GLOBAL PROCS for powernets handling
//////////////////////////////////////////

///remove the old powernet and replace it with a new one throughout the network.
/proc/propagate_network(obj/structure/cable/C, datum/powernet/PN, skip_assigned_powernets = FALSE)
	var/list/found_machines = list()
	var/list/cables = list()
	var/index = 1
	var/obj/structure/cable/working_cable

	cables[C] = TRUE //associated list for performance reasons

	while(index <= length(cables))
		working_cable = cables[index]
		index++

		var/list/connections = working_cable.get_cable_connections(skip_assigned_powernets)

		for(var/obj/structure/cable/cable_entry in connections)
			if(!cables[cable_entry]) //Since it's an associated list, we can just do an access and check it's null before adding; prevents duplicate entries
				cables[cable_entry] = TRUE

	for(var/obj/structure/cable/cable_entry in cables)
		PN.add_cable(cable_entry)
		found_machines += cable_entry.get_machine_connections(skip_assigned_powernets)

	//now that the powernet is set, connect found machines to it
	for(var/obj/machinery/power/PM in found_machines)
		if(!PM.connect_to_network()) //couldn't find a node on its turf...
			PM.disconnect_from_network() //... so disconnect if already on a powernet


//Determines how strong could be shock, deals damage to mob, uses power.
//M is a mob who touched wire/whatever
//power_source is a source of electricity, can be power cell, area, apc, cable, powernet or null
//source is an object caused electrocuting (airlock, grille, etc)
//siemens_coeff - layman's terms, conductivity
//dist_check - set to only shock mobs within 1 of source (vendors, airlocks, etc.)
//No animations will be performed by this proc.
/proc/electrocute_mob(mob/living/carbon/M, power_source, obj/source, siemens_coeff = 1, dist_check = FALSE)
	if(!istype(M) || ismecha(M.loc))
		return 0	//feckin mechs are dumb
	if(dist_check)
		if(!in_range(source,M))
			return 0
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.siemens_coefficient == 0)
				SEND_SIGNAL(M, COMSIG_LIVING_SHOCK_PREVENTED, power_source, source, siemens_coeff, dist_check)
				return 0		//to avoid spamming with insulated glvoes on

	var/area/source_area
	if(istype(power_source, /area))
		source_area = power_source
		power_source = source_area.get_apc()
	if(istype(power_source, /obj/structure/cable))
		var/obj/structure/cable/Cable = power_source
		power_source = Cable.powernet

	var/datum/powernet/PN
	var/obj/item/stock_parts/cell/cell

	if(istype(power_source, /datum/powernet))
		PN = power_source
	else if(istype(power_source, /obj/item/stock_parts/cell))
		cell = power_source
	else if(istype(power_source, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc = power_source
		cell = apc.cell
		if (apc.terminal)
			PN = apc.terminal.powernet
	else if (!power_source)
		return 0
	else
		log_admin("ERROR: /proc/electrocute_mob([M], [power_source], [source]): wrong power_source")
		return 0
	if (!cell && !PN)
		return 0
	var/PN_damage = 0
	var/cell_damage = 0
	if (PN)
		PN_damage = PN.get_electrocute_damage()
	if (cell)
		cell_damage = cell.get_electrocute_damage()
	var/shock_damage = 0
	if (PN_damage>=cell_damage)
		power_source = PN
		shock_damage = PN_damage
	else
		power_source = cell
		shock_damage = cell_damage
	var/drained_hp = M.electrocute_act(shock_damage, source, siemens_coeff) //zzzzzzap!
	log_combat(source, M, "electrocuted")

	var/drained_energy = drained_hp*20

	if (source_area)
		source_area.use_power(drained_energy/GLOB.CELLRATE)
	else if (istype(power_source, /datum/powernet))
		var/drained_power = drained_energy/GLOB.CELLRATE //convert from "joules" to "watts"
		PN.delayedload += (min(drained_power, max(PN.newavail - PN.delayedload, 0)))
	else if (istype(power_source, /obj/item/stock_parts/cell))
		cell.use(drained_energy)
	return drained_energy

////////////////////////////////////////////////
// Misc.
///////////////////////////////////////////////

// return a cable able connect to machinery on layer if there's one on the turf, null if there isn't one
/turf/proc/get_cable_node(machinery_layer = MACHINERY_LAYER_1)
	if(!can_have_cabling())
		return null
	for(var/obj/structure/cable/C in src)
		if(C.machinery_layer & machinery_layer)
			C.update_icon()
			return C
	return null

/area/proc/get_apc()
	for(var/obj/machinery/power/apc/APC in GLOB.apcs_list)
		if(APC.area == src)
			return APC
