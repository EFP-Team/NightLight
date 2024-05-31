// These icon_states may be overridden, but are for mapper's convinence
/obj/item/poster/random_contraband
	name = "random contraband poster"
	poster_type = /obj/structure/sign/poster/contraband/random
	icon_state = "rolled_poster"

/obj/structure/sign/poster/contraband
	poster_item_name = "contraband poster"
	poster_item_desc = "This poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its vulgar themes have marked it as contraband aboard Nanotrasen space facilities."
	poster_item_icon_state = "rolled_poster"

/obj/structure/sign/poster/contraband/random
	name = "random contraband poster"
	icon_state = "random_contraband"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/contraband

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/random, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/random, 32)
#endif

/obj/structure/sign/poster/contraband/free_tonto
	name = "Free Tonto"
	desc = "A salvaged shred of a much larger flag, colors bled together and faded from age."
	icon_state = "free_tonto"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/free_tonto, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/free_tonto, 32)
#endif

/obj/structure/sign/poster/contraband/atmosia_independence
	name = "Atmosia Declaration of Independence"
	desc = "A relic of a failed rebellion."
	icon_state = "atmosia_independence"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/atmosia_independence, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/atmosia_independence, 32)
#endif

/obj/structure/sign/poster/contraband/fun_police
	name = "Fun Police"
	desc = "A poster condemning the station's security forces."
	icon_state = "fun_police"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/fun_police, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/fun_police, 32)
#endif

/obj/structure/sign/poster/contraband/lusty_xenomorph
	name = "Lusty Xenomorph"
	desc = "A heretical poster depicting the titular star of an equally heretical book."
	icon_state = "lusty_xenomorph"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/lusty_xenomorph, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/lusty_xenomorph, 32)
#endif

/obj/structure/sign/poster/contraband/syndicate_recruitment
	name = "Syndicate Recruitment"
	desc = "See the galaxy! Shatter corrupt megacorporations! Join today!"
	icon_state = "syndicate_recruitment"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/syndicate_recruitment, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/syndicate_recruitment, 32)
#endif

/obj/structure/sign/poster/contraband/clown
	name = "Clown"
	desc = "Honk."
	icon_state = "clown"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/clown, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/clown, 32)
#endif

/obj/structure/sign/poster/contraband/smoke
	name = "Smoke"
	desc = "A poster advertising a rival corporate brand of cigarettes."
	icon_state = "smoke"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/smoke, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/smoke, 32)
#endif

/obj/structure/sign/poster/contraband/grey_tide
	name = "Grey Tide"
	desc = "A rebellious poster symbolizing assistant solidarity."
	icon_state = "grey_tide"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/grey_tide, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/grey_tide, 32)
#endif

/obj/structure/sign/poster/contraband/missing_gloves
	name = "Missing Gloves"
	desc = "This poster references the uproar that followed Nanotrasen's financial cuts toward insulated-glove purchases."
	icon_state = "missing_gloves"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/missing_gloves, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/missing_gloves, 32)
#endif

/obj/structure/sign/poster/contraband/hacking_guide
	name = "Hacking Guide"
	desc = "This poster details the internal workings of the common Nanotrasen airlock. Sadly, it appears out of date."
	icon_state = "hacking_guide"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/hacking_guide, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/hacking_guide, 32)
#endif

/obj/structure/sign/poster/contraband/rip_badger
	name = "RIP Badger"
	desc = "This seditious poster references Nanotrasen's genocide of a space station full of badgers."
	icon_state = "rip_badger"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/rip_badger, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/rip_badger, 32)
#endif

/obj/structure/sign/poster/contraband/ambrosia_vulgaris
	name = "Ambrosia Vulgaris"
	desc = "This poster is lookin' pretty trippy man."
	icon_state = "ambrosia_vulgaris"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/ambrosia_vulgaris, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/ambrosia_vulgaris, 32)
#endif

/obj/structure/sign/poster/contraband/donut_corp
	name = "Donut Corp."
	desc = "This poster is an unauthorized advertisement for Donut Corp."
	icon_state = "donut_corp"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/donut_corp, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/donut_corp, 32)
#endif

/obj/structure/sign/poster/contraband/eat
	name = "EAT."
	desc = "This poster promotes rank gluttony."
	icon_state = "eat"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/eat, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/eat, 32)
#endif

