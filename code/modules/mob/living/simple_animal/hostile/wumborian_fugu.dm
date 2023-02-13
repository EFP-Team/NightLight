/**
 * # Wumborian Fugu
 *
 * A strange alien creature capable of increasing its mass when threatened,
 * giving it unmatched defensive capabilities temporarily. The rest of the
 * time, it is quite fragile.
 *
 * On death, the "fugu gland" is dropped, which can be used on simple mobs
 * to increase their size, health, strength, and lets them smash walls.
 */
/mob/living/simple_animal/hostile/asteroid/fugu
	name = "wumborian fugu"
	desc = "The wumborian fugu rapidly increases its body mass in order to ward off its prey. Great care should be taken to avoid it while it's in this state as it is nearly invincible, but it cannot maintain its form forever."
	icon = 'icons/mob/simple/lavaland/64x64megafauna.dmi'
	icon_state = "Fugu0"
	icon_living = "Fugu0"
	icon_aggro = "Fugu0"
	icon_dead = "Fugu_dead"
	icon_gib = "syndicate_gib"
	health_doll_icon = "Fugu0"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	move_to_delay = 5
	friendly_verb_continuous = "floats near"
	friendly_verb_simple = "float near"
	speak_emote = list("puffs")
	vision_range = 5
	speed = 0
	maxHealth = 50
	health = 50
	pixel_x = -16
	base_pixel_x = -16
	harm_intent_damage = 5
	obj_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	throw_message = "is avoided by the"
	aggro_vision_range = 9
	mob_size = MOB_SIZE_SMALL
	environment_smash = ENVIRONMENT_SMASH_NONE
	gold_core_spawnable = HOSTILE_SPAWN
	var/wumbo = 0
	var/inflate_cooldown = 0
	var/datum/action/innate/fugu/expand/E
	loot = list(/obj/item/fugu_gland{layer = ABOVE_MOB_LAYER})

/mob/living/simple_animal/hostile/asteroid/fugu/Initialize(mapload)
	. = ..()
	E = new
	E.Grant(src)

/mob/living/simple_animal/hostile/asteroid/fugu/Destroy()
	QDEL_NULL(E)
	return ..()

/mob/living/simple_animal/hostile/asteroid/fugu/Life(delta_time = SSMOBS_DT, times_fired)
	if(!wumbo)
		inflate_cooldown = max((inflate_cooldown - (0.5 * delta_time)), 0)
	if(target && AIStatus == AI_ON)
		E.Activate()
	..()

/mob/living/simple_animal/hostile/asteroid/fugu/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && wumbo)
		return FALSE
	. = ..()

/mob/living/simple_animal/hostile/asteroid/fugu/Aggro()
	..()
	E.Activate()

/datum/action/innate/fugu
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_fugu"
	overlay_icon_state = "bg_fugu_border"

/datum/action/innate/fugu/expand
	name = "Inflate"
	desc = "Temporarily increases your size, and makes you significantly more dangerous and tough! Do not bully the fugu!"
	button_icon_state = "expand"

/datum/action/innate/fugu/expand/Activate()
	var/mob/living/simple_animal/hostile/asteroid/fugu/F = owner
	if(F.wumbo)
		to_chat(F, span_warning("YOU'RE ALREADY WUMBO!"))
		return
	if(F.inflate_cooldown)
		to_chat(F, span_warning("You need time to gather your strength!"))
		return
	if(HAS_TRAIT(F, TRAIT_FUGU_GLANDED))
		to_chat(F, span_warning("Something is interfering with your growth!"))
		return
	F.wumbo = 1
	F.icon_state = "Fugu1"
	F.obj_damage = 60
	F.melee_damage_lower = 15
	F.melee_damage_upper = 20
	F.harm_intent_damage = 0
	F.throw_message = "is absorbed by the girth of the"
	F.retreat_distance = null
	F.minimum_distance = 1
	F.move_to_delay = 6
	F.AddElement(/datum/element/wall_smasher)
	F.mob_size = MOB_SIZE_LARGE
	F.speed = 1
	addtimer(CALLBACK(F, TYPE_PROC_REF(/mob/living/simple_animal/hostile/asteroid/fugu, Deflate)), 100)

// Why is half of this in an action and the other hand a proc on the mob?
/mob/living/simple_animal/hostile/asteroid/fugu/proc/Deflate()
	if(wumbo)
		SSmove_manager.stop_looping(src)
		wumbo = 0
		icon_state = "Fugu0"
		obj_damage = 0
		melee_damage_lower = 0
		melee_damage_upper = 0
		harm_intent_damage = 5
		throw_message = "is avoided by the"
		retreat_distance = 9
		minimum_distance = 9
		move_to_delay = 2
		inflate_cooldown = 4
		RemoveElement(/datum/element/wall_smasher)
		mob_size = MOB_SIZE_SMALL
		speed = 0

/mob/living/simple_animal/hostile/asteroid/fugu/death(gibbed)
	Deflate()
	..(gibbed)
