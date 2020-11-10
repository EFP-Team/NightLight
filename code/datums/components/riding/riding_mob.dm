

/datum/component/riding/creature/Initialize(mob/living/riding_mob, force = FALSE, ride_check_flags = NONE, potion_boost = FALSE)
	. = ..()
	var/mob/living/parent_living = parent
	parent_living.stop_pulling() // was only used on humans previously, may change some other behavior
	riding_mob.set_glide_size(parent_living.glide_size)
	handle_vehicle_offsets(parent_living.dir)

	if(can_use_abilities)
		setup_abilities(riding_mob)

/datum/component/riding/creature/Destroy(force, silent)
	unequip_buckle_inhands(parent)
	return ..()

/datum/component/riding/creature/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_EMOTE, .proc/check_emote)

// this applies to humans and most creatures, but is replaced again for cyborgs
/datum/component/riding/creature/ride_check(mob/living/rider)
	var/mob/living/parent_living = parent

	if(parent_living.mobility_flags & ~MOBILITY_MOVE)
		return

	var/kick_us_off
	// no matter what, you can't ride something that's on the floor
	if(parent_living.body_position != STANDING_UP)
		kick_us_off = TRUE
	// for piggybacks and (redundant?) borg riding, check if the rider is stunned/restrained
	else if((ride_check_flags & RIDER_NEEDS_ARMS) && (HAS_TRAIT(rider, TRAIT_RESTRAINED) || rider.incapacitated(TRUE, TRUE)))
		kick_us_off = TRUE
	// for fireman carries, check if the ridden is stunned/restrained
	else if((ride_check_flags & CARRIER_NEEDS_ARM) && (HAS_TRAIT(parent_living, TRAIT_RESTRAINED) || parent_living.incapacitated(TRUE, TRUE)))
		kick_us_off = TRUE

	if(!kick_us_off)
		return TRUE

	rider.visible_message("<span class='warning'>[rider] falls off of [parent_living]!</span>", \
					"<span class='warning'>You fall off of [parent_living]!</span>")
	rider.Paralyze(1 SECONDS)
	rider.Knockdown(4 SECONDS)
	parent_living.unbuckle_mob(rider)

/// Yeets the rider off, used for animals and cyborgs, redefined for humans who shove their piggyback rider off
/datum/component/riding/proc/force_dismount(mob/living/rider, gentle = FALSE)
	var/atom/movable/parent_movable = parent
	parent_movable.unbuckle_mob(rider)

	if(!isanimal(parent_movable) && !iscyborg(parent_movable))
		return

	var/turf/target = get_edge_target_turf(parent_movable, parent_movable.dir)
	var/turf/targetm = get_step(get_turf(parent_movable), parent_movable.dir)
	rider.Move(targetm)
	rider.Knockdown(3 SECONDS)
	if(gentle)
		rider.visible_message("<span class='warning'>[rider] is thrown clear of [parent_movable]!</span>", \
		"<span class='warning'>You're thrown clear of [parent_movable]!</span>")
		rider.throw_at(target, 8, 3, parent_movable, gentle = TRUE)
	else
		rider.visible_message("<span class='warning'>[rider] is thrown violently from [parent_movable]!</span>", \
		"<span class='warning'>You're thrown violently from [parent_movable]!</span>")
		rider.throw_at(target, 14, 5, parent_movable, gentle = FALSE)

/// If we're a cyborg or animal and we spin, we yeet whoever's on us off us
/datum/component/riding/proc/check_emote(mob/living/user, datum/emote/emote)
	if((!iscyborg(user) && !isanimal(user)) || !istype(emote, /datum/emote/spin))
		return

	for(var/mob/yeet_mob in user.buckled_mobs)
		force_dismount(yeet_mob, (user.a_intent == INTENT_HELP)) // gentle on help, byeeee if not

///////Yes, I said humans. No, this won't end well...//////////
/datum/component/riding/creature/human/Initialize(mob/living/riding_mob, force = FALSE, ride_check_flags = NONE, potion_boost = FALSE)
	. = ..()
	var/mob/living/carbon/human/human_parent = parent
	human_parent.add_movespeed_modifier(/datum/movespeed_modifier/human_carry)

	if(ride_check_flags & RIDER_NEEDS_ARMS) // piggyback
		human_parent.buckle_lying = 0
	else if(ride_check_flags & CARRIER_NEEDS_ARM) // fireman
		human_parent.buckle_lying = 90

/datum/component/riding/creature/human/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/on_host_unarmed_melee)

/datum/component/riding/creature/human/vehicle_mob_unbuckle(datum/source, mob/living/M, force = FALSE)
	unequip_buckle_inhands(parent)
	var/mob/living/carbon/human/H = parent
	H.remove_movespeed_modifier(/datum/movespeed_modifier/human_carry)
	return ..()

/// If the carrier gets shoved, drop our load
/datum/component/riding/creature/human/proc/on_host_unarmed_melee(mob/living/carbon/human/human_parent, atom/target)
	SIGNAL_HANDLER

	if(human_parent.a_intent == INTENT_DISARM && (target in human_parent.buckled_mobs))
		force_dismount(target)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/riding/creature/human/handle_vehicle_layer(dir)
	var/atom/movable/AM = parent
	if(!AM.buckled_mobs || !AM.buckled_mobs.len)
		AM.layer = MOB_LAYER
		return

	for(var/mob/M in AM.buckled_mobs) //ensure proper layering of piggyback and carry, sometimes weird offsets get applied
		M.layer = MOB_LAYER

	if(!AM.buckle_lying) // rider is vertical, must be piggybacking
		if(dir == SOUTH)
			AM.layer = ABOVE_MOB_LAYER
		else
			AM.layer = OBJ_LAYER
	else  // laying flat, we must be firemanning the rider
		if(dir == NORTH)
			AM.layer = OBJ_LAYER
		else
			AM.layer = ABOVE_MOB_LAYER