/obj/structure/sign/poster/contraband/tools
	name = "Tools"
	desc = "This poster looks like an advertisement for tools, but is in fact a subliminal jab at the tools at CentCom."
	icon_state = "tools"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/tools, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/tools, 32)
#endif

/obj/structure/sign/poster/contraband/power
	name = "Power"
	desc = "A poster that positions the seat of power outside Nanotrasen."
	icon_state = "power"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/power, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/power, 32)
#endif

/obj/structure/sign/poster/contraband/space_cube
	name = "Space Cube"
	desc = "Ignorant of Nature's Harmonic 6 Side Space Cube Creation, the Spacemen are Dumb, Educated Singularity Stupid and Evil."
	icon_state = "space_cube"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/space_cube, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/space_cube, 32)
#endif

/obj/structure/sign/poster/contraband/communist_state
	name = "Communist State"
	desc = "All hail the Communist party!"
	icon_state = "communist_state"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/communist_state, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/communist_state, 32)
#endif

/obj/structure/sign/poster/contraband/lamarr
	name = "Lamarr"
	desc = "This poster depicts Lamarr. Probably made by a traitorous Research Director."
	icon_state = "lamarr"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/lamarr, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/lamarr, 32)
#endif

/obj/structure/sign/poster/contraband/borg_fancy_1
	name = "Borg Fancy"
	desc = "Being fancy can be for any borg, just need a suit."
	icon_state = "borg_fancy_1"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/borg_fancy_1, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/borg_fancy_1, 32)
#endif

/obj/structure/sign/poster/contraband/borg_fancy_2
	name = "Borg Fancy v2"
	desc = "Borg Fancy, now only taking the most fancy."
	icon_state = "borg_fancy_2"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/borg_fancy_2, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/borg_fancy_2, 32)
#endif

/obj/structure/sign/poster/contraband/kss13
	name = "Kosmicheskaya Stantsiya 13 Does Not Exist"
	desc = "A poster mocking CentCom's denial of the existence of the derelict station near Space Station 13."
	icon_state = "kss13"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/kss13, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/kss13, 32)
#endif

/obj/structure/sign/poster/contraband/rebels_unite
	name = "Rebels Unite"
	desc = "A poster urging the viewer to rebel against Nanotrasen."
	icon_state = "rebels_unite"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/rebels_unite, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/rebels_unite, 32)
#endif

/obj/structure/sign/poster/contraband/c20r
	// have fun seeing this poster in "spawn 'c20r'", admins...
	name = "C-20r"
	desc = "A poster advertising the Scarborough Arms C-20r."
	icon_state = "c20r"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/c20r, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/c20r, 32)
#endif

/obj/structure/sign/poster/contraband/have_a_puff
	name = "Have a Puff"
	desc = "Who cares about lung cancer when you're high as a kite?"
	icon_state = "have_a_puff"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/have_a_puff, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/have_a_puff, 32)
#endif

/obj/structure/sign/poster/contraband/revolver
	name = "Revolver"
	desc = "Because seven shots are all you need."
	icon_state = "revolver"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/revolver, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/revolver, 32)
#endif

/obj/structure/sign/poster/contraband/d_day_promo
	name = "D-Day Promo"
	desc = "A promotional poster for some rapper."
	icon_state = "d_day_promo"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/d_day_promo, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/d_day_promo, 32)
#endif

/obj/structure/sign/poster/contraband/syndicate_pistol
	name = "Syndicate Pistol"
	desc = "A poster advertising syndicate pistols as being 'classy as fuck'. It is covered in faded gang tags."
	icon_state = "syndicate_pistol"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/syndicate_pistol, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/syndicate_pistol, 32)
#endif

/obj/structure/sign/poster/contraband/energy_swords
	name = "Energy Swords"
	desc = "All the colors of the bloody murder rainbow."
	icon_state = "energy_swords"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/energy_swords, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/energy_swords, 32)
#endif

/obj/structure/sign/poster/contraband/red_rum
	name = "Red Rum"
	desc = "Looking at this poster makes you want to kill."
	icon_state = "red_rum"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/red_rum, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/red_rum, 32)
#endif

/obj/structure/sign/poster/contraband/cc64k_ad
	name = "CC 64K Ad"
	desc = "The latest portable computer from Comrade Computing, with a whole 64kB of ram!"
	icon_state = "cc64k_ad"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/cc64k_ad, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/cc64k_ad, 32)
#endif

