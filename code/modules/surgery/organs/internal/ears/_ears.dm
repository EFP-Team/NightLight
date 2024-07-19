/obj/item/organ/internal/ears
	name = "ears"
	icon_state = "ears"
	desc = "There are three parts to the ear. Inner, middle and outer. Only one of these parts should be normally visible."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS
	visual = FALSE
	gender = PLURAL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	low_threshold_passed = "<span class='info'>Your ears begin to resonate with an internal ring sometimes.</span>"
	now_failing = "<span class='warning'>You are unable to hear at all!</span>"
	now_fixed = "<span class='info'>Noise slowly begins filling your ears once more.</span>"
	low_threshold_cleared = "<span class='info'>The ringing in your ears has died down.</span>"

	/// What broad type of ear overlay do we have
	var/ear_overlay_type
	/// The ear overlay type
	var/datum/bodypart_overlay/mutant/ear_overlay
	/// `deaf` measures "ticks" of deafness. While > 0, the person is unable to hear anything.
	var/deaf = 0

	// `damage` in this case measures long term damage to the ears, if too high,
	// the person will not have either `deaf` or `ear_damage` decrease
	// without external aid (earmuffs, drugs)

	/// Resistance against loud noises
	var/bang_protect = 0
	/// Multiplier for both long term and short term ear damage
	var/damage_multiplier = 1

/obj/item/organ/internal/ears/on_life(seconds_per_tick, times_fired)
	// only inform when things got worse, needs to happen before we heal
	if((damage > low_threshold && prev_damage < low_threshold) || (damage > high_threshold && prev_damage < high_threshold))
		to_chat(owner, span_warning("The ringing in your ears grows louder, blocking out any external noises for a moment."))

	. = ..()
	// if we have non-damage related deafness like mutations, quirks or clothing (earmuffs), don't bother processing here.
	// Ear healing from earmuffs or chems happen elsewhere
	if(HAS_TRAIT_NOT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
		return
	// no healing if failing
	if(organ_flags & ORGAN_FAILING)
		return
	adjustEarDamage(0, -0.5 * seconds_per_tick)
	if((damage > low_threshold) && SPT_PROB(damage / 60, seconds_per_tick))
		adjustEarDamage(0, 4)
		SEND_SOUND(owner, sound('sound/weapons/flash_ring.ogg'))

/obj/item/organ/internal/ears/Destroy()
	QDEL_NULL(ear_overlay)
	return ..()

/obj/item/organ/internal/ears/apply_organ_damage(damage_amount, maximum, required_organ_flag)
	. = ..()
	update_temp_deafness()

/obj/item/organ/internal/ears/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	update_temp_deafness()
	if(!ear_overlay && ear_overlay_type)
		imprint_ear(organ_owner)

/obj/item/organ/internal/ears/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_MOB_SAY)
	REMOVE_TRAIT(organ_owner, TRAIT_DEAF, EAR_DAMAGE)

/// Called on first insert to generate an ear overlay
/obj/item/organ/internal/ears/proc/imprint_ear(mob/living/carbon/ear_owner)
	ear_overlay = new ear_overlay_type()
	bodypart_owner?.add_bodypart_overlay(ear_overlay)

/obj/item/organ/internal/ears/on_bodypart_insert(obj/item/bodypart/limb, movement_flags)
	. = ..()
	if(ear_overlay)
		limb.add_bodypart_overlay(ear_overlay)

/obj/item/organ/internal/ears/on_bodypart_remove(obj/item/bodypart/limb, movement_flags)
	. = ..()
	if(ear_overlay)
		limb.remove_bodypart_overlay(ear_overlay)

/**
 * Snowflake proc to handle temporary deafness
 *
 * * ddmg: Handles normal organ damage
 * * ddeaf: Handles temporary deafness, 1 ddeaf = 2 seconds of deafness, by default (with no multiplier)
 */
