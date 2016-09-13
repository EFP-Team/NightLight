#define LIMBGROWER_MAIN_MENU       1
#define LIMBGROWER_CATEGORY_MENU   2
#define LIMBGROWER_CHEMICAL_MENU   3
//use these for the menu system


/obj/machinery/limbgrower
	name = "limb grower"
	desc = "It grows new limbs using Synthflesh."
	icon = 'icons/obj/machines/limbgrower.dmi'
	icon_state = "limbgrower_idleoff"
	density = 1
	flags = OPENCONTAINER

	var/operating = 0
	anchored = 1
	use_power = 1
	var/disabled = 0
	idle_power_usage = 10
	active_power_usage = 100
	var/busy = 0
	var/prod_coeff = 1

	var/datum/design/being_built
	var/datum/research/files
	var/selected_category
	var/screen = 1
	var/emag = 0 //Gives access to other cool stuff

	var/list/categories = list(
							"human",
							"lizard",
							"plasmaman",
							"special"
							)

	var/mob/living/carbon/human/human



/obj/machinery/limbgrower/New()
	..()
	create_reagents(0)
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/limbgrower(null)
	human = new /mob/living/carbon/human()
	B.apply_default_parts(src)


	reagents.add_reagent("synthflesh",50)

	files = new /datum/research/limbgrower(src)

/obj/item/weapon/circuitboard/machine/limbgrower
	name = "circuit board (Limb Grower)"
	build_path = /obj/machinery/limbgrower
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/reagent_containers/glass/beaker = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/machinery/limbgrower/interact(mob/user)
	if(!is_operational())
		return

	var/dat = main_win(user)

	switch(screen)
		if(LIMBGROWER_MAIN_MENU)
			dat = main_win(user)
		if(LIMBGROWER_CATEGORY_MENU)
			dat = category_win(user,selected_category)
		if(LIMBGROWER_CHEMICAL_MENU)
			dat = chemical_win(user)

	var/datum/browser/popup = new(user, "Limb Grower", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/limbgrower/deconstruction()
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)

/obj/machinery/limbgrower/attackby(obj/item/O, mob/user, params)
	if (busy)
		user << "<span class=\"alert\">The Limb Grower is busy. Please wait for completion of previous operation.</span>"
		return 1

	if(default_deconstruction_screwdriver(user, "limbgrower_panelopen", "limbgrower_idleoff", O))
		updateUsrDialog()
		return

	if(exchange_parts(user, O))
		return

	if(panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			default_deconstruction_crowbar(O)
			return 1

	if(user.a_intent == "harm") //so we can hit the machine
		return ..()

	if(stat)
		return 1

	if(O.flags & HOLOGRAM)
		return 1

/obj/machinery/limbgrower/Topic(href, href_list)
	if(..())
		return
	if (!busy)
		if(href_list["menu"])
			screen = text2num(href_list["menu"])

		if(href_list["category"])
			selected_category = href_list["category"]

		if(href_list["disposeI"])  //Get rid of a reagent incase you add the wrong one by mistake
			reagents.del_reagent(href_list["disposeI"])

		if(href_list["make"])

			/////////////////
			//href protection
			being_built = files.FindDesignByID(href_list["make"]) //check if it's a valid design
			if(!being_built)
				return


			var/synth_cost = being_built.reagents["synthflesh"]*prod_coeff
			var/power = max(2000, synth_cost/5)

			if(reagents.has_reagent("synthflesh", being_built.reagents["synthflesh"]*prod_coeff))
				busy = 1
				use_power(power)
				flick("limbgrower_fill",src)
				icon_state = "limbgrower_idleon"
				spawn(32*prod_coeff)
					use_power(power)
					reagents.remove_reagent("synthflesh",being_built.reagents["synthflesh"]*prod_coeff)
					var/B = being_built.build_path
					if(ispath(B, /obj/item/bodypart))	//This feels like spatgheti code, but i need to initilise a limb somehow
						build_limb(B)
					else
						//Just build whatever it is
						var/obj/L = new B()
						L.loc = loc;
					busy = 0
					flick("limbgrower_unfill",src)
					icon_state = "limbgrower_idleoff"
					src.updateUsrDialog()

	else
		usr << "<span class=\"alert\">The limb grower is busy. Please wait for completion of previous operation.</span>"

	src.updateUsrDialog()

	return

/obj/machinery/limbgrower/proc/build_limb(var/B)
	//i need to create a body part manually using a set specias dna
	var/obj/item/bodypart/L
	var/selected_part
	L = new B()
	if(selected_category=="human" || selected_category=="lizard")
		L.icon = 'icons/mob/human_parts_greyscale.dmi'
	// gotta check which part of the body it is, so that i can get the correct icon
	if(ispath(B,/obj/item/bodypart/r_arm))
		L.icon_state = "[selected_category]_r_arm_s"
		selected_part = "right arm"
	else if(ispath(B,/obj/item/bodypart/l_arm))
		selected_part = "left arm"
		L.icon_state = "[selected_category]_l_arm_s"
	else if(ispath(B,/obj/item/bodypart/r_leg))
		selected_part = "right leg"
		L.icon_state = "[selected_category]_r_leg_s"
	else if(ispath(B,/obj/item/bodypart/l_leg))
		selected_part = "left leg"
		L.icon_state = "[selected_category]_l_leg_s"
	L.name = "Synthetic [selected_category] Limb"
	L.desc = "A synthetic [selected_category] limb that will morph on its first use in surgery. This one is for the [selected_part]"
	L.loc = loc;

/obj/machinery/limbgrower/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)
	var/T=1.2
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T -= M.rating*0.2
	prod_coeff = min(1,max(0,T)) // Coeff going 1 -> 0,8 -> 0,6 -> 0,4

