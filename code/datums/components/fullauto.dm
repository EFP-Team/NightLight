#define AUTOFIRE_MOUSEUP 0
#define AUTOFIRE_MOUSEDOWN 1

/datum/component/automatic_fire
	var/client/clicker
	var/mob/living/shooter
	var/atom/target
	var/turf/target_loc //For dealing with locking on targets due to BYOND engine limitations (the mouse input only happening when mouse moves).
	var/autofire_stat = AUTOFIRE_STAT_IDLE
	var/mouse_parameters
	var/autofire_shot_delay = 0.3 SECONDS //Time between individual shots.
	var/auto_delay_timer
	var/mouse_status = AUTOFIRE_MOUSEUP //This seems hacky but there can be two MouseDown() without a MouseUp() in between if the user holds click and uses alt+tab, printscreen or similar.


/datum/component/automatic_fire/Initialize(_autofire_shot_delay)
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/gun = parent
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/wake_up)
	if(_autofire_shot_delay)
		autofire_shot_delay = _autofire_shot_delay
	if(ismob(gun.loc))
		var/mob/user = gun.loc
		wake_up(src, user)


/datum/component/automatic_fire/Destroy()
	autofire_off()
	return ..()


/datum/component/automatic_fire/proc/wake_up(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(autofire_stat & (AUTOFIRE_STAT_ALERT))
		return //We've updated the firemode. No need for more.
	if(autofire_stat & AUTOFIRE_STAT_FIRING)
		stop_autofiring() //Let's stop shooting to avoid issues.
		return

	RegisterSignal(parent, list(COMSIG_PARENT_PREQDELETED, COMSIG_ITEM_DROPPED), .proc/autofire_off)

	if(iscarbon(user))
		var/mob/living/carbon/shooter = user
		if(shooter.is_holding(parent))
			autofire_on(shooter.client)
		else
			autofire_off()


// There is a gun and there is a user wielding it. The component now waits for the mouse click.
/datum/component/automatic_fire/proc/autofire_on(client/usercli)
	SIGNAL_HANDLER
	if(autofire_stat & (AUTOFIRE_STAT_ALERT|AUTOFIRE_STAT_FIRING))
		return
	autofire_stat = AUTOFIRE_STAT_ALERT
	clicker = usercli
	shooter = clicker.mob
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDOWN, .proc/on_mouse_down)
	RegisterSignal(shooter, COMSIG_MOB_LOGOUT, .proc/autofire_off)
	parent.RegisterSignal(src, COMSIG_AUTOFIRE_ONMOUSEDOWN, /obj/item/gun/.proc/autofire_bypass_check)
	parent.RegisterSignal(parent, COMSIG_AUTOFIRE_SHOT, /obj/item/gun/.proc/do_autofire)


/datum/component/automatic_fire/proc/autofire_off(datum/source)
	SIGNAL_HANDLER
	if(autofire_stat & (AUTOFIRE_STAT_IDLE))
		return
	if(autofire_stat & AUTOFIRE_STAT_FIRING)
		stop_autofiring()

	autofire_stat = AUTOFIRE_STAT_IDLE

	if(!QDELETED(clicker))
		UnregisterSignal(clicker, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG))
	mouse_status = AUTOFIRE_MOUSEUP //In regards to the component there's no click anymore to care about.
	clicker = null
	if(!QDELETED(shooter))
		UnregisterSignal(shooter, COMSIG_MOB_LOGOUT)
	UnregisterSignal(parent, list(COMSIG_PARENT_PREQDELETED, COMSIG_ITEM_DROPPED))
	shooter = null
	parent.UnregisterSignal(parent, COMSIG_AUTOFIRE_SHOT)
	parent.UnregisterSignal(src, COMSIG_AUTOFIRE_ONMOUSEDOWN)


