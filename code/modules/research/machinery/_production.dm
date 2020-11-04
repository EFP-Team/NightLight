#define BASE_OF_CATEGORY "_root"


/obj/machinery/rnd/production
	name = "technology fabricator"
	desc = "Makes researched and prototype items with materials and energy."
	layer = BELOW_OBJ_LAYER
	var/efficiency_coeff = 1				//Materials needed / coeff = actual.
	var/list/categories = list()
	var/datum/component/remote_materials/materials
	var/allowed_department_flags = ALL
	var/production_animation				//What's flick()'d on print.
	var/allowed_buildtypes = NONE
	var/list/datum/design/matching_designs
	var/department_tag = "Unidentified"			//used for material distribution among other things.

	var/screen = RESEARCH_FABRICATOR_SCREEN_MAIN
	var/selected_category

/obj/machinery/rnd/production/Initialize(mapload)
	. = ..()
	create_reagents(0, OPENCONTAINER)
	matching_designs = list()
	// To make life easier for ui, we insert BASE_OF_CATEGORY at the front so
	// items without a sub category get displayed first
	var/list/category_order
	for(var/category_name in categories)
		category_order = categories[category_name]
		category_order.Insert(1,BASE_OF_CATEGORY)

	materials = AddComponent(/datum/component/remote_materials, "lathe", mapload, breakdown_flags=BREAKDOWN_FLAGS_LATHE)
	RefreshParts()

/obj/machinery/rnd/production/Destroy()
	materials = null
	matching_designs = null
	return ..()

/obj/machinery/rnd/production/RefreshParts()
	calculate_efficiency()

/obj/machinery/rnd/production/ui_interact(mob/user)
	user.set_machine(src)
	var/datum/browser/popup = new(user, "rndconsole", name, 460, 550)
	popup.set_content(generate_ui())
	popup.open()

/obj/machinery/rnd/production/proc/calculate_efficiency()
	efficiency_coeff = 1
	if(reagents)		//If reagents/materials aren't initialized, don't bother, we'll be doing this again after reagents init anyways.
		reagents.maximum_volume = 0
		for(var/obj/item/reagent_containers/glass/G in component_parts)
			reagents.maximum_volume += G.volume
			G.reagents.trans_to(src, G.reagents.total_volume)
	if(materials)
		var/total_storage = 0
		for(var/obj/item/stock_parts/matter_bin/M in component_parts)
			total_storage += M.rating * 75000
		materials.set_local_size(total_storage)
	var/total_rating = 1.2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		total_rating = clamp(total_rating - (M.rating * 0.1), 0, 1)
	if(total_rating == 0)
		efficiency_coeff = INFINITY
	else
		efficiency_coeff = 1/total_rating

//we eject the materials upon deconstruction.
/obj/machinery/rnd/production/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	return ..()

/obj/machinery/rnd/production/proc/do_print(path, amount, list/matlist, notify_admins)
	if(notify_admins)
		investigate_log("[key_name(usr)] built [amount] of [path] at [src]([type]).", INVESTIGATE_RESEARCH)
		message_admins("[ADMIN_LOOKUPFLW(usr)] has built [amount] of [path] at \a [src]([type]).")
	for(var/i in 1 to amount)
		var/obj/item/I = new path(get_turf(src))
		if(efficient_with(I.type))
			I.material_flags |= MATERIAL_NO_EFFECTS //Find a better way to do this.
			I.set_custom_materials(matlist)
	SSblackbox.record_feedback("nested tally", "item_printed", amount, list("[type]", "[path]"))

/obj/machinery/rnd/production/proc/check_mat(datum/design/being_built, mat)	// now returns how many times the item can be built with the material
	if (!materials.mat_container)  // no connected silo
		return 0
	var/list/all_materials = being_built.reagents_list + being_built.materials

	var/A = materials.mat_container.get_material_amount(mat)
	if(!A)
		A = reagents.get_reagent_amount(mat)

	// these types don't have their .materials set in do_print, so don't allow
	// them to be constructed efficiently
	var/ef = efficient_with(being_built.build_path) ? efficiency_coeff : 1
	return round(A / max(1, all_materials[mat] / ef))

/obj/machinery/rnd/production/proc/efficient_with(path)
	return !ispath(path, /obj/item/stack/sheet) && !ispath(path, /obj/item/stack/ore/bluespace_crystal)

