/datum/component/cooking/Initialize()
	if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(create_mob_button))

/datum/component/cooking/proc/create_mob_button(mob/user, client/CL)
	SIGNAL_HANDLER

	var/datum/hud/H = user.hud_used
	var/atom/movable/screen/cook/C = new()
	C.icon = H.ui_style
	H.static_inventory += C
	CL.screen += C
	RegisterSignal(C, COMSIG_CLICK, PROC_REF(component_ui_interact))

/datum/component/cooking
	var/busy
	var/display_craftable_only = FALSE
	var/display_compact = TRUE

/* This is what procs do:
	get_environment - gets a list of things accessable for crafting by user
	get_surroundings - takes a list of things and makes a list of key-types to values-amounts of said type in the list
	check_contents - takes a recipe and a key-type list and checks if said recipe can be done with available stuff
	check_tools - takes recipe, a key-type list, and a user and checks if there are enough tools to do the stuff, checks bugs one level deep
	construct_item - takes a recipe and a user, call all the checking procs, calls do_after, checks all the things again, calls del_reqs, creates result, calls CheckParts of said result with argument being list returned by deel_reqs
	del_reqs - takes recipe and a user, loops over the recipes reqs var and tries to find everything in the list make by get_environment and delete it/add to parts list, then returns the said list
*/

/**
 * Check that the contents of the recipe meet the requirements.
 *
 * user: The /mob that initated the crafting.
 * R: The /datum/crafting_recipe being attempted.
 * contents: List of items to search for R's reqs.
 */
/datum/component/cooking/proc/check_contents(atom/a, datum/crafting_recipe/R, list/contents)
	var/list/item_instances = contents["instances"]
	var/list/machines = contents["machinery"]
	contents = contents["other"]


	var/list/requirements_list = list()

	// Process all requirements
	for(var/requirement_path in R.reqs)
		// Check we have the appropriate amount available in the contents list
		var/needed_amount = R.reqs[requirement_path]
		for(var/content_item_path in contents)
			// Right path and not blacklisted
			if(!ispath(content_item_path, requirement_path) || R.blacklist.Find(content_item_path))
				continue

			needed_amount -= contents[content_item_path]
			if(needed_amount <= 0)
				break

		if(needed_amount > 0)
			return FALSE

		// Store the instances of what we will use for R.check_requirements() for requirement_path
		var/list/instances_list = list()
		for(var/instance_path in item_instances)
			if(ispath(instance_path, requirement_path))
				instances_list += item_instances[instance_path]

		requirements_list[requirement_path] = instances_list

	for(var/requirement_path in R.chem_catalysts)
		if(contents[requirement_path] < R.chem_catalysts[requirement_path])
			return FALSE

	for(var/machinery_path in R.machinery)
		if(!machines[machinery_path])//We don't care for volume with machines, just if one is there or not
			return FALSE

	return R.check_requirements(a, requirements_list)

/datum/component/cooking/proc/get_environment(atom/a, list/blacklist = null, radius_range = 1)
	. = list()

	if(!isturf(a.loc))
		return

	for(var/atom/movable/AM in range(radius_range, a))
		if((AM.flags_1 & HOLOGRAM_1) || (blacklist && (AM.type in blacklist)))
			continue
		. += AM


/datum/component/cooking/proc/get_surroundings(atom/a, list/blacklist=null)
	. = list()
	.["tool_behaviour"] = list()
	.["other"] = list()
	.["instances"] = list()
	.["machinery"] = list()
	for(var/obj/object in get_environment(a, blacklist))
		if(isitem(object))
			var/obj/item/item = object
			LAZYADDASSOCLIST(.["instances"], item.type, item)
			if(isstack(item))
				var/obj/item/stack/stack = item
				.["other"][item.type] += stack.amount
			else if(item.tool_behaviour)
				.["tool_behaviour"] += item.tool_behaviour
				.["other"][item.type] += 1
			else
				if(is_reagent_container(item))
					var/obj/item/reagent_containers/container = item
					if(container.is_drainable())
						for(var/datum/reagent/reagent in container.reagents.reagent_list)
							.["other"][reagent.type] += reagent.volume
				.["other"][item.type] += 1
		else if (ismachinery(object))
			LAZYADDASSOCLIST(.["machinery"], object.type, object)



