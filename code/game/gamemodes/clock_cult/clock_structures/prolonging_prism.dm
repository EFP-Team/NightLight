//Prolonging Prism: A prism that consumes power to delay the shuttle
/obj/structure/destructible/clockwork/powered/prolonging_prism
	name = "prolonging prism"
	desc = "A dark onyx prism, held in midair by spiraling tendrils of stone."
	clockwork_desc = "A powerful prism that will delay the arrival of an emergency shuttle."
	icon_state = "prolonging_prism_inactive"
	active_icon = "prolonging_prism"
	inactive_icon = "prolonging_prism_inactive"
	unanchored_icon = "prolonging_prism_unwrenched"
	construction_value = 20
	max_integrity = 125
	obj_integrity = 125
	break_message = "<span class='warning'>The prism falls to the ground with a heavy thud!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/small = 3, \
	/obj/item/clockwork/alloy_shards/medium = 1, \
	/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/component/vanguard_cogwheel/onyx_prism = 1)
	var/static/list/component_refund = list(VANGUARD_COGWHEEL = 2, GEIS_CAPACITOR = 1, REPLICANT_ALLOY = 1)
	var/static/delay_cost = 2500
	var/static/delay_cost_increase = 500
	var/static/delay_remaining = 0

/obj/structure/destructible/clockwork/powered/prolonging_prism/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		if(SSshuttle.emergency.mode == SHUTTLE_DOCKED || SSshuttle.emergency.mode == SHUTTLE_IGNITING || SSshuttle.emergency.mode == SHUTTLE_STRANDED || SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
			to_chat(user, "<span class='inathneq'>An emergency shuttle has arrived and this prism is no longer useful; attempt to activate it to gain a partial refund of components used.</span>")
		else
			var/efficiency = get_efficiency_mod()
			var/efficiency_time = get_efficiency_mod(TRUE)
			to_chat(user, "<span class='inathneq_small'>It requires at least <b>[get_delay_cost() * efficiency]W</b> of power to attempt to delay the arrival of an emergency shuttle by \
			<b>[2 * efficiency_time]</b> minutes.</span>")
			to_chat(user, "<span class='inathneq_small'>This cost increases by <b>100W</b> for every <b>10 CV</b> and <b>[delay_cost_increase]W</b> for every shuttle delayed.</span>")

/obj/structure/destructible/clockwork/powered/prolonging_prism/forced_disable(bad_effects)
	if(active)
		if(bad_effects)
			try_use_power(MIN_CLOCKCULT_POWER*4)
		visible_message("<span class='warning'>[src] emits an airy chuckling sound and falls dark!</span>")
		toggle()
		return TRUE

/obj/structure/destructible/clockwork/powered/prolonging_prism/attack_hand(mob/living/user)
	if(user.canUseTopic(src, !issilicon(user), NO_DEXTERY) && is_servant_of_ratvar(user))
		if(SSshuttle.emergency.mode == SHUTTLE_DOCKED || SSshuttle.emergency.mode == SHUTTLE_IGNITING || SSshuttle.emergency.mode == SHUTTLE_STRANDED || SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
			to_chat(user, "<span class='brass'>You break [src] apart, refunding some of the components used.</span>")
			for(var/i in component_refund)
				generate_cache_component(i, src)
			take_damage(max_integrity)
			return 0
		if(active)
			return 0
		var/turf/T = get_turf(src)
		if(!T || T.z != ZLEVEL_STATION)
			to_chat(user, "<span class='warning'>[src] must be on the station to function!</span>")
			return 0
		if(SSshuttle.emergency.mode != SHUTTLE_CALL)
			to_chat(user, "<span class='warning'>No emergency shuttles are attempting to arrive at the station!</span>")
			return 0
		var/efficiency = get_efficiency_mod()
		if(!try_use_power(get_delay_cost() * efficiency))
			to_chat(user, "<span class='warning'>[src] needs more power to function!</span>")
			return 0
		delay_cost += delay_cost_increase
		delay_remaining += PRISM_DELAY_DURATION
		toggle(0, user)

/obj/structure/destructible/clockwork/powered/prolonging_prism/process()
	var/turf/own_turf = get_turf(src)
	if(SSshuttle.emergency.mode != SHUTTLE_CALL || delay_remaining <= 0 || !own_turf || own_turf.z != ZLEVEL_STATION)
		forced_disable(FALSE)
		return
	. = ..()
	var/delay_amount = 40
	delay_remaining -= delay_amount
	var/efficiency = get_efficiency_mod()
	SSshuttle.emergency.setTimer(SSshuttle.emergency.timeLeft(1) + (delay_amount * efficiency))
	var/highest_y
	var/highest_x
	var/lowest_y
	var/lowest_x
	var/list/prism_turfs = list()
	for(var/t in SSshuttle.emergency.ripple_area(SSshuttle.getDock("emergency_home")))
		var/turf/T = t
		prism_turfs += T
		if(!highest_y || T.y > highest_y)
			highest_y = T.y
		if(!highest_x || T.x > highest_x)
			highest_x = T.x
		if(!lowest_y || T.y < lowest_y)
			lowest_y = T.y
		if(!lowest_x || T.x < lowest_x)
			lowest_x = T.x
	var/mean_y = Lerp(lowest_y, highest_y)
	var/mean_x = Lerp(lowest_x, highest_x)
	if(prob(50))
		mean_y = Ceiling(mean_y)
	else
		mean_y = Floor(mean_y)
	if(prob(50))
		mean_x = Ceiling(mean_x)
	else
		mean_x = Floor(mean_x)
	var/turf/semi_random_center_turf = locate(mean_x, mean_y, ZLEVEL_STATION)
	for(var/t in getline(src, semi_random_center_turf))
		prism_turfs += t
	var/placement_style = prob(50)
	for(var/t in prism_turfs)
		var/turf/T = t
		var/placed = FALSE
		if(placement_style)
			if(IsOdd(T.x + T.y))
				placed = seven_random_hexes(T, efficiency)
			else if(prob(50 * efficiency))
				new /obj/effect/temp_visual/ratvar/prolonging_prism(T)
				placed = TRUE
		else
			if(IsEven(T.x + T.y))
				placed = seven_random_hexes(T, efficiency)
			else if(prob(50 * efficiency))
				new /obj/effect/temp_visual/ratvar/prolonging_prism(T)
				placed = TRUE
		if(placed)
			prism_turfs -= T //if we placed something, remove the turf entirely, not letting stuff place twice
		CHECK_TICK //we may be going over a hell of a lot of turfs

/obj/structure/destructible/clockwork/powered/prolonging_prism/proc/get_delay_cost()
	return Floor((GLOB.clockwork_construction_value * 10) + delay_cost, MIN_CLOCKCULT_POWER)

/obj/structure/destructible/clockwork/powered/prolonging_prism/proc/seven_random_hexes(turf/T, efficiency)
	var/static/list/hex_states = list("prismhex1", "prismhex2", "prismhex3", "prismhex4", "prismhex5", "prismhex6", "prismhex7")
	var/list/hex_combo = list()
	for(var/n in hex_states) //BUILD ME A HEXAGON
		if(prob(50 * efficiency))
			hex_combo += mutable_appearance('icons/effects/64x64.dmi', n)
	if(LAZYLEN(hex_combo)) //YOU BUILT A HEXAGON
		var/obj/effect/temp_visual/ratvar/prolonging_prism/P = new /obj/effect/temp_visual/ratvar/prolonging_prism(T)
		P.icon_state = null
		P.add_overlay(hex_combo)
		return TRUE