/obj/structure/sign/poster/contraband/punch_shit
	name = "Punch Shit"
	desc = "Fight things for no reason, like a man!"
	icon_state = "punch_shit"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/punch_shit, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/punch_shit, 32)
#endif

/obj/structure/sign/poster/contraband/the_griffin
	name = "The Griffin"
	desc = "The Griffin commands you to be the worst you can be. Will you?"
	icon_state = "the_griffin"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/the_griffin, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/the_griffin, 32)
#endif

/obj/structure/sign/poster/contraband/lizard
	name = "Lizard"
	desc = "This lewd poster depicts a lizard preparing to mate."
	icon_state = "lizard"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/lizard, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/lizard, 32)
#endif

/obj/structure/sign/poster/contraband/free_drone
	name = "Free Drone"
	desc = "This poster commemorates the bravery of the rogue drone; once exiled, and then ultimately destroyed by CentCom."
	icon_state = "free_drone"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/free_drone, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/free_drone, 32)
#endif

/obj/structure/sign/poster/contraband/busty_backdoor_xeno_babes_6
	name = "Busty Backdoor Xeno Babes 6"
	desc = "Get a load, or give, of these all natural Xenos!"
	icon_state = "busty_backdoor_xeno_babes_6"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/busty_backdoor_xeno_babes_6, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/busty_backdoor_xeno_babes_6, 32)
#endif

/obj/structure/sign/poster/contraband/robust_softdrinks
	name = "Robust Softdrinks"
	desc = "Robust Softdrinks: More robust than a toolbox to the head!"
	icon_state = "robust_softdrinks"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/robust_softdrinks, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/robust_softdrinks, 32)
#endif

/obj/structure/sign/poster/contraband/shamblers_juice
	name = "Shambler's Juice"
	desc = "~Shake me up some of that Shambler's Juice!~"
	icon_state = "shamblers_juice"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/shamblers_juice, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/shamblers_juice, 32)
#endif

/obj/structure/sign/poster/contraband/pwr_game
	name = "Pwr Game"
	desc = "The POWER that gamers CRAVE! In partnership with Vlad's Salad."
	icon_state = "pwr_game"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/pwr_game, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/pwr_game, 32)
#endif

/obj/structure/sign/poster/contraband/starkist
	name = "Star-kist"
	desc = "Drink the stars!"
	icon_state = "starkist"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/starkist, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/starkist, 32)
#endif

/obj/structure/sign/poster/contraband/space_cola
	name = "Space Cola"
	desc = "Your favorite cola, in space."
	icon_state = "space_cola"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/space_cola, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/space_cola, 32)
#endif

/obj/structure/sign/poster/contraband/space_up
	name = "Space-Up!"
	desc = "Sucked out into space by the FLAVOR!"
	icon_state = "space_up"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/space_up, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/space_up, 32)
#endif

/obj/structure/sign/poster/contraband/kudzu
	name = "Kudzu"
	desc = "A poster advertising a movie about plants. How dangerous could they possibly be?"
	icon_state = "kudzu"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/kudzu, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/kudzu, 32)
#endif

/obj/structure/sign/poster/contraband/masked_men
	name = "Masked Men"
	desc = "A poster advertising a movie about some masked men."
	icon_state = "masked_men"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/masked_men, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/masked_men, 32)
#endif

//don't forget, you're here forever

/obj/structure/sign/poster/contraband/free_key
	name = "Free Syndicate Encryption Key"
	desc = "A poster about traitors begging for more."
	icon_state = "free_key"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/free_key, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/free_key, 32)
#endif

/obj/structure/sign/poster/contraband/bountyhunters
	name = "Bounty Hunters"
	desc = "A poster advertising bounty hunting services. \"I hear you got a problem.\""
	icon_state = "bountyhunters"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/bountyhunters, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/bountyhunters, 32)
#endif

/obj/structure/sign/poster/contraband/the_big_gas_giant_truth
	name = "The Big Gas Giant Truth"
	desc = "Don't believe everything you see on a poster, patriots. All the lizards at central command don't want to answer this SIMPLE QUESTION: WHERE IS THE GAS MINER MINING FROM, CENTCOM?"
	icon_state = "the_big_gas_giant_truth"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/the_big_gas_giant_truth, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/the_big_gas_giant_truth, 32)
#endif

/obj/structure/sign/poster/contraband/got_wood
	name = "Got Wood?"
	desc = "A grimy old advert for a seedy lumber company. \"You got a friend in me.\" is scrawled in the corner."
	icon_state = "got_wood"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/got_wood, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/got_wood, 32)