/// Returns a boolean on whether the tool requirements of the input recipe are satisfied by the input source and surroundings.
/datum/component/cooking/proc/check_tools(atom/source, datum/crafting_recipe/recipe, list/surroundings)
	if(!length(recipe.tool_behaviors) && !length(recipe.tool_paths))
		return TRUE
	var/list/available_tools = list()
	var/list/present_qualities = list()

	for(var/obj/item/contained_item in source.contents)
		if(contained_item.atom_storage)
			for(var/obj/item/subcontained_item in contained_item.contents)
				available_tools[subcontained_item.type] = TRUE
				if(subcontained_item.tool_behaviour)
					present_qualities[subcontained_item.tool_behaviour] = TRUE
		available_tools[contained_item.type] = TRUE
		if(contained_item.tool_behaviour)
			present_qualities[contained_item.tool_behaviour] = TRUE

	for(var/quality in surroundings["tool_behaviour"])
		present_qualities[quality] = TRUE

	for(var/path in surroundings["other"])
		available_tools[path] = TRUE

	for(var/required_quality in recipe.tool_behaviors)
		if(present_qualities[required_quality])
			continue
		return FALSE

	for(var/required_path in recipe.tool_paths)
		var/found_this_tool = FALSE
		for(var/tool_path in available_tools)
			if(!ispath(required_path, tool_path))
				continue
			found_this_tool = TRUE
			break
		if(found_this_tool)
			continue
		return FALSE

	return TRUE


/datum/component/cooking/proc/construct_item(atom/a, datum/crafting_recipe/R)
	var/list/contents = get_surroundings(a,R.blacklist)
	var/send_feedback = 1
	if(check_contents(a, R, contents))
		if(check_tools(a, R, contents))
			if(R.one_per_turf)
				for(var/content in get_turf(a))
					if(istype(content, R.result))
						return ", object already present."
			//If we're a mob we'll try a do_after; non mobs will instead instantly construct the item
			if(ismob(a) && !do_after(a, R.time, target = a))
				return "."
			contents = get_surroundings(a,R.blacklist)
			if(!check_contents(a, R, contents))
				return ", missing component."
			if(!check_tools(a, R, contents))
				return ", missing tool."
			var/list/parts = del_reqs(R, a)
			var/atom/movable/I = new R.result (get_turf(a.loc))
			I.CheckParts(parts, R)
			if(send_feedback)
				SSblackbox.record_feedback("tally", "object_crafted", 1, I.type)
			return I //Send the item back to whatever called this proc so it can handle whatever it wants to do with the new item
		return ", missing tool."
	return ", missing component."

/*Del reqs works like this:

	Loop over reqs var of the recipe
	Set var amt to the value current cycle req is pointing to, its amount of type we need to delete
	Get var/surroundings list of things accessable to crafting by get_environment()
	Check the type of the current cycle req
		If its reagent then do a while loop, inside it try to locate() reagent containers, inside such containers try to locate needed reagent, if there isn't remove thing from surroundings
			If there is enough reagent in the search result then delete the needed amount, create the same type of reagent with the same data var and put it into deletion list
			If there isn't enough take all of that reagent from the container, put into deletion list, substract the amt var by the volume of reagent, remove the container from surroundings list and keep searching
			While doing above stuff check deletion list if it already has such reagnet, if yes merge instead of adding second one
		If its stack check if it has enough amount
			If yes create new stack with the needed amount and put in into deletion list, substract taken amount from the stack
			If no put all of the stack in the deletion list, substract its amount from amt and keep searching
			While doing above stuff check deletion list if it already has such stack type, if yes try to merge them instead of adding new one
		If its anything else just locate() in in the list in a while loop, each find --s the amt var and puts the found stuff in deletion loop

	Then do a loop over parts var of the recipe
		Do similar stuff to what we have done above, but now in deletion list, until the parts conditions are satisfied keep taking from the deletion list and putting it into parts list for return

	After its done loop over deletion list and delete all the shit that wasn't taken by parts loop

	del_reqs return the list of parts resulting object will receive as argument of CheckParts proc, on the atom level it will add them all to the contents, on all other levels it calls ..() and does whatever is needed afterwards but from contents list already
*/

