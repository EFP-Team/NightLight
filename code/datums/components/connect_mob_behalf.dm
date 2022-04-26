/// This component behaves similar to connect_loc_behalf, but working off clients and mobs instead of loc
/// To be clear, we hook into a signal on a tracked client's mob
/// We retain the ability to react to that signal on a seperate listener, which makes this quite powerful
/datum/component/connect_mob_behalf
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// An assoc list of signal -> procpath to register to the mob our client "owns"
	var/list/connections
	/// The master client we're working with
	var/client/tracked
	/// The mob we're currently tracking
	var/mob/tracked_mob

/datum/component/connect_mob_behalf/Initialize(client/tracked, list/connections)
	. = ..()
	if (!istype(tracked))
		return COMPONENT_INCOMPATIBLE
	src.connections = connections
	src.tracked = tracked

/datum/component/connect_mob_behalf/RegisterWithParent()
	RegisterSignal(tracked, COMSIG_PARENT_QDELETING, .proc/handle_tracked_qdel)
	update_signals()

/datum/component/connect_mob_behalf/UnregisterFromParent()
	unregister_signals()
	UnregisterSignal(tracked, COMSIG_PARENT_QDELETING)

	tracked = null

/datum/component/connect_mob_behalf/proc/handle_tracked_qdel()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/connect_mob_behalf/proc/update_signals()
	unregister_signals()
	if(!tracked) // Please do not ask, thanks
		return
	tracked_mob = tracked.mob
	RegisterSignal(tracked_mob, COMSIG_MOB_LOGOUT, .proc/on_logout)
	for (var/signal in connections)
		parent.RegisterSignal(tracked_mob, signal, connections[signal])

/datum/component/connect_mob_behalf/proc/unregister_signals()
	if(isnull(tracked_mob))
		return

	parent.UnregisterSignal(tracked_mob, connections)
	UnregisterSignal(tracked_mob, COMSIG_MOB_LOGOUT)

	tracked_mob = null

/datum/component/connect_mob_behalf/proc/on_logout(mob/source)
	SIGNAL_HANDLER
	update_signals()
