/datum/component/no_beacon_crossing/Initialize()
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/check_passed)


/datum/component/no_beacon_crossing/proc/check_passed(atom/parentatom = parent)
	if(isobj(parentatom.loc))
		return
	// if you somehow got past a beacon wall then time to die
	var/obj/structure/beacon_generator/closest
	var/obj/structure/infection/core/C = GLOB.infection_core
	if(!C)
		return
	for(var/obj/structure/beacon_generator/BG in GLOB.infection_beacons)
		if(!closest)
			closest = BG
			continue
		if(get_dist(C, closest) > get_dist(C, BG))
			closest = BG
	var/obj/structure/beacon_wall/edge = closest.walls[1]
	var/facingdir = closest.dir
	if(facingdir == NORTH && edge.y <= parentatom.y)
		kill_parent()
	if(facingdir == SOUTH && edge.y >= parentatom.y)
		kill_parent()
	if(facingdir == EAST && edge.x >= parentatom.x)
		kill_parent()
	if(facingdir == WEST && edge.x <= parentatom.x)
		kill_parent()

/datum/component/no_beacon_crossing/proc/kill_parent(atom/parentatom = parent)
	// time to go
	parentatom.visible_message("[parentatom] dissolves into nothing as the energy of the beacons destroys it!")
	playsound(get_turf(parentatom), 'sound/effects/supermatter.ogg', 50, 1)
	if(isliving(parent))
		var/mob/living/todie = parent
		todie.health = 0
		todie.death()
	else
		qdel(parent)