
/proc/alpha_mask_filter(x, y, icon/icon, render_source, flags)
	. = list("type" = "alpha")
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(icon))
		.["icon"] = icon
	if(!isnull(render_source))
		.["render_source"] = render_source
	if(!isnull(flags))
		.["flags"] = flags

/proc/angular_blur_filter(x, y, size)
	. = list("type" = "angular_blur")
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(size))
		.["size"] = size

/proc/color_matrix_filter(matrix/in_matrix, space)
	. = list("type" = "color")
	.["color"] = in_matrix
	if(!isnull(space))
		.["space"] = space

/proc/displacement_map_filter(icon, render_source, x, y, size = 32)
	. = list("type" = "displace")
	if(!isnull(icon))
		.["icon"] = icon
	if(!isnull(render_source))
		.["render_source"] = render_source
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(size))
		.["size"] = size

/proc/drop_shadow_filter(x, y, size, offset, color)
	. = list("type" = "drop_shadow")
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(size))
		.["size"] = size
	if(!isnull(offset))
		.["offset"] = offset
	if(!isnull(color))
		.["color"] = color

/proc/gauss_blur_filter(size)
	. = list("type" = "blur")
	if(!isnull(size))
		.["size"] = size

/proc/layering_filter(icon, render_source, x, y, flags, color, transform, blend_mode)
	. = list("type" = "layer")
	if(!isnull(icon))
		.["icon"] = icon
	if(!isnull(render_source))
		.["render_source"] = render_source
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(color))
		.["color"] = color
	if(!isnull(flags))
		.["flags"] = flags
	if(!isnull(transform))
		.["transform"] = transform
	if(!isnull(blend_mode))
		.["blend_mode"] = blend_mode

/proc/motion_blur_filter(x, y)
	. = list("type" = "motion_blur")
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y

/proc/outline_filter(size, color, flags)
	. = list("type" = "outline")
	if(!isnull(size))
		.["size"] = size
	if(!isnull(color))
		.["color"] = color
	if(!isnull(flags))
		.["flags"] = flags

/proc/radial_blur_filter(size, x, y)
	. = list("type" = "radial_blur")
	if(!isnull(size))
		.["size"] = size
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y

/proc/rays_filter(size, color, offset, density, threshold, factor, x, y, flags)
	. = list("type" = "rays")
	if(!isnull(size))
		.["size"] = size
	if(!isnull(color))
		.["color"] = color
	if(!isnull(offset))
		.["offset"] = offset
	if(!isnull(density))
		.["density"] = density
	if(!isnull(threshold))
		.["threshold"] = threshold
	if(!isnull(factor))
		.["factor"] = factor
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(flags))
		.["flags"] = flags

/proc/ripple_filter(radius, size, falloff, repeat, x, y, flags)
	. = list("type" = "ripple")
	if(!isnull(radius))
		.["radius"] = radius
	if(!isnull(size))
		.["size"] = size
	if(!isnull(falloff))
		.["falloff"] = falloff
	if(!isnull(repeat))
		.["repeat"] = repeat
	if(!isnull(flags))
		.["flags"] = flags
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y

/proc/wave_filter(x, y, size, offset, flags)
	. = list("type" = "wave")
	if(!isnull(size))
		.["size"] = size
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(offset))
		.["offset"] = offset
	if(!isnull(flags))
		.["flags"] = flags

/proc/apply_wibbly_filters(atom/in_atom, length)
	for(var/i in 1 to 7)
		//This is a very baffling and strange way of doing this but I am just preserving old functionality
		var/X
		var/Y
		var/rsq
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<100 || rsq>900) // Yeah let's just loop infinitely due to bad luck what's the worst that could happen?
		var/random_roll = rand()
		in_atom.add_filter("wibbly-[i]", 5, wave_filter(x = X, y = Y, size = rand() * 2.5 + 0.5, offset = random_roll))
		in_atom.animate_filter("wibbly-[i]", offset = random_roll, time = 0, loop = 3, flags = ANIMATION_PARALLEL)
		in_atom.animate_filter("wibbly-[i]", offset = random_roll - 1, time = rand() * 20 + 10)

/proc/remove_wibbly_filters(atom/in_atom)
	for(var/i in 1 to 7)
		in_atom.animate_filter("wibbly-[i]")
		in_atom.remove_filter("wibbly-[i]")
