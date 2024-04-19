/proc/getviewsize(view)
	if(!view) // Just to avoid any runtimes that could otherwise cause constant disconnect loops.
		stack_trace("Missing value for 'view' in getviewsize(), defaulting to world.view!")
		view = world.view

	if(isnum(view))
		var/totalviewrange = (view < 0 ? -1 : 1) + 2 * view
		return list(totalviewrange, totalviewrange)
	else
		var/list/viewrangelist = splittext(view, "x")
		return list(text2num(viewrangelist[1]), text2num(viewrangelist[2]))


/// Takes a string or num view, and converts it to pixel width/height in a list(pixel_width, pixel_height)
/proc/view_to_pixels(view)
	if(!view)
		return list(0, 0)
	var/list/view_info = getviewsize(view)
	view_info[1] *= world.icon_size
	view_info[2] *= world.icon_size
	return view_info


/// Frustrated with bugs in can_see(), this instead uses viewers for a much more effective approach.

/// Basic check to see if the src object can see the target object. Default distance is 8.
#define CAN_I_SEE(target) (src in viewers(7, target))


/// Checks if the source can see the target object. Ie, can X object be seen by Y user.
#define CAN_THEY_SEE(target, source) (source in viewers(7, target))


/// Further checks distance between source and target.
#define CAN_SEE_RANGED(target, source, dist) (source in viewers(dist, target))
