GLOBAL_LIST_INIT(reagentgrinder_radial_grind, list(
	"grind" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_grind"),
	"juice" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_juice"),
	"eject" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject")))

GLOBAL_LIST_INIT(reagentgrinder_radial_mix, list(
	"mix" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_mix"),
	"eject" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject")))

#define MILK_TO_BUTTER_COEFF 15

/obj/machinery/reagentgrinder
	name = "\improper All-In-One Grinder"
	desc = "From BlenderTech. Will It Blend? Let's test it out!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/reagentgrinder
	pass_flags = PASSTABLE
	resistance_flags = ACID_PROOF
	var/operating = FALSE
	var/obj/item/reagent_containers/beaker = null
	var/limit = 10
	var/speed = 1
	var/list/holdingitems

/obj/machinery/reagentgrinder/Initialize()
	. = ..()
	holdingitems = list()
	beaker = new /obj/item/reagent_containers/glass/beaker/large(src)
	beaker.desc += " May contain blended dust. Don't breathe this in!"

/obj/machinery/reagentgrinder/constructed/Initialize()
	. = ..()
	holdingitems = list()
	QDEL_NULL(beaker)
	update_icon()

/obj/machinery/reagentgrinder/Destroy()
	if(beaker)
		beaker.forceMove(drop_location())
	drop_all_items()
	return ..()

/obj/machinery/reagentgrinder/contents_explosion(severity, target)
	if(beaker)
		beaker.ex_act(severity, target)

/obj/machinery/reagentgrinder/RefreshParts()
	speed = 1
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		speed = M.rating

/obj/machinery/reagentgrinder/handle_atom_del(atom/A)
	. = ..()
	if(A == beaker)
		beaker = null
		update_icon()
	if(holdingitems[A])
		holdingitems -= A

/obj/machinery/reagentgrinder/proc/drop_all_items()
	for(var/i in holdingitems)
		var/atom/movable/AM = i
		AM.forceMove(drop_location())
	holdingitems = list()

/obj/machinery/reagentgrinder/update_icon()
	if(beaker)
		icon_state = "juicer1"
	else
		icon_state = "juicer0"

/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user, params)
	//You can only screw open empty grinder
	if(!beaker && !length(holdingitems) && default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		return

	if(default_deconstruction_crowbar(I))
		return

	if(default_unfasten_wrench(user, I))
		return

	if(panel_open) //Can't insert objects when its screwed open
		return TRUE

	if (istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		if (!beaker)
			if(!user.transferItemToLoc(I, src))
				to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
				return TRUE
			to_chat(user, "<span class='notice'>You slide [I] into [src].</span>")
			beaker = I
			update_icon()
		else
			to_chat(user, "<span class='warning'>There's already a container inside [src].</span>")
		return TRUE //no afterattack

	if(holdingitems.len >= limit)
		to_chat(user, "<span class='warning'>[src] is filled to capacity!</span>")
		return TRUE

	//Fill machine with a bag!
	if(istype(I, /obj/item/storage/bag))
		var/list/inserted = list()
		if(SEND_SIGNAL(I, COMSIG_TRY_STORAGE_TAKE_TYPE, /obj/item/reagent_containers/food/snacks/grown, src, limit - length(holdingitems), null, null, user, inserted))
			for(var/i in inserted)
				holdingitems[i] = TRUE
			if(!I.contents.len)
				to_chat(user, "<span class='notice'>You empty [I] into [src].</span>")
			else
				to_chat(user, "<span class='notice'>You fill [src] to the brim.</span>")
		return TRUE

	if(!I.grind_results && !I.juice_results)
		if(user.a_intent == INTENT_HARM)
			return ..()
		else
			to_chat(user, "<span class='warning'>You cannot grind [I] into reagents!</span>")
			return TRUE

	if(!I.grind_requirements(src)) //Error messages should be in the objects' definitions
		return

	if(user.transferItemToLoc(I, src))
		to_chat(user, "<span class='notice'>You add [I] to [src].</span>")
		holdingitems[I] = TRUE
		return FALSE

//obj/machinery/reagentgrinder/ui_interact(mob/user) // The microwave Menu //I am reasonably certain that this is not a microwave
/obj/machinery/reagentgrinder/attack_hand(mob/user)
	. = ..()

	if(operating)
		return

	if(stat & (NOPOWER|BROKEN) || !beaker || (!length(holdingitems) && !beaker.reagents.total_volume))
		eject(user)
		return

	var/option = show_radial_menu(user, src, length(holdingitems) ? GLOB.reagentgrinder_radial_grind : GLOB.reagentgrinder_radial_mix, require_near = TRUE)

	if(operating || !beaker || stat & (NOPOWER|BROKEN))
		return

	switch(option)
		if("eject")
			eject(user)
		if("grind")
			grind(user)
		if("juice")
			juice(user)
		if("mix")
			mix(user)

/obj/machinery/reagentgrinder/proc/eject(mob/user)
	for(var/i in holdingitems)
		var/obj/item/O = i
		O.forceMove(drop_location())
		holdingitems -= O
	if(beaker)
		beaker.forceMove(drop_location())
		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(beaker)
		beaker = null
		update_icon()

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
	holdingitems -= O
	qdel(O)

/obj/machinery/reagentgrinder/proc/shake_for(duration)
	var/offset = prob(50) ? -2 : 2
	var/old_pixel_x = pixel_x
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = -1) //start shaking
	addtimer(CALLBACK(src, .proc/stop_shaking, old_pixel_x), duration)

/obj/machinery/reagentgrinder/proc/stop_shaking(old_px)
	animate(src)
	pixel_x = old_px

/obj/machinery/reagentgrinder/proc/operate_for(time, silent = FALSE, juicing = FALSE)
	shake_for(time / speed)
	operating = TRUE
	if(!silent)
		if(!juicing)
			playsound(src, 'sound/machines/blender.ogg', 50, 1)
		else
			playsound(src, 'sound/machines/juicer.ogg', 20, 1)
	addtimer(CALLBACK(src, .proc/stop_operating), time / speed)

/obj/machinery/reagentgrinder/proc/stop_operating()
	operating = FALSE

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(!beaker || (beaker && (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)))
		return
	operate_for(50, juicing = TRUE)
	for(var/obj/item/i in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/obj/item/I = i
		if(I.juice_results)
			juice_item(I)

/obj/machinery/reagentgrinder/proc/juice_item(obj/item/I) //Juicing results can be found in respective object definitions
	if(I.on_juice(src) == -1)
		to_chat(usr, "<span class='danger'>[src] shorts out as it tries to juice up [I], and transfers it back to storage.</span>")
		return
	beaker.reagents.add_reagent_list(I.juice_results)
	remove_object(I)

/obj/machinery/reagentgrinder/proc/grind()
	power_change()
	if(!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	operate_for(60)
	for(var/i in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/obj/item/I = i
		if(I.grind_results)
			grind_item(i)

/obj/machinery/reagentgrinder/proc/grind_item(obj/item/I) //Grind results can be found in respective object definitions
	if(I.on_grind(src) == -1) //Call on_grind() to change amount as needed, and stop grinding the item if it returns -1
		to_chat(usr, "<span class='danger'>[src] shorts out as it tries to grind up [I], and transfers it back to storage.</span>")
		return
	beaker.reagents.add_reagent_list(I.grind_results)
	if(I.reagents)
		I.reagents.trans_to(beaker, I.reagents.total_volume)
	remove_object(I)

/obj/machinery/reagentgrinder/proc/mix(mob/user)
	//For butter and other things that would change upon shaking or mixing
	power_change()
	if(!beaker)
		return
	operate_for(50, juicing = TRUE)
	addtimer(CALLBACK(src, /obj/machinery/reagentgrinder/proc/mix_complete), 50)

/obj/machinery/reagentgrinder/proc/mix_complete()
	if(beaker && beaker.reagents.total_volume)
		//Recipe to make Butter
		var/butter_amt = FLOOR(beaker.reagents.get_reagent_amount("milk") / MILK_TO_BUTTER_COEFF, 1)
		beaker.reagents.remove_reagent("milk", MILK_TO_BUTTER_COEFF * butter_amt)
		for(var/i in 1 to butter_amt)
			new /obj/item/reagent_containers/food/snacks/butter(drop_location())
		//Recipe to make Mayonnaise
		if (beaker.reagents.has_reagent("eggyolk"))
			var/amount = beaker.reagents.get_reagent_amount("eggyolk")
			beaker.reagents.remove_reagent("eggyolk", amount)
			beaker.reagents.add_reagent("mayonnaise", amount)
