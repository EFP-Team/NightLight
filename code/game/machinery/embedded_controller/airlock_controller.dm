//States for airlock_control
#define AIRLOCK_STATE_INOPEN "inopen"
#define AIRLOCK_STATE_PRESSURIZE "pressurize"
#define AIRLOCK_STATE_CLOSED "closed"
#define AIRLOCK_STATE_DEPRESSURIZE "depressurize"
#define AIRLOCK_STATE_OUTOPEN "outopen"

/datum/computer/file/embedded_program/airlock_controller
	var/id_tag
	var/exterior_door_tag //Burn chamber facing door
	var/interior_door_tag //Station facing door
	var/airpump_tag //See: dp_vent_pump.dm
	var/sensor_tag //See: /obj/machinery/airlock_sensor
	var/sanitize_external //Before the interior airlock opens, do we first drain all gases inside the chamber and then repressurize?

	state = AIRLOCK_STATE_CLOSED
	var/target_state = AIRLOCK_STATE_CLOSED
	var/sensor_pressure = null

/datum/computer/file/embedded_program/airlock_controller/receive_signal(datum/signal/signal)
	var/receive_tag = signal.data["tag"]
	if(!receive_tag)
		return

	if(receive_tag==sensor_tag)
		if(signal.data["pressure"])
			sensor_pressure = text2num(signal.data["pressure"])

	else if(receive_tag==exterior_door_tag)
		memory["exterior_status"] = signal.data["door_status"]

	else if(receive_tag==interior_door_tag)
		memory["interior_status"] = signal.data["door_status"]

	else if(receive_tag==airpump_tag)
		if(signal.data["power"])
			memory["pump_status"] = signal.data["direction"]
		else
			memory["pump_status"] = "off"

	else if(receive_tag==id_tag)
		switch(signal.data["command"])
			if("cycle")
				if(state < AIRLOCK_STATE_CLOSED)
					target_state = AIRLOCK_STATE_OUTOPEN
				else
					target_state = AIRLOCK_STATE_INOPEN

/datum/computer/file/embedded_program/airlock_controller/receive_user_command(command)
	switch(command)
		if("cycleClosed")
			target_state = AIRLOCK_STATE_CLOSED
		if("cycleExterior")
			target_state = AIRLOCK_STATE_OUTOPEN
		if("cycleInterior")
			target_state = AIRLOCK_STATE_INOPEN
		if("abort")
			target_state = AIRLOCK_STATE_CLOSED

/datum/computer/file/embedded_program/airlock_controller/process()
	var/process_again = 1
	while(process_again)
		process_again = 0
		switch(state)
			if(AIRLOCK_STATE_INOPEN)
				if(target_state != state)
					if(memory["interior_status"] == "closed")
						state = AIRLOCK_STATE_CLOSED
						process_again = 1
					else
						post_signal(new /datum/signal(list(
							"tag" = interior_door_tag,
							"command" = "secure_close"
						)))
				else
					if(memory["pump_status"] != "off")
						post_signal(new /datum/signal(list(
							"tag" = airpump_tag,
							"power" = 0,
							"sigtype" = "command"
						)))

			if(AIRLOCK_STATE_PRESSURIZE)
				if(target_state == AIRLOCK_STATE_INOPEN)
					if(sensor_pressure >= ONE_ATMOSPHERE*0.95)
						if(memory["interior_status"] == "open")
							state = AIRLOCK_STATE_INOPEN
							process_again = 1
						else
							post_signal(new /datum/signal(list(
								"tag" = interior_door_tag,
								"command" = "secure_open"
							)))
					else
						var/datum/signal/signal = new(list(
							"tag" = airpump_tag,
							"sigtype" = "command"
						))
						if(memory["pump_status"] == "siphon")
							signal.data["stabilize"] = 1
						else if(memory["pump_status"] != "release")
							signal.data["power"] = 1
						post_signal(signal)
				else
					state = AIRLOCK_STATE_CLOSED
					process_again = 1

			if(AIRLOCK_STATE_CLOSED)
				if(target_state == AIRLOCK_STATE_OUTOPEN)
					if(memory["interior_status"] == "closed")
						state = AIRLOCK_STATE_DEPRESSURIZE
						process_again = 1
					else
						post_signal(new /datum/signal(list(
							"tag" = interior_door_tag,
							"command" = "secure_close"
						)))
				else if(target_state == AIRLOCK_STATE_INOPEN)
					if(memory["exterior_status"] == "closed")
						state = AIRLOCK_STATE_PRESSURIZE
						process_again = 1
					else
						post_signal(new /datum/signal(list(
							"tag" = exterior_door_tag,
							"command" = "secure_close"
						)))

				else
					if(memory["pump_status"] != "off")
						post_signal(new /datum/signal(list(
							"tag" = airpump_tag,
							"power" = 0,
							"sigtype" = "command"
						)))

			if(AIRLOCK_STATE_DEPRESSURIZE)
				var/target_pressure = ONE_ATMOSPHERE*0.05
				if(sanitize_external)
					target_pressure = ONE_ATMOSPHERE*0.01

				if(sensor_pressure <= target_pressure)
					if(target_state == AIRLOCK_STATE_OUTOPEN)
						if(memory["exterior_status"] == "open")
							state = AIRLOCK_STATE_OUTOPEN
						else
							post_signal(new /datum/signal(list(
								"tag" = exterior_door_tag,
								"command" = "secure_open"
							)))
					else
						state = AIRLOCK_STATE_CLOSED
						process_again = 1
				else if((target_state != AIRLOCK_STATE_OUTOPEN) && !sanitize_external)
					state = AIRLOCK_STATE_CLOSED
					process_again = 1
				else
					var/datum/signal/signal = new(list(
						"tag" = airpump_tag,
						"sigtype" = "command"
					))
					if(memory["pump_status"] == "release")
						signal.data["purge"] = 1
					else if(memory["pump_status"] != "siphon")
						signal.data["power"] = 1
					post_signal(signal)

			if(AIRLOCK_STATE_OUTOPEN) //state 2
				if(target_state != AIRLOCK_STATE_OUTOPEN)
					if(memory["exterior_status"] == "closed")
						if(sanitize_external)
							state = AIRLOCK_STATE_DEPRESSURIZE
							process_again = 1
						else
							state = AIRLOCK_STATE_CLOSED
							process_again = 1
					else
						post_signal(new /datum/signal(list(
							"tag" = exterior_door_tag,
							"command" = "secure_close"
						)))
				else
					if(memory["pump_status"] != "off")
						post_signal(new /datum/signal(list(
							"tag" = airpump_tag,
							"power" = 0,
							"sigtype" = "command"
						)))

	memory["sensor_pressure"] = sensor_pressure
	memory["processing"] = state != target_state
	//sensor_pressure = null //not sure if we can comment this out. Uncomment in case of problems -rastaf0

	return 1


