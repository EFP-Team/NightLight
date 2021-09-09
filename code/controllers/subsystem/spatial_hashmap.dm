/datum/spatial_hashmap_cell
	///our x index in the list of cells
	var/cell_x
	///our y index in the list of cells
	var/cell_y

	//every data point in a hashmap cell is separated by usecase

	///every hearing sensitive movable inside this cell
	var/list/hearing_contents = list()
	///every client possessed movable inside this cell
	var/list/client_contents = list()

/datum/spatial_hashmap_cell/New(cell_x, cell_y, cell_z)
	. = ..()
	src.cell_x = cell_x
	src.cell_y = cell_y

/datum/spatial_hashmap_cell/Destroy(force, ...)
	if(!force)//fuck you dont destroy this
		return

	. = ..()

SUBSYSTEM_DEF(spatial_hashmap)
	can_fire = FALSE
	init_order = INIT_ORDER_HASHMAP
	name = "Spatial Hashmap"

	///list of the spatial_hashmap_cell datums per z level, arranged in the order of y index then x index
	var/list/hashmaps_by_z_level = list()

/datum/controller/subsystem/spatial_hashmap/Initialize(start_timeofday)
	. = ..()
	var/cells_per_side = world.maxx / HASHMAP_CELLSIZE //assume world.maxx == world.maxy
	for(var/datum/space_level/z_level as anything in SSmapping.z_list)
		var/list/new_cell_hashmap = list()

		hashmaps_by_z_level += list(new_cell_hashmap)

		for(var/y in 1 to cells_per_side)
			new_cell_hashmap += list(list())
			for(var/x in 1 to cells_per_side)
				var/datum/spatial_hashmap_cell/cell = new(x, y)
				new_cell_hashmap[y] += cell

/**
 * searches through the hashmap cells intersecting range radius around center and returns the added contents that are also in LOS
 * much faster than iterating through view() to find all of what you want for things that arent that common
 *
 * * center - the atom that is the center of the searched circle
 * * type - the hashmap contents channel you are looking for, see __DEFINES/spatial_hashmap.dm
 * * range - the radius of our search circle. the code assumes this is > 1
 * * ignore_visibility - if TRUE, line of sight is ignored, the contents of the hashmap are only filtered for distance
 * * include_center - if FALSE, subtracts center from the output before filtering, used to speedup searches where you dont care about center being in the output
 */
/datum/controller/subsystem/spatial_hashmap/proc/find_hashmap_contents_in_view(atom/center, type, range, ignore_visibility = FALSE, include_center = TRUE)//should probably just be a global proc but w/e
	var/turf/center_turf = get_turf(center)
	//currently this proc takes around 70 microseconds to complete for range = 10 in a openish space (714 per 50ms tick)
	//and about 15 microseconds for range=3 (3300 per 50ms tick)

	var/center_x = center_turf.x//TODOKYLER: rename to center_x and center_y
	var/center_y = center_turf.y

	var/list/contents_to_return = list()

	var/static/hashmap_cells_per_axis = world.maxx / HASHMAP_CELLSIZE//im going to assume this doesnt change at runtime

	//the minimum x and y cell indexes to test
	var/min_x = max(CEILING((center_x - range) * (1 / HASHMAP_CELLSIZE), 1), 1)
	var/min_y = max(CEILING((center_y - range) * (1 / HASHMAP_CELLSIZE), 1), 1)//calculating these indices only takes around 2 microseconds

	//the maximum x and y cell indexes to test
	var/max_x = min(CEILING((center_x + range) * (1 / HASHMAP_CELLSIZE), 1), hashmap_cells_per_axis)
	var/max_y = min(CEILING((center_y + range) * (1 / HASHMAP_CELLSIZE), 1), hashmap_cells_per_axis)

	var/list/hashmap_level = hashmaps_by_z_level[center_turf.z]
	switch(type)
		if(HASHMAP_CONTENTS_TYPE_CLIENTS)
			for(var/list/hashmap_row as anything in hashmap_level.Copy(min_y, max_y + 1))//from testing, slightly faster than iterating numbers from min_index to max_index
				for(var/datum/spatial_hashmap_cell/cell as anything in hashmap_row.Copy(min_x, max_x + 1))
					contents_to_return += cell.client_contents

		if(HASHMAP_CONTENTS_TYPE_HEARING)
			for(var/list/hashmap_row as anything in hashmap_level.Copy(min_y, max_y + 1))
				for(var/datum/spatial_hashmap_cell/cell as anything in hashmap_row.Copy(min_x, max_x + 1))
					contents_to_return += cell.hearing_contents

	if(!include_center)
		contents_to_return -= center

	if(!length(contents_to_return))//length takes ~300 nano seconds for lists of length 600
		//ismovable(thing) takes ~300 nanoseconds as well
		return contents_to_return //we know that all of our contents are whats already in center

	if(ignore_visibility)
		for(var/atom/movable/target as anything in contents_to_return)
			var/turf/target_turf = get_turf(target)
			if(get_dist(center_turf, target_turf) > range)
				contents_to_return -= target

		return contents_to_return

	//now that we have the first list of things to return, filter for things with line of sight to x and y
	for(var/atom/movable/target as anything in contents_to_return)
		var/turf/target_turf = get_turf(target)
		var/distance = get_dist(center_turf, target_turf)

		if(distance < 2)//we're adjacent so we can see it :clueless:
			continue

		if(distance > range)
			contents_to_return -= target
			continue

		//this turf search algorithm is the worst scaling part of this proc, scaling worse than view() for moderate ranges and > 50 length contents_to_return
		//luckily its significantly faster than view for large ranges in large spaces and/or relatively few contents_to_return
		var/turf/inbetween_turf = center_turf
		while(TRUE)
			inbetween_turf = get_step(inbetween_turf, get_dir(inbetween_turf, target_turf))

			if(inbetween_turf == target_turf)//we've gotten to target's turf without returning due to turf opacity, so we must be able to see target
				break

			if(inbetween_turf.opacity || inbetween_turf.opacity_sources)//this turf or something on it is opaque so we cant see through it
				contents_to_return -= target
				break

	return contents_to_return

