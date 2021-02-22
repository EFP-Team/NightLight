/obj/machinery/atmospherics/components/unary/burstpipe
	icon_state = "burst_pipe"

	name = "exploded pipe"
	desc = "It is an exploded pipe."

	layer = GAS_PUMP_LAYER
	showpipe = FALSE

/obj/machinery/atmospherics/components/unary/burstpipe/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.volume = 2000

/obj/machinery/atmospherics/components/unary/burstpipe/Initialize(mapload, set_dir, set_piping_layer)
	. = ..()
	dir = set_dir
	piping_layer = set_piping_layer
	PIPING_LAYER_SHIFT(src, piping_layer)
	initialize_directions = dir

/obj/machinery/atmospherics/components/unary/burstpipe/proc/do_connect()
	SetInitDirections()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		if(src in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node.disconnect(src)
		nodes[1] = null
	if(parents[1])
		nullifyPipenet(parents[1])

	atmosinit()
	node = nodes[1]
	if(node)
		node.atmosinit()
		node.addMember(src)
	SSair.add_to_rebuild_queue(src)

/obj/machinery/atmospherics/components/unary/burstpipe/process_atmos()
	if(!parents)
		return
	var/datum/gas_mixture/external = loc.return_air()
	var/datum/gas_mixture/internal = airs[1]

	if(internal.release_gas_to(external, INFINITY))
		air_update_turf(FALSE, FALSE)
		update_parents()

/obj/machinery/atmospherics/components/unary/burstpipe/wrench_act(mob/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
	if (I.use_tool(src, user, 40, volume=50))
		user.visible_message(
			"[user] unfastens \the [src].",
			"<span class='notice'>You unfasten \the [src].</span>")
		qdel(src)

/obj/machinery/atmospherics/components/unary/burstpipe/can_crawl_through()
	return TRUE