/obj/machinery/limbgrower/proc/main_win(mob/user)
	var/dat = "<div class='statusDisplay'><h3>Limb Grower Menu:</h3><br>"
	dat += "<A href='?src=\ref[src];menu=[LIMBGROWER_CHEMICAL_MENU]'>Chemical Storage</A>"
	dat += materials_printout()
	dat += "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(C=="special" && !emag)	//Only want to show special when console is emagged
			continue

		dat += "<td><A href='?src=\ref[src];category=[C];menu=[LIMBGROWER_CATEGORY_MENU]'>[C]</A></td>"
		dat += "</tr><tr>"
		//one category per line

	dat += "</tr></table></div>"
	return dat

/obj/machinery/limbgrower/proc/category_win(mob/user,selected_category)
	var/dat = "<A href='?src=\ref[src];menu=[LIMBGROWER_MAIN_MENU]'>Return to main menu</A>"
	dat += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3><br>"
	dat += materials_printout()

	for(var/v in files.known_designs)
		var/datum/design/D = files.known_designs[v]
		if(!(selected_category in D.category))
			continue
		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='?src=\ref[src];make=[D.id];multiplier=1'>[D.name]</a>"
		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	return dat


/obj/machinery/limbgrower/proc/chemical_win(mob/user)
	var/dat = "<A href='?src=\ref[src];menu=[LIMBGROWER_MAIN_MENU]'>Return to main menu</A>"
	dat += "<div class='statusDisplay'><h3>Browsing Chemical Storage:</h3><br>"
	dat += materials_printout()

	for(var/datum/reagent/R in reagents.reagent_list)
		dat += "[R.name]: [R.volume]"
		dat += "<A href='?src=\ref[src];disposeI=[R.id]'>Purge</A><BR>"

	dat += "</div>"
	return dat

/obj/machinery/limbgrower/proc/materials_printout()
	var/dat = "<b>Total amount:></b> [reagents.total_volume] / [reagents.maximum_volume] cm<sup>3</sup><br>"
	return dat

/obj/machinery/limbgrower/proc/can_build(datum/design/D)
	return (reagents.has_reagent("synthflesh", D.reagents["synthflesh"]*prod_coeff)) //Return whether the machine has enough synthflesh to produce the design

/obj/machinery/limbgrower/proc/get_design_cost(datum/design/D)
	var/dat
	if(D.reagents["synthflesh"])
		dat += "[D.reagents["synthflesh"] * prod_coeff] Synthetic flesh "
	return dat

/obj/machinery/limbgrower/emag_act(mob/user)
	if(emag==1)
		return
	for(var/datum/design/D in files.possible_designs)
		if((D.build_type & LIMBGROWER) && ("special" in D.category))
			files.AddDesign2Known(D)
	usr << "A warning flashes onto the screen, stating that safety overrides have been deactivited"
	emag = 1