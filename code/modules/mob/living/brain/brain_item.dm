/obj/item/organ/internal/brain
	name = "brain"
	desc = "A piece of juicy meat found in a person's head."
	icon_state = "brain"
	visual = TRUE
	throw_speed = 3
	throw_range = 5
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_BRAIN
	organ_flags = ORGAN_VITAL
	attack_verb_continuous = list("attacks", "slaps", "whacks")
	attack_verb_simple = list("attack", "slap", "whack")

	///The brain's organ variables are significantly more different than the other organs, with half the decay rate for balance reasons, and twice the maxHealth
	decay_factor = STANDARD_ORGAN_DECAY * 0.5 //30 minutes of decaying to result in a fully damaged brain, since a fast decay rate would be unfun gameplay-wise

	maxHealth = BRAIN_DAMAGE_DEATH
	low_threshold = 45
	high_threshold = 120

	organ_traits = list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE, TRAIT_CAN_STRIP)

	var/suicided = FALSE
	var/mob/living/brain/brainmob = null
	/// If it's a fake brain with no brainmob assigned. Feedback messages will be faked as if it does have a brainmob. See changelings & dullahans.
	var/decoy_override = FALSE
	/// Two variables necessary for calculating whether we get a brain trauma or not
	var/damage_delta = 0


	var/list/datum/brain_trauma/traumas = list()

	/// List of skillchip items, their location should be this brain.
	var/list/obj/item/skillchip/skillchips
	/// Maximum skillchip complexity we can support before they stop working. Do not reference this var directly and instead call get_max_skillchip_complexity()
	var/max_skillchip_complexity = 3
	/// Maximum skillchip slots available. Do not reference this var directly and instead call get_max_skillchip_slots()
	var/max_skillchip_slots = 5

/obj/item/organ/internal/brain/Insert(mob/living/carbon/brain_owner, special = FALSE, drop_if_replaced = TRUE, no_id_transfer = FALSE)
	. = ..()
	if(!.)
		return

	name = initial(name)

	// Special check for if you're trapped in a body you can't control because it's owned by a ling.
	if(brain_owner?.mind?.has_antag_datum(/datum/antagonist/changeling) && !no_id_transfer)
		if(brainmob && !(brain_owner.stat == DEAD || (HAS_TRAIT(brain_owner, TRAIT_DEATHCOMA))))
			to_chat(brainmob, span_danger("You can't feel your body! You're still just a brain!"))
		forceMove(brain_owner)
		brain_owner.update_body_parts()
		return

	// Not a ling? Now you get to assume direct control.
	if(brainmob)
		if(brain_owner.key)
			brain_owner.ghostize()

		if(brainmob.mind)
			brainmob.mind.transfer_to(brain_owner)
		else
			brain_owner.key = brainmob.key

		brain_owner.set_suicide(HAS_TRAIT(brainmob, TRAIT_SUICIDED))

		QDEL_NULL(brainmob)
	else
		brain_owner.set_suicide(suicided)

	for(var/datum/brain_trauma/trauma as anything in traumas)
		if(trauma.owner)
			if(trauma.owner == brain_owner)
				// if we're being special replaced, the trauma is already applied, so this is expected
				// but if we're not... this is likely a bug, and should be reported
				if(!special)
					stack_trace("A brain trauma ([trauma]) is being re-applied to its owning mob ([brain_owner])!")
				continue

			stack_trace("A brain trauma ([trauma]) is being applied to a new mob ([brain_owner]) when it's owned by someone else ([trauma.owner])!")
			continue

		trauma.owner = brain_owner
		trauma.on_gain()

	//Update the body's icon so it doesnt appear debrained anymore
	brain_owner.update_body_parts()