/obj/item/organ/internal/ears/proc/adjustEarDamage(ddmg = 0, ddeaf = 0)
	if(owner.status_flags & GODMODE)
		update_temp_deafness()
		return

	var/mod_damage = ddmg > 0 ? (ddmg * damage_multiplier) : ddmg
	if(mod_damage)
		apply_organ_damage(mod_damage)
	var/mod_deaf = ddeaf > 0 ? (ddeaf * damage_multiplier) : ddeaf
	if(mod_deaf)
		deaf = max(deaf + mod_deaf, 0)
	update_temp_deafness()

/// Updates status of deafness
/obj/item/organ/internal/ears/proc/update_temp_deafness()
	// if we're failing we always have at least some deaf stacks (and thus deafness)
	if(organ_flags & ORGAN_FAILING)
		deaf = max(deaf, 1 * damage_multiplier)

	if(isnull(owner))
		return

	if(owner.status_flags & GODMODE)
		deaf = 0

	if(deaf > 0)
		if(!HAS_TRAIT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
			RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(adjust_speech))
			ADD_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
	else
		REMOVE_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
		UnregisterSignal(owner, COMSIG_MOB_SAY)

/// Being deafened by loud noises makes you shout
/obj/item/organ/internal/ears/proc/adjust_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(HAS_TRAIT_NOT_FROM(source, TRAIT_DEAF, EAR_DAMAGE))
		return
	if(HAS_TRAIT(source, TRAIT_SIGN_LANG))
		return

	var/message = speech_args[SPEECH_MESSAGE]
	// Replace only end-of-sentence punctuation with exclamation marks (hence the empty space)
	// We don't wanna mess with things like ellipses
	message = replacetext(message, ". ", "! ")
	message = replacetext(message, "? ", "?! ")
	// Special case for the last character
	switch(copytext_char(message, -1))
		if(".")
			if(copytext_char(message, -2) != "..") // Once again ignoring ellipses, let people trail off
				message = copytext_char(message, 1, -1) + "!"
		if("?")
			message = copytext_char(message, 1, -1) + "?!"
		if("!")
			pass()
		else
			message += "!"

	speech_args[SPEECH_MESSAGE] = message
	return COMPONENT_UPPERCASE_SPEECH

/obj/item/organ/internal/ears/invincible
	damage_multiplier = 0

/obj/item/organ/internal/ears/cat
	name = "cat ears"
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "kitty"
	visual = TRUE
	damage_multiplier = 2
	ear_overlay_type = /datum/bodypart_overlay/mutant/ears/felinid

/obj/item/organ/internal/ears/cat/imprint_ear(mob/living/carbon/ear_owner)
	. = ..()
	var/ear_to_use = ear_owner.dna?.features?["ears"]
	if(isnull(ear_to_use) || ear_to_use == SPRITE_ACCESSORY_NONE)
		ear_to_use = /datum/sprite_accessory/ears/cat::name
	ear_overlay.set_appearance_from_name(ear_owner.dna.features["ears"])

/obj/item/organ/internal/ears/penguin
	name = "penguin ears"
	desc = "The source of a penguin's happy feet."

/obj/item/organ/internal/ears/penguin/on_mob_insert(mob/living/carbon/human/ear_owner)
	. = ..()
	to_chat(ear_owner, span_notice("You suddenly feel like you've lost your balance."))
	ear_owner.AddElementTrait(TRAIT_WADDLING, ORGAN_TRAIT, /datum/element/waddling)

/obj/item/organ/internal/ears/penguin/on_mob_remove(mob/living/carbon/human/ear_owner)
	. = ..()
	to_chat(ear_owner, span_notice("Your sense of balance comes back to you."))
	REMOVE_TRAIT(ear_owner, TRAIT_WADDLING, ORGAN_TRAIT)

/obj/item/organ/internal/ears/cybernetic
	name = "basic cybernetic ears"
	icon_state = "ears-c"
	desc = "A basic cybernetic organ designed to mimic the operation of ears."
	damage_multiplier = 0.9
	organ_flags = ORGAN_ROBOTIC
	failing_desc = "seems to be broken."

/obj/item/organ/internal/ears/cybernetic/upgraded
	name = "cybernetic ears"
	icon_state = "ears-c-u"
	desc =  "An advanced cybernetic ear, surpassing the performance of organic ears."
	damage_multiplier = 0.5

