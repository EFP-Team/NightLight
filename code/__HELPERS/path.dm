#define PATH_DIST(A, B) (A.Distance_cardinal(B))
#define PATH_ADJ(A, B) (A.reachableTurftest(B))

#define PATH_REVERSE(A) ((A & MASK_ODD)<<1)|((A & MASK_EVEN)>>1)

//JPS nodes variables
/datum/jpsnode
	var/turf/tile //turf associated with the PathNode
	var/datum/jpsnode/prevNode //link to the parent PathNode
	var/f		//A* Node weight (f = g + h)
	var/g = 1	// all steps cost 1, i dunno if we really need this var, nt works fine
	var/h		//A* heuristic variable (distance)
	var/nt		//count the number of Nodes traversed
	var/jumps // how many steps it took from the last node
	var/retired
	var/turf/goal

//s,p,ph,pnt,*bf*,jmp
/datum/jpsnode/New(s,p, turf/goal)
	tile = s
	prevNode = p

	if(prevNode)
		jumps = PATH_DIST(prevNode.tile, tile)
		nt = prevNode.nt + jumps
		goal = prevNode.goal
	else
		nt = 0
	h = PATH_DIST(tile, goal)

	f = nt + h*(1+ PF_TIEBREAKER)

/datum/jpsnode/proc/setp(p, _jmp) // even jmp shouldnt be necessaryt, should be inferrable
	prevNode = p

	jumps = _jmp
	goal = prevNode.goal
	nt = prevNode.nt + jumps
	h = PATH_DIST(tile, goal)
	f = nt + h*(1+ PF_TIEBREAKER)


/datum/pathfind
	///
	var/atom/movable/caller

	var/turf/start
	///
	var/turf/end

	var/datum/heap/open //the open list

	var/list/openc //open list for node check

	var/list/path

	var/list/closed

	var/id

	var/mintargetdist = 0
	var/maxnodedepth = 50
	var/maxnodes = 50
	var/adjacent = /turf/proc/reachableTurftest
	var/dist = /turf/proc/Distance_cardinal
	var/turf/exclude = null
	var/simulated_only = FALSE

/datum/pathfind/New(atom/movable/caller, atom/goal)
	src.caller = caller
	end = get_turf(goal)
	open = new /datum/heap(/proc/HeapPathWeightCompare)
	openc = new() //open list for node check

//datum/pathfind/proc/generate_node(turf/the_tile, )
/datum/pathfind/proc/start_search()
	caller.calculating_path = TRUE

	start = get_turf(caller)
	if(!start || !end)
		stack_trace("Invalid A* start or destination")
		return FALSE
	if(start.z != end.z || start == end ) //no pathfinding between z levels
		return FALSE
	if(maxnodes)
		//if start turf is farther than maxnodes from end turf, no need to do anything
		if(PATH_DIST(start, end) > maxnodes)
			return FALSE
		maxnodedepth = maxnodes //no need to consider path longer than maxnodes

	//initialization
	var/datum/jpsnode/cur = new (start,null,end)//current processed turf
	open.Insert(cur)
	openc[start] = cur
	//then run the main loop
	var/total_tiles

	while(!open.IsEmpty() && !path)
		if(!caller)
			return
		//testing("pop")
		cur = open.Pop() //get the lower f turf in the open list
		//get the lower f node on the open list
		//if we only want to get near the target, check if we're close enough
		total_tiles++
		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.tile,dist)(end) <= mintargetdist
		cur.tile.color = COLOR_BLUE

		//found the target turf (or close enough), let's create the path to it
		if(cur.tile == end || closeenough)
			testing("done? close enough: [closeenough]")
			unwind_path(cur)
			break

		//get adjacents turfs using the adjacent proc, checking for access with id
		if((maxnodedepth)&&(cur.nt > maxnodedepth))//if too many steps, don't process that path
			continue

		lateral_scan(cur)
		cur.bf = 0
		CHECK_TICK
	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5*path.len))
			path.Swap(i,path.len-i+1)
	openc = null
	//cleaning after us
	testing("Old path done with [total_tiles] tiles popped")
	caller.calculating_path = FALSE
	return path

/datum/pathfind/proc/unwind_path(datum/jpsnode/unwind_node)
	//testing("unwind?")
	path = new()
	var/turf/iter_turf = unwind_node.tile
	path.Add(iter_turf)
	while(unwind_node.prevNode)
		var/dir_goal = get_dir(iter_turf, unwind_node.prevNode.tile)
		for(var/i = 1 to unwind_node.jumps)
			if(iter_turf == unwind_node.prevNode.tile)
				break
			iter_turf = get_step(iter_turf,dir_goal)
			path.Add(iter_turf)
			iter_turf.color = COLOR_YELLOW
		unwind_node = unwind_node.prevNode
	return path

