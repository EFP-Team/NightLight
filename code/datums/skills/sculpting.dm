/datum/skill/sculpting
	name = "Sculpting"
	title = "Sculpting"
	desc = "Art is never finished, only abandoned." // - Leonardo da Vinci
	modifiers = list(
		SKILL_SPEED_MODIFIER = list(1, 0.95, 0.89, 0.82, 0.74, 0.65, 0.55),
		// the beauty multiplier of a sculpted object
		SKILL_VALUE_MODIFIER = list(0.5, 0.75, 1, 1.25, 1.75, 2.5, 3.5),
	)
	skill_item_path = /obj/item/clothing/neck/cloak/skill_reward/sculpting
