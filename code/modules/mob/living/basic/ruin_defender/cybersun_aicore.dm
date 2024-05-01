/// Boss for the hauntedtradingpost space ruin
/// It's a stationary AI core that casts spells
#define LIGHTNING_ABILITY_TYPEPATH /datum/action/cooldown/spell/pointed/lightning_strike
#define BARRAGE_ABILITY_TYPEPATH /datum/action/cooldown/spell/pointed/projectile/cybersun_barrage

/mob/living/basic/cybersun_ai_core
	name = "\improper Cybersun AI Core"
	desc = "An evil looking computer."
	icon = 'icons/mob/silicon/ai.dmi'
	icon_state = "ai-red"
	icon_living = "ai-red"
	gender = NEUTER
	basic_mob_flags = MOB_ROBOTIC
	mob_size = MOB_SIZE_HUGE
	basic_mob_flags = DEL_ON_DEATH
	health = 250
	maxHealth = 250
	faction = list(ROLE_SYNDICATE)
	ai_controller = /datum/ai_controller/basic_controller/cybersun_ai_core
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	combat_mode = TRUE
	move_resist = INFINITY
	damage_coeff = list(BRUTE = 1.5, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
	/// Ability which fires da lightning bolt
	var/datum/action/cooldown/mob_cooldown/lightning_strike
	/// Ability which fires da big laser
	var/datum/action/cooldown/mob_cooldown/targeted_mob_ability/donk_laser
// list of stuff tagged to self destruct when this boss dies
GLOBAL_LIST_EMPTY(selfdestructs_when_boss_dies)

/mob/living/basic/cybersun_ai_core/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, INNATE_TRAIT)
	var/static/list/death_loot = list(/obj/effect/temp_visual/cybersun_ai_core_death)
	AddElement(/datum/element/death_drops, death_loot)
	AddElement(/datum/element/relay_attackers)
	var/static/list/innate_actions = list(
		LIGHTNING_ABILITY_TYPEPATH = BB_CYBERSUN_CORE_LIGHTNING,
		BARRAGE_ABILITY_TYPEPATH = BB_CYBERSUN_CORE_BARRAGE,
	)
	grant_actions_by_list(innate_actions)
/mob/living/basic/cybersun_ai_core/death(gibbed)
	do_sparks(number = 5, source = src)
	return ..()
/obj/effect/temp_visual/cybersun_ai_core_death
	icon = 'icons/mob/silicon/ai.dmi'
	icon_state = "ai-red_dead"
	duration = 2 SECONDS
/obj/effect/temp_visual/cybersun_ai_core_death/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/misc/metal_creak.ogg', vol = 100, vary = TRUE, pressure_affected = FALSE)
	Shake(1, 0, 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(gib)), duration - 1, TIMER_DELETE_ME)

/obj/effect/temp_visual/cybersun_ai_core_death/proc/gib()
///dramatic death animations
	playsound(loc, 'sound/effects/explosion2.ogg', vol = 75, vary = TRUE, pressure_affected = FALSE)
	var/turf/my_turf = get_turf(src)
	new /obj/effect/gibspawner/robot(my_turf)
	//disable all the tripwire traps
	for (var/obj/item/pressure_plate/puzzle/invisible_tripwire as anything in GLOB.selfdestructs_when_boss_dies)
		addtimer(CALLBACK(invisible_tripwire, TYPE_PROC_REF(/atom/, take_damage), invisible_tripwire.max_integrity), 0.1 SECONDS)
	//and the electric overload traps
	for (var/obj/effect/overloader_trap as anything in GLOB.selfdestructs_when_boss_dies)
		addtimer(CALLBACK(overloader_trap, TYPE_PROC_REF(/atom/, take_damage), overloader_trap.max_integrity), 0.2 SECONDS)
	//then disable the AI defence holograms
	for (var/obj/structure/holosign/barrier/cyborg/cybersun_ai_shield as anything in GLOB.selfdestructs_when_boss_dies)
		addtimer(CALLBACK(cybersun_ai_shield, TYPE_PROC_REF(/atom/, take_damage), cybersun_ai_shield.max_integrity), rand(0.2 SECONDS, 1 SECONDS))
	//then the power generator
	for (var/obj/machinery/power/smes/magical/cybersun as anything in GLOB.selfdestructs_when_boss_dies)
		addtimer(CALLBACK(cybersun, TYPE_PROC_REF(/atom/, take_damage), cybersun.max_integrity), 2 SECONDS)
	for (var/mob/murderer in range(10, src))
		if (!murderer.client || !isliving(murderer))
			continue
		playsound(loc, 'sound/effects/explosion2.ogg', vol = 75, vary = TRUE, pressure_affected = FALSE)
		shake_camera(murderer, duration = 1.7 SECONDS, strength = 1)
	for (var/mob/living in viewers(src, null))
		if (!living.client || !isliving(living))
			continue
		playsound(loc, 'sound/effects/explosion2.ogg', vol = 55, vary = TRUE, pressure_affected = FALSE)
		shake_camera(living, duration = 1 SECONDS, strength = 1)

/// how the ai core thinks
/datum/ai_controller/basic_controller/cybersun_ai_core
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGETLESS_TIME = 0,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/lightning_strike,
		/datum/ai_planning_subtree/targeted_mob_ability/cybersun_barrage,
	)

