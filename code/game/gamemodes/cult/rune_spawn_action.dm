//after a delay, creates a rune below you. for constructs creating runes.
/datum/action/innate/cult/create_rune
	background_icon_state = "bg_cult"
	var/obj/effect/rune/rune_type
	var/cooldown = 0
	var/base_cooldown = 900
	var/scribe_time = 100
	var/damage_interrupt = TRUE
	var/action_interrupt = TRUE
	var/obj/effect/overlay/temp/cult/rune_spawn/rune_word_type
	var/obj/effect/overlay/temp/cult/rune_spawn/rune_center_type
	var/rune_color

/datum/action/innate/cult/create_rune/IsAvailable()
	if(!rune_type || cooldown > world.time)
		return FALSE
	return ..()

/datum/action/innate/cult/create_rune/Activate()
	var/chosen_keyword
	if(!isturf(owner.loc))
		to_chat(owner, "<span class='warning>You need more space to scribe a rune!</span>")
		return
	if(initial(rune_type.req_keyword))
		chosen_keyword = stripped_input(owner, "Enter a keyword for the new rune.", "Words of Power")
		if(!chosen_keyword)
			return

	var/obj/effect/overlay/temp/cult/rune_spawn/R1 = new(owner.loc, scribe_time, rune_color)
	var/obj/effect/overlay/temp/cult/rune_spawn/inner/R2 = new(owner.loc, scribe_time, rune_color)
	var/obj/effect/overlay/temp/cult/rune_spawn/R3
	if(rune_word_type)
		R3 = new rune_word_type(owner.loc, scribe_time, rune_color)
	var/obj/effect/overlay/temp/cult/rune_spawn/R4
	if(rune_center_type)
		R4 = new rune_center_type(owner.loc, scribe_time, rune_color)

	cooldown = base_cooldown + world.time
	owner.update_action_buttons_icon()
	addtimer(CALLBACK(owner, /mob.proc/update_action_buttons_icon), base_cooldown)
	var/list/health
	if(damage_interrupt && isliving(owner))
		var/mob/living/L = owner
		health = list("health" = L.health)
	if(do_after(owner, scribe_time, target = owner, extra_checks = CALLBACK(owner, /mob.proc/break_do_after_checks, health, action_interrupt)))
		var/obj/effect/rune/rune = new rune(owner.loc)
		rune.keyword = chosen_keyword
	else
		qdel(R1)
		qdel(R2)
		if(R3)
			qdel(R3)
		if(R4)
			qdel(R4)
		cooldown = 0
		owner.update_action_buttons_icon()

//teleport rune
/datum/action/innate/cult/create_rune/tele
	button_icon_state = "telerune"
	rune_type = /obj/effect/rune/teleport
	rune_word_type = /obj/effect/overlay/temp/cult/rune_spawn/rune2
	rune_center_type = /obj/effect/overlay/temp/cult/rune_spawn/rune2/center
	rune_color = RUNE_COLOR_TELEPORT