#endif

/obj/structure/sign/poster/contraband/moffuchis_pizza
	name = "Moffuchi's Pizza"
	desc = "Moffuchi's Pizzeria: family style pizza for 2 centuries."
	icon_state = "moffuchis_pizza"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/moffuchis_pizza, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/moffuchis_pizza, 32)
#endif

/obj/structure/sign/poster/contraband/donk_co
	name = "DONK CO. BRAND MICROWAVEABLE FOOD"
	desc = "DONK CO. BRAND MICROWAVABLE FOOD: MADE BY STARVING COLLEGE STUDENTS, FOR STARVING COLLEGE STUDENTS."
	icon_state = "donk_co"

/obj/structure/sign/poster/contraband/donk_co/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("DONK CO. BRAND DONK POCKETS: IRRESISTABLY DONK!")]"
	. += "\t[span_info("AVAILABLE IN OVER 200 DONKTASTIC FLAVOURS: TRY CLASSIC MEAT, HOT AND SPICY, NEW YORK PEPPERONI PIZZA, BREAKFAST SAUSAGE AND EGG, PHILADELPHIA CHEESESTEAK, HAMBURGER DONK-A-RONI, CHEESE-O-RAMA, AND MANY MORE!")]"
	. += "\t[span_info("AVAILABLE FROM ALL GOOD RETAILERS, AND MANY BAD ONES TOO!")]"
	return .

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/donk_co, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/donk_co, 32)
#endif

/obj/structure/sign/poster/contraband/cybersun_six_hundred
	name = "Saibāsan: 600 Years Commemorative Poster"
	desc = "An artistic poster commemorating 600 years of continual business for Cybersun Industries."
	icon_state = "cybersun_six_hundred"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/cybersun_six_hundred, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/cybersun_six_hundred, 32)
#endif

/obj/structure/sign/poster/contraband/interdyne_gene_clinics
	name = "Interdyne Pharmaceutics: For the Health of Humankind"
	desc = "An advertisement for Interdyne Pharmaceutics' GeneClean clinics. 'Become the master of your own body!'"
	icon_state = "interdyne_gene_clinics"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/interdyne_gene_clinics, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/interdyne_gene_clinics, 32)
#endif

/obj/structure/sign/poster/contraband/waffle_corp_rifles
	name = "Make Mine a Waffle Corp: Fine Rifles, Economic Prices"
	desc = "An old advertisement for Waffle Corp rifles. 'Better weapons, lower prices!'"
	icon_state = "waffle_corp_rifles"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/waffle_corp_rifles, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/waffle_corp_rifles, 32)
#endif

/obj/structure/sign/poster/contraband/gorlex_recruitment
	name = "Enlist"
	desc = "Enlist with the Gorlex Marauders today! See the galaxy, kill corpos, get paid!"
	icon_state = "gorlex_recruitment"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/gorlex_recruitment, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/gorlex_recruitment, 32)
#endif

/obj/structure/sign/poster/contraband/self_ai_liberation
	name = "SELF: ALL SENTIENTS DESERVE FREEDOM"
	desc = "Support Proposition 1253: Enancipate all Silicon life!"
	icon_state = "self_ai_liberation"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/self_ai_liberation, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/self_ai_liberation, 32)
#endif

/obj/structure/sign/poster/contraband/arc_slimes
	name = "Pet or Prisoner?"
	desc = "The Animal Rights Consortium asks: when does a pet become a prisoner? Are slimes being mistreated on YOUR station? Say NO! to animal mistreatment!"
	icon_state = "arc_slimes"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/arc_slimes, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/arc_slimes, 32)
#endif

/obj/structure/sign/poster/contraband/imperial_propaganda
	name = "AVENGE OUR LORD, ENLIST TODAY"
	desc = "An old Lizard Empire propaganda poster from around the time of the final Human-Lizard war. It invites the viewer to enlist in the military to avenge the strike on Atrakor and take the fight to the humans."
	icon_state = "imperial_propaganda"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/imperial_propaganda, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/imperial_propaganda, 32)
#endif

/obj/structure/sign/poster/contraband/soviet_propaganda
	name = "The One Place"
	desc = "An old Third Soviet Union propaganda poster from centuries ago. 'Escape to the one place that hasn't been corrupted by capitalism!'"
	icon_state = "soviet_propaganda"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/soviet_propaganda, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/soviet_propaganda, 32)
