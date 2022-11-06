/client/proc/fax_panel()
	set category = "Admin.Events"
	set name = "Fax Panel"

	admin_fax_panel()

/client/proc/admin_fax_panel()
	if(!check_rights(R_ADMIN))
		return

	var/datum/fax_panel_interface/ui = new(usr)
	ui.ui_interact(usr)

/// Panel
/datum/fax_panel_interface
	/// All faxes in game list
	var/available_faxes = list()
	var/stamp_list = list()
	var/sending_fax_name = "Secret"
	var/obj/item/paper/fax_paper = new /obj/item/paper(null)

/datum/fax_panel_interface/New()
	for(var/obj/machinery/fax/fax in GLOB.machines)
		available_faxes += fax
	for(var/stamp in subtypesof(/obj/item/stamp))
		var/obj/item/stamp/real_stamp = stamp 
		if(length(initial(real_stamp.actions)) == 0)
			stamp_list += list(list(initial(real_stamp.name), initial(real_stamp.icon_state)))
	fax_paper.request_state = TRUE

/datum/fax_panel_interface/proc/get_fax_by_name(name)
	if(!length(available_faxes))
		return

	for(var/obj/machinery/fax/potential_fax in available_faxes)
		if(potential_fax.fax_name == name)
			return potential_fax
	return

/datum/fax_panel_interface/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminFax")
		ui.open()

/datum/fax_panel_interface/ui_state(mob/user)
	return GLOB.admin_state

/datum/fax_panel_interface/ui_static_data(mob/user)
	var/list/data = list()
	data["faxes"] = list()
	data["stamps"] = list()
	for(var/stamp in stamp_list)
		data["stamps"] += list(stamp[1])
	for(var/obj/machinery/fax/another_fax in available_faxes)
		data["faxes"] += list(another_fax.fax_name)
	return data

/datum/fax_panel_interface/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(!check_rights(R_ADMIN))
		return
	var/obj/machinery/fax/action_fax
	if(params["faxName"])
		action_fax = get_fax_by_name(params["faxName"])
	switch(action)
		if("jump")
			var/turf/fax_turf = get_turf(action_fax)
			if(!fax_turf || !usr.client)
				return
			usr.client.jumptoturf(fax_turf)
		if("preview")
			if(!fax_paper)
				return
			fax_paper.ui_interact(usr)
		if("save")
			fax_paper.ui_status(usr, UI_CLOSE)
			fax_paper.clear_paper()
			var/stamp 

			for(var/needed_stamp in stamp_list)
				if(needed_stamp[1] == params["stamp"])
					stamp = needed_stamp[2]
					break
			
			fax_paper.name = "paper — [params["paperName"] ? params["paperName"] : "Classic Report"]"
			fax_paper.add_raw_text(params["rawText"])
			if(stamp)
				fax_paper.add_stamp("paper121x54 [stamp]", params["stampX"], params["stampY"], 0, stamp)
		if("send")
			var/obj/item/paper/our_fax = fax_paper.copy(/obj/item/paper, null, FALSE)
			our_fax.name = fax_paper.name
			action_fax.receive(our_fax, params["fromWho"])
		if("createPaper")
			fax_paper.copy(/obj/item/paper, usr.loc, FALSE)
			
		// signal.send_to_receivers()
		// message_admins("[key_name_admin(usr)] has send custom PDA message to [spam ? "everyone" : params["user"]].")
		// log_admin("[key_name(usr)] has send custom PDA message to [spam ? "everyone" : params["user"]]. Message: [params["message"]].")

