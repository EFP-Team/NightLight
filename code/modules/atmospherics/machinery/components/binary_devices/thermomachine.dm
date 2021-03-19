/obj/machinery/atmospherics/components/binary/thermomachine
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"

	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."

	density = TRUE
	max_integrity = 300
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 80, ACID = 30)
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/thermomachine

	pipe_flags = PIPING_ONE_PER_TURF

	var/icon_state_off = "freezer"
	var/icon_state_on = "freezer_1"
	var/icon_state_open = "freezer-o"

	var/min_temperature = T20C //actual temperature will be defined by RefreshParts() and by the cooling var
	var/max_temperature = T20C //actual temperature will be defined by RefreshParts() and by the cooling var
	var/target_temperature = T20C
	var/heat_capacity = 0
	var/interactive = TRUE // So mapmakers can disable interaction.
	var/cooling = TRUE
	var/base_heating = 140
	var/base_cooling = 170
	var/was_on = FALSE      //checks if the machine was on before it lost power

/obj/machinery/atmospherics/components/binary/thermomachine/Initialize()
	. = ..()
	initialize_directions = dir
	RefreshParts()
	update_appearance()

/obj/machinery/atmospherics/components/binary/thermomachine/getNodeConnects()
	return list(dir, turn(dir, 180))

/obj/machinery/atmospherics/components/binary/thermomachine/proc/swap_function()
	cooling = !cooling
	if(cooling)
		icon_state_off = "freezer"
		icon_state_on = "freezer_1"
		icon_state_open = "freezer-o"
	else
		icon_state_off = "heater"
		icon_state_on = "heater_1"
		icon_state_open = "heater-o"
	target_temperature = T20C
	RefreshParts()
	update_appearance()

/obj/machinery/atmospherics/components/binary/thermomachine/on_construction(obj_color, set_layer)
	var/obj/item/circuitboard/machine/thermomachine/board = circuit
	if(board)
		piping_layer = board.pipe_layer
		set_layer = piping_layer

	for(var/obj/machinery/atmospherics/device in get_turf(src))
		if(device.piping_layer != piping_layer || device == src)
			continue
		visible_message("<span class='warning'>A pipe is hogging the output, remove the obstruction or change the machine piping layer.</span>")
		deconstruct(TRUE)
		return
	return..()

/obj/machinery/atmospherics/components/binary/thermomachine/RefreshParts()
	var/calculated_bin_rating
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		calculated_bin_rating += bin.rating
	heat_capacity = 5000 * ((calculated_bin_rating - 1) ** 2)
	min_temperature = T20C
	max_temperature = T20C
	if(cooling)
		var/calculated_laser_rating
		for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
			calculated_laser_rating += laser.rating
		min_temperature = max(T0C - (base_cooling + calculated_laser_rating * 15), TCMB) //73.15K with T1 stock parts
	else
		var/calculated_laser_rating
		for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
			calculated_laser_rating += laser.rating
		max_temperature = T20C + (base_heating * calculated_laser_rating) //573.15K with T1 stock parts

/obj/machinery/atmospherics/components/binary/thermomachine/update_icon_state()
	if(panel_open)
		icon_state = icon_state_open
		return ..()
	if(on && is_operational)
		icon_state = icon_state_on
		return ..()
	icon_state = icon_state_off
	return ..()

/obj/machinery/atmospherics/components/binary/thermomachine/update_overlays()
	. = ..()
	. += getpipeimage(icon, "pipe", dir, COLOR_LIME, piping_layer)
	. += getpipeimage(icon, "pipe", turn(dir, 180), COLOR_MOSTLY_PURE_RED, piping_layer)

/obj/machinery/atmospherics/components/binary/thermomachine/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		add_overlay(getpipeimage(icon, "scrub_cap", initialize_directions))

/obj/machinery/atmospherics/components/binary/thermomachine/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The thermostat is set to [target_temperature]K ([(T0C-target_temperature)*-1]C).</span>"
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Efficiency <b>[(heat_capacity/5000)*100]%</b>.</span>"
		. += "<span class='notice'>Temperature range <b>[min_temperature]K - [max_temperature]K ([(T0C-min_temperature)*-1]C - [(T0C-max_temperature)*-1]C)</b>.</span>"

/obj/machinery/atmospherics/components/binary/thermomachine/AltClick(mob/living/user)
	if(!can_interact(user))
		return
	if(cooling)
		target_temperature = min_temperature
		investigate_log("was set to [target_temperature] K by [key_name(user)]", INVESTIGATE_ATMOS)
		to_chat(user, "<span class='notice'>You minimize the target temperature on [src] to [target_temperature] K.</span>")
	else
		target_temperature = max_temperature
		investigate_log("was set to [target_temperature] K by [key_name(user)]", INVESTIGATE_ATMOS)
		to_chat(user, "<span class='notice'>You maximize the target temperature on [src] to [target_temperature] K.</span>")

