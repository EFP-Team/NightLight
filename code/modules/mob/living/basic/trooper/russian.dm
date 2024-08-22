/// Russian trooper subtype
/mob/living/basic/trooper/russian
	name = "Russian Mobster"
	desc = "For the Motherland!"
	speed = 1.2
	melee_damage_lower = 15
	melee_damage_upper = 15
	unsuitable_cold_damage = 1
	unsuitable_heat_damage = 1
	faction = list(FACTION_RUSSIAN)
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH

	mob_spawner = /obj/effect/mob_spawn/corpse/human/russian
	r_hand = /obj/item/knife/kitchen
	loot = list(
		/obj/effect/mob_spawn/corpse/human/russian,
		/obj/item/knife/kitchen,
	)

/mob/living/basic/trooper/russian/ranged
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged
	mob_spawner = /obj/effect/mob_spawn/corpse/human/russian/ranged
	r_hand = /obj/item/gun/ballistic/automatic/pistol
	loot = list(
		/obj/effect/mob_spawn/corpse/human/russian/ranged,
		/obj/item/gun/ballistic/revolver/sakhnomanni,
	)

/mob/living/basic/trooper/russian/ranged/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, casing_type = /obj/item/ammo_casing/short310, projectile_sound = 'sound/weapons/gun/revolver/shot.ogg', burst_shots = 2, burst_intervals = 1.5, cooldown_time = 1 SECONDS)

/mob/living/basic/trooper/russian/ranged/lootless
	loot = list()