/datum/component/automatic_fire/proc/on_mouse_down(client/source, atom/_target, turf/location, control, params)
	var/list/modifiers = params2list(params) //If they're shift+clicking, for example, let's not have them accidentally shoot.
	if(modifiers["shift"] && (world.time <= source.mob.next_click || source.mob.ShiftClickOn(_target)))
		source.click_intercept_time = world.time
		return
	if(modifiers["ctrl"])
		return
	if(modifiers["middle"])
		return
	if(modifiers["alt"] && (world.time <= source.mob.next_click || source.mob.AltClickOn(_target)))
		source.click_intercept_time = world.time
		return

	if(source.mob.in_throw_mode)
		return
	if(!isturf(source.mob.loc)) //No firing inside lockers and stuff.
		return
	if(get_dist(source.mob, _target) < 2) //Adjacent clicking.
		return

	if(isnull(location)) //Clicking on a screen object.
		if(_target.plane != CLICKCATCHER_PLANE) //The clickcatcher is a special case. We want the click to trigger then, under it.
			return //If we click and drag on our worn backpack, for example, we want it to open instead.
		_target = params2turf(modifiers["screen-loc"], get_turf(source.eye), source)
		if(!_target)
			CRASH("Failed to get the turf under clickcatcher")

	if(SEND_SIGNAL(src, COMSIG_AUTOFIRE_ONMOUSEDOWN, source, _target, location, control, params) & COMPONENT_AUTOFIRE_ONMOUSEDOWN_BYPASS)
		return

	source.click_intercept_time = world.time //From this point onwards Click() will no longer be triggered.

	if(autofire_stat & (AUTOFIRE_STAT_IDLE))
		CRASH("on_mouse_down() called with [autofire_stat] autofire_stat")
	if(autofire_stat & AUTOFIRE_STAT_FIRING)
		stop_autofiring() //This can happen if we click and hold and then alt+tab, printscreen or other such action. MouseUp won't be called then and it will keep autofiring.

	target = _target
	target_loc = get_turf(target)
	mouse_parameters = params
	start_autofiring()


//Dakka-dakka
/datum/component/automatic_fire/proc/start_autofiring()
	if(autofire_stat == AUTOFIRE_STAT_FIRING)
		return //Already pew-pewing.
	autofire_stat = AUTOFIRE_STAT_FIRING

	if(auto_delay_timer) //This shouldn't be happening, so let's stack_trace it and remove it if nothing is caught.
		stack_trace("start_autofiring called with a non-null auto_delay_timer")
		if(!deltimer(auto_delay_timer))
			addtimer(CALLBACK(src, .proc/keep_trying_to_delete_timer, auto_delay_timer), 1)
		auto_delay_timer = null

	clicker.mouse_override_icon = 'icons/effects/mouse_pointers/weapon_pointer.dmi'
	clicker.mouse_pointer_icon = clicker.mouse_override_icon

	if(mouse_status == AUTOFIRE_MOUSEUP) //See mouse_status definition for the reason for this.
		RegisterSignal(clicker, COMSIG_CLIENT_MOUSEUP, .proc/on_mouse_up)
		mouse_status = AUTOFIRE_MOUSEDOWN

	RegisterSignal(shooter, COMSIG_MOB_SWAP_HANDS, .proc/stop_autofiring)

	if(isgun(parent))
		var/obj/item/gun/shoota = parent
		if(!shoota.on_autofire_start(shooter)) //This is needed because the minigun has a do_after before firing and signals are async.
			stop_autofiring()
			return
	if(autofire_stat != AUTOFIRE_STAT_FIRING)
		return //Things may have changed while on_autofire_start() was being processed, due to do_after's sleep.

	if(!process_shot()) //First shot is processed instantly.
		return //If it fails, such as when the gun is empty, then there's no need to schedule a second shot.
	auto_delay_timer = addtimer(CALLBACK(src, .proc/process_shot), autofire_shot_delay, TIMER_STOPPABLE|TIMER_LOOP)

	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDRAG, .proc/on_mouse_drag)