/obj/machinery/atmospherics/components/binary/thermomachine/process_atmos()
	if(!is_operational || !on || !nodes[1])  //if it has no power or its switched off, dont process atmos
		return
	else if(is_operational && was_on == TRUE)  //if it was switched on before it turned off due to no power, turn the machine back on
		on = TRUE
	var/datum/gas_mixture/main_port = airs[1]
	var/datum/gas_mixture/thermal_exchange_port = airs[2]
	var/turf/local_turf = get_turf(src)
	var/main_heat_capacity = main_port.heat_capacity()
	var/thermal_heat_capacity = thermal_exchange_port.heat_capacity()
	var/temperature_delta = main_port.temperature - target_temperature

	var/motor_heat = 2500
	if(abs(temperature_delta) < 1.5) //allow the machine to work more finely
		motor_heat = 0

	var/heat_amount = temperature_delta * (main_heat_capacity * heat_capacity / (main_heat_capacity + heat_capacity))
	var/efficiency = 1
	if(main_port.total_moles() && thermal_exchange_port.total_moles())
		if(cooling)
			thermal_exchange_port.temperature = max(thermal_exchange_port.temperature + heat_amount / thermal_heat_capacity + motor_heat / thermal_heat_capacity, TCMB)
		var/temperature_difference = thermal_exchange_port.temperature - main_port.temperature
		temperature_difference = cooling ? temperature_difference : 0
		if(temperature_difference > 0)
			efficiency = max(1 - log(10, temperature_difference) * 0.1, 1)
		main_port.temperature = max(main_port.temperature - (heat_amount * efficiency)/ main_heat_capacity + motor_heat / main_heat_capacity, TCMB)
	else if(main_port.total_moles() && (thermal_exchange_port.total_moles() || !nodes[2]))
		var/datum/gas_mixture/enviroment = local_turf.return_air()
		if(cooling)
			var/enviroment_heat_capacity = enviroment.heat_capacity()
			enviroment.temperature = max(enviroment.temperature + heat_amount / enviroment_heat_capacity, TCMB)
			air_update_turf(FALSE, FALSE)
		var/temperature_difference = enviroment.temperature - main_port.temperature
		temperature_difference = cooling ? temperature_difference : 0
		if(temperature_difference > 0)
			efficiency = max(1 - log(10, temperature_difference) * 0.1, 1)
		main_port.temperature = max(main_port.temperature - (heat_amount * efficiency) / main_heat_capacity + motor_heat / main_heat_capacity, TCMB)

	temperature_delta = abs(temperature_delta)
	if(temperature_delta > 1)
		active_power_usage = ((heat_capacity * temperature_delta) + idle_power_usage) ** (1 + (1 - efficiency))
	else
		active_power_usage = idle_power_usage
	update_parents()

/obj/machinery/atmospherics/components/binary/thermomachine/attackby(obj/item/I, mob/user, params)
	if(!on)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/binary/thermomachine/default_change_direction_wrench(mob/user, obj/item/I)
	if(!.)
		return FALSE
	SetInitDirections()
	var/obj/machinery/atmospherics/node1 = nodes[1]
	var/obj/machinery/atmospherics/node2 = nodes[2]
	if(node1)
		if(src in node1.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node1.disconnect(src)
		nodes[1] = null
	if(node2)
		if(src in node2.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node2.disconnect(src)
		nodes[2] = null

	if(parents[1])
		nullifyPipenet(parents[1])
	if(parents[2])
		nullifyPipenet(parents[2])

	atmosinit()
	node1 = nodes[1]
	if(node1)
		node1.atmosinit()
		node1.addMember(src)
	node2 = nodes[2]
	if(node2)
		node2.atmosinit()
		node2.addMember(src)
	SSair.add_to_rebuild_queue(src)
	return TRUE

/obj/machinery/atmospherics/components/binary/thermomachine/ui_status(mob/user)
	if(interactive)
		return ..()
	return UI_CLOSE

/obj/machinery/atmospherics/components/binary/thermomachine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ThermoMachine", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/thermomachine/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["cooling"] = cooling

	data["min"] = min_temperature
	data["max"] = max_temperature
	data["target"] = target_temperature
	data["initial"] = initial(target_temperature)

	var/datum/gas_mixture/air1 = airs[1]
	data["temperature"] = air1.temperature
	data["pressure"] = air1.return_pressure()
	return data

/obj/machinery/atmospherics/components/binary/thermomachine/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("power")
			on = !on
			use_power = on ? ACTIVE_POWER_USE : IDLE_POWER_USE
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
			was_on = !was_on  //if the machine was manually turned on, ensure it remembers it
		if("cooling")
			swap_function()
			investigate_log("was changed to [cooling ? "cooling" : "heating"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("target")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("Set new target ([min_temperature]-[max_temperature] K):", name, target_temperature) as num|null
				if(!isnull(target))
					. = TRUE
			else if(adjust)
				target = target_temperature + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target_temperature = clamp(target, min_temperature, max_temperature)
				investigate_log("was set to [target_temperature] K by [key_name(usr)]", INVESTIGATE_ATMOS)

	update_appearance()

/obj/machinery/atmospherics/components/binary/thermomachine/CtrlClick(mob/living/user)
	if(!can_interact(user))
		return
	on = !on
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	update_appearance()

/obj/machinery/atmospherics/components/binary/thermomachine/freezer
	icon_state = "freezer"
	icon_state_off = "freezer"
	icon_state_on = "freezer_1"
	icon_state_open = "freezer-o"
	cooling = TRUE

/obj/machinery/atmospherics/components/binary/thermomachine/freezer/on
	on = TRUE
	icon_state = "freezer_1"

/obj/machinery/atmospherics/components/binary/thermomachine/freezer/on/Initialize()
	. = ..()
	if(target_temperature == initial(target_temperature))
		target_temperature = min_temperature

/obj/machinery/atmospherics/components/binary/thermomachine/freezer/on/coldroom
	name = "Cold room temperature control unit"

/obj/machinery/atmospherics/components/binary/thermomachine/freezer/on/coldroom/Initialize()
	. = ..()
	target_temperature = COLD_ROOM_TEMP

/obj/machinery/atmospherics/components/binary/thermomachine/heater
	icon_state = "heater"
	icon_state_off = "heater"
	icon_state_on = "heater_1"
	icon_state_open = "heater-o"
	cooling = FALSE

/obj/machinery/atmospherics/components/binary/thermomachine/heater/on
	on = TRUE
	icon_state = "heater_1"
