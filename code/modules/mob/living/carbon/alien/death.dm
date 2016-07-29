/mob/living/carbon/alien/spawn_gibs()
	xgibs(loc, viruses)

/mob/living/carbon/alien/gib_animation()
	PoolOrNew(/obj/effect/overlay/temp/gib_animation, list(loc, "gibbed-a"))

/mob/living/carbon/alien/spawn_dust()
	new /obj/effect/decal/remains/xeno(loc)

/mob/living/carbon/alien/dust_animation()
	PoolOrNew(/obj/effect/overlay/temp/dust_animation, list(loc, "dust-a"))
