/*!
	This datum should be used for handling mineral contents of machines and whatever else is supposed to hold minerals and make use of them.

	Variables:
		amount - raw amount of the mineral this container is holding, calculated by the defined value SHEET_MATERIAL_AMOUNT=SHEET_MATERIAL_AMOUNT.
		max_amount - max raw amount of mineral this container can hold.
		sheet_type - type of the mineral sheet the container handles, used for output.
		parent - object that this container is being used by, used for output.
		MAX_STACK_SIZE - size of a stack of mineral sheets. Constant.
*/

/datum/component/material_container
	/// The total amount of materials this material container contains
	var/total_amount = 0
	/// The maximum amount of materials this material container can contain
	var/max_amount
	/// Map of material ref -> amount
	var/list/materials //Map of key = material ref | Value = amount
	/// The list of materials that this material container can accept
	var/list/allowed_materials
	/// The typecache of things that this material container can accept
	var/list/allowed_item_typecache
	/// The last main material that was inserted into this container
	var/last_inserted_id
	/// Whether or not this material container allows specific amounts from sheets to be inserted
	var/precise_insertion = FALSE
	/// A callback for checking wheter we can insert a material into this container
	var/datum/callback/insertion_check
	/// A callback invoked before materials are inserted into this container
	var/datum/callback/precondition
	/// A callback invoked after materials are inserted into this container
	var/datum/callback/after_insert
	/// A callback invoked after sheets are retrieve from this container
	var/datum/callback/after_retrieve
	/// The material container flags. See __DEFINES/materials.dm.
	var/mat_container_flags

/// Sets up the proper signals and fills the list of materials with the appropriate references.
/datum/component/material_container/Initialize(list/init_mats,
			max_amt = 0,
			_mat_container_flags=NONE,
			list/allowed_mats=init_mats,
			list/allowed_items,
			datum/callback/_insertion_check,
			datum/callback/_precondition,
			datum/callback/_after_insert,
			datum/callback/_after_retrieve)

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	materials = list()
	max_amount = max(0, max_amt)
	mat_container_flags = _mat_container_flags

	allowed_materials = allowed_mats || list()
	if(allowed_items)
		if(ispath(allowed_items) && allowed_items == /obj/item/stack)
			allowed_item_typecache = GLOB.typecache_stack
		else
			allowed_item_typecache = typecacheof(allowed_items)

	insertion_check = _insertion_check
	precondition = _precondition
	after_insert = _after_insert
	after_retrieve = _after_retrieve

	for(var/mat in init_mats) //Make the assoc list material reference -> amount
		var/mat_ref = GET_MATERIAL_REF(mat)
		if(isnull(mat_ref))
			continue
		var/mat_amt = init_mats[mat]
		if(isnull(mat_amt))
			mat_amt = 0
		materials[mat_ref] += mat_amt

	if(_mat_container_flags & MATCONTAINER_NO_INSERT)
		return

	var/atom/atom_target = parent
	atom_target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

	RegisterSignal(atom_target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

/datum/component/material_container/Destroy(force, silent)
	materials = null
	allowed_materials = null
	if(insertion_check)
		QDEL_NULL(insertion_check)
	if(precondition)
		QDEL_NULL(precondition)
	if(after_insert)
		QDEL_NULL(after_insert)
	return ..()


/datum/component/material_container/RegisterWithParent()
	. = ..()

	if(!(mat_container_flags & MATCONTAINER_NO_INSERT))
		RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	if(mat_container_flags & MATCONTAINER_EXAMINE)
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))


/datum/component/material_container/vv_edit_var(var_name, var_value)
	var/old_flags = mat_container_flags
	. = ..()
	if(var_name == NAMEOF(src, mat_container_flags) && parent)
		if(!(old_flags & MATCONTAINER_EXAMINE) && mat_container_flags & MATCONTAINER_EXAMINE)
			RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
		else if(old_flags & MATCONTAINER_EXAMINE && !(mat_container_flags & MATCONTAINER_EXAMINE))
			UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)

		if(old_flags & MATCONTAINER_NO_INSERT && !(mat_container_flags & MATCONTAINER_NO_INSERT))
			RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
		else if(!(old_flags & MATCONTAINER_NO_INSERT) && mat_container_flags & MATCONTAINER_NO_INSERT)
			UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)


