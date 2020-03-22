#define ELECTROLYZER_MODE_STANDBY	"standby"
#define ELECTROLYZER_MODE_WORKING	"working"

/obj/machinery/electrolyzer
	anchored = FALSE
	density = TRUE
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN
	icon = 'icons/obj/atmos.dmi'
	icon_state = "electrolyzer-off"
	name = "electrolyzer"
	desc = "Made by Space Amish using traditional space techniques, this heater/cooler is guaranteed not to set the station on fire. Warranty void if used in engines."
	max_integrity = 250
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 10)
	circuit = /obj/item/circuitboard/machine/electrolyzer
	ui_x = 400
	ui_y = 305

	var/obj/item/stock_parts/cell/cell
	var/on = FALSE
	var/mode = ELECTROLYZER_MODE_STANDBY
	var/setMode = "auto" // Anything other than "heat" or "cool" is considered auto.
	var/heatingPower = 40000
	var/workloadPower = 40000
	var/efficiency = 20000
	var/produces_gas = TRUE
	var/gasefficency = 1

	var/o2comp = 0
	var/h2comp = 0
	var/h2ocomp = 0
	var/gas_change_rate = 0.05
	var/combined_gas = 0

/obj/machinery/electrolyzer/get_cell()
	return cell

/obj/machinery/electrolyzer/Initialize()
	. = ..()
	cell = new(src)
	update_icon()

/obj/machinery/electrolyzer/on_construction()
	qdel(cell)
	cell = null
	panel_open = TRUE
	update_icon()
	return ..()

/obj/machinery/electrolyzer/on_deconstruction()
	if(cell)
		component_parts += cell
		cell = null
	return ..()

/obj/machinery/electrolyzer/examine(mob/user)
	. = ..()
	. += "\The [src] is [on ? "on" : "off"], and the hatch is [panel_open ? "open" : "closed"]."
	if(cell)
		. += "The charge meter reads [cell ? round(cell.percent(), 1) : 0]%."
	else
		. += "There is no power cell installed."
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads:Power consumption at <b>[(efficiency*-0.0025)+150]%</b>.</span>" //100%, 75%, 50%, 25%

/obj/machinery/electrolyzer/update_icon_state()
	if(on)
		icon_state = "electrolyzer-[mode]"
	else
		icon_state = "electrolyzer-off"

/obj/machinery/electrolyzer/update_overlays()
	. = ..()

	if(panel_open)
		. += "electrolyzer-open"

/obj/machinery/electrolyzer/process()
	if(!on || !is_operational())
		if (on) // If it's broken, turn it off too
			on = FALSE
		return PROCESS_KILL

	if(cell && cell.charge > 0)
		var/turf/L = loc
		if(!istype(L))
			if(mode != ELECTROLYZER_MODE_STANDBY)
				mode = ELECTROLYZER_MODE_STANDBY
				update_icon()
			return

		var/datum/gas_mixture/env = L.return_air()
		var/datum/gas_mixture/removed
		if(produces_gas)
		//Remove gas from surrounding area
			removed = env.remove(gasefficency * env.total_moles())
		else
		// Pass all the gas related code an empty gas container
			removed = new()

		if(h2ocomp > 0)
			produces_gas = TRUE
		else
			produces_gas = FALSE

		if(produces_gas)
			removed.assert_gases(/datum/gas/oxygen, /datum/gas/water_vapor, /datum/gas/hydrogen)
			combined_gas = max(removed.total_moles(), 0)
			o2comp += clamp(max(removed.gases[/datum/gas/oxygen][MOLES]/combined_gas, 0) - o2comp, -1, gas_change_rate)
			h2comp += clamp(max(removed.gases[/datum/gas/hydrogen][MOLES]/combined_gas, 0) - h2comp, -1, gas_change_rate)
			h2ocomp += clamp(max(removed.gases[/datum/gas/water_vapor][MOLES]/combined_gas, 0) - h2ocomp, -1, gas_change_rate)
			removed.gases[/datum/gas/oxygen][MOLES] += max(1, 0)
			removed.gases[/datum/gas/hydrogen][MOLES] += max(1, 0)
			removed.gases[/datum/gas/water_vapor][MOLES] -= max(1, 0)
			if(h2ocomp > 0)
				produces_gas = TRUE
			else
				produces_gas = FALSE
			if(produces_gas)
				env.merge(removed)
				air_update_turf()
				if(mode != ELECTROLYZER_MODE_WORKING)
					mode = ELECTROLYZER_MODE_WORKING
					update_icon()
		else
			mode = ELECTROLYZER_MODE_STANDBY
			update_icon()
		return
		var/heat_efficency = 1 / h2ocomp
		var/requiredPower = abs(env.temperature - h2ocomp) * heat_efficency
		cell.use(requiredPower / efficiency)
	else
		on = FALSE
		update_icon()
		return PROCESS_KILL

