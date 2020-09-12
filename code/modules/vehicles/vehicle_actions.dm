//VEHICLE DEFAULT HANDLING
/obj/vehicle/proc/generate_actions()
	return

/obj/vehicle/proc/generate_action_type(actiontype)
	var/datum/action/vehicle/A = new actiontype
	if(!istype(A))
		return
	A.vehicle_target = src
	return A

/obj/vehicle/proc/initialize_passenger_action_type(actiontype)
	autogrant_actions_passenger += actiontype
	for(var/i in occupants)
		grant_passenger_actions(i)	//refresh

/obj/vehicle/proc/initialize_controller_action_type(actiontype, control_flag)
	LAZYINITLIST(autogrant_actions_controller["[control_flag]"])
	autogrant_actions_controller["[control_flag]"] += actiontype
	for(var/i in occupants)
		grant_controller_actions(i)	//refresh

/obj/vehicle/proc/grant_action_type_to_mob(actiontype, mob/m)
	if(isnull(occupants[m]) || !actiontype)
		return FALSE
	LAZYINITLIST(occupant_actions[m])
	if(occupant_actions[m][actiontype])
		return TRUE
	var/datum/action/action = generate_action_type(actiontype)
	action.Grant(m)
	occupant_actions[m][action.type] = action
	return TRUE

/obj/vehicle/proc/remove_action_type_from_mob(actiontype, mob/m)
	if(isnull(occupants[m]) || !actiontype)
		return FALSE
	LAZYINITLIST(occupant_actions[m])
	if(occupant_actions[m][actiontype])
		var/datum/action/action = occupant_actions[m][actiontype]
		action.Remove(m)
		occupant_actions[m] -= actiontype
	return TRUE

/obj/vehicle/proc/grant_passenger_actions(mob/M)
	for(var/v in autogrant_actions_passenger)
		grant_action_type_to_mob(v, M)

/obj/vehicle/proc/remove_passenger_actions(mob/M)
	for(var/v in autogrant_actions_passenger)
		remove_action_type_from_mob(v, M)

/obj/vehicle/proc/grant_controller_actions(mob/M)
	if(!istype(M) || isnull(occupants[M]))
		return FALSE
	for(var/i in GLOB.bitflags)
		if(occupants[M] & i)
			grant_controller_actions_by_flag(M, i)
	return TRUE

/obj/vehicle/proc/remove_controller_actions(mob/M)
	if(!istype(M) || isnull(occupants[M]))
		return FALSE
	for(var/i in GLOB.bitflags)
		remove_controller_actions_by_flag(M, i)
	return TRUE

/obj/vehicle/proc/grant_controller_actions_by_flag(mob/M, flag)
	if(!istype(M))
		return FALSE
	for(var/v in autogrant_actions_controller["[flag]"])
		grant_action_type_to_mob(v, M)
	return TRUE

/obj/vehicle/proc/remove_controller_actions_by_flag(mob/M, flag)
	if(!istype(M))
		return FALSE
	for(var/v in autogrant_actions_controller["[flag]"])
		remove_action_type_from_mob(v, M)
	return TRUE

/obj/vehicle/proc/cleanup_actions_for_mob(mob/M)
	if(!istype(M))
		return FALSE
	for(var/path in occupant_actions[M])
		stack_trace("Leftover action type [path] in vehicle type [type] for mob type [M.type] - THIS SHOULD NOT BE HAPPENING!")
		var/datum/action/action = occupant_actions[M][path]
		action.Remove(M)
		occupant_actions[M] -= path
	occupant_actions -= M
	return TRUE

/////////////ACTION DATUMS\\\\\\\\\

/datum/action/vehicle
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_vehicle.dmi'
	button_icon_state = "vehicle_eject"
	var/obj/vehicle/vehicle_target

/datum/action/vehicle/sealed
	var/obj/vehicle/sealed/vehicle_entered_target

/datum/action/vehicle/sealed/climb_out
	name = "Climb Out"
	desc = "Climb out of your vehicle!"
	button_icon_state = "car_eject"

/datum/action/vehicle/sealed/climb_out/Trigger()
	if(..() && istype(vehicle_entered_target))
		vehicle_entered_target.mob_try_exit(owner, owner)

/datum/action/vehicle/ridden
	var/obj/vehicle/ridden/vehicle_ridden_target

/datum/action/vehicle/sealed/remove_key
	name = "Remove key"
	desc = "Take your key out of the vehicle's ignition."
	button_icon_state = "car_removekey"

/datum/action/vehicle/sealed/remove_key/Trigger()
	vehicle_entered_target.remove_key(owner)

//CLOWN CAR ACTION DATUMS
/datum/action/vehicle/sealed/horn
	name = "Honk Horn"
	desc = "Honk your classy horn."
	button_icon_state = "car_horn"
	var/hornsound = 'sound/items/carhorn.ogg'
	var/last_honk_time

/datum/action/vehicle/sealed/horn/Trigger()
	if(world.time - last_honk_time > 20)
		vehicle_entered_target.visible_message("<span class='danger'>[vehicle_entered_target] loudly honks!</span>")
		to_chat(owner, "<span class='notice'>You press the vehicle's horn.</span>")
		playsound(vehicle_entered_target, hornsound, 75)
		last_honk_time = world.time

