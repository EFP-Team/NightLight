#define LIGHTING_OBJECT_TRANSPARENT 1
#define LIGHTING_OBJECT_DARK 2
#define LIGHTING_OBJECT_COLOR 3

/atom/movable/lighting_object
	name          = ""

	anchored      = TRUE

	icon             = LIGHTING_ICON
	icon_state       = "transparent"
	color            = null //we manually set color in init instead
	plane            = LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility     = INVISIBILITY_LIGHTING
	vis_flags = VIS_HIDE
	var/mutable_appearance/current_underlay
	var/current_state = LIGHTING_OBJECT_TRANSPARENT

	var/needs_update = FALSE
	var/turf/myturf

/atom/movable/lighting_object/Initialize(mapload)
	. = ..()
	verbs.Cut()
	//We avoid setting this in the base as if we do then the parent atom handling will add_atom_color it and that
	//is totally unsuitable for this object, as we are always changing it's colour manually
	color = LIGHTING_BASE_MATRIX

	current_underlay = mutable_appearance(LIGHTING_ICON, "transparent", layer + 1, LIGHTING_PLANE, alpha)
	current_underlay.color = LIGHTING_BASE_MATRIX
	current_underlay.invisibility = INVISIBILITY_LIGHTING

	myturf = loc
	if (myturf.lighting_object)
		qdel(myturf.lighting_object, force = TRUE)
	myturf.lighting_object = src
	myturf.luminosity = 0

	for(var/turf/open/space/S in RANGE_TURFS(1, src)) //RANGE_TURFS is in code\__HELPERS\game.dm
		S.update_starlight()

	needs_update = TRUE
	SSlighting.objects_queue += src

/atom/movable/lighting_object/Destroy(force)
	if (force)
		SSlighting.objects_queue -= src
		if (loc != myturf)
			var/turf/oldturf = get_turf(myturf)
			var/turf/newturf = get_turf(loc)
			stack_trace("A lighting object was qdeleted with a different loc then it is suppose to have ([COORD(oldturf)] -> [COORD(newturf)])")
		if (isturf(myturf))
			myturf.lighting_object = null
			myturf.luminosity = 1
		myturf = null

		return ..()

	else
		return QDEL_HINT_LETMELIVE

/atom/movable/lighting_object/proc/update()
	if (loc != myturf)
		if (loc)
			var/turf/oldturf = get_turf(myturf)
			var/turf/newturf = get_turf(loc)
			warning("A lighting object realised it's loc had changed in update() ([myturf]\[[myturf ? myturf.type : "null"]]([COORD(oldturf)]) -> [loc]\[[ loc ? loc.type : "null"]]([COORD(newturf)]))!")

		qdel(src, TRUE)
		return

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	// See LIGHTING_CORNER_DIAGONAL in lighting_corner.dm for why these values are what they are.
	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/list/corners = myturf.corners
	var/datum/lighting_corner/cr = dummy_lighting_corner
	var/datum/lighting_corner/cg = dummy_lighting_corner
	var/datum/lighting_corner/cb = dummy_lighting_corner
	var/datum/lighting_corner/ca = dummy_lighting_corner
	if (corners) //done this way for speed
		cr = corners[3] || dummy_lighting_corner
		cg = corners[2] || dummy_lighting_corner
		cb = corners[4] || dummy_lighting_corner
		ca = corners[1] || dummy_lighting_corner

	var/max = max(cr.cache_mx, cg.cache_mx, cb.cache_mx, ca.cache_mx)

	var/rr = cr.cache_r
	var/rg = cr.cache_g
	var/rb = cr.cache_b

	var/gr = cg.cache_r
	var/gg = cg.cache_g
	var/gb = cg.cache_b

	var/br = cb.cache_r
	var/bg = cb.cache_g
	var/bb = cb.cache_b

	var/ar = ca.cache_r
	var/ag = ca.cache_g
	var/ab = ca.cache_b

	#if LIGHTING_SOFT_THRESHOLD != 0
	var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points™?, it won't even be a flat 0.
	// This number is mostly arbitrary.
	var/set_luminosity = max > 1e-6
	#endif

	if((rr & gr & br & ar) && (rg + gg + bg + ag + rb + gb + bb + ab == 8) && current_state != LIGHTING_OBJECT_TRANSPARENT)
		myturf.underlays -= current_underlay
		current_underlay.icon_state = "transparent"
		current_underlay.color = null
	//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		//icon_state = "transparent"
		//color = null
		myturf.underlays += current_underlay
		current_state = LIGHTING_OBJECT_TRANSPARENT
	else if(!set_luminosity && current_state != LIGHTING_OBJECT_DARK)
		myturf.underlays -= current_underlay
		current_underlay.icon_state = "dark"
		current_underlay.color = null
		//icon_state = "dark"
		//color = null
		myturf.underlays += current_underlay
		current_state = LIGHTING_OBJECT_DARK
	else if(current_state != LIGHTING_OBJECT_COLOR)
		myturf.underlays -= current_underlay
		current_underlay.icon_state = null
		current_underlay.color = list(
			rr, rg, rb, 00,
			gr, gg, gb, 00,
			br, bg, bb, 00,
			ar, ag, ab, 00,
			00, 00, 00, 01
		)
		/*icon_state = null
		color = list(
			rr, rg, rb, 00,
			gr, gg, gb, 00,
			br, bg, bb, 00,
			ar, ag, ab, 00,
			00, 00, 00, 01
		)
		*/
		myturf.underlays += current_underlay
		current_state = LIGHTING_OBJECT_COLOR

	luminosity = set_luminosity

// Variety of overrides so the overlays don't get affected by weird things.

/atom/movable/lighting_object/ex_act(severity)
	return FALSE

/atom/movable/lighting_object/singularity_act()
	return

/atom/movable/lighting_object/singularity_pull()
	return

/atom/movable/lighting_object/blob_act()
	return

/atom/movable/lighting_object/onTransitZ()
	return

/atom/movable/lighting_object/wash(clean_types)
	SHOULD_CALL_PARENT(FALSE) // lighting objects are dirty, confirmed
	return

// Override here to prevent things accidentally moving around overlays.
/atom/movable/lighting_object/forceMove(atom/destination, no_tp=FALSE, harderforce = FALSE)
	if(harderforce)
		. = ..()

#undef LIGHTING_OBJECT_TRANSPARENT
#undef LIGHTING_OBJECT_DARK
#undef LIGHTING_OBJECT_COLOR
