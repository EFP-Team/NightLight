/datum/ai_controller/basic_controller/slime
	blackboard = list(
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_RABID = FALSE,
		BB_HUNGER_DISABLED = FALSE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/slime,
	)

/datum/ai_planning_subtree/random_speech/slime
	speech_chance = 1
	speak = list("Blorble...")
	emote_hear = list("blorbles.")
	emote_see = list("bounces","jiggles", "bounces in place")
