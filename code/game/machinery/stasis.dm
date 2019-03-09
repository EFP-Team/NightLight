/obj/machinery/stasis
	name = "Lifeform Stasis Unit"
	desc = "A not so comfortable looking bed with some nozzles at the top and bottom. It will keep someone in stasis."
	icon = 'icons/obj/surgery.dmi' //PLACEHOLDER
	icon_state = "optable" //PLACEHOLDER
	density = FALSE
	can_buckle = TRUE
	buckle_lying = TRUE
	circuit = /obj/item/circuitboard/machine/stasis
	idle_power_usage = 40
	active_power_usage = 340

/obj/machinery/stasis/Exited(atom/movable/AM, atom/newloc)
	if(AM == occupant)
		var/mob/living/L = AM
		if(L.IsInStasis())
			thaw_them(L)
	. = ..()

/obj/machinery/stasis/proc/chill_out(mob/living/target)
	if(target != occupant)
		return
	var/freq = rand(24750, 26550)
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 2, frequency = freq)
	target.SetStasis(TRUE)
	target.ExtinguishMob()
	use_power = ACTIVE_POWER_USE

/obj/machinery/stasis/proc/thaw_them(mob/living/target)
	target.SetStasis(FALSE)
	if(target == occupant)
		use_power = IDLE_POWER_USE

/obj/machinery/stasis/post_buckle_mob(mob/living/L)
	if(!can_be_occupant(L))
		return
	occupant = L
	if(is_operational())
		chill_out(L)

/obj/machinery/stasis/post_unbuckle_mob(mob/living/L)
	if(L == occupant)
		occupant = null
	thaw_them(L)

/obj/machinery/stasis/process()
	if( !( occupant && isliving(occupant) ) )
		return
	var/mob/living/L_occupant = occupant
	if(is_operational())
		if(!L_occupant.IsInStasis())
			chill_out(L_occupant)
	else if(L_occupant.IsInStasis())
		thaw_them(L_occupant)