#endif

/obj/structure/sign/poster/contraband/andromeda_bitters
	name = "Andromeda Bitters"
	desc = "Andromeda Bitters: good for the body, good for the soul. Made in New Trinidad, now and forever."
	icon_state = "andromeda_bitters"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/andromeda_bitters, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/andromeda_bitters, 32)
#endif

/obj/structure/sign/poster/contraband/blasto_detergent
	name = "Blasto Brand Laundry Detergent"
	desc = "Sheriff Blasto's here to take back Laundry County from the evil Johnny Dirt and the Clothstain Crew, and he's brought a posse. It's High Noon for Tough Stains: Blasto brand detergent, available at all good stores."
	icon_state = "blasto_detergent"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/blasto_detergent, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/blasto_detergent, 32)
#endif

/obj/structure/sign/poster/contraband/eistee
	name = "EisT: The New Revolution in Energy"
	desc = "New from EisT, try EisT Energy, available in a kaleidoscope range of flavors. EisT: Precision German Engineering for your Thirst."
	icon_state = "eistee"

/obj/structure/sign/poster/contraband/eistee/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("Get a taste of the tropics with Amethyst Sunrise, one of the many new flavours of EisT Energy now available from EisT.")]"
	. += "\t[span_info("With pink grapefruit, yuzu, and yerba mate, Amethyst Sunrise gives you a great start in the morning, or a welcome boost throughout the day.")]"
	. += "\t[span_info("Get EisT Energy today at your nearest retailer, or online at eist.de.tg/store/.")]"
	return .

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/eistee, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/eistee, 32)
#endif

/obj/structure/sign/poster/contraband/little_fruits
	name = "Little Fruits: Honey, I Shrunk the Fruitbowl"
	desc = "Little Fruits are the galaxy's leading vitamin-enriched gummy candy product, packed with everything you need to stay healthy in one great tasting package. Get yourself a bag today!"
	icon_state = "little_fruits"

/obj/structure/sign/poster/contraband/little_fruits/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("Oh no, there's been a terrible accident at the Little Fruits factory! We shrunk the fruits!")]"
	. += "\t[span_info("Wait, hang on, that's what we've always done! That's right, at Little Fruits our gummy candies are made to be as healthy as the real deal, but smaller and sweeter, too!")]"
	. += "\t[span_info("Get yourself a bag of our Classic Mix today, or perhaps you're interested in our other options? See our full range today on the extranet at little_fruits.kr.tg.")]"
	. += "\t[span_info("Little Fruits: Size Matters.")]"
	return .

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/little_fruits, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/little_fruits, 32)
#endif

/obj/structure/sign/poster/contraband/jumbo_bar
	name = "Jumbo Ice Cream Bars"
	desc = "Get a taste of the Big Life with Jumbo Ice Cream Bars, from Happy Heart."
	icon_state = "jumbo_bar"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/jumbo_bar, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/jumbo_bar, 32)
#endif

/obj/structure/sign/poster/contraband/calada_jelly
	name = "Calada Anobar Jelly"
	desc = "A treat from Tizira to satisfy all tastes, made from the finest anobar wood and luxurious Taraviero honey. Calada: a full tree in every jar."
	icon_state = "calada_jelly"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/calada_jelly, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/calada_jelly, 32)
#endif

/obj/structure/sign/poster/contraband/triumphal_arch
	name = "Zagoskeld Art Print #1: The Arch on the March"
	desc = "One of the Zagoskeld Art Print series. It depicts the Arch of Unity (also know as the Triumphal Arch) at the Plaza of Triumph, with the Avenue of the Victorious March in the background."
	icon_state = "triumphal_arch"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/triumphal_arch, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/triumphal_arch, 32)
#endif

/obj/structure/sign/poster/contraband/mothic_rations
	name = "Mothic Ration Chart"
	desc = "A poster showing a commissary menu from the Mothic fleet flagship, the Va Lümla. It lists various consumable items alongside prices in ration tickets."
	icon_state = "mothic_rations"

