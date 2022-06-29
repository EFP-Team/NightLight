// Contains cult communion, guide, and cult master abilities

/datum/action/innate/cult
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS

/datum/action/innate/cult/IsAvailable()
	if(!IS_CULTIST(owner))
		return FALSE
	return ..()

/datum/action/innate/cult/comm
	name = "Communion"
	desc = "Whispered words that all cultists can hear.<br><b>Warning:</b>Nearby non-cultists can still hear you."
	button_icon_state = "cult_comms"

/datum/action/innate/cult/comm/Activate()
	var/input = tgui_input_text(usr, "Message to tell to the other acolytes", "Voice of Blood")
	if(!input || !IsAvailable())
		return

	var/list/filter_result = CAN_BYPASS_FILTER(usr) ? null : is_ic_filtered(input)
	if(filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		return

	var/list/soft_filter_result = CAN_BYPASS_FILTER(usr) ? null : is_soft_ic_filtered(input)
	if(soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[html_encode(input)]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[input]\"")
	cultist_commune(usr, input)

/datum/action/innate/cult/comm/proc/cultist_commune(mob/living/user, message)
	var/my_message
	if(!message)
		return
	user.whisper("O bidai nabora se[pick("'","`")]sma!", language = /datum/language/common)
	user.whisper(html_decode(message), filterproof = TRUE)
	var/title = "Acolyte"
	var/span = "cult italic"
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/cult/master))
		span = "cultlarge"
		title = "Master"
	else if(!ishuman(user))
		title = "Construct"
	my_message = "<span class='[span]'><b>[title] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(IS_CULTIST(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="cult")

/datum/action/innate/cult/comm/spirit
	name = "Spiritual Communion"
	desc = "Conveys a message from the spirit realm that all cultists can hear."

/datum/action/innate/cult/comm/spirit/IsAvailable()
	if(IS_CULTIST(owner.mind.current))
		return TRUE

