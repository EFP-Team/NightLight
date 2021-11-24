/mob/living/silicon/pai/var/list/available_software = list(
															//Nightvision
															//T-Ray
															//radiation eyes
															//chem goggs
															//mesons
															"crew manifest" = 5,
															"digital messenger" = 5,
															"atmosphere sensor" = 5,
															"photography module" = 5,
															"camera zoom" = 10,
															"printer module" = 10,
															"remote signaler" = 10,
															"medical records" = 10,
															"security records" = 10,
															"host scan" = 10,
															"medical HUD" = 20,
															"security HUD" = 20,
															"loudness booster" = 20,
															"newscaster" = 20,
															"door jack" = 25,
															"encryption keys" = 25,
															"internal gps" = 35,
															"universal translator" = 35
															)

// Opens TGUI interface
/mob/living/silicon/pai/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiInterface", name)
		ui.open()

// Static UI data
/mob/living/silicon/pai/ui_static_data(mob/user)
	var/list/data = list()
	var/mob/living/silicon/pai/pai = user
	data["records"] = list()
	data["software"] = list()
	if("medical records" in pai.software)
		data["records"]["medical"] = GLOB.data_core.get_general_records()
	if("security records" in pai.software)
		data["records"]["security"] = GLOB.data_core.get_security_records()
	if(software)
		data["software"]["available"] = available_software
		data["software"]["installed"] = software
	return data

// Variables sent to TGUI
/mob/living/silicon/pai/ui_data(mob/user)
	var/list/data = list()
	data["directives"] = laws.supplied
	data["door_jack"] = hacking_cable || null
	data["emagged"] = emagged
	data["image"] = card.emotion_icon
	data["languages"] = languages_granted
	data["master"] = list()
	data["pda"] = list()
	data["ram"] = ram
	if(aiPDA)
		data["pda"]["power"] = !aiPDA.toff
		data["pda"]["silent"] = aiPDA.silent
	if(master)
		data["master"]["name"] = master
		data["master"]["dna"] = master_dna
	return data

// Actions received from TGUI
/mob/living/silicon/pai/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("buy")
			if(available_software.Find(params["selection"]) && !software.Find(params["selection"]))
				var/cost = available_software[params["selection"]]
				if(ram >= cost)
					software.Add(params["selection"])
					ram -= cost
					var/datum/hud/pai/pAIhud = hud_used
					pAIhud?.update_software_buttons()
				else
					to_chat(usr, span_notice("Insufficient RAM available."))
			else
				to_chat(usr, span_notice("Software not found."))
		if("atmosphere_sensor")
			if(!holoform)
				to_chat(usr, span_notice("You must be mobile to do this!"))
				return FALSE
			if(!atmos_analyzer)
				atmos_analyzer = new(src)
			atmos_analyzer.attack_self(src)
		if("camera_zoom")
			aicamera.adjust_zoom(usr)
		if("change_image")
			var/newImage = tgui_input_list(usr, "Select your new display image.", "Display Image", sort_list(list("Happy", "Cat", "Extremely Happy", "Face", "Laugh", "Off", "Sad", "Angry", "What", "Sunglasses")))
			switch(newImage)
				if(null)
					card.emotion_icon = "null"
				if("Extremely Happy")
					card.emotion_icon = "extremely-happy"
				else
					card.emotion_icon = "[lowertext(newImage)]"
			card.update_appearance()
		if("check_dna")
			if(!master_dna)
				to_chat(src, span_warning("You do not have a master DNA to compare to!"))
				return FALSE
			if(iscarbon(card.loc))
				CheckDNA(card.loc, src) //you should only be able to check when directly in hand, muh immersions?
			else
				to_chat(src, span_warning("You are not being carried by anyone!"))
				return FALSE // FALSE ? If you return here you won't call paiinterface() below
		if("crew_manifest")
			ai_roster()
		if("door_jack")
			if(params["jack"] == "jack")
				if(hacking_cable?.machine)
					hackdoor = hacking_cable.machine
					hackloop()
			if(params["jack"]  == "cancel")
				hackdoor = null
				QDEL_NULL(hacking_cable)
			if(params["jack"]  == "cable")
				extendcable()
		if("encryption_keys")
			encryptmod = !encryptmod
			radio.subspace_transmission = !radio.subspace_transmission
		if("host_scan")
			if(!hostscan)
				hostscan = new(src)
			if(params["scan"] == "scan")
				hostscan()
			if(params["scan"] == "wounds")
				hostscan.attack_self(usr)
			if(params["scan"] == "limbs")
				hostscan.toggle_mode()
		if("internal_gps")
			if(!internal_gps)
				internal_gps = new(src)
			internal_gps.attack_self(src)
		if("loudness_booster")
			if(!internal_instrument)
				internal_instrument = new(src)
			internal_instrument.interact(src) // Open Instrument
		if("medical_hud")
			medHUD = !medHUD
			if(medHUD)
				var/datum/atom_hud/med = GLOB.huds[med_hud]
				med.add_hud_to(src)
			else
				var/datum/atom_hud/med = GLOB.huds[med_hud]
				med.remove_hud_from(src)
		if("newscaster")
			newscaster.ui_interact(src)
		if("pda")
			if(isnull(aiPDA))
				return FALSE
			if(params["pda"] == "power")
				aiPDA.toff = !aiPDA.toff
			if(params["pda"] == "silent")
				aiPDA.silent = !aiPDA.silent
			if(params["pda"] == "message")
				cmd_send_pdamesg(usr)
		if("photography_module")
			aicamera.toggle_camera_mode(usr)
		if("printer_module")
			aicamera.paiprint(usr)
		if("radio")
			radio.attack_self(src)
		if("remote_signaler")
			signaler.ui_interact(src)
		if("security_hud")
			secHUD = !secHUD
			if(secHUD)
				var/datum/atom_hud/sec = GLOB.huds[sec_hud]
				sec.add_hud_to(src)
			else
				var/datum/atom_hud/sec = GLOB.huds[sec_hud]
				sec.remove_hud_from(src)
		if("universal_translator")
			if(!languages_granted)
				grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_SOFTWARE)
				languages_granted = TRUE
	return