/datum/pathfind/proc/can_step(turf/start, turf/next)
	return !call(start,adjacent)(caller, next, id, simulated_only)

/datum/pathfind/proc/can_step_dir(turf/start, turf/next)
	return !call(start,adjacent)(caller, next, id, simulated_only)

/datum/pathfind/proc/queue_node(turf/turf_for_node, turf/moved_from)
	if(!turf_for_node || !moved_from)
		return
	var/datum/jpsnode/our_node = openc[turf_for_node]
	var/datum/jpsnode/from_node = openc[moved_from]

	if(!from_node)
		CRASH("missing from node in queue?")

	var/steps_taken = PATH_DIST(moved_from, turf_for_node)

	if(our_node)
		//is already in open list, check if it's a better way from the current turf
		if((our_node.nt + steps_taken) < from_node.nt)
			our_node.setp(from_node, steps_taken)
			open.ReSort(our_node)//reorder the changed element in the list
	else
	//is not already in open list, so add it
		testing("adding further node")
		our_node = new(turf_for_node,from_node)
		open.Insert(our_node)
		openc[turf_for_node] = our_node
		turf_for_node.color = COLOR_RED

/datum/pathfind/proc/lateral_scan(datum/jpsnode/unwind_node)
	var/steps_taken = 0
	var/turf/original_turf = unwind_node.tile
	var/turf/current_turf
	for(var/i = 0 to 3)
		steps_taken = 0
		current_turf = original_turf
		var/f= 1<<i //get cardinal directions.1,2,4,8
		while(TRUE)
			var/closeenough
			if(mintargetdist)
				closeenough = (PATH_DIST(current_turf, end) <= mintargetdist)
			if(current_turf == end || closeenough)
				testing("done? lat close enough: [closeenough]")
				var/datum/jpsnode/final_node = new(current_turf,unwind_node)
				unwind_path(final_node)
				return

			if(steps_taken > 30)
				testing("too many steps, breaking to next")
				break
			if(!(unwind_node.bf & f))
				//testing("skip dir: [f] br: [cur.bf]")
				break

			var/turf/next_turf = get_step(current_turf,f)
			next_turf.color = COLOR_GRAY
			if(next_turf == exclude || !call(current_turf,adjacent)(caller, next_turf, id, simulated_only)) //typecheck?
				break

			steps_taken++
			testing("taking step [steps_taken] in dir [f]")


			var/r=PATH_REVERSE(f) //getting reverse direction throught swapping even and odd bits.((f & 01010101)<<1)|((f & 10101010)>>1)
			var/newt = unwind_node.nt + steps_taken//PATH_DIST(cur.tile, next_turf)

			var/next_interesting = FALSE

			for(var/i2 = 0 to 3)
				var/f2= 1<<i2 //get cardinal directions.1,2,4,8
				if(r == f2 || f == f2)  // not going in the continuing direction, check the left and right turns
					continue
				//if(f != f2)
				var/turf/possible_block = get_step(current_turf, f2)
				var/turf/possible_interest = get_step(next_turf, f2)
				if(!call(current_turf,adjacent)(caller, possible_block, id, simulated_only) && call(next_turf,adjacent)(caller, possible_interest, id, simulated_only))
					var/datum/jpsnode/neighbor_node = openc[possible_interest]
					//testing("let's see if CN exists [CN]")
					if(neighbor_node)
					//is already in open list, check if it's a better way from the current turf

						if((newt < neighbor_node.nt))
							neighbor_node.setp(unwind_node, steps_taken)
							open.ReSort(neighbor_node)//reorder the changed element in the list
					else
					//is not already in open list, so add it
						testing("adding neighbor node")
						neighbor_node = new(possible_interest,unwind_node)
						open.Insert(neighbor_node)
						openc[possible_interest] = neighbor_node
						next_interesting = TRUE
						possible_interest.color = COLOR_RED

			var/turf/continuing_turf = get_step(next_turf, f)
			if(next_interesting || !call(next_turf,adjacent)(caller, continuing_turf, id, simulated_only))
				var/datum/jpsnode/next_node = openc[next_turf]  //current checking turf
				//testing("let's see if CN exists [CN]")
				if(next_node)
				//is already in open list, check if it's a better way from the current turf

					if((newt < next_node.nt))
						next_node.setp(unwind_node, steps_taken)
						open.ReSort(next_node)//reorder the changed element in the list
				else
				//is not already in open list, so add it
					testing("adding further node")
					next_node = new(next_turf,unwind_node, steps_taken, end)
					open.Insert(next_node)
					openc[next_turf] = next_node
					next_interesting = TRUE
					next_turf.color = COLOR_RED
				break
			current_turf = next_turf
		testing("took [steps_taken] steps in dir [f]")



