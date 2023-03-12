/datum/action/cooldown/spell/touch/star_touch
	name = "Star Touch"
	desc = "Marks someone with a star mark or puts someone with a star mark to sleep for 4 seconds, removing the star mark. \
		When the victim is hit it also creates a beam that deals a bit of fire damage and damages the cells. \
		The beam lasts a minute, until the beam is obstructed or until a new target has been found."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "star_touch"

	sound = 'sound/items/welder.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS
	invocation = "ST'R 'N'RG'!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE

	hand_path = /obj/item/melee/touch_attack/star_touch
	/// Stores the current beam target
	var/mob/living/current_target
	/// Checks the time of the last check
	var/last_check = 0
	/// The delay of when the beam gets checked
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	/// The maximum range of the beam
	var/max_range = 8
	/// Wether the beam is active or not
	var/active = FALSE
	/// The storage for the beam
	var/datum/beam/current_beam = null

/datum/action/cooldown/spell/touch/star_touch/New(Target)
	. = ..()
	START_PROCESSING(SSobj, src)

/datum/action/cooldown/spell/touch/star_touch/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/touch/star_touch/on_antimagic_triggered(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	victim.visible_message(
		span_danger("The spell bounces off of you!"),
	)

/datum/action/cooldown/spell/touch/star_touch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/human/victim, mob/living/carbon/caster)
	if(victim.has_status_effect(/datum/status_effect/star_mark))
		victim.apply_effect(4 SECONDS, effecttype = EFFECT_UNCONSCIOUS)
		victim.remove_status_effect(/datum/status_effect/star_mark)
	else
		victim.apply_status_effect(/datum/status_effect/star_mark)
	new /obj/effect/forcefield/cosmic_field(get_turf(src))
	start_beam(victim, caster)
	return TRUE

/datum/action/cooldown/spell/touch/star_touch/Destroy()
	STOP_PROCESSING(SSobj, src)
	lose_target()
	return ..()

/**
 * Proc that always is called when we want to end the beam and makes sure things are cleaned up, see beam_died()
 */
/datum/action/cooldown/spell/touch/star_touch/proc/lose_target()
	if(active)
		QDEL_NULL(current_beam)
		active = FALSE
	if(current_target)
		on_beam_release(current_target)
	current_target = null

/**
 * Proc that is only called when the beam fails due to something, so not when manually ended.
 * manual disconnection = lose_target, so it can silently end
 * automatic disconnection = beam_died, so we can give a warning message first
 */
/datum/action/cooldown/spell/touch/star_touch/proc/beam_died()
	SIGNAL_HANDLER
	current_beam = null
	active = FALSE //skip qdelling the beam again if we're doing this proc, because
	to_chat(owner, span_warning("You lose control of the beam!"))
	lose_target()

/// Used for starting the beam when a target has been acquired
/datum/action/cooldown/spell/touch/star_touch/proc/start_beam(atom/target, mob/living/user)

	if(current_target)
		lose_target()
	if(!isliving(target))
		return

	current_target = target
	active = TRUE
	current_beam = user.Beam(current_target, icon_state="cosmig_beam", time = 1 MINUTES, maxdistance = max_range, beam_type = /obj/effect/ebeam/cosmic)
	RegisterSignal(current_beam, COMSIG_PARENT_QDELETING, PROC_REF(beam_died))//this is a WAY better rangecheck than what was done before (process check)

	SSblackbox.record_feedback("tally", "gun_fired", 1, type)
	if(current_target)
		on_beam_hit(current_target)

/datum/action/cooldown/spell/touch/star_touch/process()
	if(!owner || (next_use_time - world.time) <= 0)
		STOP_PROCESSING(SSfastprocess, src)
	build_all_button_icons(UPDATE_BUTTON_STATUS)

	if(!current_target)
		lose_target()
		return

	if(world.time <= last_check+check_delay)
		return

	last_check = world.time

	if(!los_check(owner, current_target))
		QDEL_NULL(current_beam)//this will give the target lost message
		return

	if(current_target)
		on_beam_tick(current_target)

/// Checks if the beam is going through an invalid turf
/datum/action/cooldown/spell/touch/star_touch/proc/los_check(atom/movable/user, mob/target)
	var/turf/user_turf = user.loc
	if(!istype(user_turf))
		return FALSE
	var/obj/dummy = new(user_turf)
	dummy.pass_flags |= PASSTABLE|PASSGLASS|PASSGRILLE //Grille/Glass so it can be used through common windows
	var/turf/previous_step = user_turf
	var/first_step = TRUE
	for(var/turf/next_step as anything in (get_line(user_turf, target) - user_turf))
		if(first_step)
			for(var/obj/blocker in user_turf)
				if(!blocker.density || !(blocker.flags_1 & ON_BORDER_1))
					continue
				if(blocker.CanPass(dummy, get_dir(user_turf, next_step)))
					continue
				return FALSE // Could not leave the first turf.
			first_step = FALSE
		if(next_step.density)
			qdel(dummy)
			return FALSE
		for(var/atom/movable/movable as anything in next_step)
			if(!movable.CanPass(dummy, get_dir(next_step, previous_step)))
				qdel(dummy)
				return FALSE
		previous_step = next_step
	qdel(dummy)
	return TRUE

/// What to add when the beam connects to a target
/datum/action/cooldown/spell/touch/star_touch/proc/on_beam_hit(mob/living/target)
	if(!istype(target, /mob/living/basic/star_gazer))
		target.AddElement(/datum/element/effect_trail/cosmig_trail)
	return

/// What to process when the beam is connected to a target
/datum/action/cooldown/spell/touch/star_touch/proc/on_beam_tick(mob/living/target)
	target.adjustFireLoss(2)
	target.adjustCloneLoss(1)
	return

/// What to remove when the beam disconnects from a target
/datum/action/cooldown/spell/touch/star_touch/proc/on_beam_release(mob/living/target)
	if(!istype(target, /mob/living/basic/star_gazer))
		target.RemoveElement(/datum/element/effect_trail/cosmig_trail)
	return

/obj/item/melee/touch_attack/star_touch
	name = "Star Touch"
	desc = "A sinister looking aura that distorts the flow of reality around it. \
		Causes people with a star mark to sleep for 4 seconds, and causes people without a star mark to get one."
	icon_state = "star"
	inhand_icon_state = "star"

/obj/item/melee/touch_attack/star_touch/ignition_effect(atom/to_light, mob/user)
	. = span_notice("[user] effortlessly snaps [user.p_their()] fingers near [to_light], igniting it with cosmic energies. Fucking badass!")
	remove_hand_with_no_refund(user)

/obj/effect/ebeam/cosmic
	name = "cosmic beam"