/obj/machinery/embedded_controller/radio/airlock_controller
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	base_icon_state = "airlock_control"

	name = "airlock console"
	density = FALSE

	frequency = FREQ_AIRLOCK_CONTROL
	power_channel = AREA_USAGE_ENVIRON

	// Setup parameters only
	var/exterior_door_tag
	var/interior_door_tag
	var/airpump_tag
	var/sensor_tag
	var/sanitize_external

/obj/machinery/embedded_controller/radio/airlock_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockController", src)
		ui.open()

/obj/machinery/embedded_controller/radio/airlock_controller/ui_data(mob/user)
	var/list/data = list()
	data["airlockState"] = program.state
	data["sensorPressure"] = program.memory["sensor_pressure"] ? program.memory["sensor_pressure"] : "----"
	data["exteriorStatus"] = program.memory["exterior_status"] ? program.memory["exterior_status"] : "----"
	data["interiorStatus"] = program.memory["interior_status"] ? program.memory["interior_status"] : "----"
	data["pumpStatus"] = program.memory["pump_status"] ? program.memory["pump_status"] : "----"
	return data

/obj/machinery/embedded_controller/radio/airlock_controller/ui_act(action, params)
	. = ..()
	if(.)
		return
	// no need for sanitisation, command just changes target_state and can't do anything else
	process_command(action)
	return TRUE

/obj/machinery/embedded_controller/radio/airlock_controller/incinerator_ordmix
	name = "Incinerator Access Console"
	airpump_tag = INCINERATOR_ORDMIX_DP_VENTPUMP
	exterior_door_tag = INCINERATOR_ORDMIX_AIRLOCK_EXTERIOR
	id_tag = INCINERATOR_ORDMIX_AIRLOCK_CONTROLLER
	interior_door_tag = INCINERATOR_ORDMIX_AIRLOCK_INTERIOR
	sanitize_external = TRUE
	sensor_tag = INCINERATOR_ORDMIX_AIRLOCK_SENSOR

/obj/machinery/embedded_controller/radio/airlock_controller/incinerator_atmos
	name = "Incinerator Access Console"
	airpump_tag = INCINERATOR_ATMOS_DP_VENTPUMP
	exterior_door_tag = INCINERATOR_ATMOS_AIRLOCK_EXTERIOR
	id_tag = INCINERATOR_ATMOS_AIRLOCK_CONTROLLER
	interior_door_tag = INCINERATOR_ATMOS_AIRLOCK_INTERIOR
	sanitize_external = TRUE
	sensor_tag = INCINERATOR_ATMOS_AIRLOCK_SENSOR

/obj/machinery/embedded_controller/radio/airlock_controller/incinerator_syndicatelava
	name = "Incinerator Access Console"
	airpump_tag = INCINERATOR_SYNDICATELAVA_DP_VENTPUMP
	exterior_door_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_EXTERIOR
	id_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_CONTROLLER
	interior_door_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_INTERIOR
	sanitize_external = TRUE
	sensor_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_SENSOR

/obj/machinery/embedded_controller/radio/airlock_controller/Initialize(mapload)
	. = ..()
	if(!mapload)
		return

	var/datum/computer/file/embedded_program/airlock_controller/new_prog = new

	new_prog.id_tag = id_tag
	new_prog.exterior_door_tag = exterior_door_tag
	new_prog.interior_door_tag = interior_door_tag
	new_prog.airpump_tag = airpump_tag
	new_prog.sensor_tag = sensor_tag
	new_prog.sanitize_external = sanitize_external

	new_prog.master = src
	program = new_prog

/obj/machinery/embedded_controller/radio/airlock_controller/update_icon_state()
	if(on && program)
		icon_state = "[base_icon_state]_[program.memory["processing"] ? "process" : "standby"]"
		return ..()
	icon_state = "[base_icon_state]_off"
	return ..()