/obj/machinery/rnd/production/proc/user_try_print_id(id, amount)
	if(!id)
		return FALSE
	if(istext(amount))
		amount = text2num(amount)
	if(isnull(amount))
		amount = 1
	var/datum/design/D = stored_research.researched_designs[id] ? SSresearch.techweb_design_by_id(id) : null
	if(!istype(D))
		return FALSE
	if(!(isnull(allowed_department_flags) || (D.departmental_flags & allowed_department_flags)))
		say("Warning: Printing failed: This fabricator does not have the necessary keys to decrypt design schematics. Please update the research data with the on-screen button and contact Nanotrasen Support!")
		return FALSE
	if(D.build_type && !(D.build_type & allowed_buildtypes))
		say("This machine does not have the necessary manipulation systems for this design. Please contact Nanotrasen Support!")
		return FALSE
	if(!materials.mat_container)
		say("No connection to material storage, please contact the quartermaster.")
		return FALSE
	if(materials.on_hold())
		say("Mineral access is on hold, please contact the quartermaster.")
		return FALSE
	var/power = 1000
	amount = clamp(amount, 1, 50)
	for(var/M in D.materials)
		power += round(D.materials[M] * amount / 35)
	power = min(3000, power)
	use_power(power)
	var/coeff = efficient_with(D.build_path) ? efficiency_coeff : 1
	var/list/efficient_mats = list()
	for(var/MAT in D.materials)
		efficient_mats[MAT] = D.materials[MAT]/coeff
	if(!materials.mat_container.has_materials(efficient_mats, amount))
		say("Not enough materials to complete prototype[amount > 1? "s" : ""].")
		return FALSE
	for(var/R in D.reagents_list)
		if(!reagents.has_reagent(R, D.reagents_list[R]*amount/coeff))
			say("Not enough reagents to complete prototype[amount > 1? "s" : ""].")
			return FALSE
	materials.mat_container.use_materials(efficient_mats, amount)
	materials.silo_log(src, "built", -amount, "[D.name]", efficient_mats)
	for(var/R in D.reagents_list)
		reagents.remove_reagent(R, D.reagents_list[R]*amount/coeff)
	busy = TRUE
	if(production_animation)
		flick(production_animation, src)
	var/timecoeff = D.lathe_time_factor / efficiency_coeff
	addtimer(CALLBACK(src, .proc/reset_busy), (30 * timecoeff * amount) ** 0.5)
	addtimer(CALLBACK(src, .proc/do_print, D.build_path, amount, efficient_mats, D.dangerous_construction), (32 * timecoeff * amount) ** 0.8)
	return TRUE

/obj/machinery/rnd/production/proc/search(string)
	matching_designs.Cut()
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(v)
		if(!(D.build_type & allowed_buildtypes) || !(isnull(allowed_department_flags) ||(D.departmental_flags & allowed_department_flags)))
			continue
		if(findtext(D.name,string))
			matching_designs.Add(D)

/obj/machinery/rnd/production/proc/generate_ui()
	var/list/ui = list()
	ui += ui_header()
	switch(screen)
		if(RESEARCH_FABRICATOR_SCREEN_MATERIALS)
			ui += ui_screen_materials()
		if(RESEARCH_FABRICATOR_SCREEN_CHEMICALS)
			ui += ui_screen_chemicals()
		if(RESEARCH_FABRICATOR_SCREEN_SEARCH)
			ui += ui_screen_search()
		if(RESEARCH_FABRICATOR_SCREEN_CATEGORYVIEW)
			ui += ui_screen_category_view()
		else
			ui += ui_screen_main()
	for(var/i in 1 to length(ui))
		if(!findtextEx(ui[i], RDSCREEN_NOBREAK))
			ui[i] += "<br>"
		ui[i] = replacetextEx(ui[i], RDSCREEN_NOBREAK, "")
	return ui.Join("")

