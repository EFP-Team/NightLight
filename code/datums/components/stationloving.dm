/// Teleports the movable atom back to a safe turf on the station if it leaves the z-level or becomes inaccessible.
/datum/component/stationloving
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// If TRUE, notifies admins when parent is teleported back to the station.
	var/inform_admins = FALSE
	/// Boolean that prevents liches from imbuing their soul in this item.
	var/disallow_soul_imbue = TRUE
	/// If FALSE, prevents parent from being qdel'd unless it's a force = TRUE qdel.
	var/allow_item_destruction = FALSE

	/// Typecache of shuttles that we allow the disk to stay on
	var/static/list/allowed_shuttles = typecacheof(list(
		/area/shuttle/syndicate,
		/area/shuttle/escape,
		/area/shuttle/pod_1,
		/area/shuttle/pod_2,
		/area/shuttle/pod_3,
		/area/shuttle/pod_4,
	))
	/// Typecache of areas on the centcom Z-level that we do not allow the disk to stay on
	var/static/list/disallowed_centcom_areas = typecacheof(list(
		/area/centcom/abductor_ship,
		/area/awaymission/errorroom,
	))

/datum/component/stationloving/Initialize(inform_admins = FALSE, allow_item_destruction = FALSE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.inform_admins = inform_admins
	src.allow_item_destruction = allow_item_destruction

	// Just in case something is being created outside of station/centcom
	if(!atom_in_bounds(parent))
		relocate()

/datum/component/stationloving/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_PREQDELETED, .proc/on_parent_pre_qdeleted)
	RegisterSignal(parent, COMSIG_ITEM_IMBUE_SOUL, .proc/check_soul_imbue)
	RegisterSignal(parent, COMSIG_ITEM_MARK_RETRIEVAL, .proc/check_mark_retrieval)
	// Relocate when we become unreachable
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/on_parent_moved)
	// Relocate when our loc, or any of our loc's locs, becomes unreachable
	var/static/list/loc_connections = list(
		COMSIG_MOVABLE_MOVED = .proc/on_parent_moved,
		SIGNAL_ADDTRAIT(TRAIT_SECLUDED_LOCATION) = .proc/on_loc_secluded,
	)
	AddComponent(/datum/component/connect_containers, parent, loc_connections)

/datum/component/stationloving/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_Z_CHANGED,
		COMSIG_PARENT_PREQDELETED,
		COMSIG_ITEM_IMBUE_SOUL,
		COMSIG_ITEM_MARK_RETRIEVAL,
		COMSIG_MOVABLE_MOVED,
	))

	qdel(GetComponent(/datum/component/connect_containers))

/datum/component/stationloving/InheritComponent(datum/component/stationloving/newc, original, inform_admins, allow_death)
	if (original)
		if (newc)
			inform_admins = newc.inform_admins
			allow_death = newc.allow_item_destruction
		else
			inform_admins = inform_admins

/// We're told to relocate from an unfavorable position to a valid one! Get the turf, then call the proc to do the actual relocation.
/datum/component/stationloving/proc/relocate()
	var/turf/target_turf = get_valid_turf()
	full_move(target_turf)
	return target_turf

/// Find a safe turf, and if there is no safe turf, use a blobstart landmark.
/datum/component/stationloving/proc/get_valid_turf()
	var/turf/returnable_turf = find_safe_turf()

	if(!returnable_turf)
		if(GLOB.blobstart.len > 0)
			returnable_turf = get_turf(pick(GLOB.blobstart))
		else
			CRASH("Unable to find a blobstart landmark for [type] to relocate [parent].")

	return returnable_turf

/// Alright, let's actually move (we've exceeded all possible thresholds/affordances to the holder of this item). If no turf is provided, we'll find one ourselves.
/// Don't handle logging here. Please do it in the calling proc, since this is meant to operate agnostic of context.
/datum/component/stationloving/proc/full_move(turf/location_turf)
	if(!location_turf)
		location_turf = find_safe_turf()

	var/atom/movable/movable_parent = parent
	playsound(movable_parent, 'sound/machines/synth_no.ogg', 5, TRUE)

	var/mob/holder = get(movable_parent, /mob)
	if(holder)
		to_chat(holder, span_danger("You can't help but feel that you just lost something back there..."))
		holder.temporarilyRemoveItemFromInventory(parent, TRUE) // prevents ghost diskie

	movable_parent.forceMove(location_turf)

/// Signal proc for [COMSIG_MOVABLE_MOVED], called when our parent moves, or our parent's loc, or our parent's loc loc...
/// To check if our disk is moving somewhere it shouldn't be, such as off Z level, or into an invalid area
/datum/component/stationloving/proc/on_parent_moved(atom/movable/source, turf/old_turf)
	SIGNAL_HANDLER

	if(atom_in_bounds(source))
		return

	var/turf/current_turf = get_turf(source)
	var/turf/new_destination = relocate()

	// Expected behavior from relocate() is that it will return a turf if it's full-steam-ahead on moving the parent, and null if it's not.
	if(isnull(new_destination))
		return

	var/secluded
	// Our turf actually didn't change, so it's more likely we became secluded
	if(current_turf == old_turf)
		secluded = TRUE

	generate_logs(old_turf, current_turf, new_destination, loc_changed = !secluded)