/datum/component/material_container/proc/on_examine(datum/source, mob/user, list/examine_texts)
	SIGNAL_HANDLER

	for(var/I in materials)
		var/datum/material/M = I
		var/amt = materials[I]
		if(amt)
			examine_texts += span_notice("It has [amt] units of [lowertext(M.name)] stored.")

/// Proc that allows players to fill the parent with mats
/datum/component/material_container/proc/on_attackby(datum/source, obj/item/I, mob/living/user)
	SIGNAL_HANDLER

	var/list/tc = allowed_item_typecache
	if(!(mat_container_flags & MATCONTAINER_ANY_INTENT) && user.combat_mode)
		return
	if(I.item_flags & ABSTRACT)
		return
	if((I.flags_1 & HOLOGRAM_1) || (I.item_flags & NO_MAT_REDEMPTION) || (tc && !is_type_in_typecache(I, tc)))
		if(!(mat_container_flags & MATCONTAINER_SILENT))
			to_chat(user, span_warning("[parent] won't accept [I]!"))
		return
	. = COMPONENT_NO_AFTERATTACK
	var/datum/callback/pc = precondition
	if(pc && !pc.Invoke(user))
		return
	var/material_amount = get_item_material_amount(I, mat_container_flags)
	if(!material_amount)
		to_chat(user, span_warning("[I] does not contain sufficient materials to be accepted by [parent]."))
		return
	if(!has_space(material_amount))
		if(isstack(I))
			//figure out how much space is left
			var/space_left = max_amount - total_amount
			//figure out the amount of sheets that can fit that space
			var/obj/item/stack/stack_to_split = I
			var/material_per_sheet = material_amount / stack_to_split.amount
			var/sheets_to_insert = round(space_left / material_per_sheet)
			if(!sheets_to_insert)
				to_chat(user, span_warning("[parent] can't hold any more of [I] sheets."))
				return
			//split the amount we don't need off
			INVOKE_ASYNC(stack_to_split, TYPE_PROC_REF(/obj/item/stack, split_stack), user, stack_to_split.amount - sheets_to_insert)
		else
			to_chat(user, span_warning("[I] contains more materials than [parent] has space to hold."))
			return
	user_insert(I, user, mat_container_flags)

/// Proc used for when player inserts materials
/datum/component/material_container/proc/user_insert(obj/item/held_item, mob/living/user, breakdown_flags = mat_container_flags)
	set waitfor = FALSE
	var/requested_amount
	var/active_held = user.get_active_held_item()  // differs from I when using TK
	if(isstack(held_item) && precise_insertion)
		var/atom/current_parent = parent
		var/obj/item/stack/item_stack = held_item
		requested_amount = tgui_input_number(user, "How much do you want to insert?", "Inserting [item_stack.singular_name]s", item_stack.amount, item_stack.amount)
		if(!requested_amount || QDELETED(held_item) || QDELETED(user) || QDELETED(src))
			return
		if(parent != current_parent || user.get_active_held_item() != active_held)
			return
	if(!user.temporarilyRemoveItemFromInventory(held_item))
		to_chat(user, span_warning("[held_item] is stuck to you and cannot be placed into [parent]."))
		return
	var/held_item_name = held_item.name // insert_item() will delete the item when actually inserted.
	var/inserted = insert_item(held_item, stack_amt = requested_amount, breakdown_flags= mat_container_flags)
	if(inserted)
		to_chat(user, span_notice("You insert a material total of [held_item_name] into [parent]."))
		qdel(held_item)
	else if(held_item == active_held)
		user.put_in_active_hand(held_item)

