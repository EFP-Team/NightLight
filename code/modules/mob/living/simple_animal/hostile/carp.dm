#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin for megacarps (ty robustin!)

/mob/living/simple_animal/hostile/carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon = 'icons/mob/simple/carp.dmi'
	icon_state = "base"
	icon_living = "base"
	icon_dead = "base_dead"
	icon_gib = "carp_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	movement_type = FLYING
	ai_controller = /datum/ai_controller/hostile_friend
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/food/fishmeat/carp = 2, /obj/item/stack/sheet/animalhide/carp = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	emote_taunt = list("gnashes")
	taunt_chance = 30
	speed = 0
	maxHealth = 25
	health = 25
	search_objects = 1
	wanted_objects = list(/obj/item/storage/cans)
	harm_intent_damage = 8
	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("gnashes")
	//Space carp aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("carp")
	pressure_resistance = 200
	gold_core_spawnable = HOSTILE_SPAWN
	/// If the carp uses random coloring
	var/random_color = TRUE
	/// The chance for a rare color variant
	var/rarechance = 1
	/// List of usual carp colors
	var/static/list/carp_colors = list(
		"lightpurple" = "#aba2ff",
		"lightpink" = "#da77a8",
		"green" = "#70ff25",
		"grape" = "#df0afb",
		"swamp" = "#e5e75a",
		"turquoise" = "#04e1ed",
		"brown" = "#ca805a",
		"teal" = "#20e28e",
		"lightblue" = "#4d88cc",
		"rusty" = "#dd5f34",
		"lightred" = "#fd6767",
		"yellow" = "#f3ca4a",
		"blue" = "#09bae1",
		"palegreen" = "#7ef099"
	)
	/// List of rare carp colors
	var/static/list/carp_colors_rare = list(
		"silver" = "#fdfbf3"
	)
	/// Is the carp tamed?
	var/tamed = FALSE

/mob/living/simple_animal/hostile/carp/Initialize(mapload, mob/tamer)
	AddElement(/datum/element/simple_flying)
	if(random_color)
		set_greyscale(new_config=/datum/greyscale_config/carp)
		carp_randomify(rarechance)
	. = ..()
	ADD_TRAIT(src, TRAIT_HEALS_FROM_CARP_RIFTS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	add_cell_sample()
	if(ai_controller)
		ai_controller.blackboard[BB_HOSTILE_ATTACK_WORD] = pick(speak_emote)
		if(tamer)
			tamed(tamer)
		else
			make_tameable()

/mob/living/simple_animal/hostile/carp/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!. || !tamed)
		return

	var/datum/weakref/friendref = ai_controller.blackboard[BB_HOSTILE_FRIEND]
	var/mob/living/friend = friendref?.resolve()
	if(friend)
		tamed(friend)

	update_icon()

/mob/living/simple_animal/hostile/carp/death(gibbed)
	if (tamed)
		can_buckle = FALSE
	return ..()

/mob/living/simple_animal/hostile/carp/proc/make_tameable()
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/meat), tame_chance = 10, bonus_tame_chance = 5, after_tame = CALLBACK(src, PROC_REF(tamed)))

/mob/living/simple_animal/hostile/carp/proc/tamed(mob/living/tamer)
	tamed = TRUE
	buckle_lying = 0
	AddElement(/datum/element/ridable, /datum/component/riding/creature/carp)
	if(ai_controller)
		var/datum/ai_controller/hostile_friend/ai_current_controller = ai_controller
		ai_current_controller.befriend(tamer)
		can_have_ai = FALSE
		toggle_ai(AI_OFF)


/mob/living/simple_animal/hostile/carp/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CARP, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/**
 * Randomly assigns a color to a carp from either a common or rare color variant lists
 *
 * Arguments:
 * * rare The chance of the carp receiving color from the rare color variant list
 */
/mob/living/simple_animal/hostile/carp/proc/carp_randomify(rarechance)
	var/our_color
	if(prob(rarechance))
		our_color = pick(carp_colors_rare)
		set_greyscale(colors=list(carp_colors_rare[our_color]))
	else
		our_color = pick(carp_colors)
		set_greyscale(colors=list(carp_colors[our_color]))

/mob/living/simple_animal/hostile/carp/proc/chomp_plastic()
	var/obj/item/storage/cans/tasty_plastic = locate(/obj/item/storage/cans) in view(1, src)
	if(tasty_plastic && Adjacent(tasty_plastic))
		visible_message(span_notice("[src] gets its head stuck in [tasty_plastic], and gets cut breaking free from it!"), span_notice("You try to avoid [tasty_plastic], but it looks so... delicious... Ow! It cuts the inside of your mouth!"))

		new /obj/effect/decal/cleanable/plastic(loc)

		adjustBruteLoss(5)
		qdel(tasty_plastic)