/// Signal proc for [SIGNAL_ADDTRAIT], via [TRAIT_SECLUDED_LOCATION] on our locs, to ensure nothing funky happens
/datum/component/stationloving/proc/on_loc_secluded(atom/movable/source)
	SIGNAL_HANDLER

	var/turf/new_destination = relocate()
	// for our intents and purposes regarding secluded, the source is both the source atom and the destination turf
	generate_logs(source, source, new_destination, loc_changed = FALSE)

/// Generate logs and messages for when our parent goes back to the station. Args are important in how you pass them in in relation to their meaning.
/// Source Atom was the location where the parent was "safe", the very last coordinate that it was okay at right before we started to move it. Could be the thing that's secluding the disk, or the source turf.
/// Destination Turf was the turf that the parent was moved to. This is the "unsafe" turf that triggered the forceMove. If we're calling this since parent got put in a secluded area, pass loc_changed as FALSE.
/// Final Turf is the turf that we forceMoved the parent to after we determined it was in an invalid area.
/datum/component/stationloving/proc/generate_logs(atom/source, turf/destination_turf, turf/final_turf, loc_changed = TRUE)
	if(loc_changed)
		log_game("[parent] attempted to be moved out of bounds from [loc_name(source)] \
		to [loc_name(destination_turf)]. Moving it to [loc_name(final_turf)].")

		if(inform_admins)
			message_admins("[parent] attempted to be moved out of bounds from [ADMIN_VERBOSEJMP(source)] \
				to [ADMIN_VERBOSEJMP(destination_turf)]. Moving it to [ADMIN_VERBOSEJMP(final_turf)].")
	else
		log_game("[parent] moved out of bounds at [loc_name(source)], becoming inaccessible / secluded. \
			Moving it to [loc_name(final_turf)].")

		if(inform_admins)
			message_admins("[parent] moved out of bounds at [ADMIN_VERBOSEJMP(source)], becoming inaccessible / secluded. \
				Moving it to [ADMIN_VERBOSEJMP(final_turf)].")

/datum/component/stationloving/proc/check_soul_imbue(datum/source)
	SIGNAL_HANDLER

	if(disallow_soul_imbue)
		return COMPONENT_BLOCK_IMBUE

/datum/component/stationloving/proc/check_mark_retrieval(datum/source)
	SIGNAL_HANDLER

	return COMPONENT_BLOCK_MARK_RETRIEVAL

/// Checks whether a given atom's turf is within bounds. Returns TRUE if it is, FALSE if it isn't.
/datum/component/stationloving/proc/atom_in_bounds(atom/atom_to_check)
	// Our loc is a secluded location = not in bounds
	if (atom_to_check.loc && HAS_TRAIT(atom_to_check.loc, TRAIT_SECLUDED_LOCATION))
		return FALSE
	// No turf below us = nullspace = not in bounds
	var/turf/destination_turf = get_turf(atom_to_check)
	var/area/destination_area = get_area(atom_to_check)
	if (!destination_turf)
		return FALSE
	if (is_station_level(destination_turf.z))
		return TRUE

	if (is_centcom_level(destination_turf.z))
		if (is_type_in_typecache(destination_area, disallowed_centcom_areas))
			return FALSE
		return TRUE

	if (is_reserved_level(destination_turf.z))
		if (is_type_in_typecache(destination_area, allowed_shuttles))
			return TRUE
		return FALSE

/// Signal handler for before the parent is qdel'd. Can prevent the parent from being deleted where allow_item_destruction is FALSE and force is FALSE.
/datum/component/stationloving/proc/on_parent_pre_qdeleted(datum/source, force)
	SIGNAL_HANDLER

	var/turf/current_turf = get_turf(parent)

	if(force && inform_admins)
		message_admins("[parent] has been !!force deleted!! in [ADMIN_VERBOSEJMP(current_turf)].")
		log_game("[parent] has been !!force deleted!! in [loc_name(current_turf)].")

	if(force || allow_item_destruction)
		return FALSE

	var/turf/new_turf = relocate()
	log_game("[parent] has been destroyed in [loc_name(current_turf)]. \
		Preventing destruction and moving it to [loc_name(new_turf)].")
	if(inform_admins)
		message_admins("[parent] has been destroyed in [ADMIN_VERBOSEJMP(current_turf)]. \
			Preventing destruction and moving it to [ADMIN_VERBOSEJMP(new_turf)].")
	return TRUE