/datum/action/innate/cult/comm/spirit/cultist_commune(mob/living/user, message)
	var/my_message
	if(!message)
		return
	my_message = span_cultboldtalic("The [user.name]: [message]")
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(IS_CULTIST(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

/datum/action/innate/cult/mastervote
	name = "Assert Leadership"
	button_icon_state = "cultvote"

/datum/action/innate/cult/mastervote/IsAvailable()
	if(!owner.mind)
		return
	var/datum/antagonist/cult/C = owner.mind?.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(!C || C.cult_team.cult_vote_called || !ishuman(owner))
		return FALSE
	return ..()

/datum/action/innate/cult/mastervote/Activate()
	var/choice = tgui_alert(owner, "The mantle of leadership is heavy. Success in this role requires an expert level of communication and experience. Are you sure?",, list("Yes", "No"))
	if(choice == "Yes" && IsAvailable())
		var/datum/antagonist/cult/C = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
		pollCultists(owner,C.cult_team)

/proc/pollCultists(mob/living/Nominee,datum/team/cult/team) //Cult Master Poll
	if(world.time < CULT_POLL_WAIT)
		to_chat(Nominee, "It would be premature to select a leader while everyone is still settling in, try again in [DisplayTimeText(CULT_POLL_WAIT-world.time)].")
		return
	team.cult_vote_called = TRUE //somebody's trying to be a master, make sure we don't let anyone else try
	for(var/datum/mind/B in team.members)
		if(B.current)
			B.current.update_action_buttons_icon()
			if(!B.current.incapacitated())
				SEND_SOUND(B.current, 'sound/hallucinations/im_here1.ogg')
				to_chat(B.current, span_cultlarge("Acolyte [Nominee] has asserted that [Nominee.p_theyre()] worthy of leading the cult. A vote will be called shortly."))
	sleep(100)
	var/list/asked_cultists = list()
	for(var/datum/mind/B in team.members)
		if(B.current && B.current != Nominee && !B.current.incapacitated())
			SEND_SOUND(B.current, 'sound/magic/exit_blood.ogg')
			asked_cultists += B.current
	var/list/yes_voters = poll_candidates("[Nominee] seeks to lead your cult, do you support [Nominee.p_them()]?", poll_time = 300, group = asked_cultists)
	if(QDELETED(Nominee) || Nominee.incapacitated())
		team.cult_vote_called = FALSE
		for(var/datum/mind/B in team.members)
			if(B.current)
				B.current.update_action_buttons_icon()
				if(!B.current.incapacitated())
					to_chat(B.current,span_cultlarge("[Nominee] has died in the process of attempting to win the cult's support!"))
		return FALSE
	if(!Nominee.mind)
		team.cult_vote_called = FALSE
		for(var/datum/mind/B in team.members)
			if(B.current)
				B.current.update_action_buttons_icon()
				if(!B.current.incapacitated())
					to_chat(B.current,span_cultlarge("[Nominee] has gone catatonic in the process of attempting to win the cult's support!"))
		return FALSE
	if(LAZYLEN(yes_voters) <= LAZYLEN(asked_cultists) * 0.5)
		team.cult_vote_called = FALSE
		for(var/datum/mind/B in team.members)
			if(B.current)
				B.current.update_action_buttons_icon()
				if(!B.current.incapacitated())
					to_chat(B.current, span_cultlarge("[Nominee] could not win the cult's support and shall continue to serve as an acolyte."))
		return FALSE
	team.cult_master = Nominee
	var/datum/antagonist/cult/cultist = Nominee.mind.has_antag_datum(/datum/antagonist/cult)
	if (cultist)
		cultist.silent = TRUE
		cultist.on_removal()
	Nominee.mind.add_antag_datum(/datum/antagonist/cult/master)
	for(var/datum/mind/B in team.members)
		if(B.current)
			for(var/datum/action/innate/cult/mastervote/vote in B.current.actions)
				vote.Remove(B.current)
			if(!B.current.incapacitated())
				to_chat(B.current,span_cultlarge("[Nominee] has won the cult's support and is now their master. Follow [Nominee.p_their()] orders to the best of your ability!"))
	return TRUE

/datum/action/innate/cult/master/IsAvailable()
	if(!owner.mind || !owner.mind.has_antag_datum(/datum/antagonist/cult/master) || GLOB.cult_narsie)
		return FALSE
	return ..()

/datum/action/innate/cult/master/finalreck
	name = "Final Reckoning"
	desc = "A single-use spell that brings the entire cult to the master's location."
	button_icon_state = "sintouch"

/datum/action/innate/cult/master/finalreck/Activate()
	var/datum/antagonist/cult/antag = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(!antag)
		return
	var/place = get_area(owner)
	var/datum/objective/eldergod/summon_objective = locate() in antag.cult_team.objectives
	if(place in summon_objective.summon_spots)//cant do final reckoning in the summon area to prevent abuse, you'll need to get everyone to stand on the circle!
		to_chat(owner, span_cultlarge("The veil is too weak here! Move to an area where it is strong enough to support this magic."))
		return
	for(var/i in 1 to 4)
		chant(i)
		var/list/destinations = list()
		for(var/turf/T in orange(1, owner))
			if(!T.is_blocked_turf(TRUE))
				destinations += T
		if(!LAZYLEN(destinations))
			to_chat(owner, span_warning("You need more space to summon your cult!"))
			return
		if(do_after(owner, 30, target = owner))
			for(var/datum/mind/B in antag.cult_team.members)
				if(B.current && B.current.stat != DEAD)
					var/turf/mobloc = get_turf(B.current)
					switch(i)
						if(1)
							new /obj/effect/temp_visual/cult/sparks(mobloc, B.current.dir)
							playsound(mobloc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
						if(2)
							new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, B.current.dir)
							playsound(mobloc, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
						if(3)
							new /obj/effect/temp_visual/dir_setting/cult/phase(mobloc, B.current.dir)
							playsound(mobloc, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
						if(4)
							playsound(mobloc, 'sound/magic/exit_blood.ogg', 100, TRUE)
							if(B.current != owner)
								var/turf/final = pick(destinations)
								if(istype(B.current.loc, /obj/item/soulstone))
									var/obj/item/soulstone/S = B.current.loc
									S.release_shades(owner)
								B.current.setDir(SOUTH)
								new /obj/effect/temp_visual/cult/blood(final)
								addtimer(CALLBACK(B.current, /mob/.proc/reckon, final), 10)
		else
			return
	antag.cult_team.reckoning_complete = TRUE
	Remove(owner)

/mob/proc/reckon(turf/final)
	new /obj/effect/temp_visual/cult/blood/out(get_turf(src))
	forceMove(final)

/datum/action/innate/cult/master/finalreck/proc/chant(chant_number)
	switch(chant_number)
		if(1)
			owner.say("C'arta forbici!", language = /datum/language/common, forced = "cult invocation")
		if(2)
			owner.say("Pleggh e'ntrath!", language = /datum/language/common, forced = "cult invocation")
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 50, TRUE)
		if(3)
			owner.say("Barhah hra zar'garis!", language = /datum/language/common, forced = "cult invocation")
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 75, TRUE)
		if(4)
			owner.say("N'ath reth sh'yro eth d'rekkathnor!!!", language = /datum/language/common, forced = "cult invocation")
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 100, TRUE)

/datum/action/innate/cult/master/cultmark
	name = "Mark Target"
	desc = "Marks a target for the cult."
	button_icon_state = "cult_mark"
	var/obj/effect/proc_holder/cultmark/CM
	var/cooldown = 0
	var/base_cooldown = 1200

/datum/action/innate/cult/master/cultmark/New(Target)
	CM = new()
	CM.attached_action = src
	..()

/datum/action/innate/cult/master/cultmark/IsAvailable()
	if(cooldown > world.time)
		if(!CM.active)
			to_chat(owner, span_cultlarge("<b>You need to wait [DisplayTimeText(cooldown - world.time)] before you can mark another target!</b>"))
		return FALSE
	return ..()

/datum/action/innate/cult/master/cultmark/Destroy()
	QDEL_NULL(CM)
	return ..()

/datum/action/innate/cult/master/cultmark/Activate()
	CM.toggle(owner) //the important bit
	return TRUE

/obj/effect/proc_holder/cultmark
	active = FALSE
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	var/datum/action/innate/cult/master/cultmark/attached_action

/obj/effect/proc_holder/cultmark/Destroy()
	attached_action = null
	return ..()

/obj/effect/proc_holder/cultmark/proc/toggle(mob/user)
	if(active)
		remove_ranged_ability(span_cult("You cease the marking ritual."))
	else
		add_ranged_ability(user, span_cult("You prepare to mark a target for your cult..."))

/obj/effect/proc_holder/cultmark/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated())
		remove_ranged_ability()
		return
	var/turf/T = get_turf(ranged_ability_user)
	if(!isturf(T))
		return FALSE

	var/datum/antagonist/cult/C = caller.mind.has_antag_datum(/datum/antagonist/cult,TRUE)

	if(target in view(7, get_turf(ranged_ability_user)))
		if(C.cult_team.blood_target)
			to_chat(ranged_ability_user, span_cult("The cult has already designated a target!"))
			return FALSE
		C.cult_team.blood_target = target
		var/area/A = get_area(target)
		attached_action.cooldown = world.time + attached_action.base_cooldown
		addtimer(CALLBACK(attached_action.owner, /mob.proc/update_action_buttons_icon), attached_action.base_cooldown)
		C.cult_team.blood_target_image = image('icons/effects/mouse_pointers/cult_target.dmi', target, "glow", ABOVE_MOB_LAYER)
		C.cult_team.blood_target_image.appearance_flags = RESET_COLOR
		C.cult_team.blood_target_image.pixel_x = -target.pixel_x
		C.cult_team.blood_target_image.pixel_y = -target.pixel_y
		for(var/datum/mind/B as anything in get_antag_minds(/datum/antagonist/cult))
			if(B.current && B.current.stat != DEAD && B.current.client)
				to_chat(B.current, span_cultlarge("<b>[ranged_ability_user] has marked [C.cult_team.blood_target] in the [A.name] as the cult's top priority, get there immediately!</b>"))
				SEND_SOUND(B.current, sound(pick('sound/hallucinations/over_here2.ogg','sound/hallucinations/over_here3.ogg'),0,1,75))
				B.current.client.images += C.cult_team.blood_target_image
		attached_action.owner.update_action_buttons_icon()
		remove_ranged_ability(span_cult("The marking rite is complete! It will last for 90 seconds."))
		C.cult_team.blood_target_reset_timer = addtimer(CALLBACK(GLOBAL_PROC, .proc/reset_blood_target,C.cult_team), 900, TIMER_STOPPABLE)
		return TRUE
	return FALSE

