// Plant analyzer
/obj/item/device/analyzer/plant_analyzer
	name = "plant analyzer"
	desc = "A scanner used to evaluate a plant's various areas of growth."
	icon = 'icons/obj/device.dmi'
	icon_state = "hydro"
	item_state = "analyzer"
	origin_tech = "magnets=1;biotech=1"

	attack_self(mob/user as mob)
		return 0

// *************************************
// Hydroponics Tools
// *************************************

/obj/item/weapon/weedspray // -- Skie
	desc = "It's a toxic mixture, in spray form, to kill small weeds."
	icon = 'icons/obj/hydroponics.dmi'
	name = "weed-spray"
	icon_state = "weedspray"
	item_state = "spray"
	flags = OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 2.0
	throw_speed = 3
	throw_range = 10
	var/toxicity = 4
	var/WeedKillStr = 2

	suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] is huffing the [src.name]! It looks like \he's trying to commit suicide.</span>"
		return (TOXLOSS)

/obj/item/weapon/pestspray // -- Skie
	desc = "It's some pest eliminator spray! <I>Do not inhale!</I>"
	icon = 'icons/obj/hydroponics.dmi'
	name = "pest-spray"
	icon_state = "pestspray"
	item_state = "spray"
	flags = OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 2.0
	throw_speed = 3
	throw_range = 10
	var/toxicity = 4
	var/PestKillStr = 2

	suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] is huffing the [src.name]! It looks like \he's trying to commit suicide.</span>"
		return (TOXLOSS)

/obj/item/weapon/minihoe // -- Numbers
	name = "mini hoe"
	desc = "It's used for removing weeds or scratching your back."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hoe"
	item_state = "hoe"
	flags = CONDUCT
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	m_amt = 50
	attack_verb = list("slashed", "sliced", "cut", "clawed")
	hitsound = 'sound/weapons/bladeslice.ogg'

// *************************************
// Nutrient defines for hydroponics
// *************************************


/obj/item/weapon/reagent_containers/glass/bottle/nutrient

	name = "bottle of nutrient"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	w_class = 1.0

	New()
		..()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)


/obj/item/weapon/reagent_containers/glass/bottle/nutrient/ez
	name = "bottle of E-Z-Nutrient"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	New()
		..()
		reagents.add_reagent("nutriment", 30)

/obj/item/weapon/reagent_containers/glass/bottle/nutrient/l4z
	name = "bottle of Left 4 Zed"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"
	New()
		..()
		reagents.add_reagent("mutagen", 5)

/obj/item/weapon/reagent_containers/glass/bottle/nutrient/rh
	name = "bottle of Robust Harvest"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"
	New()
		..()
		reagents.add_reagent("diethylamine", 10)


// *************************************
// Pestkiller defines for hydroponics
// *************************************

/obj/item/pestkiller
	name = "bottle of pestkiller"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	var/toxicity = 0
	var/PestKillStr = 0
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/pestkiller/carbaryl
	name = "bottle of carbaryl"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	toxicity = 4
	PestKillStr = 2
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/pestkiller/lindane
	name = "bottle of lindane"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"
	toxicity = 6
	PestKillStr = 4
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/pestkiller/phosmet
	name = "bottle of phosmet"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"
	toxicity = 8
	PestKillStr = 7
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

// *************************************
// Weedkiller defines for hydroponics
// *************************************

/obj/item/weedkiller
	name = "bottle of weedkiller"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	var/toxicity = 0
	var/WeedKillStr = 0

/obj/item/weedkiller/glyphosate
	name = "bottle of glyphosate"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	toxicity = 4
	WeedKillStr = 2

/obj/item/weedkiller/triclopyr
	name = "bottle of triclopyr"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"
	toxicity = 6
	WeedKillStr = 4

/obj/item/weedkiller/D24
	name = "bottle of 2,4-D"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"
	toxicity = 8
	WeedKillStr = 7