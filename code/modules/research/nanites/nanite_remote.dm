#define REMOTE_MODE_OFF "Off"
#define REMOTE_MODE_SELF "Local"
#define REMOTE_MODE_TARGET "Targeted"
#define REMOTE_MODE_AOE "Area"
#define REMOTE_MODE_RELAY "Relay"

/obj/item/nanite_remote
	name = "nanite remote control"
	desc = "A device that can remotely control active nanites through wireless signals."
	w_class = WEIGHT_CLASS_SMALL
	req_access = list(ACCESS_ROBOTICS)
	icon = 'icons/obj/device.dmi'
	icon_state = "nanite_remote"
	var/locked = FALSE //Can be locked, so it can be given to users with a set code and mode
	var/mode = REMOTE_MODE_OFF
	var/list/saved_codes = list()
	var/code = 0
	var/relay_code = 0

/obj/item/nanite_remote/examine(mob/user)
	..()
	if(locked)
		to_chat(user, "<span class='notice'>Alt-click to unlock.</span>")

/obj/item/nanite_remote/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(locked)
		if(allowed(user))
			to_chat(user, "<span class='notice'>You unlock [src].</span>")
			locked = FALSE
			update_icon()
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/item/nanite_remote/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class='warning'>You override [src]'s ID lock.</span>")
	obj_flags |= EMAGGED
	if(locked)
		locked = FALSE
		update_icon()

/obj/item/nanite_remote/update_icon()
	..()
	cut_overlays()
	if(locked)
		add_overlay("nanite_remote_locked")

/obj/item/nanite_remote/afterattack(atom/target, mob/user, etc)
	switch(mode)
		if(REMOTE_MODE_OFF)
			return
		if(REMOTE_MODE_SELF)
			to_chat(user, "<span class='notice'>You activate [src], signaling the nanites in your bloodstream.<span>")
			signal_mob(user, code)
		if(REMOTE_MODE_TARGET)
			if(isliving(target) && (get_dist(target, get_turf(src)) <= 7))
				to_chat(user, "<span class='notice'>You activate [src], signaling the nanites inside [target].<span>")
				signal_mob(target, code)
		if(REMOTE_MODE_AOE)
			to_chat(user, "<span class='notice'>You activate [src], signaling the nanites inside every host around you.<span>")
			for(var/mob/living/L in view(user, 7))
				signal_mob(L, code)
		if(REMOTE_MODE_RELAY)
			to_chat(user, "<span class='notice'>You activate [src], signaling all connected relay nanites.<span>")
			for(var/M in GLOB.nanite_signal_mobs)
				signal_relay(M, code, relay_code)

/obj/item/nanite_remote/proc/signal_mob(mob/living/M, code)
	for(var/datum/reagent/nanites/programmed/N in M.reagents.reagent_list)
		N.receive_signal(code)

/obj/item/nanite_remote/proc/signal_relay(mob/living/M, code, relay_code)
	for(var/datum/reagent/nanites/programmed/relay/N in M.reagents.reagent_list)
		N.relay_signal(code, relay_code)

/obj/item/nanite_remote/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.hands_state)
	SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "nanite_remote", name, 420, 800, master_ui, state)
		ui.open()

/obj/item/nanite_remote/ui_data()
	var/list/data = list()
	data["code"] = code
	data["relay_code"] = relay_code
	data["saved_codes"] = saved_codes
	data["mode"] = mode
	data["locked"] = locked
	return data

/obj/item/nanite_remote/ui_act(action, params)
	if(..())
		return
	if(locked)
		return
	switch(action)
		if("set_code")
			var/new_code = input("Set code (0000-9999):", name, code) as null|num
			if(!isnull(new_code))
				new_code = CLAMP(round(new_code, 1),0,9999)
				code = new_code
			. = TRUE
		if("set_relay_code")
			var/new_code = input("Set relay code (0000-9999):", name, code) as null|num
			if(!isnull(new_code))
				new_code = CLAMP(round(new_code, 1),0,9999)
				relay_code = new_code
			. = TRUE
		if("save_code")
			var/code_name = stripped_input(/*TODO INPUT_STUFF*/)
			if(!code_name)
				return

			saved_codes[code_name] = code
			. = TRUE
		if("remove_code")
			var/code_name = params["code_name"]
			saved_codes[code_name] = null
			. = TRUE
		if("select_mode")
			mode = params["mode"]
			. = TRUE
		if("lock")
			if(!(obj_flags & EMAGGED))
				locked = TRUE
				update_icon()
			. = TRUE


#undef REMOTE_MODE_OFF
#undef REMOTE_MODE_SELF
#undef REMOTE_MODE_TARGET
#undef REMOTE_MODE_AOE
#undef REMOTE_MODE_RELAY