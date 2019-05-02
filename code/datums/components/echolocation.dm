/datum/component/echolocation
	var/echo_range = 4
	var/cooldown = 0
	var/list/static/echo_blacklist
	var/list/static/uniques
	var/list/static/echo_images

/datum/component/echolocation/Initialize()
	. = ..()
	var/mob/M = parent
	if(!istype(M))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ECHOLOCATION_PING, .proc/echolocate)
	echo_blacklist = typecacheof(list(
	/atom/movable/lighting_object,
	/obj/effect,
	/obj/screen,
	/image,
	/turf/open,
	/area)
	)

	uniques = typecacheof(list(
	/obj/structure/table,
	/mob/living/carbon/human,
	/obj/machinery/door/airlock)
	)

	echo_images = list()
	var/datum/action/innate/echo/E = new
	var/datum/action/innate/echo/auto/A = new
	E.Grant(M)
	A.Grant(M)

/datum/component/echolocation/proc/echolocate()
	if(!(cooldown < world.time - 10))
		return
	cooldown = world.time
	var/mob/H = parent
	var/mutable_appearance/image_output
	var/list/filtered = list()
	var/list/turfs = list()
	var/list/seen = oview(echo_range, H)
	var/list/receivers = list()
	receivers += H
	for(var/I in seen)
		var/atom/A = I
		if(!(A.type in echo_blacklist) && !A.invisibility)
			if(istype(I, /obj))
				if(istype(A.loc, /turf))
					filtered += I
			if(istype(I, /mob/living))
				filtered += I
			if(istype(I, /turf/closed/wall))
				turfs += I
	for(var/mob/M in seen)
		var/datum/component/echolocation/E = M.GetComponent(/datum/component/echolocation)
		if(E)
			receivers += M
	for(var/F in filtered)
		var/atom/S = F
		if(echo_images[S.type])
			image_output = mutable_appearance(echo_images[S.type].icon, echo_images[S.type].icon_state, echo_images[S.type].layer, echo_images[S.type].plane)
			image_output.filters = echo_images[S.type].filters
			realign_icon(image_output, S)
		else
			image_output = generate_image(S)
			realign_icon(image_output, S)
			if(!(uniques[S.type]))
				echo_images[S.type] = image_output
		for(var/D in S.datum_outputs)
			var/datum/outputs/O = D
			if(O.echo_override)
				image_output = mutable_appearance(O.echo_override.icon, O.echo_override.icon_state, O.echo_override.layer, O.echo_override.plane)
				realign_icon(image_output, S)
		show_image(receivers, image_output, S)
	for(var/T in turfs)
		image_output = generate_wall_image(T)
		image_output.loc = T
		show_image(receivers, image_output, T)

/datum/component/echolocation/proc/show_image(list/receivers, mutable_appearance/mutable_echo, atom/input)
	var/image/image_echo = image(mutable_echo)
	if(istype(input, /turf))
		image_echo.loc = input
	else
		image_echo.loc = input.loc
	for(var/M in receivers)
		var/mob/receiving_mob = M
		if(receiving_mob.client)
			receiving_mob.client.images += image_echo
			addtimer(CALLBACK(src, .proc/remove_image, image_echo, receiving_mob), 30)

/datum/component/echolocation/proc/remove_image(sound_image, mob/M)
	if(M.client && sound_image)
		M.client.images -= sound_image
		qdel(sound_image)

/datum/component/echolocation/proc/generate_image(atom/input)
	var/icon/I
	if(uniques[input.type])
		I = getFlatIcon(input)
	else
		I = icon(input.icon, input.icon_state)
	I.MapColors(rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,255), rgb(0,0,0,-254))
	var/mutable_appearance/final_image = mutable_appearance(I, input.icon_state, CURSE_LAYER, 50)
	final_image.filters += filter(type="outline", size=1, color="#FFFFFF")
	return final_image

/datum/component/echolocation/proc/generate_wall_image(turf/input)
	var/icon/I = icon('icons/obj/echo_override.dmi',"wall")
	var/list/dirs = list()
	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(input, direction)
		if(istype(T, /turf/closed))
			dirs += direction
	for(var/dir in dirs)
		switch(dir)
			if(NORTH)
				I.DrawBox(null,2,32,31,31)
			if(SOUTH)
				I.DrawBox(null,2,1,31,1)
			if(EAST)
				I.DrawBox(null,32,2,32,31)
			if(WEST)
				I.DrawBox(null,1,2,1,31)
	return mutable_appearance(I, null, CURSE_LAYER, 50)

/datum/component/echolocation/proc/realign_icon(mutable_appearance/I, atom/input)
	I.dir = input.dir
	I.loc = input.loc
	I.pixel_x = input.pixel_x
	I.pixel_y = input.pixel_y

//actions


/datum/action/innate/echo
	name = "Echolocate"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "meson"

/datum/action/innate/echo/Activate()
	SEND_SIGNAL(owner, COMSIG_ECHOLOCATION_PING)

/datum/action/innate/echo/auto
	name = "Automatic Echolocation"

/datum/action/innate/echo/auto/Activate()
	addtimer(CALLBACK(src, .proc/echolocate), 10)
	to_chat(owner, "Instinct takes over your echolocation.")
	active = TRUE

/datum/action/innate/echo/auto/Deactivate()
	active = FALSE
	to_chat(owner, "You pay more attention on when to echolocate.")

/datum/action/innate/echo/auto/proc/echolocate()
	if(active)
		SEND_SIGNAL(owner, COMSIG_ECHOLOCATION_PING)
		addtimer(CALLBACK(src, .proc/echolocate), 10)