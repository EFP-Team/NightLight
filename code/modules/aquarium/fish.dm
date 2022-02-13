// Fish path used for autogenerated fish
/obj/item/fish
	name = "generic looking aquarium fish"
	desc = "very bland"
	w_class = WEIGHT_CLASS_TINY

/// Automatically generates object of given base path from the behaviour type in loc
/proc/generate_fish(loc,behaviour_type,base_path=/obj/item/fish)
	var/datum/aquarium_behaviour/behaviour = behaviour_type
	var/obj/item/fish = new base_path(loc)
	fish.name = initial(behaviour.name)
	fish.icon = initial(behaviour.icon)
	fish.icon_state = initial(behaviour.icon_state)
	fish.desc = initial(behaviour.desc)
	if(initial(behaviour.color))
		fish.add_atom_colour(initial(behaviour.color), FIXED_COLOUR_PRIORITY)
	if(ispath(behaviour_type,/datum/aquarium_behaviour/fish))
		var/datum/aquarium_behaviour/fish/fish_behaviour = behaviour_type
		var/fillet_type = initial(fish_behaviour.fillet_type)
		if(fillet_type)
			fish.AddElement(/datum/element/processable, TOOL_KNIFE, fillet_type, 1, 5)
	fish.AddElement(/datum/element/deferred_aquarium_content, behaviour_type)
	return fish

/// Returns random fish, using random_case_rarity probabilities.
/proc/random_fish_type(case_fish_only=TRUE, required_fluid)
	var/static/probability_table
	var/argkey = "fish_[required_fluid]_[case_fish_only]" //If this expands more extract bespoke element arg generation to some common helper.
	if(!probability_table || !probability_table[argkey])
		if(!probability_table)
			probability_table = list()
		var/chance_table = list()
		for(var/_fish_behavior in subtypesof(/datum/aquarium_behaviour/fish))
			var/datum/aquarium_behaviour/fish/fish_behavior = _fish_behavior
			if(required_fluid && initial(fish_behavior.required_fluid_type) != required_fluid)
				continue
			if(initial(fish_behavior.available_in_random_cases) || !case_fish_only)
				chance_table[fish_behavior] = initial(fish_behavior.random_case_rarity)
		probability_table[argkey] = chance_table
	return pick_weight(probability_table[argkey])

// Actual fish definitions below - there's no specific paths, they are autogenerated from behaviours

// Freshwater fish

/datum/aquarium_behaviour/fish/goldfish
	name = "goldfish"
	desc = "Despite common belief, goldfish do not have three-second memories. They can actually remember things that happened up to three months ago."
	icon_state = "goldfish"
	sprite_width = 8
	sprite_height = 8

	stable_population = 3

/datum/aquarium_behaviour/fish/angelfish
	name = "angelfish"
	desc = "Young Angelfish often live in groups, while adults prefer solitary life. They become territorial and aggressive toward other fish when they reach adulthood."
	icon_state = "angelfish"
	dedicated_in_aquarium_icon_state = "bigfish"
	sprite_height = 7
	source_height = 7

	stable_population = 3

/datum/aquarium_behaviour/fish/guppy
	name = "guppy"
	desc = "Guppy is also known as rainbow fish because of the brightly colored body and fins."
	icon_state = "guppy"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	aquarium_vc_color = "#91AE64"
	sprite_width = 8
	sprite_height = 5

	stable_population = 6

/datum/aquarium_behaviour/fish/plasmatetra
	name = "plasma tetra"
	desc = "Due to their small size, tetras are prey to many predators in their watery world, including eels, crustaceans, and invertebrates."
	icon_state = "plastetra"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	aquarium_vc_color = "#D30EB0"

	stable_population = 3

/datum/aquarium_behaviour/fish/catfish
	name = "cory catfish"
	desc = "A catfish has about 100,000 taste buds, and their bodies are covered with them to help detect chemicals present in the water and also to respond to touch."
	icon_state = "catfish"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	aquarium_vc_color = "#907420"

	stable_population = 3

/datum/aquarium_behaviour/fish/spacecarp
	name = "space carp"
	desc = "This space predator fish is known to cause yearly damage to space stations during their migrations."
	icon_state = "carp"
	sprite_width = 8
	sprite_height = 8
	available_in_random_cases = FALSE

// Saltwater fish below

/datum/aquarium_behaviour/fish/clownfish
	name = "clownfish"
	desc = "Clownfish catch prey by swimming onto the reef, attracting larger fish, and luring them back to the anemone. The anemone will sting and eat the larger fish, leaving the remains for the clownfish."
	icon_state = "clownfish"
	dedicated_in_aquarium_icon_state = "clownfish_small"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	sprite_width = 8
	sprite_height = 5

	stable_population = 4

/datum/aquarium_behaviour/fish/cardinal
	name = "cardinalfish"
	desc = "Cardinalfish are often found near sea urchins, where the fish hide when threatened."
	icon_state = "cardinalfish"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER

	stable_population = 4

/datum/aquarium_behaviour/fish/greenchromis
	name = "green chromis"
	desc = "The Chromis can vary in color from blue to green depending on the lighting and distance from the lights."
	icon_state = "greenchromis"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	aquarium_vc_color = "#00ff00"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER

	stable_population = 5

