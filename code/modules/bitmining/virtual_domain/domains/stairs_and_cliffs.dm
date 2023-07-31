/datum/map_template/virtual_domain/stairs_and_cliffs
	name = "Stairs and Cliffs"
	cost = BITMINING_COST_LOW
	desc = "A treacherous climb few calves can survive. Great cardio though."
	help_text = "Ever heard of 'Snakes and Ladders'? It's like that, but with instead of ladders its stairs and instead of snakes its a steep drop down a cliff into rough rocks or liquid plasma."
	extra_loot = list(/obj/item/clothing/suit/costume/snowman = 1, /obj/item/clothing/head/costume/snowman = 1 )
	difficulty = BITMINING_DIFFICULTY_LOW
	filename = "stairs_and_cliffs.dmm"
	forced_outfit = /datum/outfit/job/virtual_domain_iceclimber
	id = "stairs_and_cliffs"
	reward_points = BITMINING_REWARD_LOW
	safehouse_path = /datum/map_template/safehouse/ice

/turf/open/cliff/snowrock/virtual_domain
	name = "icy cliff"
	initial_gas_mix = "o2=22;n2=82;TEMP=180"

/turf/open/lava/plasma/virtual_domain
	name = "plasma lake"
	initial_gas_mix = "o2=22;n2=82;TEMP=180"

/datum/outfit/job/virtual_domain_iceclimber
	name = "Ice Climber"
	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/hooded/wintercoat
	backpack_contents = list(
		/obj/item/flashlight = 1,
		/obj/item/flashlight/flare = 2,
		)
	backpack = /obj/item/storage/backpack/duffelbag
	shoes = /obj/item/clothing/shoes/winterboots