/datum/controller/subsystem/spatial_hashmap/proc/find_hashmap_contents_in_view_no_view(atom/center, type, range, ignore_visibility = FALSE, include_center = TRUE)//should probably just be a global proc but w/e
	var/turf/center_turf = get_turf(center)
	//currently this proc takes around 70 microseconds to complete for range = 10 in a openish space (714 per 50ms tick)
	//and about 15 microseconds for range=3 (3300 per 50ms tick)

	var/x = center_turf.x//TODOKYLER: rename to center_x and center_y
	var/y = center_turf.y

	var/list/contents_to_return = list()

	var/static/hashmap_cells_per_axis = world.maxx / HASHMAP_CELLSIZE//im going to assume this doesnt change at runtime

	//the minimum x and y cell indexes to test
	var/min_x = max(CEILING((x - range) / HASHMAP_CELLSIZE, 1), 1)//( -round(-(x) / (y)) * (y) ) -round(-((x - range) / HASHMAP_CELLSIZE))
	var/min_y = max(CEILING((y - range) / HASHMAP_CELLSIZE, 1), 1)//calculating these indices only takes around 2 microseconds

	//the maximum x and y cell indexes to test
	var/max_x = min(CEILING((x + range) / HASHMAP_CELLSIZE, 1), hashmap_cells_per_axis)
	var/max_y = min(CEILING((y + range) / HASHMAP_CELLSIZE, 1), hashmap_cells_per_axis)

	var/list/hashmap_level = hashmaps_by_z_level[center_turf.z]
	switch(type)
		if(HASHMAP_CONTENTS_TYPE_CLIENTS)
			for(var/list/hashmap_row as anything in hashmap_level.Copy(min_y, max_y+1))//from testing, slightly faster than iterating numbers from min_index to max_index
				for(var/datum/spatial_hashmap_cell/cell as anything in hashmap_row.Copy(min_x, max_x + 1))
					contents_to_return += cell.client_contents

		if(HASHMAP_CONTENTS_TYPE_HEARING)
			for(var/list/hashmap_row as anything in hashmap_level.Copy(min_y, max_y+1))
				for(var/datum/spatial_hashmap_cell/cell as anything in hashmap_row.Copy(min_x, max_x + 1))
					contents_to_return += cell.hearing_contents

	if(!include_center)
		contents_to_return -= center

	if(!length(contents_to_return))//length takes ~300 nano seconds for lists of length 600
		//ismovable(thing) takes ~300 nanoseconds as well
		return contents_to_return //we know that all of our contents are whats already in center

	if(ignore_visibility)
		for(var/atom/movable/target as anything in contents_to_return)
			var/turf/target_turf = get_turf(target)
			if(get_dist(center_turf, target_turf) > range)
				contents_to_return -= target

		return contents_to_return

	//now that we have the first list of things to return, filter for things with line of sight to x and y
	for(var/atom/movable/target as anything in contents_to_return)
		if(get_dist(center_turf, get_turf(target)) > range)
			contents_to_return -= target
			continue

	return contents_to_return