/obj/item/organ/internal/brain/on_insert(mob/living/carbon/organ_owner, special)
	// Are we inserting into a new mob from a head?
	// If yes, we want to quickly steal the brainmob from the head before we do anything else.
	// This is usually stuff like reattaching dismembered/amputated heads.
	if(istype(loc, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/brain_holder = loc
		if(brain_holder.brainmob)
			brainmob = brain_holder.brainmob
			brain_holder.brainmob = null
			brainmob.container = null
			brainmob.forceMove(src)

	return ..()

/obj/item/organ/internal/brain/Remove(mob/living/carbon/brain_owner, special = 0, no_id_transfer = FALSE)
	// Delete skillchips first as parent proc sets owner to null, and skillchips need to know the brain's owner.
	if(!QDELETED(brain_owner) && length(skillchips))
		if(!special)
			to_chat(brain_owner, span_notice("You feel your skillchips enable emergency power saving mode, deactivating as your brain leaves your body..."))
		for(var/chip in skillchips)
			var/obj/item/skillchip/skillchip = chip
			// Run the try_ proc with force = TRUE.
			skillchip.try_deactivate_skillchip(silent = special, force = TRUE)

	. = ..()

	for(var/X in traumas)
		var/datum/brain_trauma/BT = X
		BT.on_lose(TRUE)
		BT.owner = null

	if((!gc_destroyed || (owner && !owner.gc_destroyed)) && !no_id_transfer)
		transfer_identity(brain_owner)
	brain_owner.update_body_parts()
	brain_owner.clear_mood_event("brain_damage")

/obj/item/organ/internal/brain/proc/transfer_identity(mob/living/L)
	name = "[L.name]'s [initial(name)]"
	if(brainmob || decoy_override)
		return
	if(!L.mind)
		return
	brainmob = new(src)
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	brainmob.timeofhostdeath = L.timeofdeath

	if(suicided)
		ADD_TRAIT(brainmob, TRAIT_SUICIDED, REF(src))

	if(L.has_dna())
		var/mob/living/carbon/C = L
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
		if(HAS_TRAIT(L, TRAIT_BADDNA))
			LAZYSET(brainmob.status_traits, TRAIT_BADDNA, L.status_traits[TRAIT_BADDNA])
	if(L.mind && L.mind.current)
		L.mind.transfer_to(brainmob)
	to_chat(brainmob, span_notice("You feel slightly disoriented. That's normal when you're just a brain."))

/obj/item/organ/internal/brain/attackby(obj/item/O, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)

	if(istype(O, /obj/item/borg/apparatus/organ_storage))
		return //Borg organ bags shouldn't be killing brains

	if(damage && O.is_drainable() && O.reagents.has_reagent(/datum/reagent/medicine/mannitol)) //attempt to heal the brain
		. = TRUE //don't do attack animation.
		if(brainmob?.health <= HEALTH_THRESHOLD_DEAD) //if the brain is fucked anyway, do nothing
			to_chat(user, span_warning("[src] is far too damaged, there's nothing else we can do for it!"))
			return

		user.visible_message(span_notice("[user] starts to slowly pour the contents of [O] onto [src]."), span_notice("You start to slowly pour the contents of [O] onto [src]."))
		if(!do_after(user, 3 SECONDS, src))
			to_chat(user, span_warning("You failed to pour the contents of [O] onto [src]!"))
			return

		user.visible_message(span_notice("[user] pours the contents of [O] onto [src], causing it to reform its original shape and turn a slightly brighter shade of pink."), span_notice("You pour the contents of [O] onto [src], causing it to reform its original shape and turn a slightly brighter shade of pink."))
		var/amount = O.reagents.get_reagent_amount(/datum/reagent/medicine/mannitol)
		var/healto = max(0, damage - amount * 2)
		O.reagents.remove_all(ROUND_UP(O.reagents.total_volume / amount * (damage - healto) * 0.5)) //only removes however much solution is needed while also taking into account how much of the solution is mannitol
		set_organ_damage(healto) //heals 2 damage per unit of mannitol, and by using "set_organ_damage", we clear the failing variable if that was up
		return

	// Cutting out skill chips.
	if(length(skillchips) && O.get_sharpness() == SHARP_EDGED)
		to_chat(user,span_notice("You begin to excise skillchips from [src]."))
		if(do_after(user, 15 SECONDS, target = src))
			for(var/chip in skillchips)
				var/obj/item/skillchip/skillchip = chip

				if(!istype(skillchip))
					stack_trace("Item of type [skillchip.type] qdel'd from [src] skillchip list.")
					qdel(skillchip)
					continue

				remove_skillchip(skillchip)

				if(skillchip.removable)
					skillchip.forceMove(drop_location())
					continue

				qdel(skillchip)

			skillchips = null
		return

	if(brainmob) //if we aren't trying to heal the brain, pass the attack onto the brainmob.
		O.attack(brainmob, user) //Oh noooeeeee

	if(O.force != 0 && !(O.item_flags & NOBLUDGEON))
		user.do_attack_animation(src)
		playsound(loc, 'sound/effects/meatslap.ogg', 50)
		set_organ_damage(maxHealth) //fails the brain as the brain was attacked, they're pretty fragile.
		visible_message(span_danger("[user] hits [src] with [O]!"))
		to_chat(user, span_danger("You hit [src] with [O]!"))

/obj/item/organ/internal/brain/examine(mob/user)
	. = ..()
	if(length(skillchips))
		. += span_info("It has a skillchip embedded in it.")
	if(suicided)
		. += span_info("It's started turning slightly grey. They must not have been able to handle the stress of it all.")
		return
	if((brainmob && (brainmob.client || brainmob.get_ghost())) || decoy_override)
		if(organ_flags & ORGAN_FAILING)
			. += span_info("It seems to still have a bit of energy within it, but it's rather damaged... You may be able to restore it with some <b>mannitol</b>.")
		else if(damage >= BRAIN_DAMAGE_DEATH*0.5)
			. += span_info("You can feel the small spark of life still left in this one, but it's got some bruises. You may be able to restore it with some <b>mannitol</b>.")
		else
			. += span_info("You can feel the small spark of life still left in this one.")
	else
		. += span_info("This one is completely devoid of life.")

/obj/item/organ/internal/brain/attack(mob/living/carbon/C, mob/user)
	if(!istype(C))
		return ..()

	add_fingerprint(user)

	if(user.zone_selected != BODY_ZONE_HEAD)
		return ..()

	var/target_has_brain = C.get_organ_by_type(/obj/item/organ/internal/brain)

	if(!target_has_brain && C.is_eyes_covered())
		to_chat(user, span_warning("You're going to need to remove [C.p_their()] head cover first!"))
		return

	//since these people will be dead M != usr

	if(!target_has_brain)
		if(!C.get_bodypart(BODY_ZONE_HEAD) || !user.temporarilyRemoveItemFromInventory(src))
			return
		var/msg = "[C] has [src] inserted into [C.p_their()] head by [user]."
		if(C == user)
			msg = "[user] inserts [src] into [user.p_their()] head!"

		C.visible_message(span_danger("[msg]"),
						span_userdanger("[msg]"))

		if(C != user)
			to_chat(C, span_notice("[user] inserts [src] into your head."))
			to_chat(user, span_notice("You insert [src] into [C]'s head."))
		else
			to_chat(user, span_notice("You insert [src] into your head.") )

		Insert(C)
	else
		..()

/obj/item/organ/internal/brain/Destroy() //copypasted from MMIs.
	if(brainmob)
		QDEL_NULL(brainmob)
	QDEL_LIST(traumas)

	destroy_all_skillchips()
	if(owner?.mind) //You aren't allowed to return to brains that don't exist
		owner.mind.set_current(null)
	return ..()

/obj/item/organ/internal/brain/on_life(delta_time, times_fired)
	if(damage >= BRAIN_DAMAGE_DEATH) //rip
		to_chat(owner, span_userdanger("The last spark of life in your brain fizzles out..."))
		owner.investigate_log("has been killed by brain damage.", INVESTIGATE_DEATHS)
		owner.death()

/obj/item/organ/internal/brain/check_damage_thresholds(mob/M)
	. = ..()
	//if we're not more injured than before, return without gambling for a trauma
	if(damage <= prev_damage)
		return
	damage_delta = damage - prev_damage
	if(damage > BRAIN_DAMAGE_MILD)
		if(prob(damage_delta * (1 + max(0, (damage - BRAIN_DAMAGE_MILD)/100)))) //Base chance is the hit damage; for every point of damage past the threshold the chance is increased by 1% //learn how to do your bloody math properly goddamnit
			gain_trauma_type(BRAIN_TRAUMA_MILD, natural_gain = TRUE)

	var/is_boosted = (owner && HAS_TRAIT(owner, TRAIT_SPECIAL_TRAUMA_BOOST))
	if(damage > BRAIN_DAMAGE_SEVERE)
		if(prob(damage_delta * (1 + max(0, (damage - BRAIN_DAMAGE_SEVERE)/100)))) //Base chance is the hit damage; for every point of damage past the threshold the chance is increased by 1%
			if(prob(20 + (is_boosted * 30)))
				gain_trauma_type(BRAIN_TRAUMA_SPECIAL, is_boosted ? TRAUMA_RESILIENCE_SURGERY : null, natural_gain = TRUE)
			else
				gain_trauma_type(BRAIN_TRAUMA_SEVERE, natural_gain = TRUE)

	if (owner)
		if(owner.stat < UNCONSCIOUS) //conscious or soft-crit
			var/brain_message
			if(prev_damage < BRAIN_DAMAGE_MILD && damage >= BRAIN_DAMAGE_MILD)
				brain_message = span_warning("You feel lightheaded.")
			else if(prev_damage < BRAIN_DAMAGE_SEVERE && damage >= BRAIN_DAMAGE_SEVERE)
				brain_message = span_warning("You feel less in control of your thoughts.")
			else if(prev_damage < (BRAIN_DAMAGE_DEATH - 20) && damage >= (BRAIN_DAMAGE_DEATH - 20))
				brain_message = span_warning("You can feel your mind flickering on and off...")

			if(.)
				. += "\n[brain_message]"
			else
				return brain_message

/obj/item/organ/internal/brain/before_organ_replacement(obj/item/organ/replacement)
	. = ..()
	var/obj/item/organ/internal/brain/replacement_brain = replacement
	if(!istype(replacement_brain))
		return

	// Transfer over skillcips to the new brain

	// If we have some sort of brain type or subtype change and have skillchips, engage the failsafe procedure!
	if(owner && length(skillchips) && (replacement_brain.type != type))
		activate_skillchip_failsafe(silent = TRUE)

	// Check through all our skillchips, remove them from this brain, add them to the replacement brain.
	for(var/chip in skillchips)
		var/obj/item/skillchip/skillchip = chip

		// We're technically doing a little hackery here by bypassing the procs, but I'm the one who wrote them
		// and when you know the rules, you can break the rules.

		// Technically the owning mob is the same. We don't need to activate or deactivate the skillchips.
		// All the skillchips themselves care about is what brain they're in.
		// Because the new brain will ultimately be owned by the same body, we can safely leave skillchip logic alone.

		// Directly change the new holding_brain.
		skillchip.holding_brain = replacement_brain
		//And move the actual obj into the new brain (contents)
		skillchip.forceMove(replacement_brain)

		// Directly add them to the skillchip list in the new brain.
		LAZYADD(replacement_brain.skillchips, skillchip)

	// Any skillchips has been transferred over, time to empty the list.
	LAZYCLEARLIST(skillchips)

	// Transfer over traumas as well
	for(var/datum/brain_trauma/trauma as anything in traumas)
		remove_trauma_from_traumas(trauma)
		replacement_brain.add_trauma_to_traumas(trauma)

/obj/item/organ/internal/brain/machine_wash(obj/machinery/washing_machine/brainwasher)
	. = ..()
	if(HAS_TRAIT(brainwasher, TRAIT_BRAINWASHING))
		set_organ_damage(0)
		cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)
	else
		set_organ_damage(BRAIN_DAMAGE_DEATH)

/obj/item/organ/internal/brain/zombie
	name = "zombie brain"
	desc = "This glob of green mass can't have much intelligence inside it."
	icon_state = "brain-x"
	organ_traits = list(TRAIT_CAN_STRIP, TRAIT_PRIMITIVE)

/obj/item/organ/internal/brain/alien
	name = "alien brain"
	desc = "We barely understand the brains of terrestial animals. Who knows what we may find in the brain of such an advanced species?"
	icon_state = "brain-x"
	organ_traits = list(TRAIT_CAN_STRIP)

/obj/item/organ/internal/brain/primitive //No like books and stompy metal men
	name = "primitive brain"
	desc = "This juicy piece of meat has a clearly underdeveloped frontal lobe."
	organ_traits = list(TRAIT_ADVANCEDTOOLUSER, TRAIT_CAN_STRIP, TRAIT_PRIMITIVE) // No literacy

/obj/item/organ/internal/brain/golem
	name = "crystalline matrix"
	desc = "This collection of sparkling gems somehow allows a golem to think."
	icon_state = "adamantine_resonator"
	color = COLOR_GOLEM_GRAY
	status = ORGAN_MINERAL
	organ_traits = list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE, TRAIT_CAN_STRIP, TRAIT_ROCK_METAMORPHIC)

