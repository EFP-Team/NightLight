/obj/item/sparring_contract
	desc = "A contract for setting up sparring matches. Both sparring partners must agree with the terms to begin."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	throw_range = 1
	throw_speed = 1
	w_class = WEIGHT_CLASS_TINY
	///what weapons will be allowed during the sparring match
	var/weapons_condition = MELEE_ONLY
	///what arena the fight will take place in
	var/arena_condition = /area/service/chapel
	///what stakes the fight will have
	var/stakes_condition = STANDARD_STAKES
	///who has signed this contract
	var/list/signed_by = list(null, null)

/obj/item/sparring_contract/Initialize()
	. = ..()
	name = "[GLOB.deity]'s sparring contract"

/obj/item/sparring_contract/Destroy()
	QDEL_NULL(signed_by)
	. = ..()

/obj/item/sparring_contract/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SparringContract", name)
		ui.open()

/obj/item/sparring_contract/ui_static_data(mob/user)
	var/list/data = list()
	var/area/arena = GLOB.areas_by_type[arena_condition]
	data["set_weapon"] = weapons_condition
	data["set_area"] = arena?.name
	data["set_stakes"] = stakes_condition
	data["possible_areas"] = get_possible_areas()

	return data

/obj/item/sparring_contract/ui_data(mob/user)
	var/list/data = list()
	var/area/arena = GLOB.areas_by_type[arena_condition]
	var/mob/living/carbon/human/left_partner = signed_by[1]
	var/mob/living/carbon/human/right_partner = signed_by[2]
	data["in_area"] = ((left_partner && right_partner && arena) && (left_partner in arena.contents) && (right_partner in arena.contents))
	data["left_sign"] = left_partner ? left_partner.real_name : "none"
	data["right_sign"] = right_partner ? right_partner.real_name : "none"
	return data

/obj/item/sparring_contract/proc/get_possible_areas()
	var/list/area_names = list()
	var/datum/religion_sect/spar/sect = GLOB.religious_sect
	for(var/key in sect.arenas)
		area_names += key
	return area_names

/obj/item/sparring_contract/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/mob/user = usr

	if(!ishuman(user))
		to_chat(user, span_warning("This contract refuses to be signed by a lesser creature such as yourself."))
		return

	var/datum/religion_sect/spar/sect = GLOB.religious_sect

	if(user in sect.past_opponents && params["stakes"] == STANDARD_STAKES)
		to_chat(user, span_warning("This contract refuses to be signed up for a holy match by a previous holy match loser. Pick a different stake!"))

	//any updating of the terms should update the UI to display new terms
	. = TRUE

	switch(action)
		if("fight")
			var/mob/living/carbon/human/left_partner = signed_by[1]
			var/mob/living/carbon/human/right_partner = signed_by[2]
			if(!left_partner || !right_partner || !left_partner.mind || !right_partner.mind)
				return
			var/chaplain = left_partner.mind.holy_role ? left_partner : right_partner
			var/opponent = left_partner.mind.holy_role ? right_partner : left_partner
			new /datum/sparring_match(weapons_condition, arena_condition, stakes_condition, chaplain, opponent)
			qdel(src)
		if("sign")
			if(user in signed_by)
				to_chat(user, span_warning("You've already signed one side of the contract."))
				return
			var/area/arena_condition_name = GLOB.areas_by_type[arena_condition]
			arena_condition_name = format_text(arena_condition_name.name)
			//setting/checking for terms changed
			var/terms_changed = FALSE
			if(params["weapon"] != weapons_condition)
				if(!params["weapon"])
					return //they hit f5 to clear data then submitted
				terms_changed = TRUE
				weapons_condition = params["weapon"]
			if(params["area"] != arena_condition_name)
				if(!params["area"])
					return //they hit f5 to clear data then submitted
				terms_changed = TRUE
				var/new_area_condition = sect.arenas[params["area"]]
				arena_condition = new_area_condition
			if(params["stakes"] != stakes_condition)
				if(!params["stakes"])
					return //they hit f5 to clear data then submitted
				terms_changed = TRUE
				stakes_condition = params["stakes"]
			//if you change the terms you have to get the other person to sign again.
			if(terms_changed && (signed_by[1] || signed_by[2]))
				signed_by = list(null, null)
				to_chat(user, span_warning("You will need to get your sparring partner to sign again under these new terms you've set."))
			//fluff and signing
			if(params["sign_position"] == LEFT_FIELD)
				signed_by[1] = user
			else
				signed_by[2] = user