/mob/living/silicon/pai/proc/CheckDNA(mob/living/carbon/M, mob/living/silicon/pai/P)
	if(!istype(M))
		return
	to_chat(P, span_notice("Requesting a DNA sample."))
	var/answer = input(M, "[P] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "[P] Check DNA", "No") in list("Yes", "No")
	if(answer == "Yes")
		M.visible_message(span_notice("[M] presses [M.p_their()] thumb against [P]."),\
						span_notice("You press your thumb against [P]."),\
						span_notice("[P] makes a sharp clicking sound as it extracts DNA material from [M]."))
		if(!M.has_dna())
			to_chat(P, "<b>No DNA detected.</b>")
			return
		to_chat(P, "<font color = red><h3>[M]'s UE string : [M.dna.unique_enzymes]</h3></font>")
		if(M.dna.unique_enzymes == P.master_dna)
			to_chat(P, "<b>DNA is a match to stored Master DNA.</b>")
		else
			to_chat(P, "<b>DNA does not match stored Master DNA.</b>")
	else
		to_chat(P, span_warning("[M] does not seem like [M.p_theyre()] going to provide a DNA sample willingly."))

// Host Scan supporting proc
/mob/living/silicon/pai/proc/hostscan()
	var/mob/living/silicon/pai/pAI = usr
	var/mob/living/carbon/holder = get(pAI.card.loc, /mob/living/carbon)
	if(holder)
		pAI.hostscan.attack(holder, pAI)
	else
		to_chat(usr, span_warning("You are not being carried by anyone!"))
		return FALSE

// Extend cable supporting proc
/mob/living/silicon/pai/proc/extendcable()
	QDEL_NULL(hacking_cable) //clear any old cables
	hacking_cable = new
	var/transfered_to_mob
	if(isliving(card.loc))
		var/mob/living/L = card.loc
		if(L.put_in_hands(hacking_cable))
			transfered_to_mob = TRUE
			L.visible_message(span_warning("A port on [src] opens to reveal \a [hacking_cable], which you quickly grab hold of."), span_hear("You hear the soft click of something light and manage to catch hold of [hacking_cable]."))
		if(!transfered_to_mob)
			hacking_cable.forceMove(drop_location())
			hacking_cable.visible_message(span_warning("A port on [src] opens to reveal \a [hacking_cable], which promptly falls to the floor."), span_hear("You hear the soft click of something light and hard falling to the ground."))

// Door Jack - supporting proc
/mob/living/silicon/pai/proc/hackloop()
	var/mob/living/silicon/pai/pai = usr
	var/turf/T = get_turf(src)
	playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50, TRUE)
	to_chat(pai, "You begin overriding the airlock security protocols.")
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		if(T.loc)
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force security override in progress in [T.loc].</b></font>")
		else
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force security override in progress. Unable to pinpoint location.</b></font>")
	hacking = TRUE