////////////////////////////////////TRAUMAS////////////////////////////////////////

/obj/item/organ/internal/brain/proc/has_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
	for(var/X in traumas)
		var/datum/brain_trauma/BT = X
		if(istype(BT, brain_trauma_type) && (BT.resilience <= resilience))
			return BT

/obj/item/organ/internal/brain/proc/get_traumas_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
	. = list()
	for(var/X in traumas)
		var/datum/brain_trauma/BT = X
		if(istype(BT, brain_trauma_type) && (BT.resilience <= resilience))
			. += BT

/obj/item/organ/internal/brain/proc/can_gain_trauma(datum/brain_trauma/trauma, resilience, natural_gain = FALSE)
	if(!ispath(trauma))
		trauma = trauma.type
	if(!initial(trauma.can_gain))
		return FALSE
	if(!resilience)
		resilience = initial(trauma.resilience)

	var/resilience_tier_count = 0
	for(var/X in traumas)
		if(istype(X, trauma))
			return FALSE
		var/datum/brain_trauma/T = X
		if(resilience == T.resilience)
			resilience_tier_count++

	var/max_traumas
	switch(resilience)
		if(TRAUMA_RESILIENCE_BASIC)
			max_traumas = TRAUMA_LIMIT_BASIC
		if(TRAUMA_RESILIENCE_SURGERY)
			max_traumas = TRAUMA_LIMIT_SURGERY
		if(TRAUMA_RESILIENCE_WOUND)
			max_traumas = TRAUMA_LIMIT_WOUND
		if(TRAUMA_RESILIENCE_LOBOTOMY)
			max_traumas = TRAUMA_LIMIT_LOBOTOMY
		if(TRAUMA_RESILIENCE_MAGIC)
			max_traumas = TRAUMA_LIMIT_MAGIC
		if(TRAUMA_RESILIENCE_ABSOLUTE)
			max_traumas = TRAUMA_LIMIT_ABSOLUTE

	if(natural_gain && resilience_tier_count >= max_traumas)
		return FALSE
	return TRUE

