
/mob/living/silicon/pai/proc/fold_out(force = FALSE)
	if(emitterhealth < 0)
		src << "<span class='warning'>Your holochassis emitters are still too unstable! Please wait for automatic repair.</span>"
		return FALSE

	if(!canholo && !force)
		src << "<span class='warning'>Your master or another force has disabled your holochassis emitters!</span>"
		return FALSE

	if(holoform)
		. = fold_in(force)
		return

	if(emittersemicd)
		src << "<span class='warning'>Error: Holochassis emitters recycling. Please try again later.</span>"
		return FALSE

	emittersemicd = TRUE
	addtimer(src, "emittercool", emittercd)
	canmove = TRUE
	density = TRUE
	if(istype(card.loc, /mob/living))
		var/mob/living/L = card.loc
		if(!L.unEquip(card))
			src << "<span class='warning'>Error: Unable to expand to mobile form. Chassis is restrained by some device or person.</span>"
			return FALSE
		else if(istype(card.loc, /obj/item/device/pda))
			var/obj/item/device/pda/P = card.loc
			P.pai = null
	if(client)
		client.perspective = EYE_PERSPECTIVE
		client.eye = src
	var/turf/T = get_turf(card.loc)
	card.loc = T
	loc = T
	forceMove(T)
	card.forceMove(src)
	card.screen_loc = null
	SetLuminosity(0)
	icon_state = "[chassis]"
	src.visible_message("<span class='boldnotice'>[src] folds out its holochassis emitter and forms a holoshell around itself!</span>")
	holoform = TRUE

/mob/living/silicon/pai/proc/emittercool()
	emittersemicd = FALSE

/mob/living/silicon/pai/proc/fold_in(force = FALSE)
	emittersemicd = TRUE
	addtimer(src, "emittercool", emittercd)
	icon_state = "[chassis]"
	if(!holoform)
		. = fold_out(force)
		return
	visible_message("<span class='notice'>[src] deactivates its holochassis emitter and folds back into a compact card!</span>")
	stop_pulling()
	if(client)
		client.perspective = EYE_PERSPECTIVE
		client.eye = card
	var/turf/T = get_turf(src)
	card.loc = T
	card.forceMove(T)
	loc = card
	forceMove(card)
	canmove = FALSE
	density = FALSE
	SetLuminosity(0)
	holoform = FALSE
	if(resting)
		lay_down()

/mob/living/silicon/pai/proc/choose_chassis()
	var/choice = input(src, "What would you like to use for your holochassis composite?") as null|anything in possible_chassis
	if(!choice)
		return 0
	chassis = choice
	icon_state = "[chassis]"
	if(resting)
		icon_state = "[chassis]_rest"
	src << "<span class='boldnotice'>You switch your holochassis projection composite to [chassis]</span>"

/mob/living/silicon/pai/lay_down()
	..()
	update_resting_icon(resting)

/mob/living/silicon/pai/proc/update_resting_icon(rest)
	if(rest)
		icon_state = "[chassis]_rest"
	else
		icon_state = "[chassis]"
	if(loc != card)
		visible_message("<span class='notice'>[src] [rest? "lays down for a moment..." : "perks up from the ground"]</span>")
