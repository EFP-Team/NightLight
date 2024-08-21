/obj/item/fish/sockeye_salmon
	name = "sockeye salmon"
	desc = "A fairly common and iconic salmon endemic of the Pacific Ocean. At some point imported into outer space, where we're now."
	icon_state = "sockeye"
	dedicated_in_aquarium_icon_state = "sockeye_small"
	sprite_width = 6
	sprite_height = 4
	stable_population = 6
	required_temperature_min = MIN_AQUARIUM_TEMP+3
	required_temperature_max = MIN_AQUARIUM_TEMP+19
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
	fillet_type = /obj/item/food/fishmeat/salmon
	beauty = FISH_BEAUTY_GOOD

/obj/item/fish/arctic_char
	name = "arctic char"
	desc = "A cold-water anadromous fish widespread around the Northern Hemisphere of Earth, yet it has somehow found a way here."
	icon_state = "arctic_char"
	dedicated_in_aquarium_icon_state = "arctic_char"
	sprite_width = 7
	sprite_height = 4
	stable_population = 6
	average_size = 60
	average_weight = 1200
	weight_size_deviation = 0.5 // known for their size dismophism
	required_temperature_min = MIN_AQUARIUM_TEMP+3
	required_temperature_max = MIN_AQUARIUM_TEMP+19
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS

/obj/item/fish/pike
	name = "pike"
	desc = "A long-bodied predator with a snout that almost looks like a beak. Definitely not a weapon to swing around."
	icon = 'icons/obj/structures/aquarium/wide.dmi'
	icon_state = "pike"
	dedicated_in_aquarium_icon = 'icons/obj/structures/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state = "pike_small"
	base_pixel_x = -16
	pixel_x = -16
	stable_population = 4
	sprite_width = 10
	sprite_height = 3
	average_size = 100
	average_weight = 2000
	breeding_timeout = 4 MINUTES
	health = 150
	beauty = FISH_BEAUTY_GOOD
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
	random_case_rarity = FISH_RARITY_RARE
	fish_movement_type = /datum/fish_movement/plunger
	fishing_difficulty_modifier = 10
	required_temperature_min = MIN_AQUARIUM_TEMP+12
	required_temperature_max = MIN_AQUARIUM_TEMP+27
	fish_traits = list(/datum/fish_trait/carnivore, /datum/fish_trait/predator, /datum/fish_trait/aggressive)
	compatible_types = list(/obj/item/fish/pike/armored)
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = SEAFOOD|MEAT,
		),
		/obj/item/fish,
	)

/obj/item/fish/pike/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_FISH_SHOULD_TWOHANDED, INNATE_TRAIT)