/datum/component/riding/creature/human/get_offsets(pass_index)
	var/mob/living/carbon/human/H = parent
	if(H.buckle_lying)
		return list(TEXT_NORTH = list(0, 6), TEXT_SOUTH = list(0, 6), TEXT_EAST = list(0, 6), TEXT_WEST = list(0, 6))
	else
		return list(TEXT_NORTH = list(0, 6), TEXT_SOUTH = list(0, 6), TEXT_EAST = list(-6, 4), TEXT_WEST = list( 6, 4))

/datum/component/riding/creature/human/force_dismount(mob/living/user)
	var/atom/movable/AM = parent
	AM.unbuckle_mob(user)
	user.Paralyze(1 SECONDS)
	user.Knockdown(4 SECONDS)
	user.visible_message("<span class='warning'>[AM] pushes [user] off of [AM.p_them()]!</span>", \
						"<span class='warning'>[AM] pushes you off of [AM.p_them()]!</span>")


//Now onto cyborg riding//
/datum/component/riding/creature/cyborg/ride_check(mob/living/user)
	var/mob/living/silicon/robot/robot_parent = parent
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbonuser = user
	if(!carbonuser.usable_hands)
		Unbuckle(user)
		to_chat(user, "<span class='warning'>You can't grab onto [robot_parent] with no hands!</span>")

/datum/component/riding/creature/cyborg/handle_vehicle_layer(dir)
	var/atom/movable/AM = parent
	if(AM.buckled_mobs && AM.buckled_mobs?.len)
		if(dir == SOUTH)
			AM.layer = ABOVE_MOB_LAYER
		else
			AM.layer = OBJ_LAYER
	else
		AM.layer = MOB_LAYER

/datum/component/riding/creature/cyborg/get_offsets(pass_index) // list(dir = x, y, layer)
	return list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(-6, 3), TEXT_WEST = list( 6, 3))

/datum/component/riding/creature/cyborg/handle_vehicle_offsets(dir)
	var/atom/movable/AM = parent
	if(AM.has_buckled_mobs())
		for(var/mob/living/M in AM.buckled_mobs)
			M.setDir(dir)
			if(iscyborg(AM))
				var/mob/living/silicon/robot/R = AM
				if(istype(R.module))
					M.pixel_x = R.module.ride_offset_x[dir2text(dir)]
					M.pixel_y = R.module.ride_offset_y[dir2text(dir)]
			else
				..()


//now onto every other ridable mob//

/datum/component/riding/creature/mulebot/handle_specials()
	. = ..()
	var/atom/movable/parent_movable = parent
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 12), TEXT_SOUTH = list(0, 12), TEXT_EAST = list(0, 12), TEXT_WEST = list(0, 12)))
	set_vehicle_dir_layer(SOUTH, parent_movable.layer) //vehicles default to ABOVE_MOB_LAYER while moving, let's make sure that doesn't happen while a mob is riding us.
	set_vehicle_dir_layer(NORTH, parent_movable.layer)
	set_vehicle_dir_layer(EAST, parent_movable.layer)
	set_vehicle_dir_layer(WEST, parent_movable.layer)


/datum/component/riding/creature/cow/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 8), TEXT_SOUTH = list(0, 8), TEXT_EAST = list(-2, 8), TEXT_WEST = list(2, 8)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)


/datum/component/riding/creature/bear/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(1, 8), TEXT_SOUTH = list(1, 8), TEXT_EAST = list(-3, 6), TEXT_WEST = list(3, 6)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(WEST, ABOVE_MOB_LAYER)


/datum/component/riding/creature/carp
	override_allow_spacemove = TRUE

/datum/component/riding/creature/carp/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 13), TEXT_SOUTH = list(0, 15), TEXT_EAST = list(-2, 12), TEXT_WEST = list(2, 12)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)


/datum/component/riding/creature/megacarp/handle_specials()
	. = ..()
	var/atom/movable/parent_movable = parent
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(1, 8), TEXT_SOUTH = list(1, 8), TEXT_EAST = list(-3, 6), TEXT_WEST = list(3, 6)))
	set_vehicle_dir_offsets(SOUTH, parent_movable.pixel_x, 0)
	set_vehicle_dir_offsets(NORTH, parent_movable.pixel_x, 0)
	set_vehicle_dir_offsets(EAST, parent_movable.pixel_x, 0)
	set_vehicle_dir_offsets(WEST, parent_movable.pixel_x, 0)
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/creature/vatbeast
	override_allow_spacemove = TRUE
	can_use_abilities = TRUE

/datum/component/riding/creature/vatbeast/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 15), TEXT_SOUTH = list(0, 15), TEXT_EAST = list(-10, 15), TEXT_WEST = list(10, 15)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/creature/goliath
	keytype = /obj/item/key/lasso

/datum/component/riding/creature/goliath/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 8), TEXT_SOUTH = list(0, 8), TEXT_EAST = list(-2, 8), TEXT_WEST = list(2, 8)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)
