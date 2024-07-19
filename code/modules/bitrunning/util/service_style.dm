/// Gives the appearance of being an agent
/mob/living/carbon/human/proc/set_service_style()
	var/static/list/approved_hair_colors = list(
		"#4B3D28",
		COLOR_BLACK,
		"#8D4A43",
		"#D2B48C",
	)

	var/static/list/approved_hairstyles = list(
		/datum/sprite_accessory/hair/business,
		/datum/sprite_accessory/hair/business2,
		/datum/sprite_accessory/hair/business3,
		/datum/sprite_accessory/hair/business4,
		/datum/sprite_accessory/hair/mulder,
	)

	var/datum/sprite_accessory/hair/picked_hair = pick(approved_hairstyles)
	var/picked_color = pick(approved_hair_colors)

	set_hair_and_style(
		new_style = initial(picked_hair.name),
		new_color = picked_color,
		new_facial_style = "Shaved",
	)