/datum/aquarium_behaviour/fish/firefish
	name = "firefish goby"
	desc = "To communicate in the wild, the firefish uses its dorsal fin to alert others of potential danger."
	icon_state = "firefish"
	sprite_width = 6
	sprite_height = 5
	required_fluid_type = AQUARIUM_FLUID_SALTWATER

	stable_population = 3

/datum/aquarium_behaviour/fish/pufferfish
	name = "pufferfish"
	desc = "One Pufferfish contains enough toxins in its liver to kill 30 people."
	icon_state = "pufferfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	sprite_width = 8
	sprite_height = 8

	stable_population = 3

/datum/aquarium_behaviour/fish/lanternfish
	name = "lanternfish"
	desc = "Typically found in areas below 6600 feet below the surface of the ocean, they live in complete darkness."
	icon_state = "lanternfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	random_case_rarity = FISH_RARITY_VERY_RARE
	source_width = 28
	source_height = 21
	sprite_width = 8
	sprite_height = 8

	stable_population = 3

//Tiziran Fish
/datum/aquarium_behaviour/fish/dwarf_moonfish
	name = "dwarf moonfish"
	desc = "Ordinarily in the wild, the Zagoskian moonfish is around the size of a tuna, however through selective breeding a smaller breed suitable for being kept as an aquarium pet has been created."
	icon_state = "dwarf_moonfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 2
	fillet_type = /obj/item/food/fishmeat/moonfish

/datum/aquarium_behaviour/fish/gunner_jellyfish
	name = "gunner jellyfish"
	desc = "So called due to their resemblance to an artillery shell, the gunner jellyfish is native to Tizira, where it is enjoyed as a delicacy. Produces a mild hallucinogen that is destroyed by cooking."
	icon_state = "gunner_jellyfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 4
	fillet_type = /obj/item/food/fishmeat/gunner_jellyfish

/datum/aquarium_behaviour/fish/needlefish
	name = "needlefish"
	desc = "A tiny, transparent fish which resides in large schools in the oceans of Tizira. A common food for other, larger fish."
	icon_state = "needlefish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 12
	fillet_type = null

/datum/aquarium_behaviour/fish/armorfish
	name = "armorfish"
	desc = "A small shellfish native to Tizira's oceans, known for its exceptionally hard shell. Consumed similarly to prawns."
	icon_state = "armorfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 10
	fillet_type = /obj/item/food/fishmeat/armorfish

/obj/item/storage/box/fish_debug
	name = "box full of fish"

/obj/item/storage/box/fish_debug/PopulateContents()
	for(var/fish_type in subtypesof(/datum/aquarium_behaviour/fish))
		generate_fish(src,fish_type)

/datum/aquarium_behaviour/fish/donkfish
	name = "donk co. company patent donkfish"
	desc = "A lab-grown donkfish. Its invention was an accident for the most part, as it was intended to be consumed in donk pockets. Unfortunately, it tastes horrible, so it has now become a pseudo-mascot."
	icon_state = "donkfish"
	random_case_rarity = FISH_RARITY_VERY_RARE
	required_fluid_type = AQUARIUM_FLUID_FRESHWATER
	stable_population = 4
	fillet_type = /obj/item/food/fishmeat/donkfish

/datum/aquarium_behaviour/fish/emulsijack
	name = "toxic emulsijack"
	desc = "Ah, the terrifying emulsijack. Created in a laboratory, this slimey, scaleless fish emits an invisible toxin that emulsifies other fish for it to feed on. Its only real use is for completely ruining a tank."
	icon_state = "emulsijack"
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
	stable_population = 3

/datum/aquarium_behaviour/fish/emulsijack/process(delta_time = SSOBJ_DT)
	var/emulsified = FALSE
	if(parent.current_aquarium)
		for(var/obj/item/fish/victim in parent.current_aquarium.contents)
			var/datum/component/aquarium_content/content_component = victim.GetComponent(/datum/component/aquarium_content)
			var/datum/aquarium_behaviour/fish/fish_properties = content_component.properties
			if(istype(fish_properties, /datum/aquarium_behaviour/fish/emulsijack))
				continue //no team killing
			fish_properties.adjust_health((fish_properties.health - 3) * delta_time) //the victim may heal a bit but this will quickly kill
			emulsified = TRUE
	if(emulsified)
		adjust_health((health + 3) * delta_time)
		last_feeding = world.time //emulsijack feeds on the emulsion!
	..()

/datum/aquarium_behaviour/fish/ratfish
	name = "ratfish"
	desc = "A rat exposed to the murky waters of maintenance too long. Any higher power, if it revealed itself, would state that the ratfish's continued existence is extremely unwelcome."
	icon_state = "ratfish"
	random_case_rarity = FISH_RARITY_RARE
	required_fluid_type = AQUARIUM_FLUID_FRESHWATER
	stable_population = 10 //set by New, but this is the default config value
	fillet_type = /obj/item/food/fishmeat/donkfish

/datum/aquarium_behaviour/fish/ratfish/New()
	//stable pop reflects the config for how many mice migrate. powerful...
	stable_population = CONFIG_GET(number/mice_roundstart)