/obj/machinery/rnd/production/proc/ui_header()
	var/list/l = list()
	l += "<div class='statusDisplay'><b>[stored_research.organization] [department_tag] Department Lathe</b>"
	l += "Security protocols: [(obj_flags & EMAGGED)? "<font color='red'>Disabled</font>" : "<font color='green'>Enabled</font>"]"
	if (materials.mat_container)
		l += "<A href='?src=[REF(src)];switch_screen=[RESEARCH_FABRICATOR_SCREEN_MATERIALS]'><B>Material Amount:</B> [materials.format_amount()]</A>"
	else
		l += "<font color='red'>No material storage connected, please contact the quartermaster.</font>"
	l += "<A href='?src=[REF(src)];switch_screen=[RESEARCH_FABRICATOR_SCREEN_CHEMICALS]'><B>Chemical volume:</B> [reagents.total_volume] / [reagents.maximum_volume]</A>"
	l += "<a href='?src=[REF(src)];switch_screen=[RESEARCH_FABRICATOR_SCREEN_MAIN]'>Main Screen</a></div>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/rnd/production/proc/ui_screen_materials()
	if (!materials.mat_container)
		screen = RESEARCH_FABRICATOR_SCREEN_MAIN
		return ui_screen_main()
	var/list/l = list()
	l += "<div class='statusDisplay'><h3>Material Storage:</h3>"
	for(var/mat_id in materials.mat_container.materials)
		var/datum/material/M = mat_id
		var/amount = materials.mat_container.materials[mat_id]
		var/ref = REF(M)
		l += "* [amount] of [M.name]: "
		if(amount >= MINERAL_MATERIAL_AMOUNT) l += "<A href='?src=[REF(src)];ejectsheet=[ref];eject_amt=1'>Eject</A> [RDSCREEN_NOBREAK]"
		if(amount >= MINERAL_MATERIAL_AMOUNT*5) l += "<A href='?src=[REF(src)];ejectsheet=[ref];eject_amt=5'>5x</A> [RDSCREEN_NOBREAK]"
		if(amount >= MINERAL_MATERIAL_AMOUNT) l += "<A href='?src=[REF(src)];ejectsheet=[ref];eject_amt=50'>All</A>[RDSCREEN_NOBREAK]"
		l += ""
	l += "</div>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/rnd/production/proc/ui_screen_chemicals()
	var/list/l = list()
	l += "<div class='statusDisplay'><A href='?src=[REF(src)];disposeall=1'>Disposal All Chemicals in Storage</A>"
	l += "<h3>Chemical Storage:</h3>"
	for(var/datum/reagent/R in reagents.reagent_list)
		l += "[R.name]: [R.volume]"
		l += "<A href='?src=[REF(src)];dispose=[R.type]'>Purge</A>"
	l += "</div>"
	return l

/obj/machinery/rnd/production/proc/ui_screen_search()
	var/list/l = list()
	l += "<h2>Search Results:</h2>"
	l += "<form name='search' action='?src=[REF(src)]'>\
	<input type='hidden' name='src' value='[REF(src)]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><HR>"
	for(var/datum/design/D in matching_designs)
		l += design_menu_entry(D)
	l += "</div>"
	return l

/obj/machinery/rnd/production/proc/design_menu_entry(datum/design/D, coeff=null)
	if(!istype(D))
		return
	if(isnull(coeff))
		coeff = efficiency_coeff
	if(!efficient_with(D.build_path))
		coeff = 1
	var/list/l = list()
	var/temp_material
	var/c = 50
	var/t
	var/all_materials = D.materials + D.reagents_list
	for(var/M in all_materials)
		t = check_mat(D, M)
		temp_material += " | "
		if (t < 1)
			temp_material += "<span class='bad'>[all_materials[M]/coeff] [CallMaterialName(M)]</span>"
		else
			temp_material += " [all_materials[M]/coeff] [CallMaterialName(M)]"
		c = min(c,t)

	if (c >= 1)
		l += "<A href='?src=[REF(src)];build=[D.id];amount=1'>[D.name]</A>[RDSCREEN_NOBREAK]"
		if(c >= 5)
			l += "<A href='?src=[REF(src)];build=[D.id];amount=5'>x5</A>[RDSCREEN_NOBREAK]"
		if(c >= 10)
			l += "<A href='?src=[REF(src)];build=[D.id];amount=10'>x10</A>[RDSCREEN_NOBREAK]"
		l += "[temp_material][RDSCREEN_NOBREAK]"
	else
		l += "<span class='linkOff'>[D.name]</span>[temp_material][RDSCREEN_NOBREAK]"
	l += ""
	return l