/obj/item/organ/internal/ears/cybernetic/whisper
	name = "whisper-sensitive cybernetic ears"
	icon_state = "ears-c-u"
	desc = "Allows the user to more easily hear whispers. The user becomes extra vulnerable to loud noises, however"
	// Same sensitivity as felinid ears
	damage_multiplier = 2

// The original idea was to use signals to do this not traits. Unfortunately, the star effect used for whispers applies before any relevant signals
// This seems like the least invasive solution
/obj/item/organ/internal/ears/cybernetic/whisper/on_mob_insert(mob/living/carbon/ear_owner)
	. = ..()
	ADD_TRAIT(ear_owner, TRAIT_GOOD_HEARING, ORGAN_TRAIT)

/obj/item/organ/internal/ears/cybernetic/whisper/on_mob_remove(mob/living/carbon/ear_owner)
	. = ..()
	REMOVE_TRAIT(ear_owner, TRAIT_GOOD_HEARING, ORGAN_TRAIT)

// "X-ray ears" that let you hear through walls
/obj/item/organ/internal/ears/cybernetic/xray
	name = "wall-penetrating cybernetic ears"
	icon_state = "ears-c-u"
	desc = "Throguh the power of modern engineering, allows the user to hear speech through walls. The user becomes extra vulnerable to loud noises, however"
	// Same sensitivity as felinid ears
	damage_multiplier = 2

/obj/item/organ/internal/ears/cybernetic/xray/on_mob_insert(mob/living/carbon/ear_owner)
	. = ..()
	ADD_TRAIT(ear_owner, TRAIT_XRAY_HEARING, ORGAN_TRAIT)

/obj/item/organ/internal/ears/cybernetic/xray/on_mob_remove(mob/living/carbon/ear_owner)
	. = ..()
	REMOVE_TRAIT(ear_owner, TRAIT_XRAY_HEARING, ORGAN_TRAIT)

/obj/item/organ/internal/ears/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	apply_organ_damage(20 / severity)

// Overlay applied for the eccentric ear types
/datum/bodypart_overlay/mutant/ears
	layers = EXTERNAL_FRONT|EXTERNAL_BEHIND
	color_source = ORGAN_COLOR_HAIR
	feature_key = "ears"

/datum/bodypart_overlay/mutant/ears/get_global_feature_list()
	return SSaccessories.ears_list

/datum/bodypart_overlay/mutant/ears/can_draw_on_bodypart(mob/living/carbon/human/human)
	var/obj/item/bodypart/head/head = human.get_bodypart(BODY_ZONE_HEAD)
	if(isnull(head) || IS_ROBOTIC_LIMB(head))
		return FALSE
	for(var/obj/item/worn_item in human.get_equipped_items())
		if(worn_item.flags_inv & HIDEHAIR)
			return FALSE
	return TRUE

/datum/bodypart_overlay/mutant/ears/get_image(image_layer, obj/item/bodypart/limb)
	var/mutable_appearance/created = ..()
	var/mutable_appearance/inner = mutable_appearance(sprite_datum.icon, layer = image_layer, appearance_flags = RESET_COLOR)
	var/gender = (sprite_datum.gender_specific && limb?.limb_gender == FEMALE) ? "f" : "m"
	inner.icon_state = "[gender]_[feature_key]inner_[sprite_datum.icon_state]_[mutant_bodyparts_layertext(image_layer)]"

	if(sprite_datum.center)
		center_image(inner, sprite_datum.dimension_x, sprite_datum.dimension_y)

	created.underlays += inner
	return created

/datum/bodypart_overlay/mutant/ears/felinid
	dna_block = DNA_EARS_BLOCK

/datum/bodypart_overlay/mutant/ears/felinid/New()
	. = ..()
	set_appearance(/datum/sprite_accessory/ears/cat)

/datum/bodypart_overlay/mutant/ears/fox

/datum/bodypart_overlay/mutant/ears/fox/New()
	. = ..()
	set_appearance(/datum/sprite_accessory/ears/fox)
