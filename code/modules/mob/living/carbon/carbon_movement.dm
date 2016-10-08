/mob/living/carbon/movement_delay()
	. = ..()
	. += grab_state * 3 //can't go fast while grabbing something.

	if(ishuman(src))
		if(!(dna && dna.species && (FLYING in dna.species.specflags)))		//If someone can get me a better way to do this I'l learn gladly.
			if(!get_leg_ignore()) //ignore the fact we lack legs
				var/leg_amount = get_num_legs()
				. += 6 - 3*leg_amount //the fewer the legs, the slower the mob
				if(!leg_amount)
					. += 6 - 3*get_num_arms() //crawling is harder with fewer arms
			if(legcuffed)
				. += legcuffed.slowdown
	else
		if(!get_leg_ignore()) //ignore the fact we lack legs
			var/leg_amount = get_num_legs()
			. += 6 - 3*leg_amount //the fewer the legs, the slower the mob
			if(!leg_amount)
				. += 6 - 3*get_num_arms() //crawling is harder with fewer arms
		if(legcuffed)
			. += legcuffed.slowdown


var/const/NO_SLIP_WHEN_WALKING = 1
var/const/SLIDE = 2
var/const/GALOSHES_DONT_HELP = 4
var/const/SLIDE_ICE = 8

/mob/living/carbon/slip(s_amount, w_amount, obj/O, lube)
	if(!(lube&SLIDE_ICE))
		add_logs(src,, "slipped",, "on [O ? O.name : "floor"]")
	return loc.handle_slip(src, s_amount, w_amount, O, lube)


/mob/living/carbon/Process_Spacemove(movement_dir = 0)
	var/obj/item/device/flightpack/F = get_flightpack()
	if(istype(F) && (F.flight) && F.allow_thrust(0.01, src))
		return 1

	if(..())
		return 1
	if(!isturf(loc))
		return 0

	// Do we have a jetpack implant (and is it on)?
	var/obj/item/organ/cyberimp/chest/thrusters/T = getorganslot("thrusters")
	if(istype(T) && movement_dir && T.allow_thrust(0.01))
		return 1

	var/obj/item/weapon/tank/jetpack/J = get_jetpack()
	if(istype(J) && (movement_dir || J.stabilizers) && J.allow_thrust(0.01, src))
		return 1




/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(src.nutrition && src.stat != 2)
			src.nutrition -= HUNGER_FACTOR/10
			if(src.m_intent == "run")
				src.nutrition -= HUNGER_FACTOR/10
		if((src.disabilities & FAT) && src.m_intent == "run" && src.bodytemperature <= 360)
			src.bodytemperature += 2