/// Proc specifically for inserting items, returns the amount of materials entered.
/datum/component/material_container/proc/insert_item(obj/item/inserted, multiplier = 1, stack_amt, breakdown_flags = mat_container_flags)
	if(QDELETED(inserted))
		return FALSE

	multiplier = CEILING(multiplier, 0.01)

	var/material_amount = get_item_material_amount(inserted, breakdown_flags)
	if(!material_amount || !has_space(material_amount))
		return FALSE

	last_inserted_id = insert_item_materials(inserted, multiplier, breakdown_flags)
	after_insert?.Invoke(inserted, last_inserted_id, material_amount, src)
	qdel(inserted)
	return material_amount

/**
 * Inserts the relevant materials from an item into this material container.
 *
 * Arguments:
 * - [source][/obj/item]: The source of the materials we are inserting.
 * - multiplier: The multiplier for the materials being inserted.
 * - breakdown_flags: The breakdown bitflags that will be used to retrieve the materials from the source
 */
/datum/component/material_container/proc/insert_item_materials(obj/item/source, multiplier = 1, breakdown_flags = mat_container_flags)
	var/primary_mat
	var/max_mat_value = 0
	var/list/item_materials = source.get_material_composition(breakdown_flags)
	for(var/MAT in item_materials)
		if(!can_hold_material(MAT))
			continue
		materials[MAT] += item_materials[MAT] * multiplier
		total_amount += item_materials[MAT] * multiplier
		if(item_materials[MAT] > max_mat_value)
			max_mat_value = item_materials[MAT]
			primary_mat = MAT

	return primary_mat

/**
 * The default check for whether we can add materials to this material container.
 *
 * Arguments:
 * - [mat][/atom/material]: The material we are checking for insertability.
 */
/datum/component/material_container/proc/can_hold_material(datum/material/mat)
	if(mat in allowed_materials)
		return TRUE
	if(istype(mat) && ((mat.id in allowed_materials) || (mat.type in allowed_materials)))
		allowed_materials += mat // This could get messy with passing lists by ref... but if you're doing that the list expansion is probably being taken care of elsewhere anyway...
		return TRUE
	if(insertion_check?.Invoke(mat))
		allowed_materials += mat
		return TRUE
	return FALSE

/// For inserting an amount of material
/datum/component/material_container/proc/insert_amount_mat(amt, datum/material/mat)
	if(amt <= 0 || !has_space(amt))
		return 0

	var/total_amount_saved = total_amount
	if(mat)
		if(!istype(mat))
			mat = GET_MATERIAL_REF(mat)
		materials[mat] += amt
	else
		var/num_materials = length(materials)
		if(!num_materials)
			return 0

		amt /= num_materials
		for(var/i in materials)
			materials[i] += amt
			total_amount += amt
	return (total_amount - total_amount_saved)

/// Uses an amount of a specific material, effectively removing it.
/datum/component/material_container/proc/use_amount_mat(amt, datum/material/mat)
	if(!istype(mat))
		mat = GET_MATERIAL_REF(mat)

	if(!mat)
		return 0
	var/amount = materials[mat]
	if(amount < amt)
		return 0

	materials[mat] -= amt
	total_amount -= amt
	return amt

/// Proc for transfering materials to another container.
/datum/component/material_container/proc/transer_amt_to(datum/component/material_container/T, amt, datum/material/mat)
	if(!istype(mat))
		mat = GET_MATERIAL_REF(mat)
	if((amt == 0) || (!T) || (!mat))
		return FALSE
	if(amt<0)
		return T.transer_amt_to(src, -amt, mat)
	var/tr = min(amt, materials[mat], T.can_insert_amount_mat(amt, mat))
	if(tr)
		use_amount_mat(tr, mat)
		T.insert_amount_mat(tr, mat)
		return tr
	return FALSE

/// Proc for checking if there is room in the component, returning the amount or else the amount lacking.
/datum/component/material_container/proc/can_insert_amount_mat(amt, datum/material/mat)
	if(!amt || !mat)
		return 0

	if((total_amount + amt) <= max_amount)
		return amt
	else
		return (max_amount - total_amount)


