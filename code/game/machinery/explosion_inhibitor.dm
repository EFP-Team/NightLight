#define INHIB_OFF 0
#define INHIB_CHARGING 1
#define INHIB_ACTIVE 2
/obj/machinery/explosion_inhibitor
	name = "explosion inhibitor"
	desc = "This machine suppresses nearby explosions using a disortion field."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler-off"
	density = TRUE

	idle_power_usage = 100
	active_power_usage = 10000
	max_integrity = 50

	var/charge_timer //Id of charging timer
	var/charge_time = 30 SECONDS // How long it takes to set up
	var/state = INHIB_OFF
	var/range = 7

/obj/machinery/explosion_inhibitor/Initialize()
	. = ..()
	if(state == INHIB_ACTIVE)
		activate()

/obj/machinery/explosion_inhibitor/interact(mob/user, special_state)
	. = ..()
	switch(state)
		if(INHIB_OFF)
			start_charging(user)
		if(INHIB_CHARGING,INHIB_ACTIVE)
			deactivate(user)

/obj/machinery/explosion_inhibitor/power_change()
	. = ..()
	if(state != INHIB_OFF && machine_stat & NOPOWER)
		visible_message("<span class='warning'>[src] shuts down.</span>")
		deactivate()

/obj/machinery/explosion_inhibitor/attackby(obj/item/I, mob/living/user, params)
	if(default_unfasten_wrench(user, I))
		power_change()
		return
	return ..()

/obj/machinery/explosion_inhibitor/powered()
	if(!anchored)
		return FALSE
	return ..()

/obj/machinery/explosion_inhibitor/process()
	return // This is awful, baseline power use needs a refactor

/obj/machinery/explosion_inhibitor/proc/activate(mob/user)
	state = INHIB_ACTIVE
	if(charge_timer)
		deltimer(charge_timer)
		charge_timer = null
	use_power = ACTIVE_POWER_USE
	RegisterSignal(SSdcs,COMSIG_GLOB_BEFORE_EXPLOSION, .proc/inhibit)
	update_icon_state()

/obj/machinery/explosion_inhibitor/proc/start_charging(mob/user)
	state = INHIB_CHARGING
	if(charge_timer)
		deltimer(charge_timer)
	charge_timer = addtimer(CALLBACK(src,.proc/activate),charge_time, TIMER_UNIQUE| TIMER_STOPPABLE)
	use_power = IDLE_POWER_USE
	update_icon_state()
	if(user)
		to_chat(user,"<span class='notice'>You activate [src]. It will take [DisplayTimeText(charge_time)] to recalibrate.</span>")

/obj/machinery/explosion_inhibitor/proc/deactivate(mob/user)
	state = INHIB_OFF
	if(charge_timer)
		deltimer(charge_timer)
		charge_timer = null
	use_power = IDLE_POWER_USE
	UnregisterSignal(SSdcs,COMSIG_GLOB_BEFORE_EXPLOSION)
	update_icon_state()
	if(user)
		to_chat(user,"<span class='notice'>You deactivate [src].</span>")

/obj/machinery/explosion_inhibitor/update_icon_state()
	switch(state)
		if(INHIB_OFF)
			icon_state = "tdoppler-off"
		if(INHIB_ACTIVE)
			icon_state = "tdoppler"
		if(INHIB_CHARGING)
			icon_state = "tdoppler" //todo icon

/obj/machinery/explosion_inhibitor/ex_act(severity, target)
	if(state == INHIB_ACTIVE)
		return
	return ..()

/obj/machinery/explosion_inhibitor/proc/inhibit(datum/source,datum/explosion/exd)
	if(state != INHIB_ACTIVE)
		return

	//Explosion started beyond our range so we only affect it on turfs in our range.
	if(get_dist(exd.epicenter,src) > range && exd.epicenter.z == z)
		RegisterSignal(exd,COMSIG_EXPLOSION_TURF_BEFORE_EX_ACT, .proc/check_crosssection)
	else
		exd.devastation_range = 0
		exd.heavy_impact_range = max(exd.heavy_impact_range - 10,0)
		exd.light_impact_range = max(exd.light_impact_range - 10,0)
		exd.flash_range = max(exd.flash_range - 10,0)
		exd.flame_range = max(exd.flame_range - 10,0)

//Check if afffected turf would fall into protected area and if so modify the result accordingly
// T - turf we're going to explode
// base_dist = original explosion distance (includes reactionary explosion calculations)
// result_power_arglist = resulting distances from this modification
/obj/machinery/explosion_inhibitor/proc/check_crosssection(datum/source,turf/T,base_dist,list/result_power_arglist)
	if(get_dist(T,src) > range)
		return
	var/datum/explosion/exd = source

	var/modified_devastation_range = 0
	var/modified_heavy_impact_range = max(exd.heavy_impact_range - 10,0)
	var/modified_light_impact_range = max(exd.light_impact_range - 10,0)
	var/modified_flame_range = max(exd.flame_range - 10,0)
	//todo or maybe not: prevent flash and such on offrange explosions ?

	var/dist = base_dist

	var/flame_dist = dist < modified_flame_range
	if(dist < modified_devastation_range)
		dist = EXPLODE_DEVASTATE
	else if(dist < modified_heavy_impact_range)
		dist = EXPLODE_HEAVY
	else if(dist < modified_light_impact_range)
		dist = EXPLODE_LIGHT
	else
		dist = EXPLODE_NONE

	result_power_arglist[DIST_ARG] = dist
	result_power_arglist[FLAME_ARG] = flame_dist

	if(dist == EXPLODE_NONE)
		return COMPONENT_EXPLOSION_SKIP_TURF
	else
		return COMPONENT_EXPLOSION_MODIFY

#undef INHIB_ACTIVE
#undef INHIB_CHARGING
#undef INHIB_INHIB_OFF
