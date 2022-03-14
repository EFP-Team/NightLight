/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall
	name = "Invisible Wall"
	desc = "The mime's performance transmutates a wall into physical reality."
	school = SCHOOL_MIME
	panel = "Mime"
	summon_type = list(/obj/effect/forcefield/mime)
	invocation_type = INVOCATION_EMOTE
	invocation_self_message = "<span class='notice'>You form a wall in front of yourself.</span>"
	summon_lifespan = 300
	charge_max = 300
	requires_wizard_garb = FALSE
	antimagic_allowed = TRUE
	range = 0
	cast_sound = null
	requires_human = TRUE

	action_icon = 'icons/mob/actions/actions_mime.dmi'
	action_icon_state = "invisible_wall"
	action_background_icon_state = "bg_mime"

/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall/Click()
	if(usr?.mind)
		if(!usr.mind.miming)
			to_chat(usr, span_warning("You must dedicate yourself to silence first!"))
			return
		invocation = "<B>[usr.real_name]</B> looks as if a wall is in front of [usr.p_them()]."
	else
		invocation_type ="none"
	..()

/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_chair
	name = "Invisible Chair"
	desc = "The mime's performance transmutates a chair into physical reality."
	school = SCHOOL_MIME
	panel = "Mime"
	summon_type = list(/obj/structure/chair/mime)
	invocation_type = INVOCATION_EMOTE
	invocation_self_message = "<span class='notice'>You conjure an invisible chair and sit down.</span>"
	summon_lifespan = 250
	charge_max = 300
	requires_wizard_garb = FALSE
	antimagic_allowed = TRUE
	range = 0
	cast_sound = null
	requires_human = TRUE

	action_icon = 'icons/mob/actions/actions_mime.dmi'
	action_icon_state = "invisible_chair"
	action_background_icon_state = "bg_mime"

/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_chair/Click()
	if(usr?.mind)
		if(!usr.mind.miming)
			to_chat(usr, span_warning("You must dedicate yourself to silence first!"))
			return
		invocation = "<B>[usr.real_name]</B> pulls out an invisible chair and sits down."
	else
		invocation_type ="none"
	..()

/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_chair/cast(list/targets,mob/user = usr)
	..()
	var/turf/T = user.loc
	for (var/obj/structure/chair/A in T)
		if (is_type_in_list(A, summon_type))
			A.setDir(user.dir)
			A.buckle_mob(user)

/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_box
	name = "Invisible Box"
	desc = "The mime's performance transmutates a box into physical reality."
	school = SCHOOL_MIME
	panel = "Mime"
	summon_type = list(/obj/item/storage/box/mime)
	invocation_type = INVOCATION_EMOTE
	invocation_self_message = "<span class='notice'>You conjure up an invisible box, large enough to store a few things.</span>"
	summon_lifespan = 500
	charge_max = 300
	requires_wizard_garb = FALSE
	antimagic_allowed = TRUE
	range = 0
	cast_sound = null
	requires_human = TRUE

	action_icon = 'icons/mob/actions/actions_mime.dmi'
	action_icon_state = "invisible_box"
	action_background_icon_state = "bg_mime"

/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_box/cast(list/targets,mob/user = usr)
	..()
	var/turf/T = user.loc
	for (var/obj/item/storage/box/mime/B in T)
		user.put_in_hands(B)
		B.alpha = 255
		addtimer(CALLBACK(B, /obj/item/storage/box/mime/.proc/emptyStorage, FALSE), (summon_lifespan - 1))

/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_box/Click()
	if(usr?.mind)
		if(!usr.mind.miming)
			to_chat(usr, span_warning("You must dedicate yourself to silence first!"))
			return
		invocation = "<B>[usr.real_name]</B> moves [usr.p_their()] hands in the shape of a cube, pressing a box out of the air."
	else
		invocation_type ="none"
	..()


/obj/effect/proc_holder/spell/targeted/mime/speak
	name = "Speech"
	desc = "Make or break a vow of silence."
	school = SCHOOL_MIME
	panel = "Mime"
	requires_wizard_garb = FALSE
	requires_human = TRUE
	antimagic_allowed = TRUE
	charge_max = 3000
	range = -1
	include_user = TRUE

	action_icon = 'icons/mob/actions/actions_mime.dmi'
	action_icon_state = "mime_speech"
	action_background_icon_state = "bg_mime"

/obj/effect/proc_holder/spell/targeted/mime/speak/Click()
	if(!usr)
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(H.mind.miming)
		still_recharging_msg = span_warning("You can't break your vow of silence that fast!")
	else
		still_recharging_msg = span_warning("You'll have to wait before you can give your vow of silence again!")
	..()