//Proc to use when directly adding a trauma to the brain, so extra args can be given
/obj/item/organ/internal/brain/proc/gain_trauma(datum/brain_trauma/trauma, resilience, ...)
	var/list/arguments = list()
	if(args.len > 2)
		arguments = args.Copy(3)
	. = brain_gain_trauma(trauma, resilience, arguments)

//Direct trauma gaining proc. Necessary to assign a trauma to its brain. Avoid using directly.
/obj/item/organ/internal/brain/proc/brain_gain_trauma(datum/brain_trauma/trauma, resilience, list/arguments)
	if(!can_gain_trauma(trauma, resilience))
		return FALSE

	var/datum/brain_trauma/actual_trauma
	if(ispath(trauma))
		if(!LAZYLEN(arguments))
			actual_trauma = new trauma() //arglist with an empty list runtimes for some reason
		else
			actual_trauma = new trauma(arglist(arguments))
	else
		actual_trauma = trauma

	if(actual_trauma.brain) //we don't accept used traumas here
		WARNING("gain_trauma was given an already active trauma.")
		return FALSE

	add_trauma_to_traumas(actual_trauma)
	if(owner)
		actual_trauma.owner = owner
		SEND_SIGNAL(owner, COMSIG_CARBON_GAIN_TRAUMA, trauma)
		actual_trauma.on_gain()
	if(resilience)
		actual_trauma.resilience = resilience
	SSblackbox.record_feedback("tally", "traumas", 1, actual_trauma.type)
	return actual_trauma

