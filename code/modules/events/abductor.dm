/datum/round_event_control/abductor
	name = "Abductors"
	typepath = /datum/round_event/ghost_role/abductor
	weight = 10
	max_occurrences = 1
	min_players = 20
	dynamic_should_hijack = TRUE

/datum/round_event/ghost_role/abductor
	minimum_required = 2
	role_name = "abductor team"
	fakeable = FALSE //Nothing to fake here

/datum/round_event/ghost_role/abductor/spawn_role()
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(role = ROLE_ABDUCTOR, jobban = ROLE_ABDUCTOR, pic_source = /obj/item/melee/baton/abductor)

	if(candidates.len < 2)
		return NOT_ENOUGH_PLAYERS

	var/mob/living/carbon/human/agent = make_body(pick_n_take(candidates))
	var/mob/living/carbon/human/scientist = make_body(pick_n_take(candidates))

	var/datum/team/abductor_team/T = new
	if(T.team_number > ABDUCTOR_MAX_TEAMS)
		return MAP_ERROR

	log_game("[key_name(scientist)] has been selected as [T.name] abductor scientist.")
	log_game("[key_name(agent)] has been selected as [T.name] abductor agent.")

	scientist.mind.add_antag_datum(/datum/antagonist/abductor/scientist, T)
	agent.mind.add_antag_datum(/datum/antagonist/abductor/agent, T)

	spawned_mobs += list(agent, scientist)

	return SUCCESSFUL_SPAWN
