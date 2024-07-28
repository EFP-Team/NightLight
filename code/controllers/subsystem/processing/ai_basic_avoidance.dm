PROCESSING_SUBSYSTEM_DEF(basic_avoidance)
	name = "Basic Avoidance"
	flags = SS_NO_INIT
	wait = 2 SECONDS

PROCESSING_SUBSYSTEM_DEF(idle_ai_behaviors)
	name = "idle_ai_behaviors"
	flags = SS_NO_INIT | SS_BACKGROUND
	wait = 1.5 SECONDS
	priority = FIRE_PRIORITY_IDLE_NPC
	init_order = INIT_ORDER_AI_CONTROLLERS //must execute only after ai behaviors are initialized