/// For consuming a dictionary of materials. mats is the map of materials to use and the corresponding amounts, example: list(M/datum/material/glass =100, datum/material/iron=SMALL_MATERIAL_AMOUNT * 2)
/datum/component/material_container/proc/use_materials(list/mats, multiplier=1)
	if(!mats || !length(mats))
		return FALSE

	var/list/mats_to_remove = list() //Assoc list MAT | AMOUNT

	for(var/x in mats) //Loop through all required materials
		var/datum/material/req_mat = x
		if(!istype(req_mat))
			req_mat = GET_MATERIAL_REF(req_mat) //Get the ref if necesary
		if(!materials[req_mat]) //Do we have the resource?
			return FALSE //Can't afford it
		var/amount_required = mats[x] * multiplier
		if(amount_required < 0)
			return FALSE //No negative mats
		if(!(materials[req_mat] >= amount_required)) // do we have enough of the resource?
			return FALSE //Can't afford it
		mats_to_remove[req_mat] += amount_required //Add it to the assoc list of things to remove
		continue

	var/total_amount_save = total_amount

	for(var/i in mats_to_remove)
		total_amount_save -= use_amount_mat(mats_to_remove[i], i)

	return total_amount_save - total_amount

/// For spawning mineral sheets at a specific location. Used by machines to output sheets.
/datum/component/material_container/proc/retrieve_sheets(sheet_amt, datum/material/material, atom/target = null)
	if(!material.sheet_type)
		return 0 //Add greyscale sheet handling here later
	if(sheet_amt <= 0)
		return 0

	if(!target)
		var/atom/parent_atom = parent
		target = parent_atom.drop_location()
	if(materials[material] < (sheet_amt * SHEET_MATERIAL_AMOUNT))
		sheet_amt = round(materials[material] / SHEET_MATERIAL_AMOUNT)
	var/count = 0
	while(sheet_amt > MAX_STACK_SIZE)
		var/obj/item/stack/sheet/new_sheets = new material.sheet_type(target, MAX_STACK_SIZE, null, list((material) = SHEET_MATERIAL_AMOUNT))
		after_retrieve?.Invoke(new_sheets)
		count += MAX_STACK_SIZE
		use_amount_mat(sheet_amt * SHEET_MATERIAL_AMOUNT, material)
		sheet_amt -= MAX_STACK_SIZE
	if(sheet_amt >= 1)
		var/obj/item/stack/sheet/new_sheets = new material.sheet_type(target, sheet_amt, null, list((material) = SHEET_MATERIAL_AMOUNT))
		after_retrieve?.Invoke(new_sheets)
		count += sheet_amt
		use_amount_mat(sheet_amt * SHEET_MATERIAL_AMOUNT, material)
	return count


/// Proc to get all the materials and dump them as sheets
/datum/component/material_container/proc/retrieve_all(target = null)
	var/result = 0
	for(var/MAT in materials)
		var/amount = materials[MAT]
		result += retrieve_sheets(amount2sheet(amount), MAT, target)
	return result

/// Proc that returns TRUE if the container has space
/datum/component/material_container/proc/has_space(amt = 0)
	return (total_amount + amt) <= max_amount

/// Checks if its possible to afford a certain amount of materials. Takes a dictionary of materials.
/datum/component/material_container/proc/has_materials(list/mats, multiplier=1)
	if(!mats || !mats.len)
		return FALSE

	for(var/x in mats) //Loop through all required materials
		var/datum/material/req_mat = x
		if(!istype(req_mat))
			if(ispath(req_mat)) //Is this an actual material, or is it a category?
				req_mat = GET_MATERIAL_REF(req_mat) //Get the ref

			else // Its a category. (For example MAT_CATEGORY_RIGID)
				if(!has_enough_of_category(req_mat, mats[x], multiplier)) //Do we have enough of this category?
					return FALSE
				else
					continue

		if(!has_enough_of_material(req_mat, mats[x], multiplier))//Not a category, so just check the normal way
			return FALSE

	return TRUE

/// Returns all the categories in a recipe.
/datum/component/material_container/proc/get_categories(list/mats)
	var/list/categories = list()
	for(var/x in mats) //Loop through all required materials
		if(!istext(x)) //This means its not a category
			continue
		categories += x
	return categories