/// DA SPELLS!
// spell #1: lightning strike
/datum/ai_planning_subtree/targeted_mob_ability/lightning_strike
	ability_key = BB_CYBERSUN_CORE_LIGHTNING
	finish_planning = FALSE

/datum/action/cooldown/spell/pointed/lightning_strike
	name = "lightning strike"
	desc = "Electrocutes a target with a big lightning bolt. Has a small delay."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "lightning"
	cooldown_time = 4 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE
	sparks_amt = 1
	spell_requirements = null
	aim_assist = FALSE
	//how long after casting until the lightning strikes and damage is dealt
	var/lightning_delay = 1 SECONDS

/datum/action/cooldown/spell/pointed/lightning_strike/Activate(atom/target)
	. = ..()
	//this is where the spell will hit. it will not move even if the target does, allowing the spell to be dodged.
	var/turf/lightning_danger_zone
	if (isturf(target))
		lightning_danger_zone = target
	else
		lightning_danger_zone = target.loc
	new/obj/effect/temp_visual/lightning_strike(lightning_danger_zone)
	playsound(owner, 'sound/effects/sparks1.ogg', vol = 120, vary = TRUE)
	if(do_after(owner, lightning_delay))
		new/obj/effect/temp_visual/lightning_strike_zap(lightning_danger_zone)
		return

/obj/effect/temp_visual/lightning_strike
	name = "holographic target"
	desc = "A lightning bolt is about to hit this location. This handy hologram exists to warn people so they don't stand here."
	icon = 'icons/mob/telegraphing/telegraph_holographic.dmi'
	icon_state = "target_circle"
	duration = 1 SECONDS
	//  amount of damage a guy takes if they're on this tile
	var/zap_damage = 26
	/// don't hurt these guys capiche?
	var/list/damage_blacklist_typecache = list(
		/mob/living/basic/cybersun_ai_core,
		/mob/living/basic/viscerator,
		)

/obj/effect/temp_visual/lightning_strike/Initialize(mapload)
	. = ..()
	damage_blacklist_typecache = typecacheof(damage_blacklist_typecache)
	addtimer(CALLBACK(src, PROC_REF(zap)), duration, TIMER_DELETE_ME)

/obj/effect/temp_visual/lightning_strike/proc/zap()
	playsound(src, 'sound/magic/lightningbolt.ogg', vol = 70, vary = TRUE)
	if (!isturf(loc))
		return
	for(var/mob/living/victim in loc)
		if (is_type_in_typecache(victim, damage_blacklist_typecache))
			continue
		to_chat(victim, span_warning("You are struck by a large bolt of electricity!"))
		victim.electrocute_act(zap_damage, src, flags = SHOCK_NOGLOVES | SHOCK_NOSTUN)

/obj/effect/temp_visual/lightning_strike_zap
	name = "lightning bolt"
	desc = "Lightning bolt! Lightning bolt! Lightning bolt! Lightning bolt! Lightning bolt! Lightning bolt! Lightning bolt! Lightning bolt!"
	icon = 'icons/effects/32x96.dmi'
	icon_state = "thunderbolt"
	duration = 0.4 SECONDS

/obj/effect/temp_visual/lightning_strike_zap/Initialize(mapload)
	. = ..()
	do_sparks(number = rand(1,3), source = src)

// spell #2: cybersun laser barrage
/datum/ai_planning_subtree/targeted_mob_ability/cybersun_barrage
	ability_key = BB_CYBERSUN_CORE_BARRAGE
	finish_planning = FALSE

/datum/action/cooldown/spell/pointed/projectile/cybersun_barrage
	name = "plasma beam barrage"
	desc = "Charges up a cluster of lasers, then sends it towards a foe after a short delay."
	button_icon = 'icons/obj/weapons/transforming_energy.dmi'
	button_icon_state = "e_sword_on_red"
	cooldown_time = 6 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE
	spell_requirements = null
	projectile_type = /obj/projectile/beam/laser/cybersun/weaker
	cast_range = 6
	var/barrage_amount = 3
	var/barrage_delay = 0.7 SECONDS

/datum/action/cooldown/spell/pointed/projectile/cybersun_barrage/Activate(atom/target)

/datum/action/cooldown/spell/pointed/projectile/cybersun_barrage/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	var/turf/lockon_zone
	if (isturf(target))
		lockon_zone = target
	else
		lockon_zone = target.loc
	owner.Beam(lockon_zone, icon_state = "1-full", beam_color = COLOR_MEDIUM_DARK_RED, time = 1 SECONDS)
	playsound(lockon_zone, 'sound/machines/terminal_prompt_deny.ogg', vol = 70, vary = TRUE)
	. = ..()

/datum/action/cooldown/spell/pointed/projectile/cybersun_barrage/fire_projectile(atom/target)
	. = ..()
	if(!do_after(src, barrage_delay, src))
		return
	current_amount--
	for(var/i in 1 to barrage_amount)
		var/obj/projectile/to_fire = new projectile_type()
		ready_projectile(to_fire, target, owner, i)
		SEND_SIGNAL(owner, COMSIG_MOB_SPELL_PROJECTILE, src, target, to_fire)
		to_fire.fire()
	return TRUE

/obj/projectile/beam/laser/cybersun/weaker
	damage = 11

#undef LIGHTNING_ABILITY_TYPEPATH
#undef BARRAGE_ABILITY_TYPEPATH