/datum/computer_file/program/supermatter_monitor
	filename = "smmonitor"
	filedesc = "Supermatter Monitoring"
	ui_header = "smmon_0.gif"
	program_icon_state = "smmon_0"
	extended_desc = "This program connects to specially calibrated supermatter sensors to provide information on the status of supermatter-based engines."
	requires_ntnet = 1
	transfer_access = GLOB.access_engine
	network_destination = "supermatter monitoring system"
	size = 5
	tgui_id = "ntos_supermatter_monitor"
	ui_x = 600
	ui_y = 400
	var/last_status = 0
	var/list/supermatters
	var/obj/machinery/power/supermatter_shard/active = null		// Currently selected supermatter crystal.





/datum/computer_file/program/supermatter_monitor/process_tick()
	..()
	var/new_status = get_status()
	if(last_status != new_status)
		last_status = new_status
		ui_header = "smmon_[last_status].gif"
		program_icon_state = "smmon_[last_status]"
		if(istype(computer))
			computer.update_icon()


/datum/computer_file/program/supermatter_monitor/run_program(mob/living/user)
 . = ..(user)
 refresh()


/datum/computer_file/program/supermatter_monitor/kill_program(forced = FALSE)
	active = null
	supermatters = null
	..()



// Refreshes list of active supermatter crystals
/datum/computer_file/program/supermatter_monitor/proc/refresh()
	supermatters = list()
	var/turf/T = get_turf(ui_host())
	if(!T)
		return
	//var/valid_z_levels = (GetConnectedZlevels(T.z) & using_map.station_levels)
	for(var/obj/machinery/power/supermatter_shard/S in GLOB.machines)
		// Delaminating, not within coverage, not on a tile.
		if(!(S.z == ZLEVEL_STATION || S.z == ZLEVEL_MINING || S.z == T.z) || !istype(S.loc, /turf/))
			continue
		supermatters.Add(S)

	if(!(active in supermatters))
		active = null

/datum/computer_file/program/supermatter_monitor/proc/get_status()
	. = SUPERMATTER_INACTIVE
	for(var/obj/machinery/power/supermatter_shard/S in supermatters)
		. = max(., S.get_status())

/datum/computer_file/program/supermatter_monitor/ui_data()
	var/list/data = get_header_data()

	if(istype(active))
		var/turf/T = get_turf(active)
		if(!T)
			active = null
			return
		var/datum/gas_mixture/air = T.return_air()
		if(!istype(air))
			active = null
			return

		data["active"] = 1
		data["SM_integrity"] = active.get_integrity()
		data["SM_power"] = active.power
		data["SM_ambienttemp"] = air.temperature
		data["SM_ambientpressure"] = air.return_pressure()
		//data["SM_EPR"] = round((air.total_moles / air.group_multiplier) / 23.1, 0.01)
		var/list/gasdata = list()
		var/list/relevantgas = list("o2","co2","n2","plasma","n2o")


		if(air.total_moles())
			for(var/gasid in air.gases)
				if(!gasid in relevantgas)
					continue
				gasdata.Add(list(list(
				"name"= air.gases[gas_id][GAS_META][META_GAS_NAME],
				"amount" = round(100*air.gases[gasid][MOLES]/air.total_moles(),0.01))))

		else
			for(var/gasid in gaseslist)
				gasdata.Add(list(list(
					"name"= gasid,
					"amount" = 0)))

		data["gases"] = gasdata
	else
		var/list/SMS = list()
		for(var/obj/machinery/power/supermatter_shard/S in supermatters)
			var/area/A = get_area(S)
			SMS.Add(list(list(
			"area_name" = A.name,
			"integrity" = S.get_integrity(),
			"uid" = S.uid
			)))

		data["active"] = 0
		data["supermatters"] = SMS

	return data

/datum/computer_file/program/supermatter_monitor/ui_act(action, params)
	if(..())
		return 1

	switch(action)
		if("PRG_clear")
			active = null
			return 1
		if("PRG_refresh")
			refresh()
			return 1
		if("PRG_set")
			var/newuid = text2num(params["set"])
			for(var/obj/machinery/power/supermatter_shard/S in supermatters)
				if(S.uid == newuid)
					active = S
			return 1