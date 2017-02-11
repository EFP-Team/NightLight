/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall
	name = "Invisible Wall"
	desc = "The mime's performance transmutates into physical reality."
	school = "mime"
	panel = "Mime"
	summon_type = list(/obj/effect/forcefield/mime)
	invocation_type = "emote"
	invocation_emote_self = "<span class='notice'>You form a wall in front of yourself.</span>"
	summon_lifespan = 300
	charge_max = 300
	clothes_req = 0
	range = 0
	cast_sound = null
	human_req = 1

	action_icon_state = "mime"
	action_background_icon_state = "bg_mime"

/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall/Click()
	if(usr && usr.mind)
		if(!usr.mind.miming)
			usr << "<span class='notice'>You must dedicate yourself to silence first.</span>"
			return
		invocation = "<B>[usr.real_name]</B> looks as if a wall is in front of [usr.p_them()]."
	else
		invocation_type ="none"
	..()


/obj/effect/proc_holder/spell/targeted/mime/speak
	name = "Speech"
	desc = "Make or break a vow of silence."
	school = "mime"
	panel = "Mime"
	clothes_req = 0
	human_req = 1
	charge_max = 3000
	range = -1
	include_user = 1

	action_icon_state = "mime"
	action_background_icon_state = "bg_mime"

/obj/effect/proc_holder/spell/targeted/mime/speak/Click()
	if(!usr)
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(H.mind.miming)
		still_recharging_msg = "<span class='warning'>You can't break your vow of silence that fast!</span>"
	else
		still_recharging_msg = "<span class='warning'>You'll have to wait before you can give your vow of silence again!</span>"
	..()

/obj/effect/proc_holder/spell/targeted/mime/speak/cast(list/targets,mob/user = usr)
	for(var/mob/living/carbon/human/H in targets)
		H.mind.miming=!H.mind.miming
		if(H.mind.miming)
			H << "<span class='notice'>You make a vow of silence.</span>"
		else
			H << "<span class='notice'>You break your vow of silence.</span>"

// The spell can only be gotten from the "Advanced Mimery Kit" for Mime Traitors.

/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall/blockade
	name = "Invisible Blockade"
	desc = "With more polished skills, a powerful mime can create a invisble blockade, blocking off a 3x3 area."
	summon_type = list(/obj/effect/forcefield/mime/advanced)
	invocation_type = "emote"
	invocation_emote_self = "<span class='notice'>You form a blockade in front of yourself.</span>"
	summon_lifespan = 600
	charge_max = 600
	summon_amt = 9
	summon_ignore_prev_spawn_points = 1
	range = 1

/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall/blockade/Click()
	if(usr && usr.mind)
		if(!usr.mind.miming)
			usr << "<span class='notice'>You must dedicate yourself to silence first.</span>"
			return
		invocation = "<B>[usr.real_name]</B> looks as if a blockade is in front of [usr.p_them()]."
	else
		invocation_type ="none"
	..()

/obj/effect/proc_holder/spell/aimed/finger_guns
	name = "Finger Guns"
	desc = "An ancient technqiue, passed down from mentor to student. Allows you to shoot bullets out of your fingers."
	school = "mime"
	panel = "Mime"
	charge_max = 300
	clothes_req = 0
	invocation_type = "emote"
	invocation_emote_self = "<span class='dangers'>You fire your finger gun!</span>"
	range = 20
	projectile_type = /obj/item/projectile/bullet/weakbullet2
	sound = null
	active_msg = "You draw your fingers!"
	deactive_msg = "You put your fingers at ease. Another time."
	active = FALSE

	action_icon_state = "mime"
	action_background_icon_state = "bg_mime"
	base_icon_state = "mime"


/obj/effect/proc_holder/spell/aimed/finger_guns/Click()
	if(usr && usr.mind)
		if(!usr.mind.miming)
			usr << "<span class='notice'>You must dedicate yourself to silence first.</span>"
			return
		invocation = "<B>[usr.real_name]</B> pulls the finger gun's trigger!."
	else
		invocation_type ="none"
	..()


/obj/item/weapon/spellbook/oneuse/mimery_one
	spell = /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall/blockade
	spellname = ""
	name = "Guide to Advanced Mimery Vol 1"
	desc = "When you turn the pages, it won't make a sound!"
	icon_state ="bookmime"

/obj/item/weapon/spellbook/oneuse/mimery_two
	spell = /obj/effect/proc_holder/spell/aimed/finger_guns
	spellname = ""
	name = "Guide to Advanced Mimery Vol 2"
	desc = "There's no words written..."
	icon_state ="bookmime"