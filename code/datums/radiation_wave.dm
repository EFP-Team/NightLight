/datum/radiation_wave
	var/turf/master_turf //The center of the wave
	var/steps=0 //How far we've moved
	var/intensity=0 //How strong it was originaly
	var/range_modifier //Higher than 1 makes it drop off faster, 0.5 makes it drop off half etc
	var/list/move_dir //The direction of movement
	var/list/__dirs //The directions to the side of the wave, stored for easy looping

/datum/radiation_wave/New(turf/place, dir, strength, range_mod)
	master_turf = place

	move_dir = dir
	__dirs+=turn(dir, 90)
	__dirs+=turn(dir, -90)

	intensity = strength

	range_modifier = range_mod

	SSradiation.processing += src

/datum/radiation_wave/process()
	master_turf = get_step(master_turf, move_dir)
	steps++
	var/list/turfs = get_rad_turfs()
	check_obstructions(turfs)
	var/strength = InverseSquareLaw(intensity, (range_modifier*(steps-1))+1, 1) //The full rad amount always applies on the first step
	if(strength<1)
		return FALSE

	if(strength<=0.1)
		return FALSE
	radiate(turfs, Floor(strength))

	return TRUE

/datum/radiation_wave/proc/get_rad_turfs()
	var/list/turf/turfs
	var/distance = steps

	if(move_dir == NORTH || move_dir == SOUTH)
		distance-- //otherwise corners overlap

	turfs += master_turf

	if(!distance)
		return turfs

	var/turf/place
	for(var/dir in __dirs) //There should be just 2 dirs in here, left and right of the direction of movement
		place = master_turf
		for(var/i in 1 to distance)
			place = get_step(place, dir)
			turfs += place

	return turfs

/datum/radiation_wave/proc/check_obstructions(list/turfs)
	for(var/i in 1 to turfs.len)
		var/turf/place = turfs[i]
		var/datum/component/rad_insulation/insulation = place.GetComponent(/datum/component/rad_insulation)
		if(insulation)
			intensity -= insulation.amount

		for(var/k in 1 to place.contents.len)
			var/atom/thing = place.contents[k]
			insulation = thing.GetComponent(/datum/component/rad_insulation)
			//TODO: recursively loop through contents
			if(!insulation)
				continue
			intensity -= insulation.amount

/datum/radiation_wave/proc/radiate(list/turfs, strength)
	for(var/i in 1 to turfs.len)
		var/turf/place = turfs[i]
		for(var/k in 1 to place.contents.len)
			var/atom/thing = place.contents[k]
			//TODO: recursively loop through contents
			thing.rad_act(strength)