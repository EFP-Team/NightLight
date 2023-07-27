//Space bears!
/mob/living/basic/bear
	name = "space bear"
	desc = "You don't need to be faster than a space bear, you just need to outrun your crewmates."
	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	icon_gib = "bear_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	butcher_results = list(/obj/item/food/meat/slab/bear = 5, /obj/item/clothing/head/costume/bearpelt = 1)

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"

	maxHealth = 60
	health = 60
	speed = 0

	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	wound_bonus = -5
	bare_wound_bonus = 10 // BEAR wound bonus am i right
	sharpness = SHARP_EDGED
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	friendly_verb_continuous = "bear hugs"
	friendly_verb_simple = "bear hug"

	faction = list(FACTION_RUSSIAN)

	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = TCMB
	maximum_survivable_temperature = T0C + 1500
	ai_controller = /datum/ai_controller/basic_controller/bear
	/// is the bear wearing a armor?
	var/armored = FALSE

/mob/living/basic/bear/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/tree_climber)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BEAR, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/basic/bear/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	AddElement(/datum/element/ridable, /datum/component/riding/creature/bear)
	can_buckle = TRUE
	buckle_lying = 0

/mob/living/basic/bear/update_icons()
	..()
	if(armored)
		add_overlay("armor_bear")

/mob/living/basic/bear/proc/extract_combs(obj/structure/beebox/hive)
	if(!length(hive.honeycombs))
		return
	var/obj/item/food/honeycomb/honey_food = pick_n_take(hive.honeycombs)
	if(isnull(honey_food))
		return
	honey_food.forceMove(get_turf(src))

//SPACE BEARS! SQUEEEEEEEE~     OW! FUCK! IT BIT MY HAND OFF!!
/mob/living/basic/bear/hudson
	name = "Hudson"
	gender = MALE
	desc = "Feared outlaw, this guy is one bad news bear." //I'm sorry...

/mob/living/basic/bear/snow
	name = "space polar bear"
	icon_state = "snowbear"
	icon_living = "snowbear"
	icon_dead = "snowbear_dead"
	desc = "It's a polar bear, in space, but not actually in space."

/mob/living/basic/bear/snow/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SNOWSTORM_IMMUNE, INNATE_TRAIT)

/mob/living/basic/bear/russian
	name = "combat bear"
	desc = "A ferocious brown bear decked out in armor plating, a red star with yellow outlining details the shoulder plating."
	icon_state = "combatbear"
	icon_living = "combatbear"
	icon_dead = "combatbear_dead"
	faction = list(FACTION_RUSSIAN)
	butcher_results = list(/obj/item/food/meat/slab/bear = 5, /obj/item/clothing/head/costume/bearpelt = 1, /obj/item/bear_armor = 1)
	melee_damage_lower = 18
	melee_damage_upper = 20
	wound_bonus = 0
	armour_penetration = 20
	health = 120
	maxHealth = 120
	gold_core_spawnable = HOSTILE_SPAWN
	armored = TRUE

/mob/living/basic/bear/butter //The mighty companion to Cak. Several functions used from it.
	name = "Terrygold"
	icon_state = "butterbear"
	icon_living = "butterbear"
	icon_dead = "butterbear_dead"
	desc = "I can't believe its not a bear!"
	faction = list(FACTION_NEUTRAL, FACTION_RUSSIAN)
	obj_damage = 11
	melee_damage_lower = 0
	melee_damage_upper = 0
	sharpness = NONE //it's made of butter
	armour_penetration = 0
	response_harm_continuous = "takes a bite out of"
	response_harm_simple = "take a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'
	death_message = "loses its false life and collapses!"
	butcher_results = list(/obj/item/food/butter = 6, /obj/item/food/meat/slab = 3, /obj/item/organ/internal/brain = 1, /obj/item/organ/internal/heart = 1)
	attack_sound = 'sound/weapons/slap.ogg'
	attack_vis_effect = ATTACK_EFFECT_DISARM
	attack_verb_simple = "slap"
	attack_verb_continuous = "slaps"

/mob/living/basic/bear/butter/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(regenerate_health))

/mob/living/basic/bear/butter/proc/regenerate_health(seconds_per_tick = SSMOBS_DT, times_fired) //Heals butter bear really fast when he takes damage.
	SIGNAL_HANDLER

	if(stat == DEAD)
		return
	if(health < maxHealth)
		heal_overall_damage(5 * seconds_per_tick) //Fast life regen, makes it hard for you to get eaten to death.

/mob/living/basic/bear/butter/attack_hand(mob/living/user, list/modifiers) //Borrowed code from Cak, feeds people if they hit you. More nutriment but less vitamin to represent BUTTER.
	. = ..()
	if(user.combat_mode && user.reagents && !stat)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment, 1)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.1)

/mob/living/basic/bear/butter/CheckParts(list/parts) //Borrowed code from Cak, allows the brain used to actually control the bear.
	. = ..()
	var/obj/item/organ/internal/brain/candidate = locate(/obj/item/organ/internal/brain) in contents
	if(!candidate || !candidate.brainmob || !candidate.brainmob.mind)
		return
	var/datum/mind/candidate_mind = candidate.brainmob.mind
	candidate_mind.transfer_to(src)
	candidate_mind.grab_ghost()
	to_chat(src, "[span_boldbig("You are a butter bear!")]<b> You're a mostly harmless bear/butter hybrid that everyone loves. People can take bites out of you if they're hungry, but you regenerate health \
	so quickly that it generally doesn't matter. You're remarkably resilient to any damage besides this and it's hard for you to really die at all. You should go around and bring happiness and \
	free butter to the station!</b>")
	var/default_name = "Terrygold"
	var/new_name = sanitize_name(reject_bad_text(tgui_input_text(src, "You are the [name]. Would you like to change your name to something else?", "Name change", default_name, MAX_NAME_LEN)), cap_after_symbols = FALSE)
	if(new_name)
		to_chat(src, span_notice("Your name is now <b>[new_name]</b>!"))
		name = new_name

/mob/living/basic/bear/butter/UnarmedAttack(atom/target, proximity_flag, list/modifiers) //Makes the butter bear's attacks against vertical targets slip said targets
	. = ..()
	if(!. || !isliving(target))
		return
	var/mob/living/victim = target
	if((victim.body_position != STANDING_UP))
		return
	victim.Knockdown(20)
	playsound(loc, 'sound/misc/slip.ogg', 15)
	victim.visible_message(span_danger("[victim] slips on [src]'s butter!"))