/// Adds the passed trauma instance to our list of traumas and links it to our brain.
/// DOES NOT handle setting up the trauma, that's done by [proc/brain_gain_trauma]!
/obj/item/organ/internal/brain/proc/add_trauma_to_traumas(datum/brain_trauma/trauma)
	trauma.brain = src
	traumas += trauma

/// Removes the passed trauma instance to our list of traumas and links it to our brain
/// DOES NOT handle removing the trauma's effects, that's done by [/datum/brain_trauma/Destroy()]!
/obj/item/organ/internal/brain/proc/remove_trauma_from_traumas(datum/brain_trauma/trauma)
	trauma.brain = null
	traumas -= trauma

//Add a random trauma of a certain subtype
/obj/item/organ/internal/brain/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience, natural_gain = FALSE)
	var/list/datum/brain_trauma/possible_traumas = list()
	for(var/T in subtypesof(brain_trauma_type))
		var/datum/brain_trauma/BT = T
		if(can_gain_trauma(BT, resilience, natural_gain) && initial(BT.random_gain))
			possible_traumas += BT

	if(!LAZYLEN(possible_traumas))
		return

	var/trauma_type = pick(possible_traumas)
	return gain_trauma(trauma_type, resilience)

//Cure a random trauma of a certain resilience level
/obj/item/organ/internal/brain/proc/cure_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_BASIC)
	var/list/traumas = get_traumas_type(brain_trauma_type, resilience)
	if(LAZYLEN(traumas))
		qdel(pick(traumas))