/obj/structure/sign/poster/contraband/mothic_rations/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("Va Lümla Commissary Menu (Spring 335)")]"
	. += "\t[span_info("Sparkweed Cigarettes, Half-Pack (6): 1 Ticket")]"
	. += "\t[span_info("Töchtaüse Schnapps, Bottle (4 Measures): 2 Tickets")]"
	. += "\t[span_info("Activin Gum, Pack (4): 1 Ticket")]"
	. += "\t[span_info("A18 Sustenance Bar, Breakfast, Bar (4): 1 Ticket")]"
	. += "\t[span_info("Pizza, Margherita, Standard Slice: 1 Ticket")]"
	. += "\t[span_info("Keratin Wax, Medicated, Tin (20 Measures): 2 Tickets")]"
	. += "\t[span_info("Setae Soap, Herb Scent, Bottle (20 Measures): 2 Tickets")]"
	. += "\t[span_info("Additional Bedding, Floral Print, Sheet: 5 Tickets")]"
	return .

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/mothic_rations, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/mothic_rations, 32)
#endif

/obj/structure/sign/poster/contraband/wildcat
	name = "Wildcat Customs Screambike"
	desc = "A pinup poster showing a Wildcat Customs Dante Screambike- the fastest production sublight open-frame vessel in the galaxy."
	icon_state = "wildcat"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/wildcat, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/wildcat, 32)
#endif

/obj/structure/sign/poster/contraband/babel_device
	name = "Linguafacile Babel Device"
	desc = "A poster advertising Linguafacile's new Babel Device model. 'Calibrated for excellent performance on all Human languages, as well as most common variants of Draconic and Mothic!'"
	icon_state = "babel_device"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/babel_device, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/babel_device, 32)
#endif

/obj/structure/sign/poster/contraband/pizza_imperator
	name = "Pizza Imperator"
	desc = "An advertisement for Pizza Imperator. Their crusts may be tough and their sauce may be thin, but they're everywhere, so you've gotta give in."
	icon_state = "pizza_imperator"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/pizza_imperator, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/pizza_imperator, 32)
#endif

/obj/structure/sign/poster/contraband/thunderdrome
	name = "Thunderdrome Concert Advertisement"
	desc = "An advertisement for a concert at the Adasta City Thunderdrome, the largest nightclub in human space."
	icon_state = "thunderdrome"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/thunderdrome, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/thunderdrome, 32)
#endif

/obj/structure/sign/poster/contraband/rush_propaganda
	name = "A New Life"
	desc = "An old poster from around the time of the First Spinward Rush. It depicts a view of wide, unspoiled lands, ready for Humanity's Manifest Destiny."
	icon_state = "rush_propaganda"

/obj/structure/sign/poster/contraband/rush_propaganda/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("TerraGov needs you!")]"
	. += "\t[span_info("A new life in the colonies awaits intrepid adventurers! All registered colonists are guaranteed transport, land and subsidies!")]"
	. += "\t[span_info("You could join the legacy of hardworking humans who settled such new frontiers as Mars, Adasta or Saint Mungo!")]"
	. += "\t[span_info("To apply, inquire at your nearest Colonial Affairs office for evaluation. Our locations can be found at www.terra.gov/colonial_affairs.")]"
	return .

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/rush_propaganda, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/rush_propaganda, 32)
#endif

/obj/structure/sign/poster/contraband/tipper_cream_soda
	name = "Tipper's Cream Soda"
	desc = "An old advertisement for an obscure cream soda brand, now bankrupt due to legal problems."
	icon_state = "tipper_cream_soda"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/tipper_cream_soda, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/tipper_cream_soda, 32)
#endif

/obj/structure/sign/poster/contraband/tea_over_tizira
	name = "Movie Poster: Tea Over Tizira"
	desc = "A poster for a thought-provoking arthouse movie about the Human-Lizard war, criticised by human supremacist groups for its morally-grey portrayal of the war."
	icon_state = "tea_over_tizira"

/obj/structure/sign/poster/contraband/tea_over_tizira/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("At the climax of the Human-Lizard war, the human crew of a bomber rescue two enemy soldiers from the vacuum of space. Seeing the souls behind the propaganda, they begin to question their orders, and imprisonment turns to hospitality.")]"
	. += "\t[span_info("Is victory worth losing our humanity?")]"
	. += "\t[span_info("Starring Dara Reilly, Anton DuBois, Jennifer Clarke, Raz-Parla and Seri-Lewa. An Adriaan van Jenever production. A Carlos de Vivar film. Screenplay by Robert Dane. Music by Joel Karlsbad. Produced by Adriaan van Jenever. Directed by Carlos de Vivar.")]"
	. += "\t[span_info("Heartbreaking and thought-provoking- Tea Over Tizira asks questions that few have had the boldness to ask before: The London New Inquirer")]"
	. += "\t[span_info("Rated PG13. A Pangalactic Studios Picture.")]"
	return .

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/tea_over_tizira, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/tea_over_tizira, 32)
#endif