/datum/component/cooking/proc/del_reqs(datum/crafting_recipe/R, atom/a)
	var/list/surroundings
	var/list/Deletion = list()
	. = list()
	var/data
	var/amt
	var/list/requirements = list()
	if(R.reqs)
		requirements += R.reqs
	if(R.machinery)
		requirements += R.machinery
	main_loop:
		for(var/path_key in requirements)
			amt = R.reqs[path_key] || R.machinery[path_key]
			if(!amt)//since machinery can have 0 aka CRAFTING_MACHINERY_USE - i.e. use it, don't consume it!
				continue main_loop
			surroundings = get_environment(a, R.blacklist)
			surroundings -= Deletion
			if(ispath(path_key, /datum/reagent))
				var/datum/reagent/RG = new path_key
				var/datum/reagent/RGNT
				while(amt > 0)
					var/obj/item/reagent_containers/RC = locate() in surroundings
					RG = RC.reagents.get_reagent(path_key)
					if(RG)
						if(!locate(RG.type) in Deletion)
							Deletion += new RG.type()
						if(RG.volume > amt)
							RG.volume -= amt
							data = RG.data
							RC.reagents.conditional_update(RC)
							RC.update_appearance(UPDATE_ICON)
							RG = locate(RG.type) in Deletion
							RG.volume = amt
							RG.data += data
							continue main_loop
						else
							surroundings -= RC
							amt -= RG.volume
							RC.reagents.reagent_list -= RG
							RC.reagents.conditional_update(RC)
							RC.update_appearance(UPDATE_ICON)
							RGNT = locate(RG.type) in Deletion
							RGNT.volume += RG.volume
							RGNT.data += RG.data
							qdel(RG)
						SEND_SIGNAL(RC.reagents, COMSIG_REAGENTS_CRAFTING_PING) // - [] TODO: Make this entire thing less spaghetti
					else
						surroundings -= RC
			else if(ispath(path_key, /obj/item/stack))
				var/obj/item/stack/S
				var/obj/item/stack/SD
				while(amt > 0)
					S = locate(path_key) in surroundings
					if(S.amount >= amt)
						if(!locate(S.type) in Deletion)
							SD = new S.type()
							Deletion += SD
						S.use(amt)
						SD = locate(S.type) in Deletion
						SD.amount += amt
						continue main_loop
					else
						amt -= S.amount
						if(!locate(S.type) in Deletion)
							Deletion += S
						else
							data = S.amount
							S = locate(S.type) in Deletion
							S.add(data)
						surroundings -= S
			else
				var/atom/movable/I
				while(amt > 0)
					I = locate(path_key) in surroundings
					Deletion += I
					surroundings -= I
					amt--
	var/list/partlist = list(R.parts.len)
	for(var/M in R.parts)
		partlist[M] = R.parts[M]
	for(var/part in R.parts)
		if(istype(part, /datum/reagent))
			var/datum/reagent/RG = locate(part) in Deletion
			if(RG.volume > partlist[part])
				RG.volume = partlist[part]
			. += RG
			Deletion -= RG
			continue
		else if(isstack(part))
			var/obj/item/stack/ST = locate(part) in Deletion
			if(ST.amount > partlist[part])
				ST.amount = partlist[part]
			. += ST
			Deletion -= ST
			continue
		else
			while(partlist[part] > 0)
				var/atom/movable/AM = locate(part) in Deletion
				. += AM
				Deletion -= AM
				partlist[part] -= 1
	while(Deletion.len)
		var/DL = Deletion[Deletion.len]
		Deletion.Cut(Deletion.len)
		// Snowflake handling of reagent containers and storage atoms.
		// If we consumed them in our crafting, we should dump their contents out before qdeling them.
		if(is_reagent_container(DL))
			var/obj/item/reagent_containers/container = DL
			container.reagents.expose(container.loc, TOUCH)
		else if(istype(DL, /obj/item/storage))
			var/obj/item/storage/container = DL
			container.emptyStorage()
		qdel(DL)

/datum/component/cooking/proc/component_ui_interact(atom/movable/screen/cook/image, location, control, params, user)
	SIGNAL_HANDLER

	if(user == parent)
		INVOKE_ASYNC(src, PROC_REF(ui_interact), user)

/datum/component/cooking/ui_state(mob/user)
	return GLOB.not_incapacitated_turf_state

//For the UI related things we're going to assume the user is a mob rather than typesetting it to an atom as the UI isn't generated if the parent is an atom
/datum/component/cooking/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PersonalCooking", "Cook Book")
		ui.open()

/datum/component/cooking/ui_data(mob/user)
	var/list/data = list()
	data["busy"] = busy
	data["display_craftable_only"] = display_craftable_only
	data["display_compact"] = display_compact

	var/list/surroundings = get_surroundings(user)
	var/list/craftability = list()
	for(var/rec in GLOB.crafting_recipes)
		var/datum/crafting_recipe/R = rec

		if(!R.always_available && !(R.type in user?.mind?.learned_recipes)) //User doesn't actually know how to make this.
			continue

		if (!ispath(R.type, /datum/crafting_recipe/food/) || R.type == /datum/crafting_recipe/food)
			continue

		if(check_contents(user, R, surroundings))
			craftability["[REF(R)]"] = TRUE

	data["craftability"] = craftability
	return data

