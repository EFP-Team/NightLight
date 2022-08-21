/obj/machinery/rnd/production
	name = "technology fabricator"
	desc = "Makes researched and prototype items with materials and energy."
	layer = BELOW_OBJ_LAYER

	/// The efficiency coefficient. Material costs and print times are multiplied by this number;
	/// better parts result in a higher efficiency (and lower value).
	var/efficiency_coeff = 1

	/// The material storage used by this fabricator.
	var/datum/component/remote_materials/materials

	/// Which departments forego the lathe tax when using this lathe.
	var/allowed_department_flags = ALL

	/// What's flick()'d on print.
	var/production_animation

	/// The types of designs this fabricator can print.
	var/allowed_buildtypes = NONE

	/// All designs in the techweb that can be fabricated by this machine, since the last update.
	var/list/datum/design/cached_designs

	/// The department this fabricator is assigned to.
	var/department_tag = "Unassigned"

	/// What color is this machine's stripe? Leave null to not have a stripe.
	var/stripe_color = null

	/// Does this charge the user's ID on fabrication?
	var/charges_tax = TRUE

/obj/machinery/rnd/production/Initialize(mapload)
	. = ..()
	create_reagents(0, OPENCONTAINER)
	cached_designs = list()
	update_designs()
	materials = AddComponent(/datum/component/remote_materials, "lathe", mapload, mat_container_flags=BREAKDOWN_FLAGS_LATHE)
	AddComponent(/datum/component/payment, 0, SSeconomy.get_dep_account(payment_department), PAYMENT_CLINICAL, TRUE)
	RefreshParts()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/rnd/production/Destroy()
	materials = null
	cached_designs = null
	return ..()

/// Updates the list of designs this fabricator can print.
/obj/machinery/rnd/production/proc/update_designs()
	cached_designs.Cut()

	for(var/i in stored_research.researched_designs)
		var/datum/design/d = SSresearch.techweb_design_by_id(i)

		if((isnull(allowed_department_flags) || (d.departmental_flags & allowed_department_flags)) && (d.build_type & allowed_buildtypes))
			cached_designs |= d

	update_static_data(usr)

	say("Successfully synchronized with R&D server.")

/obj/machinery/rnd/production/RefreshParts()
	. = ..()
	calculate_efficiency()

/obj/machinery/rnd/production/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials),
	)

/obj/machinery/rnd/production/ui_interact(mob/user, datum/tgui/ui)
	user.set_machine(src)

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Fabricator")
		ui.open()

/obj/machinery/rnd/production/ui_static_data(mob/user)
	var/list/data = list()
	var/list/designs = list()

	for(var/datum/design/design in cached_designs)
		var/cost = list()

		for(var/datum/material/mat in design.materials)
			var/coeff = efficient_with(design.build_path) ? efficiency_coeff : 1
			cost[mat.name] = design.materials[mat] * coeff

		designs[design.id] = list(
			"name" = design.name,
			"desc" = design.get_description(),
			"cost" = cost,
			"id" = design.id,
			"categories" = design.category,
			"maxstack" = design.maxstack
		)

	data["designs"] = designs
	data["fab_name"] = name

	return data

/obj/machinery/rnd/production/ui_data(mob/user)
	var/list/data = list()

	data["materials"] = materials.mat_container?.ui_data()
	data["on_hold"] = materials.on_hold()
	data["busy"] = busy

	return data

/obj/machinery/rnd/production/ui_act(action, list/params)
	. = ..()

	if(.)
		return

	. = TRUE

	switch (action)
		if("remove_mat")
			var/datum/material/M = locate(params["ref"])
			eject_sheets(M, params["amount"])

		if("sync_rnd")
			update_designs()

		if("build")
			user_try_print_id(params["ref"], params["amount"])