/datum/action/vehicle/sealed/horn/clowncar/Trigger()
	if(world.time - last_honk_time > 20)
		vehicle_entered_target.visible_message("<span class='danger'>[vehicle_entered_target] loudly honks!</span>")
		to_chat(owner, "<span class='notice'>You press the vehicle's horn.</span>")
		last_honk_time = world.time
		if(vehicle_target.inserted_key)
			vehicle_target.inserted_key.attack_self(owner) //The key plays a sound
		else
			playsound(vehicle_entered_target, hornsound, 75)

/datum/action/vehicle/sealed/dump_kidnapped_mobs
	name = "Dump Kidnapped Mobs"
	desc = "Dump all objects and people in your car on the floor."
	button_icon_state = "car_dump"

/datum/action/vehicle/sealed/dump_kidnapped_mobs/Trigger()
	vehicle_entered_target.visible_message("<span class='danger'>[vehicle_entered_target] starts dumping the people inside of it.</span>")
	vehicle_entered_target.DumpSpecificMobs(VEHICLE_CONTROL_KIDNAPPED)


/datum/action/vehicle/sealed/roll_the_dice
	name = "Press Colorful Button"
	desc = "Press one of those colorful buttons on your display panel!"
	button_icon_state = "car_rtd"

/datum/action/vehicle/sealed/roll_the_dice/Trigger()
	if(istype(vehicle_entered_target, /obj/vehicle/sealed/car/clowncar))
		var/obj/vehicle/sealed/car/clowncar/C = vehicle_entered_target
		C.RollTheDice(owner)

/datum/action/vehicle/sealed/cannon
	name = "Toggle Siege Mode"
	desc = "Destroy them with their own fodder!"
	button_icon_state = "car_cannon"

/datum/action/vehicle/sealed/cannon/Trigger()
	if(istype(vehicle_entered_target, /obj/vehicle/sealed/car/clowncar))
		var/obj/vehicle/sealed/car/clowncar/C = vehicle_entered_target
		if(C.cannonbusy)
			to_chat(owner, "<span class='notice'>Please wait for the vehicle to finish its current action first.</span>")
		C.ToggleCannon()


/datum/action/vehicle/sealed/thank
	name = "Thank the Clown Car Driver"
	desc = "They're just doing their job."
	button_icon_state = "car_thanktheclown"
	COOLDOWN_DECLARE(thank_time_cooldown)


/datum/action/vehicle/sealed/thank/Trigger()
	if(!istype(vehicle_entered_target, /obj/vehicle/sealed/car/clowncar))
		return
	if(!COOLDOWN_FINISHED(src, thank_time_cooldown))
		return
	COOLDOWN_START(src, thank_time_cooldown, 6 SECONDS)
	var/obj/vehicle/sealed/car/clowncar/clown_car = vehicle_entered_target
	var/list/drivers = clown_car.return_drivers()
	if(!length(drivers))
		return
	var/mob/living/carbon/human/clown = pick(drivers)
	owner.say("Thank you for the fun ride, [clown.name]!")
	clown_car.ThanksCounter()


/datum/action/vehicle/ridden/scooter/skateboard/ollie
	name = "Ollie"
	desc = "Get some air! Land on a table to do a gnarly grind."
	button_icon_state = "skateboard_ollie"
	///Cooldown to next jump
	var/next_ollie

/datum/action/vehicle/ridden/scooter/skateboard/ollie/Trigger()
	if(world.time > next_ollie)
		var/obj/vehicle/ridden/scooter/skateboard/vehicle = vehicle_target
		if (vehicle.grinding)
			return
		var/mob/living/rider = owner
		var/turf/landing_turf = get_step(vehicle.loc, vehicle.dir)
		rider.adjustStaminaLoss(vehicle.instability*2)
		if (rider.getStaminaLoss() >= 100)
			playsound(src, 'sound/effects/bang.ogg', 20, TRUE)
			vehicle.unbuckle_mob(rider)
			rider.throw_at(landing_turf, 2, 2)
			rider.Paralyze(40)
			vehicle.visible_message("<span class='danger'>[rider] misses the landing and falls on [rider.p_their()] face!</span>")
		else
			rider.spin(4, 1)
			animate(rider, pixel_y = -6, time = 4)
			animate(vehicle, pixel_y = -6, time = 3)
			playsound(vehicle, 'sound/vehicles/skateboard_ollie.ogg', 50, TRUE)
			passtable_on(rider, VEHICLE_TRAIT)
			vehicle.pass_flags |= PASSTABLE
			rider.Move(landing_turf, vehicle_target.dir)
			passtable_off(rider, VEHICLE_TRAIT)
			vehicle.pass_flags &= ~PASSTABLE
		if(locate(/obj/structure/table) in vehicle.loc.contents)
			vehicle.grinding = TRUE
			vehicle.icon_state = "[initial(vehicle.icon_state)]-grind"
			addtimer(CALLBACK(vehicle, /obj/vehicle/ridden/scooter/skateboard/.proc/grind), 2)
		next_ollie = world.time + 5