/obj/machinery/rnd/production/Topic(raw, ls)
	if(..())
		return
	add_fingerprint(usr)
	usr.set_machine(src)
	if(ls["switch_screen"])
		screen = text2num(ls["switch_screen"])
	if(ls["build"]) //Causes the Protolathe to build something.
		if(busy)
			say("Warning: Fabricators busy!")
		else
			user_try_print_id(ls["build"], ls["amount"])
	if(ls["search"]) //Search for designs with name matching pattern
		search(ls["to_search"])
		screen = RESEARCH_FABRICATOR_SCREEN_SEARCH
	if(ls["category"])
		selected_category = ls["category"]
	if(ls["dispose"])  //Causes the protolathe to dispose of a single reagent (all of it)
		reagents.del_reagent(ls["dispose"])
	if(ls["disposeall"]) //Causes the protolathe to dispose of all it's reagents.
		reagents.clear_reagents()
	if(ls["ejectsheet"]) //Causes the protolathe to eject a sheet of material
		var/datum/material/M = locate(ls["ejectsheet"])
		eject_sheets(M, ls["eject_amt"])
	updateUsrDialog()

/obj/machinery/rnd/production/proc/eject_sheets(eject_sheet, eject_amt)
	var/datum/component/material_container/mat_container = materials.mat_container
	if (!mat_container)
		say("No access to material storage, please contact the quartermaster.")
		return 0
	if (materials.on_hold())
		say("Mineral access is on hold, please contact the quartermaster.")
		return 0
	var/count = mat_container.retrieve_sheets(text2num(eject_amt), eject_sheet, drop_location())
	var/list/matlist = list()
	matlist[eject_sheet] = MINERAL_MATERIAL_AMOUNT
	materials.silo_log(src, "ejected", -count, "sheets", matlist)
	return count

/obj/machinery/rnd/production/proc/ui_screen_main()
	var/list/l = list()
	l += "<form name='search' action='?src=[REF(src)]'>\
	<input type='hidden' name='src' value='[REF(src)]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='hidden' name='type' value='proto'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><HR>"

	l += list_categories(categories, RESEARCH_FABRICATOR_SCREEN_CATEGORYVIEW)

	return l


/obj/machinery/rnd/production/proc/ui_screen_sub_category_view(sub_name, list/things)
	var/list/l = list()
	l += "<div class='statusDisplay'><h3 style='padding: 0'>[sub_name]</h3>"
	// things are already known to be good
	for(var/datum/design/D in things)
		l += design_menu_entry(D)
	l += "</div>"
	return l

/obj/machinery/rnd/production/proc/ui_screen_category_view()
	if(!selected_category)
		return ui_screen_main()
	var/list/sub_category_order = categories[selected_category]
	var/sub_category
	var/list/category_lists = list()
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(v)
		if(!(selected_category in D.category)|| !(D.build_type & allowed_buildtypes))
			continue
		if(!(isnull(allowed_department_flags) || (D.departmental_flags & allowed_department_flags)))
			continue
		sub_category = BASE_OF_CATEGORY
		// If we have a sub_category and have a list that describes the order of the sub category
		// then put it in the right order
		if(D.sub_category && (D.sub_category in sub_category_order))
			sub_category = D.sub_category
		if(!category_lists[sub_category])
			category_lists[sub_category] = list()
		category_lists[sub_category] += D

	var/list/l = list()
	var/list/design_list
	l += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3>"
	for(var/N in sub_category_order) // Now display the items in a preprogrammed order
		design_list = category_lists[N]
		if(N == BASE_OF_CATEGORY) // no sub category
			for(var/datum/design/D in design_list)
				l += design_menu_entry(D)
		else
			if(length(design_list) > 0)
				l += ui_screen_sub_category_view(N,design_list)
	l += "</div>"
	return l

/obj/machinery/rnd/production/proc/list_categories(list/categories, menu_num)
	if(!categories)
		return

	var/line_length = 1
	var/list/l = "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(length(stored_research.researched_designs_by_category[C])==0)
			continue // If the category is empty don't bother printing it
		if(line_length > 2)
			l += "</tr><tr>"
			line_length = 1

		l += "<td><A href='?src=[REF(src)];category=[C];switch_screen=[menu_num]'>[C]</A></td>"
		line_length++

	l += "</tr></table></div>"
	return l

#undef BASE_OF_CATEGORY
