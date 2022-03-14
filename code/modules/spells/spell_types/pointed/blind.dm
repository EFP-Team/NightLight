/datum/action/cooldown/spell/pointed/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single target."
	action_icon_state = "blind"
	school = SCHOOL_TRANSMUTATION
	sound = 'sound/magic/blind.ogg'
	cooldown_time = 30 SECONDS
	cooldown_min = 5 SECONDS //12 deciseconds reduction per rank
	requires_wizard_garb = FALSE
	invocation = "STI KALY"
	invocation_type = INVOCATION_WHISPER
	on_afflicted_message = span_notice("Your eyes cry out in pain!")
	// ranged_mousepointer = 'icons/effects/mouse_pointers/blind_target.dmi'
	active_msg = "You prepare to blind a target..."

	var/eye_blind_amount = 10
	var/eye_blurry_amount = 20
	var/blind_mutation_duration = 30 SECONDS

/datum/action/cooldown/spell/pointed/blind/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE

	var/mob/living/carbon/human/human_target = cast_on
	return !human_target.is_blind()

/datum/action/cooldown/spell/pointed/blind/cast(mob/living/carbon/human/cast_on)
	cast_on.blind_eyes(eye_blind_amount)
	cast_on.blur_eyes(eye_blurry_amount)
	cast_on.dna?.add_mutation(/datum/mutation/human/blind)
	addtimer(CALLBACK(src, .proc/fix_eyes, cast_on), blind_mutation_duration)
	return TRUE

/datum/action/cooldown/spell/pointed/blind/proc/fix_eyes(mob/living/carbon/human/cast_on)
	cast_on.dna?.remove_mutation(/datum/mutation/human/blind)
