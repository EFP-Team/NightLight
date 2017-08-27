/obj/spacepod/proc/Grant(mob/living/user, list/thing, type)
	thing[user] = new type
	var/datum/action/innate/spacepod/crap = thing[user]
	crap.Grant(user, src)
	return thing

/obj/spacepod/proc/Delete(mob/living/user, list/thing, type)
	var/datum/action/innate/spacepod/crap = thing[user]
	crap.Remove(user)
	QDEL_NULL(thing[user])
	return thing

/obj/spacepod/proc/Grant_Actions(mob/living/user)
	if(user == pilot)
		unload_action = Grant(user, unload_action, /datum/action/innate/spacepod/cargo)
		fire_action = Grant(user, fire_action, /datum/action/innate/spacepod/weapons)
		door_action = Grant(user, door_action	, /datum/action/innate/spacepod/poddoor)
		tank_action = Grant(user, tank_action, /datum/action/innate/spacepod/airtank)
		lock_action = Grant(user, lock_action, /datum/action/innate/spacepod/lockpod)
	exit_action = Grant(user, exit_action, /datum/action/innate/spacepod/exit)
	light_action = Grant(user, light_action, /datum/action/innate/spacepod/lights)
	seat_action = Grant(user, seat_action, /datum/action/innate/spacepod/checkseat)


/obj/spacepod/proc/Remove_Actions(mob/living/user)
	unload_action = Delete(user, unload_action, /datum/action/innate/spacepod/cargo)
	fire_action = Delete(user, fire_action, /datum/action/innate/spacepod/weapons)
	door_action = Delete(user, door_action	, /datum/action/innate/spacepod/poddoor)
	tank_action = Delete(user, tank_action, /datum/action/innate/spacepod/airtank)
	lock_action = Delete(user, lock_action, /datum/action/innate/spacepod/lockpod)
	exit_action = Delete(user, exit_action, /datum/action/innate/spacepod/exit)
	light_action = Delete(user, light_action, /datum/action/innate/spacepod/lights)
	seat_action = Delete(user, seat_action, /datum/action/innate/spacepod/checkseat)

/datum/action/innate/spacepod
	var/obj/spacepod/S
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_CONSCIOUS

/datum/action/innate/spacepod/Grant(mob/living/L, obj/spacepod/M)
	if(M)
		S = M
	..()

/datum/action/innate/spacepod/exit
	name = "Exit Spacepod"
	desc = "Exits the spacepod"

/datum/action/innate/spacepod/exit/Activate()
	if(!S)
		return
	S.exit_pod(owner)

/datum/action/innate/spacepod/lockpod
	name = "Lock Pod"
	desc = "Locks or unlocks the pod"

/datum/action/innate/spacepod/lockpod/Activate()
	if(!S)
		return
	S.lock_pod(owner)

/datum/action/innate/spacepod/poddoor
	name = "Toggle Nearby Pod Doors"
	desc = "Opens any nearby pod doors"

/datum/action/innate/spacepod/poddoor/Activate()
	if(!S)
		return
	S.toggleDoors(owner)

/datum/action/innate/spacepod/weapons
	name = "Fire Pod Weapons"
	desc = "Fires the pods weapon system if there is one"

/datum/action/innate/spacepod/weapons/Activate()
	if(!S)
		return
	S.fireWeapon(owner)

/datum/action/innate/spacepod/cargo
	name = "Unload Cargo"
	desc = "Unloads the pod's cargo, if any"

/datum/action/innate/spacepod/cargo/Activate()
	if(!S)
		return
	S.unload(owner)

/datum/action/innate/spacepod/lights
	name = "Toggle Lights"
	desc = "Toggle the pod's lights"

/datum/action/innate/spacepod/lights/Activate()
	if(!S)
		return
	S.toggleLights(owner)

/datum/action/innate/spacepod/checkseat
	name = "Check Under Seat"
	desc = "Check under the pod's seat for anything that might've been dropped."

/datum/action/innate/spacepod/checkseat/Activate()
	if(!S)
		return
	S.checkSeat(owner)


/datum/action/innate/spacepod/airtank
	name = "Toggle internal airtank usage"
	desc = "Toggle whether you want to take air from outside or use the internal air tank."

/datum/action/innate/spacepod/airtank/Activate()
	if(!S)
		return
	S.toggle_internal_tank(owner)