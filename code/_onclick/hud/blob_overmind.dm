
/obj/screen/blob
	icon = 'icons/mob/blob.dmi'

/obj/screen/blob/MouseEntered(location,control,params)
	openToolTip(usr,src,params,title = name,content = desc, theme = "blob")

/obj/screen/blob/MouseExited()
	closeToolTip(usr)

/obj/screen/blob/blob_help
	icon_state = "ui_help"
	name = "Blob Help"
	desc = "Help on playing blob!"

/obj/screen/blob/blob_help/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.blob_help()

/obj/screen/blob/jump_to_node
	icon_state = "ui_tonode"
	name = "Jump to Node"
	desc = "Moves your camera to a selected blob node."

/obj/screen/blob/jump_to_node/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.jump_to_node()

/obj/screen/blob/jump_to_core
	icon_state = "ui_tocore"
	name = "Jump to Core"
	desc = "Moves your camera to your blob core."

/obj/screen/blob/jump_to_core/MouseEntered(location,control,params)
	if(hud && hud.mymob && isovermind(hud.mymob))
		var/mob/camera/blob/B = hud.mymob
		if(!B.placed)
			name = "Place Blob Core"
			desc = "Attempt to place your blob core at this location."
		else
			name = initial(name)
			desc = initial(desc)
	..()

/obj/screen/blob/jump_to_core/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		if(!B.placed)
			B.place_blob_core(0)
		B.transport_core()

/obj/screen/blob/blobbernaut
	icon_state = "ui_blobbernaut"
	name = "Produce Blobbernaut (40)"
	desc = "Produces a strong, smart blobbernaut from a factory blob for 40 resources.<br>The factory blob used will become fragile and unable to produce spores."

/obj/screen/blob/blobbernaut/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_blobbernaut()

/obj/screen/blob/resource_blob
	icon_state = "ui_resource"
	name = "Produce Resource Blob (40)"
	desc = "Produces a resource blob for 40 resources.<br>Resource blobs will give you resources every few seconds."

/obj/screen/blob/resource_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_resource()

/obj/screen/blob/node_blob
	icon_state = "ui_node"
	name = "Produce Node Blob (50)"
	desc = "Produces a node blob for 50 resources.<br>Node blobs will expand and activate nearby resource and factory blobs."

/obj/screen/blob/node_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_node()

/obj/screen/blob/factory_blob
	icon_state = "ui_factory"
	name = "Produce Factory Blob (60)"
	desc = "Produces a factory blob for 60 resources.<br>Factory blobs will produce spores every few seconds."

/obj/screen/blob/factory_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_factory()

/obj/screen/blob/readapt_strain
	icon_state = "ui_chemswap"
	name = "Readapt Strain (40)"
	desc = "Allows you to choose a new strain from 4 random choices for 40 resources."

/obj/screen/blob/readapt_strain/MouseEntered(location,control,params)
	if(hud && hud.mymob && isovermind(hud.mymob))
		var/mob/camera/blob/B = hud.mymob
		if(B.free_strain_rerolls)
			name = "Readapt Strain (FREE)"
			desc = "Randomly rerolls your strain for free."
		else
			name = initial(name)
			desc = initial(desc)
	..()

/obj/screen/blob/readapt_strain/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.strain_reroll()

/obj/screen/blob/relocate_core
	icon_state = "ui_swap"
	name = "Relocate Core (80)"
	desc = "Swaps a node and your core for 80 resources."

/obj/screen/blob/relocate_core/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.relocate_core()

/datum/hud/blob_overmind/New(mob/owner)
	..()
	var/obj/screen/using

	blobpwrdisplay = new /obj/screen()
	blobpwrdisplay.name = "blob power"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blobpwrdisplay.layer = ABOVE_HUD_LAYER
	blobpwrdisplay.plane = ABOVE_HUD_PLANE
	blobpwrdisplay.hud = src
	infodisplay += blobpwrdisplay

	healths = new /obj/screen/healths/blob()
	healths.hud = src
	infodisplay += healths

	using = new /obj/screen/blob/blob_help()
	using.screen_loc = "WEST:6,NORTH:-3"
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/jump_to_node()
	using.screen_loc = ui_inventory
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/jump_to_core()
	using.screen_loc = ui_zonesel
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/blobbernaut()
	using.screen_loc = ui_belt
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/resource_blob()
	using.screen_loc = ui_back
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/node_blob()
	using.screen_loc = ui_hand_position(2)
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/factory_blob()
	using.screen_loc = ui_hand_position(1)
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/readapt_strain()
	using.screen_loc = ui_storage1
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/relocate_core()
	using.screen_loc = ui_storage2
	using.hud = src
	static_inventory += using
