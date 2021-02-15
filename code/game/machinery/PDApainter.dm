/obj/machinery/pdapainter
	name = "\improper PDA & ID Painter"
	desc = "A painting machine that can be used to paint PDAs and trim IDs. To use, simply insert the item and choose the desired preset."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	density = TRUE
	max_integrity = 200
	var/obj/item/card/id/stored_id_card = null
	var/obj/item/pda/stored_pda = null
	var/static/list/pda_type_blacklist = list(
		/obj/item/pda/ai/pai,
		/obj/item/pda/ai,
		/obj/item/pda/heads,
		/obj/item/pda/clear,
		/obj/item/pda/syndicate,
		/obj/item/pda/chameleon,
		/obj/item/pda/chameleon/broken)
	var/list/pda_types = list()
	var/list/card_trims = list()
	var/target_dept

/obj/machinery/pdapainter/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return

	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/pdapainter/update_overlays()
	. = ..()

	if(machine_stat & BROKEN)
		return

	if(stored_pda || stored_id_card)
		. += "[initial(icon_state)]-closed"

/obj/machinery/pdapainter/Initialize()
	. = ..()

	if(!target_dept)
		pda_types = SSid_access.station_pda_templates.Copy()
		card_trims = SSid_access.station_job_templates.Copy()
		return

	// Cache the manager list, then check through each manager.
	// If we get a region match, add their trim templates and PDA paths to our lists.
	var/list/manager_cache = SSid_access.sub_department_managers_tgui
	for(var/access_txt in manager_cache)
		var/list/manager_info = manager_cache[access_txt]
		var/list/manager_regions = manager_info["regions"]
		if(target_dept in manager_regions)
			var/list/pda_list = manager_info["pdas"]
			var/list/trim_list = manager_info["templates"]
			pda_types |= pda_list
			card_trims |= trim_list

/obj/machinery/pdapainter/Destroy()
	QDEL_NULL(stored_pda)
	QDEL_NULL(stored_id_card)
	return ..()

/obj/machinery/pdapainter/on_deconstruction()
	// Don't use ejection procs as we're gonna be destroyed anyway, so no need to update icons or anything.
	if(stored_pda)
		stored_pda.forceMove(loc)
		stored_pda = null
	if(stored_id_card)
		stored_id_card.forceMove(loc)
		stored_id_card = null

/obj/machinery/pdapainter/contents_explosion(severity, target)
	if(stored_pda)
		stored_pda.ex_act(severity, target)
	if(stored_id_card)
		stored_id_card.ex_act(severity, target)

/obj/machinery/pdapainter/handle_atom_del(atom/A)
	if(A == stored_pda)
		stored_pda = null
		update_icon()
	if(A == stored_id_card)
		stored_id_card = null
		update_icon()

/obj/machinery/pdapainter/attackby(obj/item/O, mob/living/user, params)
	if(machine_stat & BROKEN)
		if(O.tool_behaviour == TOOL_WELDER && !user.combat_mode)
			if(!O.tool_start_check(user, amount=0))
				return
			user.visible_message("<span class='notice'>[user] is repairing [src].</span>", \
							"<span class='notice'>You begin repairing [src]...</span>", \
							"<span class='hear'>You hear welding.</span>")
			if(O.use_tool(src, user, 40, volume=50))
				if(!(machine_stat & BROKEN))
					return
				to_chat(user, "<span class='notice'>You repair [src].</span>")
				set_machine_stat(machine_stat & ~BROKEN)
				obj_integrity = max_integrity
				update_icon()
			return
		return ..()

	if(default_unfasten_wrench(user, O))
		power_change()
		return

	if(istype(O, /obj/item/pda))
		insert_pda(O, user)
		return

	if(istype(O, /obj/item/card/id))
		if(stored_id_card)
			to_chat(user, "<span class='warning'>There is already an ID card inside!</span>")
			return

		if(!user.transferItemToLoc(O, src))
			return

		stored_id_card = O
		O.add_fingerprint(user)
		update_icon()
		return

	return ..()

/obj/machinery/pdapainter/deconstruct(disassembled = TRUE)
	obj_break()

/obj/machinery/pdapainter/proc/insert_pda(obj/item/pda/new_pda, mob/living/user)
	if(!istype(new_pda))
		return FALSE

	if(user && !user.transferItemToLoc(new_pda, src))
		return FALSE
	else
		new_pda.forceMove(src)

	if(stored_pda)
		eject_pda(user)

	stored_pda = new_pda
	new_pda.add_fingerprint(user)
	update_icon()
	return TRUE

