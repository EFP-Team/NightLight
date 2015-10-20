/obj/structure/bed/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon_state = "echair0"
	var/obj/item/assembly/shock_kit/part = null
	var/last_time = 1

/obj/structure/bed/chair/e_chair/New()
	..()
	overlays += image('icons/obj/objects.dmi', src, "echair_over", MOB_LAYER + 1, dir)
	return

/obj/structure/bed/chair/e_chair/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		var/obj/structure/bed/chair/C = new /obj/structure/bed/chair(loc)
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		C.dir = dir
		part.loc = src.loc
		part.master = null
		part = null
		qdel(src)
		return
	return

/obj/structure/bed/chair/e_chair/rotate()
	..()
	overlays.Cut()
	overlays += image('icons/obj/objects.dmi', src, "echair_over", MOB_LAYER + 1, dir)	//there's probably a better way of handling this, but eh. -Pete
	return

/obj/structure/bed/chair/e_chair/proc/shock()
	if(last_time + 50 > world.time)
		return
	last_time = world.time

	// special power handling
	var/area/A = get_area(src)
	if(!isarea(A))
		return
	if(!A.powered(EQUIP))
		return
	A.use_power(EQUIP, 5000)
	var/light = A.power_light
	A.updateicon()

	flick("echair1", src)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(12, 1, src)
	s.start()
	if(buckled_mob)
		buckled_mob.burn_skin(85)
		buckled_mob << "<span class='userdanger'>You feel a deep shock course through your body!</span>"
		sleep(1)
		buckled_mob.burn_skin(85)
	visible_message("<span class='danger'>The electric chair went off!</span>", "<span class='italics'>You hear a deep sharp shock!</span>")

	A.power_light = light
	A.updateicon()
	return