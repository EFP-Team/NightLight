/// Creates a digital effect around the target
/atom/proc/create_digital_aura()
	var/base_icon
	var/dimensions = get_icon_dimensions(icon)
	if(!length(dimensions))
		return

	switch(dimensions["width"])
		if(32)
			base_icon = 'icons/effects/bitrunning.dmi'
		if(48)
			base_icon = 'icons/effects/bitrunning_48.dmi'
		if(64)
			base_icon = 'icons/effects/bitrunning_64.dmi'

	var/mutable_appearance/redshift = mutable_appearance(base_icon, "redshift")
	redshift.blend_mode = BLEND_MULTIPLY

	var/mutable_appearance/glitch_effect = mutable_appearance(base_icon, "glitch", MUTATIONS_LAYER, alpha = 150)

	add_overlay(list(glitch_effect, redshift))
	alpha = 210
	set_light(2, l_color = LIGHT_COLOR_BUBBLEGUM, l_on = TRUE)
	update_appearance()

/atom/proc/remove_digital_aura()
	cut_overlay(list("redshift", "glitch"))
	alpha = 255
	set_light(0, l_color = null, l_on = FALSE)
	update_appearance()