/// Returns TRUE if you have enough of the specified material.
/datum/component/material_container/proc/has_enough_of_material(datum/material/req_mat, amount, multiplier=1)
	if(!materials[req_mat]) //Do we have the resource?
		return FALSE //Can't afford it
	var/amount_required = amount * multiplier
	if(materials[req_mat] >= amount_required) // do we have enough of the resource?
		return TRUE
	return FALSE //Can't afford it

/// Returns TRUE if you have enough of a specified material category (Which could be multiple materials)
/datum/component/material_container/proc/has_enough_of_category(category, amount, multiplier=1)
	for(var/i in SSmaterials.materials_by_category[category])
		var/datum/material/mat = i
		if(materials[mat] >= amount) //we have enough
			return TRUE
	return FALSE

/// Turns a material amount into the amount of sheets it should output
/datum/component/material_container/proc/amount2sheet(amt)
	if(amt >= SHEET_MATERIAL_AMOUNT)
		return round(amt / SHEET_MATERIAL_AMOUNT)
	return FALSE

/// Turns an amount of sheets into the amount of material amount it should output
/datum/component/material_container/proc/sheet2amount(sheet_amt)
	if(sheet_amt > 0)
		return sheet_amt * SHEET_MATERIAL_AMOUNT
	return FALSE


///returns the amount of material relevant to this container; if this container does not support glass, any glass in 'I' will not be taken into account
/datum/component/material_container/proc/get_item_material_amount(obj/item/I, breakdown_flags = mat_container_flags)
	if(!istype(I) || !I.custom_materials)
		return 0
	var/material_amount = 0
	var/list/item_materials = I.get_material_composition(breakdown_flags)
	for(var/MAT in item_materials)
		if(!can_hold_material(MAT))
			continue
		material_amount += item_materials[MAT]
	return material_amount

/// Returns the amount of a specific material in this container.
/datum/component/material_container/proc/get_material_amount(datum/material/mat)
	if(!istype(mat))
		mat = GET_MATERIAL_REF(mat)
	return materials[mat]

/// List format is list(material_name = list(amount = ..., ref = ..., etc.))
/datum/component/material_container/ui_data(mob/user)
	var/list/data = list()

	for(var/datum/material/material as anything in materials)
		var/amount = materials[material]

		data += list(list(
			"name" = material.name,
			"ref" = REF(material),
			"amount" = amount,
			"sheets" = round(amount / SHEET_MATERIAL_AMOUNT),
			"removable" = amount >= SHEET_MATERIAL_AMOUNT,
			"color" = material.greyscale_colors
		))

	return data

/**
 * Adds context sensitivy directly to the material container file for screentips
 * Arguments:
 * * source - refers to item that will display its screentip
 * * context - refers to, in this case, an item in the users hand hovering over the material container, such as an autolathe
 * * held_item - refers to the item that has materials accepted by the material container
 * * user - refers to user who will see the screentip when the proper context and tool are there
 */
/datum/component/material_container/proc/on_requesting_context_from_item(datum/source, list/context, obj/item/held_item, mob/living/user)
	SIGNAL_HANDLER

	if(isnull(held_item))
		return NONE
	if(!(mat_container_flags & MATCONTAINER_ANY_INTENT) && user.combat_mode)
		return NONE
	if(held_item.item_flags & ABSTRACT)
		return NONE
	if((held_item.flags_1 & HOLOGRAM_1) || (held_item.item_flags & NO_MAT_REDEMPTION) || (allowed_item_typecache && !is_type_in_typecache(held_item, allowed_item_typecache)))
		return NONE
	var/list/item_materials = held_item.get_material_composition(mat_container_flags)
	if(!length(item_materials))
		return NONE
	for(var/material in item_materials)
		if(can_hold_material(material))
			continue
		return NONE

	context[SCREENTIP_CONTEXT_LMB] = "Insert"

	return CONTEXTUAL_SCREENTIP_SET
