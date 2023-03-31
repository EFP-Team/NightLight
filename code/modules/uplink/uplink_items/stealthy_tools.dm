/datum/uplink_category/stealthy_tools
	name = "Stealth Gadgets"
	weight = 4

/datum/uplink_item/stealthy_tools
	category = /datum/uplink_category/stealthy_tools


/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent Identification Card"
	desc = "Agent cards prevent artificial intelligences from tracking the wearer, and hold up to 5 wildcards \
			from other identification cards. In addition, they can be forged to display a new assignment, name and trim. \
			This can be done an unlimited amount of times. Some Syndicate areas and devices can only be accessed \
			with these cards."
	item = /obj/item/card/id/advanced/chameleon
	cost = 2

/datum/uplink_item/stealthy_tools/ai_detector
	name = "Artificial Intelligence Detector"
	desc = "A functional multitool that turns red when it detects an artificial intelligence watching it, and can be \
			activated to get an rough estimate of the AI's presence. Knowing when \
			an artificial intelligence is watching you is useful for knowing when to maintain cover."
	item = /obj/item/multitool/ai_detect
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	cost = 1

/datum/uplink_item/stealthy_tools/chameleon
	name = "Chameleon Kit"
	desc = "A set of items that contain chameleon technology allowing you to disguise as pretty much anything on the station, and more! \
			Due to budget cuts, the shoes don't provide protection against slipping and skillchips are sold separately."
	item = /obj/item/storage/box/syndie_kit/chameleon
	cost = 2
	purchasable_from = ~UPLINK_NUKE_OPS //clown ops are allowed to buy this kit, since it's basically a costume

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "No-Slip Chameleon Shoes"
	desc = "These shoes will allow the wearer to run on wet floors and slippery objects without falling down. \
			They do not work on heavily lubricated surfaces."
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 2
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon Projector"
	desc = "Projects an image across a user, disguising them as an object scanned with it, as long as they don't \
			move the projector from their hand. Disguised users move slowly, and projectiles pass over them."
	item = /obj/item/chameleon
	cost = 7

/datum/uplink_item/stealthy_tools/codespeak_manual
	name = "Codespeak Manual"
	desc = "Syndicate agents can be trained to use a series of codewords to convey complex information, which sounds like random concepts and drinks to anyone listening. \
			This manual teaches you this Codespeak. You can also hit someone else with the manual in order to teach them. This is the deluxe edition, which has unlimited uses."
	item = /obj/item/language_manual/codespeak_manual/unlimited
	cost = 3

/datum/uplink_item/stealthy_tools/emplight
	name = "EMP Flashlight"
	desc = "A small, self-recharging, short-ranged EMP device disguised as a working flashlight. \
			Useful for disrupting headsets, cameras, doors, lockers and borgs during stealth operations. \
			Attacking a target with this flashlight will direct an EM pulse at it and consumes a charge."
	item = /obj/item/flashlight/emp
	cost = 4
	surplus = 30

/datum/uplink_item/stealthy_tools/emplight/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 3

/datum/uplink_item/stealthy_tools/mulligan
	name = "Mulligan"
	desc = "Screwed up and have security on your tail? This handy syringe will give you a completely new identity \
			and appearance."
	item = /obj/item/reagent_containers/syringe/mulligan
	cost = 4
	surplus = 30
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/jammer
	name = "Radio Jammer"
	desc = "This device will disrupt any nearby outgoing radio communication when activated. Does not affect binary chat."
	item = /obj/item/jammer
	cost = 5

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Smuggler's Satchel"
	desc = "This satchel is thin enough to be hidden in the gap between plating and tiling; great for stashing \
			your stolen goods. Comes with a crowbar, a floor tile and some contraband inside."
	item = /obj/item/storage/backpack/satchel/flat/with_tools
	cost = 1
	surplus = 30
	illegal_tech = FALSE

/datum/uplink_item/stealthy_tools/telecomm_blackout
	name = "Disable Telecomms"
	desc = "When purchased, a virus will be uploaded to the telecommunication processing servers to temporarily disable themselves."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	progression_minimum = 15 MINUTES
	limited_stock = 1
	cost = 4
	restricted = TRUE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/telecomm_blackout/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	var/datum/round_event_control/event = locate(/datum/round_event_control/communications_blackout) in SSevents.control
	event.runEvent()
	return source //For log icon

/datum/uplink_item/stealthy_tools/blackout
	name = "Trigger Stationwide Blackout"
	desc = "When purchased, a virus will be uploaded to the engineering processing servers to force a routine power grid check, forcing all APCs on the station to be temporarily disabled."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	progression_minimum = 20 MINUTES
	limited_stock = 1
	cost = 6
	restricted = TRUE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/blackout/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	var/datum/round_event_control/event = locate(/datum/round_event_control/grid_check) in SSevents.control
	event.runEvent()
	return source //For log icon

/datum/uplink_item/stealthy_tools/randomize
	name = "Trigger Unfortunate Occurence"
	desc = "When purchased, syndicate probabilty matrixes will cause a random event to occur on the station."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	cost = 1
	progression_minimum = 10 MINUTES
	restricted = TRUE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/randomize/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	SSevents.spawnEvent()
	return source //For log icon
