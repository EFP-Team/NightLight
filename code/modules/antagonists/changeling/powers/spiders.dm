/datum/action/changeling/spiders
	name = "Spread Infestation - Our form divides, creating arachnids which will grow into deadly beasts."
	stats_id = "Spread Infestation"
	helptext = "The spiders are thoughtless creatures, and may attack their creators when fully grown. Requires at least 5 DNA absorptions."
	chemical_cost = 45
	dna_cost = 1
	req_dna = 5

//Makes some spiderlings. Good for setting traps and causing general trouble.
/datum/action/changeling/spiders/sting_action(mob/user)
	spawn_atom_to_turf(/obj/structure/spider/spiderling/hunter, user, 2, FALSE)
	return TRUE
