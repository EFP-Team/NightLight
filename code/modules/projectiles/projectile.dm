/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = 0
	anchored = 1
	flags = ABSTRACT | NODROP
	unacidable = 1
	pass_flags = PASSTABLE
	mouse_opacity = 0
	hitsound = 'sound/weapons/pierce.ogg'
	var/hitsound_wall = ""//"ricochet"
	var/def_zone = ""	//Aiming at
	var/mob/firer = null//Who shot it
	var/suppressed = 0	//Attack message
	var/yo = null
	var/xo = null
	var/atom/current = null
	var/atom/original = null // the original target clicked
	var/turf/starting = null // the projectile's starting turf
	var/list/permutated = list() // we've passed through these atoms, don't try to hit them again
	var/paused = FALSE //for suspending the projectile midair
	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center
	var/speed = 1 //Amount of deciseconds it takes for projectile to travel. Animation is adjusted accordingly.
	var/Angle = 0 //For new projectiles
	var/spread = 0 //Amount of degrees by which the projectiles will be spread DURING MOVEMENT. It exists for chaotic types of projectiles, like bees or something.
	var/legacy = 0 //use legacy projectile system?
	animate_movement = 0 //Change this to SLIDE_STEPS if you're using legacy

	var/damage = 10
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/nodamage = 0 //Determines if the projectile will skip any damage inflictions
	var/flag = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb
	var/projectile_type = "/obj/item/projectile"
	var/kill_count = 50 //This will de-increment every step. When 0, it will delete the projectile.
		//Effects
	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 0
	var/slur = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/stamina = 0
	var/jitter = 0
	var/forcedodge = 0
	// 1 to pass solid objects, 2 to pass solid turfs (results in bugs, bugs and tons of bugs)
	var/range = 0

/obj/item/projectile/New()
	permutated = list()
	return ..()

/obj/item/projectile/proc/Range()
	if(range)
		range--
		if(range <= 0)
			on_range()
	else
		return

/obj/item/projectile/proc/on_range() //if we want there to be effects when they reach the end of their range
	qdel(src)

/obj/item/projectile/proc/on_hit(atom/target, blocked = 0, hit_zone)
	if(isturf(target) && hitsound_wall)
		var/volume = Clamp(vol_by_damage() + 20, 0, 100)
		if(suppressed)
			volume = 5
		playsound(loc, hitsound_wall, volume, 1, -1)

	if(!isliving(target))
		return 0
	var/mob/living/L = target
	if(blocked != 100) // not completely blocked
		var/organ_hit_text = ""
		if(L.has_limbs)
			organ_hit_text = " in \the [parse_zone(def_zone)]"
		if(suppressed)
			playsound(loc, hitsound, 5, 1, -1)
			L << "<span class='userdanger'>You're shot by \a [src][organ_hit_text]!</span>"
		else
			if(hitsound)
				var/volume = vol_by_damage()
				playsound(loc, hitsound, volume, 1, -1)
			L.visible_message("<span class='danger'>[L] is hit by \a [src][organ_hit_text]!</span>", \
								"<span class='userdanger'>[L] is hit by \a [src][organ_hit_text]!</span>")	//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter
		L.on_hit(type)

	var/reagent_note
	if(reagents && reagents.reagent_list)
		reagent_note = " REAGENTS:"
		for(var/datum/reagent/R in reagents.reagent_list)
			reagent_note += R.id + " ("
			reagent_note += num2text(R.volume) + ") "

	add_logs(firer, L, "shot", src, reagent_note)
	return L.apply_effects(stun, weaken, paralyze, irradiate, stutter, slur, eyeblur, drowsy, blocked, stamina, jitter)

/obj/item/projectile/proc/vol_by_damage()
	if(src.damage)
		return Clamp((src.damage) * 0.67, 30, 100)// Multiply projectile damage by 0.67, then clamp the value between 30 and 100
	else
		return 50 //if the projectile doesn't do damage, play its hitsound at 50% volume

