/turf/open/floor/holofloor
	icon_state = "floor"
	thermal_conductivity = 0
	flags_1 = NONE
	var/direction = 2

/turf/open/floor/holofloor/attackby(obj/item/I, mob/living/user)
	return // HOLOFLOOR DOES NOT GIVE A FUCK

/turf/open/floor/holofloor/tool_act(mob/living/user, obj/item/I, tool_type)
	return

/turf/open/floor/holofloor/burn_tile()
	return //you can't burn a hologram!

/turf/open/floor/holofloor/break_tile()
	return //you can't break a hologram!

/turf/open/floor/holofloor/plating
	name = "holodeck projector floor"
	icon_state = "engine"

/turf/open/floor/holofloor/chapel
	name = "chapel floor"
	icon_state = "chapel"

/turf/open/floor/holofloor/chapel/bottom_left
	name = "chapel floor"
	icon_state = "chapel"
	direction = 8

/turf/open/floor/holofloor/chapel/top_right
	name = "chapel floor"
	icon_state = "chapel"
	direction = 4

/turf/open/floor/holofloor/chapel/bottom_right
	name = "chapel floor"
	icon_state = "chapel"

/turf/open/floor/holofloor/chapel/top_left
	name = "chapel floor"
	icon_state = "chapel"
	direction = 1

/turf/open/floor/holofloor/Initialize()
	. = ..()
	if (direction != 2)
		src.setDir(direction)
	//why do i have this? some bug with turfs with dir vars not loading correctly, this only happens after mapload. turfs will be correctly rotated before
	//mapload is finished, but not after.
	//update: 70% sure this is because turf/ChangeTurf() only takes in the path of the new turf and not any attributes, so this will have to stay
	//unless that is fixed

/turf/open/floor/holofloor/plating/burnmix
	name = "burn-mix floor"
	initial_gas_mix = BURNMIX_ATMOS

/turf/open/floor/holofloor/white
	name = "white floor"
	icon_state = "white"

/turf/open/floor/holofloor/grass
	gender = PLURAL
	name = "lush grass"
	icon_state = "grass0"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/grass/Initialize()
	. = ..()
	icon_state = "grass[rand(0,3)]"

/turf/open/floor/holofloor/beach
	gender = PLURAL
	name = "sand"
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/beach/coast_t
	gender = NEUTER
	name = "coastline"
	icon_state = "sandwater_t"

/turf/open/floor/holofloor/beach/coast_b
	gender = NEUTER
	name = "coastline"
	icon_state = "sandwater_b"

/turf/open/floor/holofloor/beach/water
	name = "water"
	icon_state = "water"
	bullet_sizzle = TRUE

/turf/open/floor/holofloor/asteroid
	gender = PLURAL
	name = "asteroid sand"
	icon_state = "asteroid"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/asteroid/Initialize()
	icon_state = "asteroid[rand(0, 12)]"
	. = ..()

/turf/open/floor/holofloor/basalt
	gender = PLURAL
	name = "basalt"
	icon_state = "basalt0"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/basalt/Initialize()
	. = ..()
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		set_basalt_light(src)

/turf/open/floor/holofloor/space
	name = "\proper space"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"

/turf/open/floor/holofloor/space/Initialize()
	icon_state = SPACE_ICON_STATE // so realistic
	. = ..()

/turf/open/floor/holofloor/hyperspace
	name = "\proper hyperspace"
	icon = 'icons/turf/space.dmi'
	icon_state = "speedspace_ns_1"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/hyperspace/Initialize()
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"
	. = ..()

/turf/open/floor/holofloor/hyperspace/ns/Initialize()
	. = ..()
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"

/turf/open/floor/holofloor/carpet
	name = "carpet"
	desc = "Electrically inviting."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET)
	canSmoothWith = list(SMOOTH_GROUP_CARPET)
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/carpet/Initialize()
	. = ..()
	addtimer(CALLBACK(src, /atom/.proc/update_icon), 1)

/turf/open/floor/holofloor/carpet/update_icon()
	. = ..()
	if(intact && smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)

/turf/open/floor/holofloor/wood
	icon_state = "wood"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/snow
	gender = PLURAL
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	slowdown = 2
	bullet_sizzle = TRUE
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/snow/cold
	initial_gas_mix = "nob=7500;TEMP=2.7"

/turf/open/floor/holofloor/dark
	icon_state = "darkfull"
