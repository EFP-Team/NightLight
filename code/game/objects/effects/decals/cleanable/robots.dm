// Note: BYOND is object oriented. There is no reason for this to be copy/pasted blood code.

/obj/effect/decal/cleanable/robot_debris
	name = "robot debris"
	desc = "It's a useless heap of junk... <i>or is it?</i>"
	icon = 'icons/mob/robots.dmi'
	icon_state = "gib1"
	layer = LOW_OBJ_LAYER
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7")
	blood_state = BLOOD_STATE_OIL
	bloodiness = MAX_SHOE_BLOODINESS
	mergeable_decal = 0

/obj/effect/decal/cleanable/robot_debris/proc/streak(list/directions)
	set waitfor = 0
	var/direction = SSrng.pick_from_list(directions)
	for (var/i = 0, i < text2num(pickweight(list("1" = 4, "2" = 3, "3" = 1))), i++)
		sleep(2)
		if (i > 0)
			if (SSrng.probability(40))
				new /obj/effect/decal/cleanable/oil/streak(src.loc)
			else if (SSrng.probability(10))
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(3, 1, src)
				s.start()
		if (!step_to(src, get_step(src, direction), 0))
			break

/obj/effect/decal/cleanable/robot_debris/ex_act()
	return

/obj/effect/decal/cleanable/robot_debris/limb
	random_icon_states = list("gibarm", "gibleg")

/obj/effect/decal/cleanable/robot_debris/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7","gibup1","gibup1")

/obj/effect/decal/cleanable/robot_debris/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7","gibdown1","gibdown1")

/obj/effect/decal/cleanable/oil
	name = "motor oil"
	desc = "It's black and greasy. Looks like Beepsky made another mess."
	icon = 'icons/mob/robots.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	blood_state = BLOOD_STATE_OIL
	bloodiness = MAX_SHOE_BLOODINESS

/obj/effect/decal/cleanable/oil/Initialize()
	..()
	reagents.add_reagent("oil", 30)

/obj/effect/decal/cleanable/oil/streak
	random_icon_states = list("streak1", "streak2", "streak3", "streak4", "streak5")