/proc/reset_blood_target(datum/team/cult/team)
	for(var/datum/mind/B in team.members)
		if(B.current && B.current.stat != DEAD && B.current.client)
			if(team.blood_target)
				to_chat(B.current,span_cultlarge("<b>The blood mark has expired!</b>"))
			B.current.client.images -= team.blood_target_image
	QDEL_NULL(team.blood_target_image)
	team.blood_target = null


/datum/action/innate/cult/master/cultmark/ghost
	name = "Mark a Blood Target for the Cult"
	desc = "Marks a target for the entire cult to track."

/datum/action/innate/cult/master/cultmark/ghost/IsAvailable()
	if(istype(owner, /mob/dead/observer) && IS_CULTIST(owner.mind.current))
		return TRUE
	else
		qdel(src)

/datum/action/innate/cult/ghostmark //Ghost version
	name = "Blood Mark your Target"
	desc = "Marks whatever you are orbitting - for the entire cult to track."
	button_icon_state = "cult_mark"
	var/tracking = FALSE
	var/cooldown = 0
	var/base_cooldown = 600

/datum/action/innate/cult/ghostmark/IsAvailable()
	if(istype(owner, /mob/dead/observer) && IS_CULTIST(owner.mind.current))
		return TRUE
	else
		qdel(src)

