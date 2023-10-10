/datum/ai_controller/basic_controller/trooper
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/attack_until_dead
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/trooper,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/trooper
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/trooper

/datum/ai_behavior/basic_melee_attack/trooper
	action_cooldown = 1.2 SECONDS

/datum/ai_planning_subtree/attack_obstacle_in_path/trooper
	attack_behaviour = /datum/ai_behavior/attack_obstructions/trooper

/datum/ai_behavior/attack_obstructions/trooper
	action_cooldown = 1.2 SECONDS

/datum/ai_controller/basic_controller/trooper/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/trooper,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/trooper
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/trooper

/datum/ai_behavior/basic_ranged_attack/trooper
	action_cooldown = 1 SECONDS
	required_distance = 5

/datum/ai_controller/basic_controller/trooper/ranged/avoid_friendly_fire
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/trooper/avoid_friendly_fire,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/trooper/avoid_friendly_fire
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/trooper/avoid_friendly_fire

/datum/ai_behavior/basic_ranged_attack/trooper/avoid_friendly_fire
	avoid_friendly_fire = TRUE

/datum/ai_controller/basic_controller/trooper/ranged/burst
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/trooper_burst
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/trooper_burst
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/trooper_burst

/datum/ai_behavior/basic_ranged_attack/trooper_burst
	action_cooldown = 3 SECONDS

/datum/ai_controller/basic_controller/trooper/ranged/shotgunner
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/trooper_shotgun
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/trooper_shotgun
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/trooper_shotgun

/datum/ai_behavior/basic_ranged_attack/trooper_shotgun
	action_cooldown = 3 SECONDS
	required_distance = 1

/datum/ai_controller/basic_controller/trooper/viscerator
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic()
	)