/// Updates the fabricator's efficiency coefficient based on the installed parts.
/obj/machinery/rnd/production/proc/calculate_efficiency()
	efficiency_coeff = 1

	if(reagents)
		reagents.maximum_volume = 0

		for(var/obj/item/reagent_containers/cup/G in component_parts)
			reagents.maximum_volume += G.volume
			G.reagents.trans_to(src, G.reagents.total_volume)

	if(materials)
		var/total_storage = 0

		for(var/obj/item/stock_parts/matter_bin/M in component_parts)
			total_storage += M.rating * 75000

		materials.set_local_size(total_storage)

	var/total_rating = 1.2

	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		total_rating -= M.rating * 0.1

	efficiency_coeff = max(total_rating, 0)

/obj/machinery/rnd/production/on_deconstruction()
	for(var/obj/item/reagent_containers/cup/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)

	return ..()

/obj/machinery/rnd/production/proc/do_print(path, amount, list/matlist, notify_admins)
	if(notify_admins)
		investigate_log("[key_name(usr)] built [amount] of [path] at [src]([type]).", INVESTIGATE_RESEARCH)
		message_admins("[ADMIN_LOOKUPFLW(usr)] has built [amount] of [path] at \a [src]([type]).")

	for(var/i in 1 to amount)
		new path(get_turf(src))

	SSblackbox.record_feedback("nested tally", "item_printed", amount, list("[type]", "[path]"))

/**
 * Returns how many times over the given material requirement for the given design is satisfied.
 *
 * Arguments:
 * - [being_built][/datum/design]: The design being referenced.
 * - material: The material being checked.
 */
/obj/machinery/rnd/production/proc/check_material_req(datum/design/being_built, material)
	if(!materials.mat_container)  // no connected silo
		return 0

	var/mat_amt = materials.mat_container.get_material_amount(material)

	if(!mat_amt)
		return 0

	// these types don't have their .materials set in do_print, so don't allow
	// them to be constructed efficiently
	var/efficiency = efficient_with(being_built.build_path) ? efficiency_coeff : 1
	return round(mat_amt / max(1, being_built.materials[material] * efficiency))

/**
 * Returns how many times over the given reagent requirement for the given design is satisfied.
 *
 * Arguments:
 * - [being_built][/datum/design]: The design being referenced.
 * - reagent: The reagent being checked.
 */
/obj/machinery/rnd/production/proc/check_reagent_req(datum/design/being_built, reagent)
	if(!reagents)  // no reagent storage
		return 0

	var/chem_amt = reagents.get_reagent_amount(reagent)
	if(!chem_amt)
		return 0

	// these types don't have their .materials set in do_print, so don't allow
	// them to be constructed efficiently
	var/efficiency = efficient_with(being_built.build_path) ? efficiency_coeff : 1
	return round(chem_amt / max(1, being_built.reagents_list[reagent] * efficiency))

/obj/machinery/rnd/production/proc/efficient_with(path)
	return !ispath(path, /obj/item/stack/sheet) && !ispath(path, /obj/item/stack/ore/bluespace_crystal)