/datum/action/innate/cult/ghostmark/proc/reset_button()
	if(owner)
		name = "Blood Mark your Target"
		desc = "Marks whatever you are orbitting - for the entire cult to track."
		button_icon_state = "cult_mark"
		owner.update_action_buttons_icon()
		SEND_SOUND(owner, 'sound/magic/enter_blood.ogg')
		to_chat(owner,span_cultbold("Your previous mark is gone - you are now ready to create a new blood mark."))

/datum/action/innate/cult/ghostmark/Activate()
	var/datum/antagonist/cult/C = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(C.cult_team.blood_target)
		if(cooldown>world.time)
			reset_blood_target(C.cult_team)
			to_chat(owner, span_cultbold("You have cleared the cult's blood target!"))
			deltimer(C.cult_team.blood_target_reset_timer)
			return
		else
			to_chat(owner, span_cultbold("The cult has already designated a target!"))
			return
	if(cooldown>world.time)
		to_chat(owner, span_cultbold("You aren't ready to place another blood mark yet!"))
		return
	target = owner.orbiting?.parent || get_turf(owner)
	if(!target)
		return
	C.cult_team.blood_target = target
	var/atom/atom_target = target
	var/area/A = get_area(atom_target)
	cooldown = world.time + base_cooldown
	addtimer(CALLBACK(owner, /mob.proc/update_action_buttons_icon), base_cooldown)
	C.cult_team.blood_target_image = image('icons/effects/mouse_pointers/cult_target.dmi', atom_target, "glow", ABOVE_MOB_LAYER)
	C.cult_team.blood_target_image.appearance_flags = RESET_COLOR
	C.cult_team.blood_target_image.pixel_x = -atom_target.pixel_x
	C.cult_team.blood_target_image.pixel_y = -atom_target.pixel_y
	SEND_SOUND(owner, sound(pick('sound/hallucinations/over_here2.ogg','sound/hallucinations/over_here3.ogg'),0,1,75))
	owner.client.images += C.cult_team.blood_target_image
	for(var/datum/mind/B as anything in get_antag_minds(/datum/antagonist/cult))
		if(B.current && B.current.stat != DEAD && B.current.client)
			to_chat(B.current, span_cultlarge("<b>[owner] has marked [C.cult_team.blood_target] in the [A.name] as the cult's top priority, get there immediately!</b>"))
			SEND_SOUND(B.current, sound(pick('sound/hallucinations/over_here2.ogg','sound/hallucinations/over_here3.ogg'),0,1,75))
			B.current.client.images += C.cult_team.blood_target_image
	to_chat(owner,span_cultbold("You have marked the [atom_target] for the cult! It will last for [DisplayTimeText(base_cooldown)]."))
	name = "Clear the Blood Mark"
	desc = "Remove the Blood Mark you previously set."
	button_icon_state = "emp"
	owner.update_action_buttons_icon()
	C.cult_team.blood_target_reset_timer = addtimer(CALLBACK(GLOBAL_PROC, .proc/reset_blood_target,C.cult_team), base_cooldown, TIMER_STOPPABLE)
	addtimer(CALLBACK(src, .proc/reset_button), base_cooldown)


