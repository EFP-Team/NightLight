/datum/preference/color/paint_color
	savefile_key = "paint_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/color/paint_color/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return "Tagger" in preferences.all_quirks

/datum/preference/color/paint_color/apply_to_human(mob/living/carbon/human/target, value)
	return
