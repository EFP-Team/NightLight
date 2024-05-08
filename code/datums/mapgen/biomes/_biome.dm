///This datum handles the transitioning from a turf to a specific biome, and handles spawning decorative structures and mobs.
/datum/biome
	///Type of turf this biome creates
	var/turf_type
	/// Chance of having a structure from the flora types list spawn
	var/flora_density = 0
	/// Chance of spawning special features, such as geysers.
	var/feature_density = 0
	/// Chance of having a mob from the fauna types list spawn
	var/fauna_density = 0
	/// Weighted list of type paths of flora that can be spawned when the
	/// turf spawns flora.
	var/list/flora_types = list()
	/// Weighted list of extra features that can spawn in the biome, such as
	/// geysers. Gets expanded automatically.
	var/list/feature_types = list()
	/// Weighted list of type paths of fauna that can be spawned when the
	/// turf spawns fauna.
	var/list/fauna_types = list()


/datum/biome/New()
	. = ..()
	if(length(flora_types))
		flora_types = expand_weights(fill_with_ones(flora_types))

	if(length(fauna_types))
		fauna_types = expand_weights(fill_with_ones(fauna_types))

	if(length(feature_types))
		feature_types = expand_weights(feature_types)


///This proc handles the creation of a turf of a specific biome type
/datum/biome/proc/generate_turf(turf/gen_turf)
	gen_turf.ChangeTurf(turf_type, null, CHANGETURF_DEFER_CHANGE)
	if(length(flora_types) && prob(flora_density))
		var/obj/structure/flora = pick(flora_types)
		new flora(gen_turf)
		return

	if(length(feature_types) && prob(feature_density))
		var/atom/picked_feature = pick(feature_types)
		new picked_feature(gen_turf)
		return

	if(length(fauna_types) && prob(fauna_density))
		var/mob/fauna = pick(fauna_types)
		new fauna(gen_turf)


/// This proc handles the creation of a turf of a specific biome type, assuming
/// that the turf has not been initialized yet. Don't call this unless you know
/// what you're doing.
/datum/biome/proc/generate_turf_for_terrain(turf/gen_turf)
	var/turf/new_turf = new turf_type(gen_turf)
	return new_turf


/// This proc handles populating the given turf based on whether flora,
/// features and fauna are allowed. Does not take megafauna into account.
/datum/biome/proc/populate_turf(turf/target_turf, flora_allowed, features_allowed, fauna_allowed)
	if(flora_allowed && length(flora_types) && prob(flora_density))
		var/obj/structure/flora = pick(flora_types)
		new flora(target_turf)
		return TRUE

	if(features_allowed && prob(feature_density))
		var/can_spawn = TRUE

		var/atom/picked_feature = pick(feature_types)

		for(var/obj/structure/existing_feature in range(7, target_turf))
			if(istype(existing_feature, picked_feature))
				can_spawn = FALSE
				break

		if(can_spawn)
			new picked_feature(target_turf)
			return TRUE

	if(fauna_allowed && length(fauna_types) && prob(fauna_density))
		var/mob/picked_mob = pick(fauna_types)

		// prevents tendrils spawning in each other's collapse range
		if(ispath(picked_mob, /obj/structure/spawner/lavaland))
			for(var/obj/structure/spawner/lavaland/spawn_blocker in range(2, target_turf))
				return FALSE

		// if the random is not a tendril (hopefully meaning it is a mob), avoid spawning if there's another one within 12 tiles
		else
			var/list/things_in_range = range(12, target_turf)
			for(var/mob/living/mob_blocker in things_in_range)
				if(ismining(mob_blocker))
					return FALSE

			// Also block spawns if there's a random lavaland mob spawner nearby
			if(locate(/obj/effect/spawner/random/lavaland_mob) in things_in_range)
				return FALSE

		new picked_mob(target_turf)
		return TRUE

	return FALSE


/datum/biome/mudlands
	turf_type = /turf/open/misc/dirt/jungle/dark
	flora_types = list(
		/obj/structure/flora/grass/jungle/a/style_random = 1,
		/obj/structure/flora/grass/jungle/b/style_random = 1,
		/obj/structure/flora/rock/pile/jungle/style_random = 1,
		/obj/structure/flora/rock/pile/jungle/large/style_random = 1,
	)
	flora_density = 3

/datum/biome/plains
	turf_type = /turf/open/misc/grass/jungle
	flora_types = list(
		/obj/structure/flora/grass/jungle/a/style_random = 1,
		/obj/structure/flora/grass/jungle/b/style_random = 1,
		/obj/structure/flora/tree/jungle/style_random = 1,
		/obj/structure/flora/rock/pile/jungle/style_random = 1,
		/obj/structure/flora/bush/jungle/a/style_random = 1,
		/obj/structure/flora/bush/jungle/b/style_random = 1,
		/obj/structure/flora/bush/jungle/c/style_random = 1,
		/obj/structure/flora/bush/large/style_random = 1,
		/obj/structure/flora/rock/pile/jungle/large/style_random = 1,
	)
	flora_density = 15

/datum/biome/jungle
	turf_type = /turf/open/misc/grass/jungle
	flora_types = list(
		/obj/structure/flora/grass/jungle/a/style_random = 1,
		/obj/structure/flora/grass/jungle/b/style_random = 1,
		/obj/structure/flora/tree/jungle/style_random = 1,
		/obj/structure/flora/rock/pile/jungle/style_random = 1,
		/obj/structure/flora/bush/jungle/a/style_random = 1,
		/obj/structure/flora/bush/jungle/b/style_random = 1,
		/obj/structure/flora/bush/jungle/c/style_random = 1,
		/obj/structure/flora/bush/large/style_random = 1,
		/obj/structure/flora/rock/pile/jungle/large/style_random = 1,
	)
	flora_density = 40

/datum/biome/jungle/deep
	flora_density = 65

/datum/biome/wasteland
	turf_type = /turf/open/misc/dirt/jungle/wasteland

/datum/biome/water
	turf_type = /turf/open/water/jungle

/datum/biome/mountain
	turf_type = /turf/closed/mineral/random/jungle