//////// ELDRITCH PULSE /////////



/datum/action/innate/cult/master/pulse
	name = "Eldritch Pulse"
	desc = "Seize upon a fellow cultist or cult structure and teleport it to a nearby location."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "arcane_barrage"
	var/obj/effect/proc_holder/pulse/PM
	var/cooldown = 0
	var/base_cooldown = 150
	var/throwing = FALSE
	var/mob/living/throwee

/datum/action/innate/cult/master/pulse/New()
	PM = new()
	PM.attached_action = src
	..()

/datum/action/innate/cult/master/pulse/IsAvailable()
	if(!owner.mind || !owner.mind.has_antag_datum(/datum/antagonist/cult/master))
		return FALSE
	if(cooldown > world.time)
		if(!PM.active)
			to_chat(owner, span_cultlarge("<b>You need to wait [DisplayTimeText(cooldown - world.time)] before you can pulse again!</b>"))
		return FALSE
	return ..()

/datum/action/innate/cult/master/pulse/Destroy()
	PM.attached_action = null //What the fuck is even going on here.
	QDEL_NULL(PM)
	return ..()


/datum/action/innate/cult/master/pulse/Activate()
	PM.toggle(owner) //the important bit
	return TRUE

/obj/effect/proc_holder/pulse
	active = FALSE
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'
	var/datum/action/innate/cult/master/pulse/attached_action

/obj/effect/proc_holder/pulse/Destroy()
	attached_action = null
	return ..()


/obj/effect/proc_holder/pulse/proc/toggle(mob/user)
	if(active)
		remove_ranged_ability(span_cult("You cease your preparations..."))
		attached_action.throwing = FALSE
	else
		add_ranged_ability(user, span_cult("You prepare to tear through the fabric of reality..."))

/obj/effect/proc_holder/pulse/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated())
		remove_ranged_ability()
		return
	var/turf/T = get_turf(ranged_ability_user)
	if(!isturf(T))
		return FALSE
	if(target in view(7, get_turf(ranged_ability_user)))
		var/mob/mob_target = target
		var/is_cultist = istype(mob_target) && IS_CULTIST(mob_target)
		if((!(is_cultist || istype(target, /obj/structure/destructible/cult)) || target == caller) && !(attached_action.throwing))
			return
		if(!attached_action.throwing)
			attached_action.throwing = TRUE
			attached_action.throwee = target
			SEND_SOUND(ranged_ability_user, sound('sound/weapons/thudswoosh.ogg'))
			to_chat(ranged_ability_user,span_cult("<b>You reach through the veil with your mind's eye and seize [target]!</b>"))
			return
		else
			new /obj/effect/temp_visual/cult/sparks(get_turf(attached_action.throwee), ranged_ability_user.dir)
			var/distance = get_dist(attached_action.throwee, target)
			if(distance >= 16)
				return
			playsound(target,'sound/magic/exit_blood.ogg')
			attached_action.throwee.Beam(target,icon_state="sendbeam", time = 4)
			attached_action.throwee.forceMove(get_turf(target))
			new /obj/effect/temp_visual/cult/sparks(get_turf(target), ranged_ability_user.dir)
			attached_action.throwing = FALSE
			attached_action.cooldown = world.time + attached_action.base_cooldown
			remove_ranged_ability(span_cult("A pulse of blood magic surges through you as you shift [attached_action.throwee] through time and space."))
			caller.update_action_buttons_icon()
			addtimer(CALLBACK(caller, /mob.proc/update_action_buttons_icon), attached_action.base_cooldown)
