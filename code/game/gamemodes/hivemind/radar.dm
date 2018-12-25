#define HIVEMIND_RADAR_MIN_DISTANCE 7 //Very generous, as the targets are only tracked for a few minutes.
#define HIVEMIND_RADAR_MAX_DISTANCE 50
#define HIVEMIND_RADAR_PING_TIME 20 //2s update time.

//Modified IA/changeling pinpointer, points to the nearest person who is afflicted with the hive tracker status effect
/datum/status_effect/agent_pinpointer/hivemind
	id = "hive_pinpointer"
	alert_type = /obj/screen/alert/status_effect/agent_pinpointer/hivemind
	minimum_range = HIVEMIND_RADAR_MIN_DISTANCE
	tick_interval = HIVEMIND_RADAR_PING_TIME
	range_fuzz_factor = 0

/datum/status_effect/agent_pinpointer/hivemind/scan_for_target()
	var/turf/my_loc = get_turf(owner)

	var/list/mob/living/carbon/targets = list()
	var/trackable_targets_exist = FALSE

	for(var/mob/living/carbon/C in GLOB.alive_mob_list)
		if(C != owner)
			var/datum/status_effect/hive_track/mark = C.has_status_effect(STATUS_EFFECT_HIVE_TRACKER)
			if(mark && mark.tracked_by == owner)
				trackable_targets_exist = TRUE
				var/their_loc = get_turf(C)
				var/distance = get_dist_euclidian(my_loc, their_loc)
				if (distance < HIVEMIND_RADAR_MAX_DISTANCE)
					targets[C] = (HIVEMIND_RADAR_MAX_DISTANCE ** 2) - (distance ** 2)

	if(targets.len)
		scan_target = pickweight(targets) //Point at a 'random' target, biasing heavily towards closer ones.
	else
		scan_target = null
	if(!trackable_targets_exist)
		to_chat(owner, "<span class='assimilator'>The psychic energies eminating from afar have died down... for now</span>")
		owner.remove_status_effect(STATUS_EFFECT_HIVE_RADAR)

//"Trackable" status effect
/datum/status_effect/hive_track
	id = "hive_track"
	var/mob/living/tracked_by
	duration = 1200
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null

/datum/status_effect/hive_track/on_creation(mob/living/new_owner, mob/living/hunter, set_duration)
	. = ..()
	if(.)
		tracked_by = hunter
		if(isnum(set_duration))
			duration = set_duration

//Screen alert
/obj/screen/alert/status_effect/agent_pinpointer/hivemind
	name = "Psychic link"
	desc = "Somebody is there, and they're definitely not friendly."