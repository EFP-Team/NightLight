/turf/cordon
	name = "cordon"
	icon = 'icons/turf/walls.dmi'
	icon_state = "cordon"
	invisibility = INVISIBILITY_ABSTRACT
	explosion_block = INFINITY
	rad_insulation = RAD_FULL_INSULATION
	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	always_lit = TRUE
	bullet_bounce_sound = null

/turf/cordon/rust_heretic_act()
	return

/turf/cordon/acid_act(acidpwr, acid_volume, acid_id)
	return FALSE

/turf/cordon/Melt()
	to_be_destroyed = FALSE
	return src

/turf/cordon/singularity_act()
	return

/turf/cordon/ScrapeAway(amount, flags)
	return // :devilcat:

/turf/cordon/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit)
	return BULLET_ACT_HIT

/area/cordon
	name = "CORDON"
	icon_state = "cordon"
	static_lighting = FALSE
	base_lighting_alpha = 255
	area_flags = UNIQUE_AREA|NOTELEPORT|HIDDEN_AREA|NO_ALERTS
	requires_power = FALSE

/area/cordon/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	for(var/mob/living/enterer as anything in arrived.get_all_contents_type(/mob/living))
		to_chat(enterer, span_userdanger("This was a bad idea..."))
		enterer.dust(TRUE, FALSE, TRUE)
