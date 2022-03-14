
/turf/open/floor/plating/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plating/lowpressure
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	baseturfs = /turf/open/floor/plating/lowpressure

/turf/open/floor/plating/icemoon
	icon_state = "plating"
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/plating/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	base_icon_state = "alienpod1"
	tiled_dirt = FALSE

/turf/open/floor/plating/abductor/setup_broken_states()
	return list("alienpod1")

/turf/open/floor/plating/abductor/Initialize(mapload)
	. = ..()
	icon_state = "alienpod[rand(1,9)]"


/turf/open/floor/plating/abductor2
	name = "alien plating"
	icon_state = "alienplating"
	base_icon_state = "alienplating"
	tiled_dirt = FALSE

/turf/open/floor/plating/abductor2/break_tile()
	return //unbreakable

/turf/open/floor/plating/abductor2/burn_tile()
	return //unburnable

/turf/open/floor/plating/abductor2/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/beach
	name = "beach"
	icon = 'icons/misc/beach.dmi'
	flags_1 = NONE
	attachment_holes = FALSE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/beach/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/beach/ex_act(severity, target)
	return

/turf/open/floor/plating/beach/sand
	gender = PLURAL
	name = "sand"
	desc = "Surf's up."
	icon_state = "sand"
	base_icon_state = "sand"
	baseturfs = /turf/open/floor/plating/beach/sand

/turf/open/floor/plating/beach/sand/setup_broken_states()
	return list("sand")

/turf/open/floor/plating/beach/coastline_t
	name = "coastline"
	desc = "Tide's high tonight. Charge your batons."
	icon_state = "sandwater_t"
	base_icon_state = "sandwater_t"
	baseturfs = /turf/open/floor/plating/beach/coastline_t

/turf/open/floor/plating/beach/sand/coastline_t/setup_broken_states()
	return list("sandwater_t")

/turf/open/floor/plating/beach/coastline_b //need to make this water subtype.
	name = "coastline"
	icon_state = "sandwater_b"
	base_icon_state = "sandwater_b"
	baseturfs = /turf/open/floor/plating/beach/coastline_b
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA

/turf/open/floor/plating/beach/sand/coastline_b/setup_broken_states()
	return list("sandwater_b")

/turf/open/floor/plating/ice
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "ice_turf-0"
	base_icon_state = "ice_turf-0"
	initial_gas_mix = FROZEN_ATMOS
	temperature = 180
	planetary_atmos = TRUE
	baseturfs = /turf/open/floor/plating/ice
	slowdown = 1
	attachment_holes = FALSE
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/ice/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_PERMAFROST, INFINITY, 0, INFINITY, TRUE)

/turf/open/floor/plating/ice/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ice/smooth
	icon_state = "ice_turf-255"
	base_icon_state = "ice_turf"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ICE)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_ICE)

/turf/open/floor/plating/ice/break_tile()
	return

/turf/open/floor/plating/ice/burn_tile()
	return

/turf/open/floor/plating/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	slowdown = 0

/turf/open/floor/plating/ice/icemoon/no_planet_atmos
	planetary_atmos = FALSE

/turf/open/floor/plating/snowed
	name = "snowed-over plating"
	desc = "A section of heated plating, helps keep the snow from stacking up too high."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snowplating"
	base_icon_state = "snowplating"
	initial_gas_mix = FROZEN_ATMOS
	temperature = 180
	attachment_holes = FALSE
	planetary_atmos = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/snowed/cavern
	initial_gas_mix = "n2=82;plasma=24;TEMP=120"

/turf/open/floor/plating/snowed/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/plating/snowed/smoothed
	icon = 'icons/turf/floors/snow_turf.dmi'
	icon_state = "snow_turf-0"
	base_icon_state = "snow_turf"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_SNOWED)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_SNOWED)
	planetary_atmos = TRUE

/turf/open/floor/plating/snowed/temperatre
	temperature = 255.37

/turf/open/floor/plating/snowed/smoothed/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/plating/lavaland_atmos
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/plating/elevatorshaft
	name = "elevator shaft"
	icon_state = "elevatorshaft"
	base_icon_state = "elevatorshaft"
