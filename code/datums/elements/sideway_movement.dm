///A simple element that forces the mob to face a perpendicular direction when moving, like crabs.
/datum/element/sideway_movement

/datum/element/sideway_movement/Attach(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOB_CLIENT_MOVED, PROC_REF(on_client_move))
	RegisterSignal(target, COMSIG_MOVABLE_MOVED_FROM_LOOP, PROC_REF(on_moved_from_loop))

/datum/element/sideway_movement/proc/on_client_move(atom/movable/source, direction, old_dir)
	SIGNAL_HANDLER
	on_move(source, direction, old_dir)

/datum/element/sideway_movement/proc/on_moved_from_loop(atom/movable/source, datum/move_loop/loop, old_dir, direction)
	SIGNAL_HANDLER
	if(!CHECK_MOVE_LOOP_FLAGS(source, MOVEMENT_LOOP_OUTSIDE_CONTROL|MOVEMENT_LOOP_NO_DIR_UPDATE))
		on_move(source, direction, old_dir)

/datum/element/sideway_movement/proc/on_move(atom/movable/source, direction, old_dir)
	if(!source.set_dir_on_move)
		return
	if(direction == old_dir) //This means more or less we're walking straight. we don't want that.
		source.setDir(angle2dir(dir2angle(direction) + pick(90, -90)))