/obj/item/projectile/Bump(atom/A, yes)
	if(!yes) //prevents double bumps.
		return
	if(A == firer || A == src)
		loc = A.loc
		return 0 //cannot shoot yourself

	var/distance = get_dist(get_turf(A), starting) // Get the distance between the turf shot from and the mob we hit and use that for the calculations.
	def_zone = ran_zone(def_zone, max(100-(7*distance), 5)) //Lower accurancy/longer range tradeoff. 7 is a balanced number to use.

	var/turf/target_turf = get_turf(A)

	var/permutation = A.bullet_act(src, def_zone) // searches for return value, could be deleted after run so check A isn't null
	if(permutation == -1 || forcedodge)// the bullet passes through a dense object!
		loc = target_turf
		if(A)
			permutated.Add(A)
		return 0
	else
		if(A && A.density && !ismob(A) && !(A.flags & ON_BORDER)) //if we hit a dense non-border obj or dense turf then we also hit one of the mobs on that tile.
			var/list/mobs_list = list()
			for(var/mob/living/L in target_turf)
				mobs_list += L
			if(mobs_list.len)
				var/mob/living/picked_mob = pick(mobs_list)
				picked_mob.bullet_act(src, def_zone)
	qdel(src)

/obj/item/projectile/Process_Spacemove(var/movement_dir = 0)
	return 1 //Bullets don't drift in space


/obj/item/projectile/proc/fire(var/setAngle)
	if(setAngle) Angle = setAngle
	if(!legacy)
		spawn() //New projectile system
			while(loc)
				if(kill_count < 1)
					qdel(src)
					return
				kill_count--
				if((!( current ) || loc == current))
					current = locate(Clamp(x+xo,1,world.maxx),Clamp(y+yo,1,world.maxy),z)

				if(!Angle)
					Angle=round(Get_Angle(src,current))
				// world << "[Angle] angle"
				// overlays.Cut()
				// var/icon/I=new(initial(icon),icon_state) //using initial(icon) makes sure that the angle for that is reset as well
				// I.Turn(Angle)
				// I.DrawBox(rgb(255,0,0,50),1,1,32,32)
				// icon = I
				if(spread) //Chaotic spread
					Angle += (rand() - 0.5) * spread
				var/matrix/M = new//matrix(transform)
				M.Turn(Angle)
				transform = M

				var/Pixel_x=round(sin(Angle)+16*sin(Angle)*2)
				var/Pixel_y=round(cos(Angle)+16*cos(Angle)*2)
				var/pixel_x_offset = pixel_x + Pixel_x
				var/pixel_y_offset = pixel_y + Pixel_y
				var/new_x = x
				var/new_y = y
				//Not sure if using whiles for this is good
				while(pixel_x_offset > 16)
					// world << "Pre-adjust coords (x++): xy [pixel_x] xy offset [pixel_x_offset]"
					pixel_x_offset -= 32
					pixel_x -= 32
					new_x++// x++
				while(pixel_x_offset < -16)
					// world << "Pre-adjust coords (x--): xy [pixel_x] xy offset [pixel_x_offset]"
					pixel_x_offset += 32
					pixel_x += 32
					new_x--

				while(pixel_y_offset > 16)
					// world << "Pre-adjust coords (y++): py [pixel_y] py offset [pixel_y_offset]"
					pixel_y_offset -= 32
					pixel_y -= 32
					new_y++
				while(pixel_y_offset < -16)
					// world << "Pre-adjust coords (y--): py [pixel_y] py offset [pixel_y_offset]"
					pixel_y_offset += 32
					pixel_y += 32
					new_y--

				speed = round(speed) //Just in case.
				step_towards(src, locate(new_x, new_y, z)) //Original projectiles stepped towards 'current'
				if(speed <= 1) //We should really only animate at speed 2
					pixel_x = pixel_x_offset
					pixel_y = pixel_y_offset
				else
					animate(src, pixel_x = pixel_x_offset, pixel_y = pixel_y_offset, time = max(1, (speed <= 3 ? speed - 1 : speed)))

				/*var/turf/T = get_turf(src)
				if(T)
					T.color = "#6666FF"
					spawn(10)
						T.color = initial(T.color) */

				if(((original && original.layer>=2.75) || ismob(original)))
					if(loc == get_turf(original))
						if(!(original in permutated))
							Bump(original, 1)
				Range()
				sleep(max(1, speed))
	else
		spawn()
			while(loc)
				if(kill_count < 1)
					qdel(src)
					return
				if(!paused)
					kill_count--
					if((!( current ) || loc == current))
						current = locate(Clamp(x+xo,1,world.maxx),Clamp(y+yo,1,world.maxy),z)
					step_towards(src, current)
					if((original && original.layer>=2.75) || ismob(original))
						if(loc == get_turf(original))
							if(!(original in permutated))
								Bump(original, 1)
				Range()
				sleep(1)


/obj/item/projectile/Crossed(atom/movable/AM) //A mob moving on a tile with a projectile is hit by it.
	..()
	if(isliving(AM) && AM.density && !checkpass(PASSMOB))
		Bump(AM, 1)