/datum/component/cooking/ui_static_data(mob/user)
	var/list/data = list()

	data["recipes"] = list()
	data["categories"] = list()
	data["foodtypes"] = list()

	if(user.has_dna())
		var/mob/living/carbon/carbon = user
		data["diet"] = carbon.dna.species.get_species_diet()

	for(var/rec in GLOB.crafting_recipes)
		var/datum/crafting_recipe/R = rec

		if(R.name == "") //This is one of the invalid parents that sneaks in
			continue

		if(!R.always_available && !(R.type in user?.mind?.learned_recipes)) //User doesn't actually know how to make this.
			continue

		if (!ispath(R.type, /datum/crafting_recipe/food/))
			continue

		if(!(R.subcategory in data["categories"]))
			data["categories"] += R.subcategory

		if(ispath(R.result, /obj/item/food))
			var/obj/item/food/item = R.result
			var/list/foodtypes = bitfield_to_list(initial(item.foodtypes), FOOD_FLAGS)
			for(var/type in foodtypes)
				if(!(type in data["foodtypes"]))
					data["foodtypes"] += type

		data["recipes"] += list(build_cooking_data(R))

	return data

/datum/component/cooking/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("make")
			var/mob/user = usr
			var/datum/crafting_recipe/crafting_recipe = locate(params["recipe"]) in GLOB.crafting_recipes
			busy = TRUE
			ui_interact(user)
			var/atom/movable/result = construct_item(user, crafting_recipe)
			if(!istext(result)) //We made an item and didn't get a fail message
				if(ismob(user) && isitem(result)) //In case the user is actually possessing a non mob like a machine
					user.put_in_hands(result)
				else
					result.forceMove(user.drop_location())
				to_chat(user, span_notice("[crafting_recipe.name] constructed."))
				user.investigate_log("[key_name(user)] crafted [crafting_recipe]", INVESTIGATE_CRAFTING)
				crafting_recipe.on_craft_completion(user, result)
			else
				to_chat(user, span_warning("Construction failed[result]"))
			busy = FALSE
		if("toggle_recipes")
			display_craftable_only = !display_craftable_only
			. = TRUE
		if("toggle_compact")
			display_compact = !display_compact
			. = TRUE

/datum/component/cooking/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/food)
	)

/datum/component/cooking/proc/build_crafting_data(datum/crafting_recipe/R)
	var/list/data = list()
	data["name"] = R.name
	data["ref"] = "[REF(R)]"
	var/list/req_text = list()
	var/list/tool_list = list()
	var/list/catalyst_text = list()

	for(var/atom/req_atom as anything in R.reqs)
		//We just need the name, so cheat-typecast to /atom for speed (even tho Reagents are /datum they DO have a "name" var)
		//Also these are typepaths so sadly we can't just do "[a]"
		req_text += "[R.reqs[req_atom]] [initial(req_atom.name)]"
	for(var/obj/machinery/content as anything in R.machinery)
		req_text += "[R.reqs[content]] [initial(content.name)]"
	if(R.additional_req_text)
		req_text += R.additional_req_text
	data["req_text"] = req_text.Join(", ")

	for(var/atom/req_catalyst as anything in R.chem_catalysts)
		catalyst_text += "[R.chem_catalysts[req_catalyst]] [initial(req_catalyst.name)]"
	data["catalyst_text"] = catalyst_text.Join(", ")

	for(var/required_quality in R.tool_behaviors)
		tool_list += required_quality
	for(var/obj/item/required_path as anything in R.tool_paths)
		tool_list += initial(required_path.name)
	data["tool_text"] = tool_list.Join(", ")

	return data

/datum/component/cooking/proc/build_cooking_data(datum/crafting_recipe/recipe)
	var/list/data = list()
	data["name"] = recipe.name
	data["ref"] = "[REF(recipe)]"

	for(var/atom/req_atom as anything in recipe.reqs)
		data["reqs"] += list(list(
			"path" = req_atom,
			"name" = initial(req_atom.name),
			"amount" = recipe.reqs[req_atom],
			"is_reagent" = ispath(req_atom, /datum/reagent/)
		))

	data["category"] = recipe.subcategory
	data["result"] = recipe.result

	if(ispath(recipe.result, /obj/item/food))
		var/obj/item/food/item = recipe.result
		data["desc"] = initial(item.desc)
		var/list/foodtypes = bitfield_to_list(initial(item.foodtypes), FOOD_FLAGS)
		for(var/type in foodtypes)
			if(!(type in data["foodtypes"]))
				data["foodtypes"] += type
		data["foodtypes"] = foodtypes
	else
		data["desc"] = "Not an item"

	return data