/mob/living/simple_animal/hostile/carp/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == CONSCIOUS)
		chomp_plastic()

/mob/living/simple_animal/hostile/carp/holocarp
	icon_state = "holocarp"
	icon_living = "holocarp"
	maxbodytemp = INFINITY
	ai_controller = null
	gold_core_spawnable = NO_SPAWN
	del_on_death = 1
	random_color = FALSE


/mob/living/simple_animal/hostile/carp/holocarp/add_cell_sample()
	return

/mob/living/simple_animal/hostile/carp/megacarp
	icon = 'icons/mob/simple/broadMobs.dmi'
	name = "Mega Space Carp"
	desc = "A ferocious, fang bearing creature that resembles a shark. This one seems especially ticked off."
	icon_state = "megacarp"
	icon_living = "megacarp"
	icon_dead = "megacarp_dead"
	icon_gib = "megacarp_gib"
	health_doll_icon = "megacarp"
	ai_controller = null
	maxHealth = 20
	health = 20
	pixel_x = -16
	base_pixel_x = -16
	mob_size = MOB_SIZE_LARGE
	random_color = FALSE

	obj_damage = 80
	melee_damage_lower = 20
	melee_damage_upper = 20
	butcher_results = list(/obj/item/food/fishmeat/carp = 2, /obj/item/stack/sheet/animalhide/carp = 3)
	var/regen_cooldown = 0

/mob/living/simple_animal/hostile/carp/megacarp/Initialize(mapload)
	. = ..()
	name = "[pick(GLOB.megacarp_first_names)] [pick(GLOB.megacarp_last_names)]"
	melee_damage_lower += rand(2, 10)
	melee_damage_upper += rand(10,20)
	maxHealth += rand(30,60)
	move_to_delay = rand(3,7)


/mob/living/simple_animal/hostile/carp/megacarp/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MEGACARP, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/carp/megacarp/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/mob/living/simple_animal/hostile/carp/megacarp/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	AddElement(/datum/element/ridable, /datum/component/riding/creature/megacarp)
	can_buckle = TRUE
	buckle_lying = 0

/mob/living/simple_animal/hostile/carp/megacarp/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(regen_cooldown < world.time)
		heal_overall_damage(2 * delta_time)

/mob/living/simple_animal/hostile/carp/lia
	name = "Lia"
	real_name = "Lia"
	desc = "A failed experiment of Nanotrasen to create weaponised carp technology. This less than intimidating carp now serves as the Head of Security's pet."
	gender = FEMALE
	speak_emote = list("squeaks")
	ai_controller = null
	gold_core_spawnable = NO_SPAWN
	faction = list("neutral")
	health = 200
	icon_dead = "magicarp_dead"
	icon_gib = "magicarp_gib"
	icon_living = "magicarp"
	icon_state = "magicarp"
	maxHealth = 200
	random_color = FALSE

/mob/living/simple_animal/hostile/carp/lia/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "bloops happily!")


/mob/living/simple_animal/hostile/carp/cayenne
	name = "Cayenne"
	real_name = "Cayenne"
	desc = "A failed Syndicate experiment in weaponized space carp technology, it now serves as a lovable mascot."
	gender = FEMALE
	speak_emote = list("squeaks")
	ai_controller = null
	gold_core_spawnable = NO_SPAWN
	faction = list(ROLE_SYNDICATE)
	rarechance = 10
	/// Overlay to apply to display the disk
	var/mutable_appearance/disk_overlay
	/// Overlay to apply over the disk so it looks like cayenne is holding it
	var/mutable_appearance/mouth_overlay

/mob/living/simple_animal/hostile/carp/cayenne/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "bloops happily!")
	var/datum/callback/got_disk = CALLBACK(src, PROC_REF(got_disk))
	var/datum/callback/display_disk = CALLBACK(src, PROC_REF(display_disk))
	AddComponent(/datum/component/nuclear_bomb_operator, got_disk, display_disk)

/// She did it! Treats for Cayenne!
/mob/living/simple_animal/hostile/carp/cayenne/proc/got_disk(obj/item/disk/nuclear/disky)
	if (disky.fake) // Never mind she didn't do it
		return
	client.give_award(/datum/award/achievement/misc/cayenne_disk, src)

/// Adds an overlay to show the disk on Cayenne
/mob/living/simple_animal/hostile/carp/cayenne/proc/display_disk(list/new_overlays)
	if (!mouth_overlay)
		mouth_overlay = mutable_appearance(SSgreyscale.GetColoredIconByType(/datum/greyscale_config/carp/disk_mouth, greyscale_colors), "disk_mouth")
	new_overlays += mouth_overlay

	if (!disk_overlay)
		disk_overlay = mutable_appearance('icons/mob/simple/carp.dmi', "disk_overlay")
	new_overlays += disk_overlay

#undef REGENERATION_DELAY
