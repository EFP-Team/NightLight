/proc/get_rad_contents(atom/location, list/output=list()) // A special GetAllContents that doesn't search past things with rad insulation
	var/static/list/ignored_things = typecacheof(list(/mob/dead, /obj/effect, /obj/docking_port, /turf, /atom/movable/lighting_object))
	. = output
	if(!location || location.GetComponent(/datum/component/rad_insulation))
		return

	output += location
	
	for(var/i in 1 to location.contents.len)
		var/atom/thing = location.contents[i]
		if(ignored_things[thing.type])
			continue
		get_rad_contents(thing, output)

/proc/radiation_pulse(turf/epicenter, intensity, range_modifier, log=0, can_contaminate=TRUE)
	for(var/dir in GLOB.cardinals)
		new /datum/radiation_wave(epicenter, dir, intensity, range_modifier, can_contaminate)

	var/list/things = get_rad_contents(epicenter) //copypasta because I don't want to put special code in waves to handle their origin
	for(var/k in 1 to things.len)
		var/atom/thing = things[k]
		if(!thing)
			continue
		thing.rad_act(intensity, TRUE)

	if(log || intensity > 500)
		log_game("Radiation pulse with intensity:[intensity] and range modifier:[range_modifier] in area [epicenter.loc.name] ")
	return TRUE