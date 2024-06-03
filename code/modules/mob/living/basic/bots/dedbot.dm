///////////////Donk Exenteration Drone - DED////////////
//A patrolling bot that cuts you up if you get close. Use ranged weapons or avoid it.

#define SPIN_SLASH_ABILITY_TYPEPATH /datum/action/cooldown/mob_cooldown/exenterate

/mob/living/basic/bot/dedbot
	name = "\improper Donk Exenteration Drone" //Exenteration means ripping entrails out, ouch!
	desc = "A bladed commercial defence drone, often called an 'Ex-Drone' or 'D.E.D.bot'. It follows a simple programmed patrol route, and slashes at anyone who doesn't have an identity implant."
	icon_state = "ded_drone0"
	base_icon_state = "ded_drone"
	req_one_access = list(ACCESS_SYNDICATE)
	health = 50
	maxHealth = 50
	melee_damage_lower = 15
	melee_damage_upper = 20
	light_power = 0
	ai_controller = /datum/ai_controller/basic_controller/bot/dedbot
	faction = list(ROLE_SYNDICATE)
	sharpness = SHARP_EDGED
	attack_verb_continuous = "eviscerates"
	attack_verb_simple = "eviscerate"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	gold_core_spawnable = HOSTILE_SPAWN
	limb_destroyer = 1
	bubble_icon = "machine"
	pass_flags = PASSMOB | PASSFLAPS
	maximum_survivable_temperature = 360 //prone to overheating
	possessed_message = "You are an exenteration drone. Exenterate."
	additional_access = /datum/id_trim/away/hauntedtradingpost/boss
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL
	mob_size = MOB_SIZE_SMALL
	robot_arm = /obj/item/hatchet/cutterblade
	density = FALSE
	COOLDOWN_DECLARE(trigger_cooldown)
	//time between exenteration uses
	var/exenteration_cooldown_duration = 0.5 SECONDS
	//aoe slash ability
	var/datum/action/cooldown/mob_cooldown/bot/exenterate

/mob/living/basic/bot/dedbot/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(slashem))
	var/static/list/innate_actions = list(
	SPIN_SLASH_ABILITY_TYPEPATH = BB_DEDBOT_SLASH,
	)
	grant_actions_by_list(innate_actions)

/mob/living/basic/bot/dedbot/proc/check_faction(mob/target)
	for(var/faction1 in faction)
		if(faction1 in target.faction)
			return TRUE
	return FALSE

/mob/living/basic/bot/dedbot/proc/slashem(datum/source, mob/living/victim, datum/ai_controller/basic_controller/bot/dedbot/controller)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, exenteration_cooldown_duration))
		return
	if (!isliving(victim)) //we target living guys
		return
	if (victim.stat || check_faction(victim)) //who arent in our faction
		return
	var/datum/action/cooldown/using_action = controller.blackboard[BB_DEDBOT_SLASH]
	if (using_action?.IsAvailable())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	COOLDOWN_START(src, exenteration_cooldown_duration, 0.5 SECONDS)

/datum/ai_controller/basic_controller/bot/dedbot
	max_target_distance = 1
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/jps/bot
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/targeted_mob_ability/exenterate,
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/find_patrol_beacon,
		/datum/ai_planning_subtree/manage_unreachable_list,
	)
	max_target_distance = AI_BOT_PATH_LENGTH
	///keys to be reset when the bot is reseted
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)

/datum/ai_planning_subtree/targeted_mob_ability/exenterate
	ability_key = BB_DEDBOT_SLASH
	finish_planning = FALSE

/datum/action/cooldown/mob_cooldown/exenterate
	name = "Exenterate"
	desc = "Disembowel every living thing in range with your blades."
	button_icon = 'icons/obj/weapons/stabby.dmi'
	button_icon_state = "huntingknife"
	click_to_activate = FALSE
	background_icon = 'icons/hud/guardian.dmi'
	background_icon_state = "base"
	cooldown_time = 0.5 SECONDS
	//how much damage this ability does
	var/damage_dealt = 18
	/// weighted list of body zones this can hit
	var/static/list/valid_targets = list(
		BODY_ZONE_CHEST = 2,
		BODY_ZONE_R_ARM = 1,
		BODY_ZONE_L_ARM = 1,
		BODY_ZONE_R_LEG = 1,
		BODY_ZONE_L_LEG = 1,
	)

/datum/action/cooldown/mob_cooldown/exenterate/Activate(atom/caster)
	caster.Shake(1.2, 0.6, 0.3 SECONDS)
	for(var/mob/living/living_mob in range(2))
		if (living_mob.faction == owner.faction)
			return
		to_chat(caster, span_warning("You slice [living_mob]!"))
		to_chat(living_mob, span_warning("You are cut by the drone's blades!"))
		living_mob.apply_damage(damage = damage_dealt, damagetype = BRUTE, def_zone = pick(valid_targets), sharpness = SHARP_EDGED)
	StartCooldown(cooldown_time)

#undef SPIN_SLASH_ABILITY_TYPEPATH