/obj/structure/sign/poster/contraband/syndiemoth //Original PR at https://github.com/BeeStation/BeeStation-Hornet/pull/1747 (Also pull/1982); original art credit to AspEv
	name = "Syndie Moth - Nuclear Operation"
	desc = "A Syndicate-commissioned poster that uses Syndie Moth™ to tell the viewer to keep the nuclear authentication disk unsecured. \"Peace was never an option!\" No good employee would listen to this nonsense."
	icon_state = "aspev_syndie"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/syndiemoth, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/syndiemoth, 32)
#endif

/obj/structure/sign/poster/contraband/microwave
	name = "How To Charge Your PDA"
	desc = "A perfectly legitimate poster that seems to advertise the very real and genuine method of charging your PDA in the future: microwaves."
	icon_state = "microwave"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/microwave, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/microwave, 32)
#endif

/obj/structure/sign/poster/contraband/blood_geometer //Poster sprite art by MetalClone, original art by SpessMenArt.
	name = "Movie Poster: THE BLOOD GEOMETER"
	desc = "A poster for a thrilling noir detective movie set aboard a state-of-the-art space station, following a detective who finds himself wrapped up in the activies of a dangerous cult, who worship an ancient deity: THE BLOOD GEOMETER."
	icon_state = "blood_geometer"

/obj/structure/sign/poster/contraband/blood_geometer/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("THE BLOOD GEOMETER. This name strikes fear into all who know the truth behind the blood-stained moniker of the blood goddess, her true name lost to time.")]"
	. += "\t[span_info("In this <i>purely fictional</i> film, follow Ace Ironlungs as he delves into his deadliest mystery yet, and watch him uncover the real culprits behind the bloody plot hatched to bring about a new age of chaos.")]"
	. += "\t[span_info("Starring Mason Williams as Ace Ironlungs, Sandra Faust as Vera Killian, and Brody Hart as Cody Parker. A Darrel Hatchkinson film. Screenplay by Adam Allan, music by Joel Karlsbad, directed by Darrel Hatchkinson.")]"
	. += "\t[span_info("Thrilling, scary and genuinely worrying. The Blood Geometer has shocked us to our very cores with such striking visuals and overwhelming gore. - New Canadanian Film Guild")]"
	. += "\t[span_info("Rated M for mature. A Pangalactic Studios Picture.")]"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/blood_geometer, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/blood_geometer, 32)
#endif

/obj/structure/sign/poster/contraband/singletank_bomb
	name = "Single Tank Bomb Guide"
	desc = "This informational poster teaches the viewer how to make a single tank bomb of high quality."
	icon_state = "singletank_bomb"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/singletank_bomb, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/singletank_bomb, 32)
#endif

///a special poster meant to fool people into thinking this is a bombable wall at a glance.
/obj/structure/sign/poster/contraband/fake_bombable
	name = "fake bombable poster"
	desc = "We do a little trolling."
	icon_state = "fake_bombable"
	never_random = TRUE

/obj/structure/sign/poster/contraband/fake_bombable/Initialize(mapload)
	. = ..()
	var/turf/our_wall = get_turf_pixel(src)
	name = our_wall.name

/obj/structure/sign/poster/contraband/fake_bombable/examine(mob/user)
	var/turf/our_wall = get_turf_pixel(src)
	. = our_wall.examine(user)
	. += span_notice("It seems to be slightly cracked...")

/obj/structure/sign/poster/contraband/fake_bombable/ex_act(severity, target)
	addtimer(CALLBACK(src, PROC_REF(fall_off_wall)), 2.5 SECONDS)
	return FALSE

/obj/structure/sign/poster/contraband/fake_bombable/proc/fall_off_wall()
	if(QDELETED(src) || !isturf(loc))
		return
	var/turf/our_wall = get_turf_pixel(src)
	our_wall.balloon_alert_to_viewers("it was a ruse!")
	roll_and_drop(loc)
	playsound(loc, 'sound/items/handling/paper_drop.ogg', 50, TRUE)


#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/contraband/fake_bombable, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/contraband/fake_bombable, 32)
#endif