/obj/effect/proc_holder/spell/targeted/mime/speak/cast(list/targets,mob/user = usr)
	for(var/mob/living/carbon/human/H in targets)
		H.mind.miming=!H.mind.miming
		if(H.mind.miming)
			to_chat(H, span_notice("You make a vow of silence."))
			SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "vow")
		else
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "vow", /datum/mood_event/broken_vow)
			to_chat(H, span_notice("You break your vow of silence."))

// These spells can only be gotten from the "Guide for Advanced Mimery series" for Mime Traitors.

/obj/effect/proc_holder/spell/targeted/forcewall/mime
	name = "Invisible Blockade"
	desc = "Form an invisible three tile wide blockade."
	school = SCHOOL_MIME
	panel = "Mime"
	wall_type = /obj/effect/forcefield/mime/advanced
	invocation_type = INVOCATION_EMOTE
	invocation_self_message = "<span class='notice'>You form a blockade in front of yourself.</span>"
	charge_max = 600
	sound = null
	requires_wizard_garb = FALSE
	antimagic_allowed = TRUE
	range = -1
	include_user = TRUE

	action_icon = 'icons/mob/actions/actions_mime.dmi'
	action_icon_state = "invisible_blockade"
	action_background_icon_state = "bg_mime"

/obj/effect/proc_holder/spell/targeted/forcewall/mime/Click()
	if(usr?.mind)
		if(!usr.mind.miming)
			to_chat(usr, span_warning("You must dedicate yourself to silence first!"))
			return
		invocation = "<B>[usr.real_name]</B> looks as if a blockade is in front of [usr.p_them()]."
	else
		invocation_type ="none"
	..()

/obj/effect/proc_holder/spell/aimed/finger_guns
	name = "Finger Guns"
	desc = "Shoot up to three mimed bullets from your fingers that damage and mute their targets. Can't be used if you have something in your hands."
	school = SCHOOL_MIME
	panel = "Mime"
	charge_max = 300
	requires_wizard_garb = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_EMOTE
	invocation_self_message = span_danger("You fire your finger gun!")
	range = 20
	projectile_type = /obj/projectile/bullet/mime
	projectile_amount = 3
	sound = null
	active_msg = "You draw your fingers!"
	deactive_msg = "You put your fingers at ease. Another time."
	active = FALSE

	action_icon = 'icons/mob/actions/actions_mime.dmi'
	action_icon_state = "finger_guns0"
	action_background_icon_state = "bg_mime"
	base_icon_state = "finger_guns"


/obj/effect/proc_holder/spell/aimed/finger_guns/Click()
	var/mob/living/carbon/human/owner = usr
	if(owner.incapacitated())
		to_chat(owner, span_warning("You can't properly point your fingers while incapacitated."))
		return
	if(owner.get_active_held_item())
		to_chat(owner, span_warning("You can't properly fire your finger guns with something in your hand."))
		return
	if(usr?.mind)
		if(!usr.mind.miming)
			to_chat(usr, span_warning("You must dedicate yourself to silence first!"))
			return
		invocation = "<B>[usr.real_name]</B> fires [usr.p_their()] finger gun!"
	else
		invocation_type ="none"
	..()

/obj/effect/proc_holder/spell/aimed/finger_guns/InterceptClickOn(mob/living/caller, params, atom/target)
	if(caller.get_active_held_item())
		to_chat(caller, span_warning("You can't properly fire your finger guns with something in your hand."))
		return
	if(caller.incapacitated())
		to_chat(caller, span_warning("You can't properly point your fingers while incapacitated."))
		if(charge_type == "recharge")
			var/refund_percent = current_amount/projectile_amount
			charge_counter = charge_max * refund_percent
			start_recharge()
		remove_ranged_ability()
		on_deactivation(caller)
	..()

/obj/item/book/granter/spell/mimery_blockade
	spell = /obj/effect/proc_holder/spell/targeted/forcewall/mime
	spellname = "Invisible Blockade"
	name = "Guide to Advanced Mimery Vol 1"
	desc = "The pages don't make any sound when turned."
	icon_state ="bookmime"
	remarks = list("...")

/obj/item/book/granter/spell/mimery_blockade/attack_self(mob/user)
	. = ..()
	if(!.)
		return
	if(!locate(/obj/effect/proc_holder/spell/targeted/mime/speak) in user.mind.spell_list)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak)

/obj/item/book/granter/spell/mimery_guns
	spell = /obj/effect/proc_holder/spell/aimed/finger_guns
	spellname = "Finger Guns"
	name = "Guide to Advanced Mimery Vol 2"
	desc = "There aren't any words written..."
	icon_state ="bookmime"
	remarks = list("...")

/obj/item/book/granter/spell/mimery_guns/attack_self(mob/user)
	. = ..()
	if(!.)
		return
	if(!locate(/obj/effect/proc_holder/spell/targeted/mime/speak) in user.mind.spell_list)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak)
