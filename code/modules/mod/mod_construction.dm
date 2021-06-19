/obj/item/mod/construction
	desc = "A part used in MOD construction."

/obj/item/mod/construction/helmet
	name = "MOD helmet"
	icon_state = "helmet"

/obj/item/mod/construction/chestplate
	name = "MOD chestplate"
	icon_state = "chestplate"

/obj/item/mod/construction/gauntlets
	name = "MOD gauntlets"
	icon_state = "gauntlets"

/obj/item/mod/construction/boots
	name = "MOD boots"
	icon_state = "boots"

/obj/item/mod/construction/core
	name = "MOD core"
	icon_state = "mod-core"
	desc = "A mystical crystal able to convert cell power into energy usable by MODsuits."

/obj/item/mod/construction/armor
	name = "MOD standard armor plates"
	desc = "Armor plates used to finish a MOD"
	icon_state = "armor"
	var/theme = /datum/mod_theme

/obj/item/mod/construction/armor/engineering
	name = "MOD engineering armor plates"
	icon_state = "engineering-armor"
	theme = /datum/mod_theme/engineering

/obj/item/mod/paint
	name = "MOD paint kit"
	desc = "This kit will repaint your MODsuit to something unique."
	icon = 'icons/obj/mod.dmi'
	icon_state = "paintkit"

/obj/item/mod/construction/shell
	name = "MOD shell"
	icon_state = "mod-construction"
	desc = "An empty MOD shell."
	var/obj/item/core
	var/screwed_core = FALSE
	var/obj/item/helmet
	var/obj/item/chestplate
	var/obj/item/gauntlets
	var/obj/item/boots
	var/wrenched_assembly = FALSE
	var/screwed_assembly = FALSE
	var/icon_to_use