/obj/machinery/electrolyzer/RefreshParts()
	var/laser = 0
	var/cap = 0
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		laser += M.rating
	for(var/obj/item/stock_parts/capacitor/M in component_parts)
		cap += M.rating

	heatingPower = laser * 40000
	efficiency = (cap + 1) * 10000

/obj/machinery/electrolyzer/emp_act(severity)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN) || . & EMP_PROTECT_CONTENTS)
		return
	if(cell)
		cell.emp_act(severity)

/obj/machinery/electrolyzer/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(default_unfasten_wrench(user, I))
		return
	else if(istype(I, /obj/item/stock_parts/cell))
		if(panel_open)
			if(cell)
				to_chat(user, "<span class='warning'>There is already a power cell inside!</span>")
				return
			else if(!user.transferItemToLoc(I, src))
				return
			cell = I
			I.add_fingerprint(usr)

			user.visible_message("<span class='notice'>\The [user] inserts a power cell into \the [src].</span>", "<span class='notice'>You insert the power cell into \the [src].</span>")
			SStgui.update_uis(src)
		else
			to_chat(user, "<span class='warning'>The hatch must be open to insert a power cell!</span>")
			return
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		panel_open = !panel_open
		user.visible_message("<span class='notice'>\The [user] [panel_open ? "opens" : "closes"] the hatch on \the [src].</span>", "<span class='notice'>You [panel_open ? "open" : "close"] the hatch on \the [src].</span>")
		update_icon()
	else if(default_deconstruction_crowbar(I))
		return
	else
		return ..()

/obj/machinery/electrolyzer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "space_heater", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/electrolyzer/ui_data()
	var/list/data = list()
	data["open"] = panel_open
	data["on"] = on
	data["mode"] = setMode
	data["hasPowercell"] = !!cell
	if(cell)
		data["powerLevel"] = round(cell.percent(), 1)

	var/turf/L = get_turf(loc)
	var/curTemp
	if(istype(L))
		var/datum/gas_mixture/env = L.return_air()
		curTemp = env.temperature
	else if(isturf(L))
		curTemp = L.temperature
	if(isnull(curTemp))
		data["currentTemp"] = "N/A"
	else
		data["currentTemp"] = round(curTemp - T0C, 1)
	return data

/obj/machinery/electrolyzer/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			mode = ELECTROLYZER_MODE_STANDBY
			usr.visible_message("<span class='notice'>[usr] switches [on ? "on" : "off"] \the [src].</span>", "<span class='notice'>You switch [on ? "on" : "off"] \the [src].</span>")
			update_icon()
			if (on)
				START_PROCESSING(SSmachines, src)
			. = TRUE
		if("mode")
			setMode = params["mode"]
			. = TRUE
		if("eject")
			if(panel_open && cell)
				cell.forceMove(drop_location())
				cell = null
				. = TRUE

#undef ELECTROLYZER_MODE_STANDBY
#undef ELECTROLYZER_MODE_WORKING