/obj/machinery/pdapainter/proc/eject_pda(mob/living/user)
	if(stored_pda)
		if(user && !issilicon(user) && in_range(src, user))
			user.put_in_hands(stored_pda)
		else
			stored_pda.forceMove(drop_location())

		stored_pda = null
		update_icon()

/obj/machinery/pdapainter/proc/insert_id_card(obj/item/card/id/new_id_card, mob/living/user)
	if(!istype(new_id_card))
		return FALSE

	if(user && !user.transferItemToLoc(new_id_card, src))
		return FALSE
	else
		new_id_card.forceMove(src)

	if(stored_id_card)
		eject_id_card(user)

	stored_id_card = new_id_card
	new_id_card.add_fingerprint(user)
	update_icon()
	return TRUE

/obj/machinery/pdapainter/proc/eject_id_card(mob/living/user)
	if(stored_id_card)
		if(user && !issilicon(user) && in_range(src, user))
			user.put_in_hands(stored_id_card)
		else
			stored_id_card.forceMove(drop_location())

		stored_id_card = null
		update_icon(user)

/obj/machinery/pdapainter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaintingMachine", name)
		ui.open()

/obj/machinery/pdapainter/ui_data(mob/user)
	var/data = list()

	if(stored_pda)
		data["hasPDA"] = TRUE
		data["pdaName"] = stored_pda.name
	else
		data["hasPDA"] = FALSE
		data["pdaName"] = null

	if(stored_id_card)
		data["hasID"] = TRUE
		data["idName"] = stored_id_card.name
	else
		data["hasID"] = FALSE
		data["idName"] = null

	return data

/obj/machinery/pdapainter/ui_static_data(mob/user)
	var/data = list()

	data["pdaTypes"] = pda_types
	data["cardTrims"] = card_trims

	return data

/obj/machinery/pdapainter/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject_pda")
			if((machine_stat & BROKEN))
				return TRUE

			var/obj/item/held_item = usr.get_active_held_item()
			if(istype(held_item, /obj/item/pda))
				// If we successfully inserted, we've ejected the old item. Return early.
				if(insert_pda(held_item, usr))
					return TRUE
			// If we did not successfully insert, try to eject.
			if(stored_pda)
				eject_pda(usr)
				return TRUE

			return TRUE
		if("eject_card")
			if((machine_stat & BROKEN))
				return TRUE

			var/obj/item/held_item = usr.get_active_held_item()
			if(istype(held_item, /obj/item/card/id))
				// If we successfully inserted, we've ejected the old item. Return early.
				if(insert_id_card(held_item, usr))
					return TRUE
			// If we did not successfully insert, try to eject.
			if(stored_id_card)
				eject_id_card(usr)
				return TRUE

			return TRUE
		if("trim_pda")
			if((machine_stat & BROKEN) || !stored_pda)
				return TRUE

			var/selection = params["selection"]
			for(var/path in pda_types)
				if(!(pda_types[path] == selection))
					continue

				var/obj/item/pda/pda_path = path
				stored_pda.icon_state = initial(pda_path.icon_state)
				stored_pda.desc = initial(pda_path.desc)
			return TRUE
		if("trim_card")
			if((machine_stat & BROKEN) || !stored_id_card)
				return TRUE

			var/selection = params["selection"]
			for(var/path in card_trims)
				if(!(card_trims[path] == selection))
					continue

				if(SSid_access.apply_trim_to_card(stored_id_card, path, copy_access = FALSE))
					return TRUE

				to_chat(usr, "<span class='warning'>The trim you selected could not be added to \the [src]. You will need a rarer ID card to imprint that trim data.</span>")

			return TRUE

/obj/machinery/pdapainter/security
	name = "\improper Security PDA & ID Painter"
	target_dept = REGION_SECURITY

/obj/machinery/pdapainter/medbay
	name = "\improper Medbay PDA & ID Painter"
	target_dept = REGION_MEDBAY

/obj/machinery/pdapainter/research
	name = "\improper Research PDA & ID Painter"
	target_dept = REGION_RESEARCH

/obj/machinery/pdapainter/engineering
	name = "\improper Engineering PDA & ID Painter"
	target_dept = REGION_ENGINEERING
