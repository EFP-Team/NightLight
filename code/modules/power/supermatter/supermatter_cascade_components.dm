/obj/crystal_mass
	name = "crystal mass"
	desc = "You see this massive crystal mass looming towards you, cracking and screeching at every seemingly random movement."
	icon = 'icons/turf/walls.dmi'
	icon_state = "crystal_cascade_1"
	layer = AREA_LAYER
	plane = ABOVE_LIGHTING_PLANE
	opacity = FALSE
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_power = 1
	light_range = 7
	light_color = COLOR_VIVID_YELLOW
	move_resist = INFINITY
	///All dirs we can expand to
	var/list/available_dirs = list(NORTH,SOUTH,EAST,WEST,UP,DOWN)
	///Cooldown on the expansion process
	COOLDOWN_DECLARE(sm_wall_cooldown)

/obj/crystal_mass/Initialize(mapload, dir_to_remove)
	. = ..()
	icon_state = "crystal_cascade_[rand(1,6)]"
	START_PROCESSING(SSsupermatter_cascade, src)

	AddComponent(/datum/component/supermatter_crystal, null, null)

	playsound(src, 'sound/misc/cracking_crystal.ogg', 45, TRUE)

	available_dirs -= dir_to_remove

	var/turf/our_turf = get_turf(src)

	if(our_turf)
		our_turf.opacity = FALSE

/obj/crystal_mass/process()

	if(!COOLDOWN_FINISHED(src, sm_wall_cooldown))
		return

	if(!available_dirs || available_dirs.len <= 0)
		light_range = 0
		return PROCESS_KILL

	COOLDOWN_START(src, sm_wall_cooldown, rand(0, 3 SECONDS))

	var/picked_dir = pick_n_take(available_dirs)
	var/turf/next_turf = get_step_multiz(src, picked_dir)

	icon_state = "crystal_cascade_[rand(1,6)]"

	if(!next_turf || locate(/obj/crystal_mass) in next_turf)
		return

	var/datum/component/supermatter_crystal/sm = GetComponent(/datum/component/supermatter_crystal)
	for(var/atom/movable/checked_atom as anything in next_turf)
		if(isliving(checked_atom))
			sm.dust_mob(src, checked_atom, span_danger("\The [src] lunges out on [checked_atom], touching [checked_atom.p_them()]... \
					[checked_atom.p_their()] body begins to shine with a brilliant light before crystallizing from the inside out and joining \the [src]!"),
				span_userdanger("The crystal mass lunges on you and hits you in the chest. As your vision is filled with a blinding light, you think to yourself \"Damn it.\""))
		else if(istype(checked_atom, /obj/cascade_portal))
			checked_atom.visible_message(span_userdanger("\The [checked_atom] screeches and closes away as it is hit by \a [src]! Too late!"))
			playsound(get_turf(checked_atom), 'sound/magic/charge.ogg', 50, TRUE)
			playsound(get_turf(checked_atom), 'sound/effects/supermatter.ogg', 50, TRUE)
			qdel(checked_atom)
		else if(isitem(checked_atom))
			playsound(get_turf(checked_atom), 'sound/effects/supermatter.ogg', 50, TRUE)
			qdel(checked_atom)

	new /obj/crystal_mass(next_turf, get_dir(next_turf, src))

/obj/crystal_mass/bullet_act(obj/projectile/projectile)
	visible_message(span_notice("[src] is unscathed!"))
	return BULLET_ACT_HIT

/obj/crystal_mass/singularity_act()
	return

/obj/crystal_mass/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("That was a really dense idea."))
	jedi.ghostize()
	var/obj/item/organ/internal/brain/rip_u = locate(/obj/item/organ/internal/brain) in jedi.internal_organs
	if(rip_u)
		rip_u.Remove(jedi)
		qdel(rip_u)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/cascade_portal
	name = "Bluespace Rift"
	desc = "Your mind begins to spin as it tries to comprehend what it sees."
	icon = 'icons/effects/224x224.dmi'
	icon_state = "reality"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	density = TRUE
	plane = MASSIVE_OBJ_PLANE
	light_color = COLOR_RED
	light_power = 0.7
	light_range = 15
	move_resist = INFINITY
	pixel_x = -96
	pixel_y = -96
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/cascade_portal/Bumped(atom/movable/hit_object)
	if(isliving(hit_object))
		hit_object.visible_message(span_danger("\The [hit_object] walks into \the [src]... \
			A blinding light covers [hit_object.p_their()] body before disappearing completely!"),
			span_userdanger("You walk into \the [src] as your body is washed with a powerful blue light. \
				You contemplate about this decision before landing face first onto the cold, hard floor."),
			span_hear("You hear a loud crack as a distortion passes through you."))
	else if(isobj(hit_object) && !iseffect(hit_object))
		hit_object.visible_message(span_danger("\The [hit_object] smacks into \the [src] and disappears out of sight."), null,
			span_hear("You hear a loud crack as a small distortion passes through you."))
	else
		return

	consume(hit_object)

	new /obj/effect/particle_effect/sparks(loc)
	playsound(loc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/cascade_portal/Destroy(force)
	. = ..()

/**
 * Proc to consume the objects colliding with the portal
 *
 * Arguments: atom/movable/consumed_object is the object hitting the portal
 */
/obj/cascade_portal/proc/consume(atom/movable/consumed_object)
	if(isliving(consumed_object))
		var/list/arrival_turfs = get_area_turfs(/area/centcom/central_command_areas/evacuation)
		var/turf/arrival_turf
		do
			arrival_turf = pick(arrival_turfs)
		while(!is_safe_turf(arrival_turf))
		var/mob/living/consumed_mob = consumed_object
		message_admins("[key_name_admin(consumed_mob)] has entered [src] [ADMIN_JMP(src)].")
		investigate_log("was entered by [key_name(consumed_mob)].", INVESTIGATE_ENGINE)
		consumed_mob.forceMove(arrival_turf)
		consumed_mob.Paralyze(100)
		consumed_mob.adjustBruteLoss(30)
		consumed_mob.flash_act(1, TRUE, TRUE)
		new /obj/effect/particle_effect/sparks(consumed_object)
		playsound(consumed_object, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	else if(isobj(consumed_object))
		qdel(consumed_object)