/obj/item/mod/construction/shell/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!core && istype(I, /obj/item/mod/construction/core)) //Construct
		if(!user.transferItemToLoc(I, src))
			return
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
		to_chat(user, span_notice("You insert [I] into [src]."))
		core = I
		icon_to_use = "core"

	if(core)
		if(I.tool_behaviour == TOOL_SCREWDRIVER) //Construct
			if(I.use_tool(src, user, 0, volume=30))
				to_chat(user, span_notice("You screw [I] into [src]."))
				screwed_core = TRUE
				icon_to_use = "screwed_core"
		else if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
			if(I.use_tool(src, user, 0, volume=30))
				core.forceMove(drop_location())
				to_chat(user, span_notice("You remove [core] from [src]."))
				core = null
				icon_to_use = null

	if(screwed_core)
		if(istype(I, /obj/item/mod/construction/helmet)) //Construct
			if(!user.transferItemToLoc(I, src))
				return
			playsound(src, 'sound/machines/click.ogg', 30, TRUE)
			to_chat(user, span_notice("You fit [I] onto [src]."))
			helmet = I
			icon_to_use = "helmet"
		else if(I.tool_behaviour == TOOL_SCREWDRIVER) //Deconstruct
			if(I.use_tool(src, user, 0, volume=30))
				to_chat(user, span_notice("You unscrew the core from [src]."))
				screwed_core = FALSE
				icon_to_use = "core"

	if(helmet)
		if(istype(I, /obj/item/mod/construction/chestplate)) //Construct
			if(!user.transferItemToLoc(I, src))
				return
			playsound(src, 'sound/machines/click.ogg', 30, TRUE)
			to_chat(user, span_notice("You fit [I] onto [src]."))
			chestplate = I
			icon_to_use = "chestplate"
		else if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
			if(I.use_tool(src, user, 0, volume=30))
				helmet.forceMove(drop_location())
				to_chat(user, span_notice("You pry [helmet] from [src]."))
				helmet = null
				icon_to_use = "screwed_core"

	if(chestplate)
		if(istype(I, /obj/item/mod/construction/gauntlets)) //Construct
			if(!user.transferItemToLoc(I, src))
				return
			playsound(src, 'sound/machines/click.ogg', 30, TRUE)
			to_chat(user, span_notice("You fit [I] onto [src]."))
			gauntlets = I
			icon_to_use = "gauntlets"
		else if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
			if(I.use_tool(src, user, 0, volume=30))
				chestplate.forceMove(drop_location())
				to_chat(user, span_notice("You pry [chestplate] from [src]."))
				chestplate = null
				icon_to_use = "helmet"

	if(gauntlets)
		if(istype(I, /obj/item/mod/construction/boots)) //Construct
			if(!user.transferItemToLoc(I, src))
				return
			playsound(src, 'sound/machines/click.ogg', 30, TRUE)
			to_chat(user, span_notice("You fit [I] onto [src]."))
			boots = I
			icon_to_use = "boots"
		else if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
			if(I.use_tool(src, user, 0, volume=30))
				gauntlets.forceMove(drop_location())
				to_chat(user, span_notice("You pry [gauntlets] from [src]."))
				gauntlets = null
				icon_to_use = "chestplate"

	if(boots)
		if(I.tool_behaviour == TOOL_WRENCH) //Construct
			if(I.use_tool(src, user, 0, volume=30))
				to_chat(user, span_notice("You wrench together the assembly."))
				wrenched_assembly = TRUE
				icon_to_use = "wrenched_assembly"
		else if(I.tool_behaviour == TOOL_CROWBAR) //Deconstruct
			if(I.use_tool(src, user, 0, volume=30))
				boots.forceMove(drop_location())
				to_chat(user, span_notice("You pry [boots] from [src]."))
				boots = null
				icon_to_use = "gauntlets"

	if(wrenched_assembly)
		if(I.tool_behaviour == TOOL_SCREWDRIVER) //Construct
			if(I.use_tool(src, user, 0, volume=30))
				to_chat(user, span_notice("You screw together the assembly."))
				screwed_assembly = TRUE
				icon_to_use = "screwed_assembly"
		else if(I.tool_behaviour == TOOL_WRENCH) //Deconstruct
			if(I.use_tool(src, user, 0, volume=30))
				to_chat(user, span_notice("You unwrench the assembled parts."))
				wrenched_assembly = FALSE
				icon_to_use = "boots"

	if(screwed_assembly)
		if(istype(I, /obj/item/mod/construction/armor)) //Construct
			var/obj/item/mod/construction/armor/external_armor = I
			if(!user.transferItemToLoc(I, src))
				return
			playsound(src, 'sound/machines/click.ogg', 30, TRUE)
			to_chat(user, span_notice("You fit [external_armor] onto [src], finishing your MODsuit."))
			var/obj/item/modsuit = new /obj/item/mod/control(drop_location(), external_armor.theme)
			qdel(src)
			user.put_in_hands(modsuit)
			return
		else if(I.tool_behaviour == TOOL_SCREWDRIVER) //Construct
			if(I.use_tool(src, user, 0, volume=30))
				to_chat(user, span_notice("You unscrew the assembled parts."))
				screwed_assembly = FALSE
				icon_to_use = "wrenched_assembly"
	update_icon_state()

/obj/item/mod/construction/shell/update_icon_state()
	. = ..()
	if(!icon_to_use)
		icon_state = "mod-construction"
	else
		icon_state = "mod-construction_[icon_to_use]"

/obj/item/mod/construction/shell/Destroy()
	QDEL_NULL(core)
	QDEL_NULL(helmet)
	QDEL_NULL(chestplate)
	QDEL_NULL(gauntlets)
	QDEL_NULL(boots)
	return ..()

/obj/item/mod/construction/shell/handle_atom_del(atom/deleted_atom)
	if(deleted_atom == core)
		core = null
	if(deleted_atom == helmet)
		helmet = null
	if(deleted_atom == chestplate)
		chestplate = null
	if(deleted_atom == gauntlets)
		gauntlets = null
	if(deleted_atom == boots)
		boots = null
	return ..()