/datum/component/automatic_fire/proc/on_mouse_up(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	UnregisterSignal(clicker, COMSIG_CLIENT_MOUSEUP)
	mouse_status = AUTOFIRE_MOUSEUP
	if(autofire_stat == AUTOFIRE_STAT_FIRING)
		stop_autofiring()
	return COMPONENT_CLIENT_MOUSEUP_INTERCEPT


/datum/component/automatic_fire/proc/stop_autofiring(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	switch(autofire_stat)
		if(AUTOFIRE_STAT_IDLE, AUTOFIRE_STAT_ALERT)
			return
	autofire_stat = AUTOFIRE_STAT_ALERT
	if(auto_delay_timer) //Keep this at the top of the proc. If anything else runtimes or fails it would cause a potentially-infinite loop.
		if(!deltimer(auto_delay_timer))
			addtimer(CALLBACK(src, .proc/keep_trying_to_delete_timer, auto_delay_timer), 1)
		auto_delay_timer = null
	if(clicker)
		clicker.mouse_override_icon = null
		clicker.mouse_pointer_icon = clicker.mouse_override_icon
		UnregisterSignal(clicker, COMSIG_CLIENT_MOUSEDRAG)
	if(!QDELETED(shooter))
		UnregisterSignal(shooter, COMSIG_MOB_SWAP_HANDS)
	target = null
	target_loc = null
	mouse_parameters = null


/datum/component/automatic_fire/proc/keep_trying_to_delete_timer(timer_id) //This is an ugly hack until a fix for timers being unable to be deleted from inside the call stack is done.
	set waitfor = FALSE
	while(!(deltimer(timer_id)))
		var/datum/timedevent/timer = SStimer.timer_id_dict[timer_id] //This is not a kosher thing to do outside of the SS. But this is a temporary hack.
		if(!timer)
			return //Has already been deleted.
		stoplag(1) //Let's try again next tick.


/datum/component/automatic_fire/proc/on_mouse_drag(client/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	if(isnull(over_location)) //This happens when the mouse is over an inventory or screen object, or on entering deep darkness, for example.
		var/list/modifiers = params2list(params)
		var/new_target = params2turf(modifiers["screen-loc"], get_turf(source.eye), source)
		mouse_parameters = params
		if(!new_target)
			if(QDELETED(target)) //No new target acquired, and old one was deleted, get us out of here.
				stop_autofiring()
				CRASH("on_mouse_drag failed to get the turf under screen object [over_object.type]. Old target was incidentally QDELETED.")
			target = get_turf(target) //If previous target wasn't a turf, let's turn it into one to avoid locking onto a potentially moving target.
			target_loc = target
			CRASH("on_mouse_drag failed to get the turf under screen object [over_object.type]")
		target = new_target
		target_loc = new_target
		return
	target = over_object
	target_loc = get_turf(over_object)
	mouse_parameters = params


/datum/component/automatic_fire/proc/process_shot()
	if(autofire_stat != AUTOFIRE_STAT_FIRING)
		return
	if(QDELETED(target) || get_turf(target) != target_loc) //Target moved or got destroyed since we last aimed.
		target = target_loc //So we keep firing on the emptied tile until we move our mouse and find a new target.
	if(get_dist(shooter, target) <= 0)
		target = get_step(shooter, shooter.dir) //Shoot in the direction faced if the mouse is on the same tile as we are.
		target_loc = target
	else if(!in_view_range(shooter, target))
		stop_autofiring() //Elvis has left the building.
		return FALSE
	shooter.face_atom(target)
	if(SEND_SIGNAL(parent, COMSIG_AUTOFIRE_SHOT, target, shooter, mouse_parameters) & COMPONENT_AUTOFIRE_SHOT_SUCCESS)
		return TRUE
	stop_autofiring()
	return FALSE

// Gun procs.

/obj/item/gun/proc/on_autofire_start(mob/living/shooter)
	if(!can_shoot(shooter) || !can_trigger_gun(shooter) || semicd)
		return FALSE
	var/obj/item/bodypart/other_hand = shooter.has_hand_for_held_index(shooter.get_inactive_hand_index())
	if(weapon_weight == WEAPON_HEAVY && (shooter.get_inactive_held_item() || !other_hand))
		to_chat(shooter, "<span class='warning'>You need two hands to fire [src]!</span>")
		return FALSE
	return TRUE


/obj/item/gun/proc/autofire_bypass_check(datum/source, client/clicker, atom/target, turf/location, control, params)
	SIGNAL_HANDLER
	if(clicker.mob.get_active_held_item() != src)
		return COMPONENT_AUTOFIRE_ONMOUSEDOWN_BYPASS


/obj/item/gun/proc/do_autofire(datum/source, atom/target, mob/living/shooter, params)
	SIGNAL_HANDLER_DOES_SLEEP
	if(!can_shoot())
		shoot_with_empty_chamber(shooter)
		return NONE
	var/obj/item/gun/akimbo_gun = shooter.get_inactive_held_item()
	var/bonus_spread = 0
	if(istype(akimbo_gun) && weapon_weight < WEAPON_MEDIUM)
		if(akimbo_gun.weapon_weight < WEAPON_MEDIUM && akimbo_gun.can_trigger_gun(shooter))
			bonus_spread = dual_wield_spread
			addtimer(CALLBACK(akimbo_gun, /obj/item/gun.proc/process_fire, target, shooter, TRUE, params, null, bonus_spread), 1)
	process_fire(target, shooter, TRUE, params, null, bonus_spread)
	return COMPONENT_AUTOFIRE_SHOT_SUCCESS //All is well, we can continue shooting.

#undef AUTOFIRE_MOUSEUP
#undef AUTOFIRE_MOUSEDOWN
