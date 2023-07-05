/datum/emote/living/carbon
	mob_type_allowed_typecache = list(/mob/living/carbon)

/datum/emote/living/carbon/airguitar
	key = "airguitar"
	message = "is strumming the air and headbanging like a safari chimp."
	hands_use_check = TRUE

/datum/emote/living/carbon/blink
	key = "blink"
	key_third_person = "blinks"
	message = "blinks."

/datum/emote/living/carbon/blink_r
	key = "blink_r"
	message = "blinks rapidly."

/datum/emote/living/carbon/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps."
	muzzle_ignore = TRUE
	hands_use_check = TRUE
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 5 SECONDS
	vary = TRUE

/datum/emote/living/carbon/clap/get_sound(mob/living/user)
	if(ishuman(user))
		if(!user.get_bodypart(BODY_ZONE_L_ARM) || !user.get_bodypart(BODY_ZONE_R_ARM))
			return
		else
			return pick('sound/misc/clap1.ogg',
							'sound/misc/clap2.ogg',
							'sound/misc/clap3.ogg',
							'sound/misc/clap4.ogg')

/datum/emote/living/carbon/crack
	key = "crack"
	key_third_person = "cracks"
	message = "cracks their knuckles."
	sound = 'sound/misc/knuckles.ogg'
	cooldown = 6 SECONDS

/datum/emote/living/carbon/crack/can_run_emote(mob/living/carbon/user, status_check = TRUE , intentional)
	if(!iscarbon(user) || user.usable_hands < 2)
		return FALSE
	return ..()

/datum/emote/living/carbon/circle
	key = "circle"
	key_third_person = "circles"
	hands_use_check = TRUE

/datum/emote/living/carbon/circle/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!length(user.get_empty_held_indexes()))
		to_chat(user, span_warning("You don't have any free hands to make a circle with."))
		return
	var/obj/item/hand_item/circlegame/N = new(user)
	if(user.put_in_hands(N))
		to_chat(user, span_notice("You make a circle with your hand."))

/datum/emote/living/carbon/moan
	key = "moan"
	key_third_person = "moans"
	message = "moans!"
	message_mime = "appears to moan!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/moan/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	if(!.)
		return FALSE

	if(!(intentional & EMOTE_EXECUTION_USER_KEYBINDING) || !iscarbon(user) || isnull(user.client) || isnull(user.client.prefs))
		return TRUE

	var/datum/preferences/cached_prefs = user.client.prefs
	var/list/moan_keys = cached_prefs.key_bindings[key]
	if(!length(moan_keys))
		return TRUE

	var/list/resist_hotkeys = cached_prefs.key_bindings["resist"]
	if(!length(resist_hotkeys))
		return TRUE

	var/hotkey_matched = FALSE
	for(var/moan_hotkey in moan_keys)
		if(moan_hotkey in resist_hotkeys)
			hotkey_matched = TRUE
			break

	if(!hotkey_matched)
		return TRUE

	var/mob/living/carbon/carbon_user = user
	to_chat(user, span_suicide("As you try to let out a moan while you resist, all that comes out of your mouth is blood! You feel extremely woozy, and then comes a rushing sensation of air..."))
	carbon_user.gib(safe_gib = TRUE)
	return FALSE

/datum/emote/living/carbon/noogie
	key = "noogie"
	key_third_person = "noogies"
	hands_use_check = TRUE

/datum/emote/living/carbon/noogie/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	var/obj/item/hand_item/noogie/noogie = new(user)
	if(user.put_in_hands(noogie))
		to_chat(user, span_notice("You ready your noogie'ing hand."))
	else
		qdel(noogie)
		to_chat(user, span_warning("You're incapable of noogie'ing in your current state."))

/datum/emote/living/carbon/roll
	key = "roll"
	key_third_person = "rolls"
	message = "rolls."
	mob_type_allowed_typecache = list(/mob/living/carbon/alien)
	hands_use_check = TRUE

/datum/emote/living/carbon/scratch
	key = "scratch"
	key_third_person = "scratches"
	message = "scratches."
	mob_type_allowed_typecache = list(/mob/living/carbon/alien)
	hands_use_check = TRUE

/datum/emote/living/carbon/sign
	key = "sign"
	key_third_person = "signs"
	message_param = "signs the number %t."
	mob_type_allowed_typecache = list(/mob/living/carbon/alien)
	hands_use_check = TRUE

/datum/emote/living/carbon/sign/select_param(mob/user, params)
	. = ..()
	if(!isnum(text2num(params)))
		return message

/datum/emote/living/carbon/sign/signal
	key = "signal"
	key_third_person = "signals"
	message_param = "raises %t fingers."
	mob_type_allowed_typecache = list(/mob/living/carbon/human)
	hands_use_check = TRUE

/datum/emote/living/carbon/slap
	key = "slap"
	key_third_person = "slaps"
	hands_use_check = TRUE
	cooldown = 3 SECONDS // to prevent endless table slamming

/datum/emote/living/carbon/slap/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	var/obj/item/hand_item/slapper/N = new(user)
	if(user.put_in_hands(N))
		to_chat(user, span_notice("You ready your slapping hand."))
	else
		qdel(N)
		to_chat(user, span_warning("You're incapable of slapping in your current state."))


/datum/emote/living/carbon/hand
	key = "hand"
	key_third_person = "hands"
	hands_use_check = TRUE


/datum/emote/living/carbon/hand/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return

	var/obj/item/hand_item/hand/hand = new(user)
	if(user.put_in_hands(hand))
		to_chat(user, span_notice("You ready your hand."))
	else
		qdel(hand)
		to_chat(user, span_warning("You're incapable of using your hand in your current state."))


/datum/emote/living/carbon/snap
	key = "snap"
	key_third_person = "snaps"
	message = "snaps their fingers."
	message_param = "snaps their fingers at %t."
	emote_type = EMOTE_AUDIBLE
	hands_use_check = TRUE
	muzzle_ignore = TRUE

/datum/emote/living/carbon/snap/get_sound(mob/living/user)
	if(ishuman(user))
		return pick('sound/misc/fingersnap1.ogg', 'sound/misc/fingersnap2.ogg')
	return null

/datum/emote/living/carbon/shoesteal
	key = "shoesteal"
	key_third_person = "shoesteals"
	hands_use_check = TRUE
	cooldown = 3 SECONDS

/datum/emote/living/carbon/shoesteal/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if (!.)
		return
	var/obj/item/hand_item/stealer/stealing_hand = new(user)
	if (user.put_in_hands(stealing_hand))
		user.balloon_alert(user, "preparing to steal shoes...")
	else
		qdel(stealing_hand)
		user.balloon_alert(user, "you can't steal shoes!")

/datum/emote/living/carbon/tail
	key = "tail"
	message = "waves their tail."
	mob_type_allowed_typecache = list(/mob/living/carbon/alien)

/datum/emote/living/carbon/wink
	key = "wink"
	key_third_person = "winks"
	message = "winks."
