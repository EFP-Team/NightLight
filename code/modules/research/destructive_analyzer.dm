

/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/rnd/destructive_analyzer
	name = "destructive analyzer"
	desc = "Learn science by destroying things!"
	icon_state = "d_analyzer"
	var/decon_mod = 0

/obj/machinery/rnd/destructive_analyzer/Initialize()
	. = ..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/destructive_analyzer(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/destructive_analyzer
	name = "Destructive Analyzer (Machine Board)"
	build_path = /obj/machinery/rnd/destructive_analyzer
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1)

/obj/machinery/rnd/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/S in component_parts)
		T += S.rating
	decon_mod = T


/obj/machinery/rnd/destructive_analyzer/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/obj/machinery/rnd/destructive_analyzer/disconnect_console()
	linked_console.linked_destroy = null
	..()

/obj/machinery/rnd/destructive_analyzer/Insert_Item(obj/item/O, mob/user)
	if(user.a_intent != INTENT_HARM)
		. = 1
		if(!is_insertion_ready(user))
			return
		if(!techweb_item_boost_check(O))
			to_chat(user, "<span class='warning'>This item is of no value to research!</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>\The [O] is stuck to your hand, you cannot put it in the [src.name]!</span>")
			return
		busy = 1
		loaded_item = O
		O.forceMove(src)
		to_chat(user, "<span class='notice'>You add the [O.name] to the [src.name]!</span>")
		flick("d_analyzer_la", src)
		spawn(10)
			icon_state = "d_analyzer_l"
			busy = 0