/obj/item/organ/internal/brain/proc/cure_all_traumas(resilience = TRAUMA_RESILIENCE_BASIC)
	var/amount_cured = 0
	var/list/traumas = get_traumas_type(resilience = resilience)
	for(var/X in traumas)
		qdel(X)
		amount_cured++
	return amount_cured

/obj/item/organ/internal/brain/apply_organ_damage(damage_amount, maximum, required_organtype)
	. = ..()
	if(!owner)
		return
	if(damage >= 60)
		owner.add_mood_event("brain_damage", /datum/mood_event/brain_damage)
	else
		owner.clear_mood_event("brain_damage")

/// This proc lets the mob's brain decide what bodypart to attack with in an unarmed strike.
/obj/item/organ/internal/brain/proc/get_attacking_limb(mob/living/carbon/human/target)
	var/obj/item/bodypart/arm/active_hand = owner.get_active_hand()
	if(target.body_position == LYING_DOWN && owner.usable_legs)
		var/obj/item/bodypart/found_bodypart = owner.get_bodypart((active_hand.held_index % 2) ? BODY_ZONE_L_LEG : BODY_ZONE_R_LEG)
		return found_bodypart || active_hand
	return active_hand

/// Brains REALLY like ghosting people. we need special tricks to avoid that, namely removing the old brain with no_id_transfer
/obj/item/organ/internal/brain/replace_into(mob/living/carbon/new_owner)
	var/obj/item/organ/internal/brain/old_brain = new_owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	old_brain.Remove(new_owner, special = TRUE, no_id_transfer = TRUE)
	qdel(old_brain)
	Insert(new_owner, special = TRUE, drop_if_replaced = FALSE, no_id_transfer = TRUE)
