// AI (i.e. game AI, not the AI player) controlled bots

/obj/machinery/bot
	icon = 'icons/obj/aibots.dmi'
	layer = MOB_LAYER
	luminosity = 3
	use_power = 0
	var/obj/item/weapon/card/id/botcard			// the ID card that the bot "holds"
	var/on = 1
	var/health = 0 //do not forget to set health for your bot!
	var/maxhealth = 0
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = 0//Maint panel
	var/locked = 1
	//var/emagged = 0 //Urist: Moving that var to the general /bot tree as it's used by most bots


/obj/machinery/bot/proc/turn_on()
	if(stat)	return 0
	on = 1
	SetLuminosity(initial(luminosity))
	return 1

/obj/machinery/bot/proc/turn_off()
	on = 0
	SetLuminosity(0)

/obj/machinery/bot/proc/explode()
	del(src)

/obj/machinery/bot/proc/healthcheck()
	if (src.health <= 0)
		src.explode()

/obj/machinery/bot/proc/Emag(mob/user as mob)
	if(locked)
		locked = 0
		emagged = 1
		user << "<span class='warning'>You bypass [src]'s controls.</span>"
	if(!locked && open)
		emagged = 2

/obj/machinery/bot/examine()
	set src in view()
	..()
	if (src.health < maxhealth)
		if (src.health > maxhealth/3)
			usr << "<span class='warning'>[src]'s parts look loose.</span>"
		else
			usr << "<span class='danger'>[src]'s parts look very loose!</span>"
	return

/obj/machinery/bot/attack_alien(var/mob/living/carbon/alien/user as mob)
	src.health -= rand(15,30)*brute_dam_coeff
	src.visible_message("\red <B>[user] has slashed [src]!</B>")
	playsound(src.loc, 'sound/weapons/slice.ogg', 25, 1, -1)
	if(prob(10))
		new /obj/effect/decal/cleanable/oil(src.loc)
	healthcheck()


/obj/machinery/bot/attack_animal(var/mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)	return
	src.health -= M.melee_damage_upper
	src.visible_message("\red <B>[M] has [M.attacktext] [src]!</B>")
	M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
	if(prob(10))
		new /obj/effect/decal/cleanable/oil(src.loc)
	healthcheck()




/obj/machinery/bot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(!locked)
			open = !open
			user << "<span class='notice'>Maintenance panel is now [src.open ? "opened" : "closed"].</span>"
	else if(istype(W, /obj/item/weapon/weldingtool))
		if(health < maxhealth)
			if(open)
				health = min(maxhealth, health+10)
				user.visible_message("\red [user] repairs [src]!","\blue You repair [src]!")
			else
				user << "<span class='notice'>Unable to repair with the maintenance panel closed.</span>"
		else
			user << "<span class='notice'>[src] does not need a repair.</span>"
	else if (istype(W, /obj/item/weapon/card/emag) && emagged < 2)
		Emag(user)
	else
		if(hasvar(W,"force") && hasvar(W,"damtype"))
			switch(W.damtype)
				if("fire")
					src.health -= W.force * fire_dam_coeff
				if("brute")
					src.health -= W.force * brute_dam_coeff
			..()
			healthcheck()
		else
			..()

/obj/machinery/bot/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()

/obj/machinery/bot/meteorhit()
	src.explode()
	return

/obj/machinery/bot/blob_act()
	src.health -= rand(20,40)*fire_dam_coeff
	healthcheck()
	return

/obj/machinery/bot/ex_act(severity)
	switch(severity)
		if(1.0)
			src.explode()
			return
		if(2.0)
			src.health -= rand(5,10)*fire_dam_coeff
			src.health -= rand(10,20)*brute_dam_coeff
			healthcheck()
			return
		if(3.0)
			if (prob(50))
				src.health -= rand(1,5)*fire_dam_coeff
				src.health -= rand(1,5)*brute_dam_coeff
				healthcheck()
				return
	return

/obj/machinery/bot/emp_act(severity)
	var/was_on = on
	stat |= EMPED
	var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( src.loc )
	pulse2.icon = 'icons/effects/effects.dmi'
	pulse2.icon_state = "empdisable"
	pulse2.name = "emp sparks"
	pulse2.anchored = 1
	pulse2.dir = pick(cardinal)

	spawn(10)
		pulse2.delete()
	if (on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if (was_on)
			turn_on()


/obj/machinery/bot/attack_ai(mob/user as mob)
	src.attack_hand(user)

/******************************************************************/
// Navigation procs
// Used for A-star pathfinding


// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
/turf/proc/CardinalTurfsWithAccess(var/obj/item/weapon/card/id/ID)
	var/L[] = new()

	//	for(var/turf/simulated/t in oview(src,1))

	for(var/d in cardinal)
		var/turf/simulated/T = get_step(src, d)
		if(istype(T) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L


// Returns true if a link between A and B is blocked
// Movement through doors allowed if ID has access
/proc/LinkBlockedWithAccess(turf/A, turf/B, obj/item/weapon/card/id/ID)

	if (A == null || B == null) return 1
	if (get_dist(A,B) > 1) return 1

	for (var/obj/O in B)
		if (O.density && !(istype(O, /obj/machinery/door) || istype(O, /obj/structure/window)) && !(O.flags & ON_BORDER))
			return 1

	return (DirBlockedWithAccess(A,get_dir(A,B), ID))

// Returns true if direction is blocked from loc
// Checks doors against access with given ID
/proc/DirBlockedWithAccess(turf/loc,var/dir,var/obj/item/weapon/card/id/ID)
	for(var/obj/structure/window/D in loc)
		if (D.density)
			return 1

	var/passable = TRUE
	for(var/obj/machinery/door/D in loc)
		if (!passable) return 1		//check EVERY door, but give up when one is blocked

		//windows
		if (istype(D, /obj/machinery/door/window))
			if(dir && D.dir)
				passable = !D.check_access(ID)
		//doors
		else
			if (D.stat && D.density)	//door is broken and shut, so the bot can't open it
				return 1
			else if (istype(D, /obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/A = D
				if (A.locked || A.welded)
					return 1			//bots can't open bolted/welded airlocks
				else passable = D.check_access(ID)
			else if (istype(D, /obj/machinery/door/firedoor))
				if(dir && D.dir)
					passable = !D.density	//bots can't open closed firedoors. Doesn't matter if they're welded.
			else if (istype(D, /obj/machinery/door/poddoor)) //blast door in-game
				passable = !D.density
	return passable
