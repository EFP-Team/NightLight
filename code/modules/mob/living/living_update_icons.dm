/**
 * Called whenever the mob is to be resized or when lying/standing up for carbons.
 * IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
 */
/mob/living/proc/update_transform(resize = RESIZE_DEFAULT_SIZE)
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = base_pixel_y + body_position_pixel_y_offset
	/**
	 * pixel x/y/w/z all discard values after the decimal separator.
	 * That, coupled with the rendered interpolation, may make the
	 * icons look awfuller than they would normally already be.
	 * The solution to this nit is translating the missing decimals.
	 * also flooring increases the distance from 0 for negative numbers.
	 */
	var/abs_pixel_y_offset = 0
	var/translate = 0
	if(current_size != RESIZE_DEFAULT_SIZE)
		abs_pixel_y_offset = abs(get_pixel_y_offset_standing(current_size))
		translate = (abs_pixel_y_offset - round(abs_pixel_y_offset)) * SIGN(body_position_pixel_y_offset)
	var/final_dir = dir
	var/changed = FALSE

	if(lying_angle != lying_prev && rotate_on_lying)
		changed = TRUE
		ntransform.TurnTo(lying_prev, lying_angle)
		if(lying_angle && lying_prev == 0)
			if(translate)
				ntransform.Translate(0, -translate)
			if(dir & (EAST|WEST)) //Standing to lying and facing east or west
				final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass
		else if(translate && !lying_angle && lying_prev != 0)
			ntransform.Translate(0, translate)

	if(resize != RESIZE_DEFAULT_SIZE)
		changed = TRUE
		ntransform.Scale(resize)
		current_size *= resize
		//Update the height of the maptext according to the size of the mob so they don't overlap.
		var/old_maptext_offset = body_maptext_height_offset
		body_maptext_height_offset = initial(maptext_height) * (current_size - 1) * 0.5
		maptext_height += body_maptext_height_offset - old_maptext_offset
		//Update final_pixel_y so our mob doesn't go out of the southern bounds of the tile when standing
		if(!lying_angle || !rotate_on_lying) //But not if the mob has been rotated.
			//Make sure the body position y offset is also updated
			body_position_pixel_y_offset = get_pixel_y_offset_standing(current_size)
			abs_pixel_y_offset = abs(body_position_pixel_y_offset)
			var/new_translate = (abs_pixel_y_offset - round(abs_pixel_y_offset)) * SIGN(body_position_pixel_y_offset)
			if(translate || new_translate)
				ntransform.Translate(0, new_translate - translate)
			final_pixel_y = base_pixel_y + body_position_pixel_y_offset

	if(!changed) //Nothing has been changed, nothing has to be done.
		return

	SEND_SIGNAL(src, COMSIG_PAUSE_FLOATING_ANIM, 0.3 SECONDS)
	//if true, we want to avoid any animation time, it'll tween and not rotate at all otherwise.
	var/is_opposite_angle = SIMPLIFY_DEGREES(lying_angle+180) == lying_prev
	animate(src, transform = ntransform, time = is_opposite_angle ? 0 : UPDATE_TRANSFORM_ANIMATION_TIME, pixel_y = final_pixel_y, dir = final_dir, easing = (EASE_IN|EASE_OUT))

	SEND_SIGNAL(src, COMSIG_LIVING_POST_UPDATE_TRANSFORM, resize, lying_angle, is_opposite_angle)
