/mob/living/basic/cobraworm
	name = "tiziran cobraworm"
	desc = "A wormlike creature from the Tiziran crudlands. It is commonly encounted near bone heaps, plastomiddens and compost basins. Its noxious spit is feared amongst Tirizan scourjocks."
	icon = 'icons/mob/cobraworm.dmi'
	icon_state = "cobraworm"
	base_icon_state = "cobraworm"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	maxHealth = 80
	health = 80
	speed = 0
	melee_damage_lower = 3
	melee_damage_upper = 6
	obj_damage = 10

/mob/living/basic/cobraworm/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/ranged_attacks, null, null, /obj/projectile/worm_spit)

/particles/worm_enzymes
	icon = 'icons/effects/particles/worm_enzymes.dmi'
	icon_state = list("enzymes_1" = 4, "enzymes_2" = 4, "enzymes_3" = 2, "enzymes_4" = 1)
	width = 64
	height = 64
	count = 1000
	spawning = 8
	lifespan = 2 SECONDS
	fade = 1.5 SECONDS
	velocity = list(0, 2, 0)
	position = list(-16, 16, 0)
	drift = generator("sphere", 0, 2, NORMAL_RAND)
	friction = 0.1
	gravity = list(0, -1)
	grow = 0

/obj/projectile/worm_spit
	name = "worm spit"
	icon_state = "worm"
	damage = 4
	damage_type = BURN
	flag = BIO

/obj/projectile/worm_spit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/venomous, /datum/reagent/nightcrawler_enzymes, 3)

/obj/projectile/wormling_ball
	name = "mud ball"
	icon_state = "mud"
	damage = 6

/obj/projectile/wormling_ball/Impact(atom/A)
	. = ..()
	var/muddy_turf = get_turf(A)
	if(!muddy_turf)
		return
	if(!isopenturf(muddy_turf))
		return
	if(locate(/obj/machinery/hydroponics/soil) in muddy_turf)
		return
	new /obj/machinery/hydroponics/soil/worm(muddy_turf)
	new /obj/effect/wormling_trap(muddy_turf)

/obj/effect/wormling_trap
	name = "wriggling worms"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "worm_effect"

/obj/effect/wormling_trap/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 10 SECONDS)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)