/obj/machinery/rnd/production/proc/user_try_print_id(id, print_quantity)
	if(!id)
		return FALSE

	if(istext(print_quantity))
		print_quantity = text2num(print_quantity)

	if(isnull(print_quantity))
		print_quantity = 1

	var/datum/design/D = stored_research.researched_designs[id] ? SSresearch.techweb_design_by_id(id) : null

	if(!istype(D))
		return FALSE

	if(busy)
		say("Warning: fabricator is busy!")
		return FALSE

	if(!(isnull(allowed_department_flags) || (D.departmental_flags & allowed_department_flags)))
		say("This fabricator does not have the necessary keys to decrypt this design.")
		return FALSE

	if(D.build_type && !(D.build_type & allowed_buildtypes))
		say("This fabricator does not have the necessary manipulation systems for this design.")
		return FALSE

	if(!materials.mat_container)
		say("No connection to material storage, please contact the quartermaster.")
		return FALSE

	if(materials.on_hold())
		say("Mineral access is on hold, please contact the quartermaster.")
		return FALSE

	var/power = active_power_usage

	print_quantity = clamp(print_quantity, 1, 50)

	for(var/M in D.materials)
		power += round(D.materials[M] * print_quantity / 35)

	power = min(active_power_usage, power)
	use_power(power)

	var/coeff = efficient_with(D.build_path) ? efficiency_coeff : 1
	var/list/efficient_mats = list()
	for(var/MAT in D.materials)
		efficient_mats[MAT] = D.materials[MAT] * coeff

	if(!materials.mat_container.has_materials(efficient_mats, print_quantity))
		say("Not enough materials to complete prototype[print_quantity > 1? "s" : ""].")
		return FALSE

	for(var/R in D.reagents_list)
		if(!reagents.has_reagent(R, D.reagents_list[R]*print_quantity * coeff))
			say("Not enough reagents to complete prototype[print_quantity > 1? "s" : ""].")
			return FALSE

	// Charge the lathe tax at least once per ten items.
	var/total_cost = LATHE_TAX * max(round(print_quantity / 10), 1)

	if(!charges_tax)
		total_cost = 0

	if(isliving(usr))
		var/mob/living/user = usr
		var/obj/item/card/id/card = user.get_idcard(TRUE)

		if(!card && istype(user.pulling, /obj/item/card/id))
			card = user.pulling

		if(card && card.registered_account)
			var/datum/bank_account/our_acc = card.registered_account
			if(our_acc.account_job.departments_bitflags & allowed_department_flags)
				total_cost = 0 // We are not charging crew for printing their own supplies and equipment.

	if(attempt_charge(src, usr, total_cost) & COMPONENT_OBJ_CANCEL_CHARGE)
		say("Insufficient funds to complete prototype. Please present a holochip or valid ID card.")
		return FALSE

	if(iscyborg(usr))
		var/mob/living/silicon/robot/borg = usr

		if(!borg.cell)
			return FALSE

		borg.cell.use(SILICON_LATHE_TAX)

	materials.mat_container.use_materials(efficient_mats, print_quantity)
	materials.silo_log(src, "built", -print_quantity, "[D.name]", efficient_mats)

	for(var/R in D.reagents_list)
		reagents.remove_reagent(R, D.reagents_list[R]*print_quantity/coeff)

	busy = TRUE

	if(production_animation)
		flick(production_animation, src)

	var/timecoeff = D.lathe_time_factor * efficiency_coeff

	addtimer(CALLBACK(src, .proc/reset_busy), (30 * timecoeff * print_quantity) ** 0.5)
	addtimer(CALLBACK(src, .proc/do_print, D.build_path, print_quantity, efficient_mats, D.dangerous_construction), (32 * timecoeff * print_quantity) ** 0.8)

	return TRUE

/obj/machinery/rnd/production/proc/eject_sheets(eject_sheet, eject_amt)
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container)
		say("No access to material storage, please contact the quartermaster.")
		return 0
	if(materials.on_hold())
		say("Mineral access is on hold, please contact the quartermaster.")
		return 0
	var/count = mat_container.retrieve_sheets(text2num(eject_amt), eject_sheet, drop_location())
	var/list/matlist = list()
	matlist[eject_sheet] = MINERAL_MATERIAL_AMOUNT
	materials.silo_log(src, "ejected", -count, "sheets", matlist)
	return count

// Stuff for the stripe on the department machines
/obj/machinery/rnd/production/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/rnd/production/update_overlays()
	. = ..()
	if(!stripe_color)
		return
	var/mutable_appearance/stripe = mutable_appearance('icons/obj/machines/research.dmi', "protolate_stripe")
	if(!panel_open)
		stripe.icon_state = "protolathe_stripe"
	else
		stripe.icon_state = "protolathe_stripe_t"
	stripe.color = stripe_color
	. += stripe

/obj/machinery/rnd/production/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Storing up to <b>[materials.local_size]</b> material units.<br>Material consumption at <b>[efficiency_coeff * 100]%</b>.<br>Build time reduced by <b>[100 - efficiency_coeff * 100]%</b>.")
