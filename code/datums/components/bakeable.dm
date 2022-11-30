///This component indicates this object can be baked in an oven.
/datum/component/bakeable
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS // So you can change bake results with various cookstuffs
	///Result atom type of baking this object
	var/atom/bake_result
	///Amount of time required to bake the food
	var/required_bake_time = 2 MINUTES
	///Is this a positive bake result?
	var/positive_result = TRUE

	///Time spent baking so far
	var/current_bake_time = 0

	/// REF() to the mob which placed us in an oven
	var/who_baked_us

/datum/component/bakeable/Initialize(bake_result, required_bake_time, positive_result, use_large_steam_sprite)
	. = ..()
	if(!isitem(parent)) //Only items support baking at the moment
		return COMPONENT_INCOMPATIBLE

	src.bake_result = bake_result
	src.required_bake_time = required_bake_time
	src.positive_result = positive_result

// Inherit the new values passed to the component
/datum/component/bakeable/InheritComponent(datum/component/bakeable/new_comp, original, bake_result, required_bake_time, positive_result, use_large_steam_sprite)
	if(!original)
		return
	if(bake_result)
		src.bake_result = bake_result
	if(required_bake_time)
		src.required_bake_time = required_bake_time
	if(positive_result)
		src.positive_result = positive_result

/datum/component/bakeable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_OVEN_PLACED_IN, PROC_REF(on_baking_start))
	RegisterSignal(parent, COMSIG_ITEM_OVEN_PROCESS, PROC_REF(on_bake))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/bakeable/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_OVEN_PLACED_IN, COMSIG_ITEM_OVEN_PROCESS, COMSIG_PARENT_EXAMINE))

/// Signal proc for [COMSIG_ITEM_OVEN_PLACED_IN] when baking starts (parent enters an oven)
/datum/component/bakeable/proc/on_baking_start(datum/source, atom/used_oven, mob/baker)
	SIGNAL_HANDLER

	if(baker)
		who_baked_us = REF(baker)

///Ran every time an item is baked by something
/datum/component/bakeable/proc/on_bake(datum/source, atom/used_oven, delta_time = 1)
	SIGNAL_HANDLER

	// Let our signal know if we're baking something good or ... burning something
	var/baking_result = positive_result ? COMPONENT_BAKING_GOOD_RESULT : COMPONENT_BAKING_BAD_RESULT

	current_bake_time += delta_time * 10 //turn it into ds
	if(current_bake_time >= required_bake_time)
		finish_baking(used_oven)

	return COMPONENT_HANDLED_BAKING | baking_result

///Ran when an object finished baking
/datum/component/bakeable/proc/finish_baking(atom/used_oven)
	var/atom/original_object = parent
	var/obj/item/plate/oven_tray/used_tray = original_object.loc
	var/atom/baked_result = new bake_result(used_tray)

	if(who_baked_us)
		ADD_TRAIT(baked_result, TRAIT_FOOD_CHEF_MADE, who_baked_us)

	if(original_object.custom_materials)
		baked_result.set_custom_materials(original_object.custom_materials, 1)

	baked_result.pixel_x = original_object.pixel_x
	baked_result.pixel_y = original_object.pixel_y
	used_tray.AddToPlate(baked_result)

	if(positive_result)
		used_oven.visible_message(span_notice("You smell something great coming from [used_oven]."), blind_message = span_notice("You smell something great..."))
		SSblackbox.record_feedback("tally", "food_made", 1, baked_result.type)
	else
		used_oven.visible_message(span_warning("You smell a burnt smell coming from [used_oven]."), blind_message = span_warning("You smell a burnt smell..."))
	SEND_SIGNAL(parent, COMSIG_ITEM_BAKED, baked_result)
	qdel(parent)

///Gives info about the items baking status so you can see if its almost done
/datum/component/bakeable/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!current_bake_time) //Not baked yet
		if(positive_result)
			examine_list += span_notice("[parent] can be <b>baked</b> into \a [initial(bake_result.name)].")
		return

	if(positive_result)
		if(current_bake_time <= required_bake_time * 0.75)
			examine_list += span_notice("[parent] probably needs to be baked a bit longer!")
		else if(current_bake_time <= required_bake_time)
			examine_list += span_notice("[parent] seems to be almost finished baking!")
	else
		examine_list += span_danger("[parent] should probably not be baked for much longer!")