/datum/pathfind/proc/lateral_scan_spec(datum/jpsnode/unwind_node, heading)
	var/steps_taken = 0
	var/turf/original_turf = unwind_node.tile
	var/turf/current_turf = original_turf

	while(TRUE)
		var/closeenough
		if(mintargetdist)
			closeenough = (PATH_DIST(current_turf, end) <= mintargetdist)
		if(current_turf == end || closeenough)
			testing("done? lat close enough: [closeenough]")
			var/datum/jpsnode/final_node = new(current_turf,unwind_node)
			//open.Insert(current_turf)
			//openc[possible_interest] = neighbor_node
			unwind_path(final_node)
			return

		if(steps_taken > 30)
			testing("too many steps, breaking to next")
			break
		/*if(!(unwind_node.bf & heading))
			//testing("skip dir: [f] br: [cur.bf]")
			break
		*/

		var/turf/next_turf = get_step(current_turf,heading)
		next_turf.color = COLOR_GRAY
		if(!can_step(current_turf, next_turf)) //typecheck?
			return

		steps_taken++
		testing("taking step [steps_taken] in dir [heading]")


		var/r=PATH_REVERSE(heading) //getting reverse direction throught swapping even and odd bits.((f & 01010101)<<1)|((f & 10101010)>>1)
		var/newt = unwind_node.nt + steps_taken//PATH_DIST(cur.tile, next_turf)


		switch(heading)
			if(NORTH)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					return current_turf
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					return current_turf
			if(SOUTH)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					return current_turf
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					return current_turf
			if(EAST)
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					return current_turf
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					return current_turf
			if(WEST)
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					return current_turf
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					return current_turf

	testing("took [steps_taken] steps in dir [heading]")


/datum/pathfind/proc/diagonal_scan_spec(datum/jpsnode/unwind_node, x_heading, y_heading)
	var/steps_taken = 0
	var/turf/original_turf = unwind_node.tile
	var/turf/current_turf = original_turf

	while(TRUE)
		var/closeenough
		if(mintargetdist)
			closeenough = (PATH_DIST(current_turf, end) <= mintargetdist)
		if(current_turf == end || closeenough)
			testing("done? lat close enough: [closeenough]")
			var/datum/jpsnode/final_node = new(current_turf,unwind_node)
			//open.Insert(current_turf)
			//openc[possible_interest] = neighbor_node
			unwind_path(final_node)
			return

		if(steps_taken > 30)
			testing("too many steps, breaking to next")
			break
		/*if(!(unwind_node.bf & heading))
			//testing("skip dir: [f] br: [cur.bf]")
			break
		*/

		var/turf/next_turf = get_step(current_turf,heading)
		next_turf.color = COLOR_GRAY
		if(!can_step(current_turf, next_turf)) //typecheck?
			return

		steps_taken++
		testing("taking step [steps_taken] in dir [heading]")


		var/r=PATH_REVERSE(heading) //getting reverse direction throught swapping even and odd bits.((f & 01010101)<<1)|((f & 10101010)>>1)
		var/newt = unwind_node.nt + steps_taken//PATH_DIST(cur.tile, next_turf)


		switch(heading)
			if(NORTHWEST)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					return current_turf
				else
					queue_node(lateral_scan_spec(current_turf, WEST)) // this is a turf not a node, fix
					//cardinal scan west
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					return current_turf
				else
					queue_node(lateral_scan_spec(current_turf, NORTH)) // this is a turf not a node, fix
					//cardinal scan north
			if(NORTHEAST)
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					return current_turf
				else
					queue_node(lateral_scan_spec(current_turf, EAST)) // this is a turf not a node, fix
					//cardinal scan east
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					return current_turf
				else
					queue_node(lateral_scan_spec(current_turf, NORTH)) // this is a turf not a node, fix
					//cardinal scan north
			if(SOUTHWEST)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					return current_turf
				else
					queue_node(lateral_scan_spec(current_turf, WEST)) // this is a turf not a node, fix
					//cardinal scan west
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					return current_turf
				else
					queue_node(lateral_scan_spec(current_turf, SOUTH)) // this is a turf not a node, fix
					//cardinal scan south
			if(SOUTHEAST)
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					return current_turf
				else
					queue_node(lateral_scan_spec(current_turf, EAST)) // this is a turf not a node, fix
					//cardinal scan east
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					return current_turf
				else
					queue_node(lateral_scan_spec(current_turf, SOUTH)) // this is a turf not a node, fix
					//cardinal scan south

	testing("took [steps_taken] steps in dir [heading]")




/datum/pathfind/proc/insert_node()
	neighbor_node = new(possible_interest,unwind_node,PATH_DIST(possible_interest, end),newt,15^r, steps_taken)
	open.Insert(neighbor_node)
	openc[possible_interest] = neighbor_node
	next_interesting = TRUE
	possible_interest.color = COLOR_RED