///get the hashmap cell encomapassing targets coordinates and of the specified type
/datum/controller/subsystem/spatial_hashmap/proc/get_cell_of(atom/target)
	var/turf/target_turf = get_turf(target)

	var/list/hashmap = hashmaps_by_z_level[target_turf.z]

	var/datum/spatial_hashmap_cell/cell_to_return = hashmap[CEILING(target_turf.y / HASHMAP_CELLSIZE, 1)][CEILING(target_turf.x / HASHMAP_CELLSIZE, 1)]
	return cell_to_return

///get all hashmap cells intersecting radius around center
/datum/controller/subsystem/spatial_hashmap/proc/get_cells_in_range(atom/center, range)
	var/turf/center_turf = get_turf(center)

	var/center_x = center_turf.x
	var/center_y = center_turf.y

	var/list/intersecting_hashmap_cells = list()

	var/static/hashmap_cells_per_axis = world.maxx / HASHMAP_CELLSIZE//im going to assume this doesnt change at runtime

	//the minimum x and y cell indexes to test
	var/min_x = max(CEILING((center_x - range) / HASHMAP_CELLSIZE, 1), 1)
	var/min_y = max(CEILING((center_y - range) / HASHMAP_CELLSIZE, 1), 1)//calculating these indices only takes around 2 microseconds

	//the maximum x and y cell indexes to test
	var/max_x = min(CEILING((center_x + range) / HASHMAP_CELLSIZE, 1), hashmap_cells_per_axis)
	var/max_y = min(CEILING((center_y + range) / HASHMAP_CELLSIZE, 1), hashmap_cells_per_axis)

	var/list/hashmap_level = hashmaps_by_z_level[center_turf.z]

	for(var/list/hashmap_row as anything in hashmap_level.Copy(min_y, max_y+1))
		for(var/datum/spatial_hashmap_cell/cell as anything in hashmap_row.Copy(min_x, max_x + 1))
			intersecting_hashmap_cells += cell

	return intersecting_hashmap_cells



//TODOKYLER: might be worth it to instead attach an element to hashmappable objects that does this due to proc call overhead stacking with each parent call
/turf/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!LAZYLEN(arrived.important_recursive_contents) || !(arrived.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS] || arrived.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
		return
	//this is turf/Entered so we know both arrived and us have nonzero coords but we dont know if old_loc does
	if(old_loc?.z == z && CEILING(old_loc.x / HASHMAP_CELLSIZE, 1) == CEILING(x / HASHMAP_CELLSIZE, 1) && CEILING(old_loc.y / HASHMAP_CELLSIZE, 1) == CEILING(y / HASHMAP_CELLSIZE, 1))
		return //both the old location and the new one are in the same hashmap cell

	var/datum/spatial_hashmap_cell/our_cell

	if(LAZYACCESS(arrived.important_recursive_contents, RECURSIVE_CONTENTS_CLIENT_MOBS))
		our_cell = SSspatial_hashmap.get_cell_of(src, RECURSIVE_CONTENTS_CLIENT_MOBS)
		our_cell.client_contents += arrived.important_recursive_contents[HASHMAP_CONTENTS_TYPE_CLIENTS]

	if(LAZYACCESS(arrived.important_recursive_contents, RECURSIVE_CONTENTS_HEARING_SENSITIVE))
		our_cell = SSspatial_hashmap.get_cell_of(src, RECURSIVE_CONTENTS_HEARING_SENSITIVE)
		our_cell.hearing_contents += arrived.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]

/turf/Exited(atom/movable/gone, direction)
	. = ..()
	if(!LAZYLEN(gone.important_recursive_contents) || !(gone.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS] || gone.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
		return
	var/turf/gone_turf = get_turf(gone)
	//this is turf/Exited so we know we have nonzero coords but we dont know if gone has nonzero coords
	if(gone_turf == src || gone_turf?.z == z && CEILING(gone_turf.x / HASHMAP_CELLSIZE, 1) == CEILING(x / HASHMAP_CELLSIZE, 1) && CEILING(gone_turf.y / HASHMAP_CELLSIZE, 1) == CEILING(y / HASHMAP_CELLSIZE, 1))
		return //both the old location and the new one are in the same hashmap cell

	var/datum/spatial_hashmap_cell/our_cell

	if(gone.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS])
		our_cell = SSspatial_hashmap.get_cell_of(src, RECURSIVE_CONTENTS_CLIENT_MOBS)
		our_cell.client_contents -= gone.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS]

	if(gone.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE])
		our_cell = SSspatial_hashmap.get_cell_of(src, RECURSIVE_CONTENTS_HEARING_SENSITIVE)
		our_cell.hearing_contents -= gone.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]
