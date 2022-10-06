// 7.62x38mmR (Nagant Revolver)

/obj/projectile/bullet/n762
	name = "7.62x38mmR bullet"
	damage = 60

// .50AE (Desert Eagle)

/obj/projectile/bullet/a50ae
	name = ".50AE bullet"
	damage = 60

// .38 (Detective's Gun)

/obj/projectile/bullet/c38
	name = ".38 bullet"
	damage = 25
	ricochets_max = 2
	ricochet_chance = 50
	ricochet_auto_aim_angle = 10
	ricochet_auto_aim_range = 3
	wound_bonus = -20
	bare_wound_bonus = 10
	embedding = list(embed_chance=25, fall_chance=2, jostle_chance=2, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=3, jostle_pain_mult=5, rip_time=1 SECONDS)
	embed_falloff_tile = -4

/obj/projectile/bullet/c38/match
	name = ".38 Match bullet"
	ricochets_max = 4
	ricochet_chance = 100
	ricochet_auto_aim_angle = 40
	ricochet_auto_aim_range = 5
	ricochet_incidence_leeway = 50
	ricochet_decay_chance = 1
	ricochet_decay_damage = 1

/obj/projectile/bullet/c38/match/bouncy
	name = ".38 Rubber bullet"
	damage = 10
	stamina = 30
	weak_against_armour = TRUE
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embedding = null

// premium .38 ammo from cargo, weak against armor, lower base damage, but excellent at embedding and causing slice wounds at close range
/obj/projectile/bullet/c38/dumdum
	name = ".38 DumDum bullet"
	damage = 15
	weak_against_armour = TRUE
	ricochets_max = 0
	sharpness = SHARP_EDGED
	wound_bonus = 20
	bare_wound_bonus = 20
	embedding = list(embed_chance=75, fall_chance=3, jostle_chance=4, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=6, rip_time=1 SECONDS)
	wound_falloff_tile = -5
	embed_falloff_tile = -15

/obj/projectile/bullet/c38/trac
	name = ".38 TRAC bullet"
	damage = 10
	ricochets_max = 0

/obj/projectile/bullet/c38/trac/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/mob/living/carbon/M = target
	if(!istype(M))
		return
	var/obj/item/implant/tracking/c38/imp
	for(var/obj/item/implant/tracking/c38/TI in M.implants) //checks if the target already contains a tracking implant
		imp = TI
		return
	if(!imp)
		imp = new /obj/item/implant/tracking/c38(M)
		imp.implant(M)

/obj/projectile/bullet/c38/hotshot //similar to incendiary bullets, but do not leave a flaming trail
	name = ".38 Hot Shot bullet"
	damage = 20
	ricochets_max = 0

/obj/projectile/bullet/c38/hotshot/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(6)
		M.ignite_mob()

/obj/projectile/bullet/c38/iceblox //see /obj/projectile/temp for the original code
	name = ".38 Iceblox bullet"
	damage = 20
	var/temperature = 100
	ricochets_max = 0

/obj/projectile/bullet/c38/iceblox/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_bodytemperature(((100-blocked)/100)*(temperature - M.bodytemperature))

// .357 (Syndie Revolver)

/obj/projectile/bullet/a357
	name = ".357 bullet"
	damage = 60
	wound_bonus = -30

// admin only really, for ocelot memes
/obj/projectile/bullet/a357/match
	name = ".357 match bullet"
	ricochets_max = 5
	ricochet_chance = 140
	ricochet_auto_aim_angle = 50
	ricochet_auto_aim_range = 6
	ricochet_incidence_leeway = 80
	ricochet_decay_chance = 1

// marksman
/obj/projectile/bullet/marksman
	name = "nanoshot"
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/solar
	muzzle_type = /obj/effect/projectile/muzzle/bullet
	impact_type = /obj/effect/projectile/impact/sniper

/obj/projectile/bullet/marksman/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	var/obj/item/gun/energy/marksman_revolver/blahgun = fired_from
	var/obj/projectile/bullet/coin/last_coin = blahgun?.last_coin
	var/turf/cur_turf = get_turf(src)
	var/coin_coords
	if(last_coin)
		coin_coords = ("([last_coin.x] [last_coin.y]) dist: [get_dist(src, last_coin)]")
	//testing("moved>> [x] [y] [coin_coords]")

	var/obj/projectile/bullet/coin/coin_check = cur_turf ? locate(/obj/projectile/bullet/coin) in cur_turf.contents : null
	if(!coin_check || coin_check.used)
		return

	testing("found a coin!")
	coin_check.shot_at(firer, src)
	Impact(coin_check)
	//testing("moved end!")

// coin
/obj/projectile/bullet/coin
	name = "marksman coin"
	pixel_speed_multiplier = 0.333
	speed = 1

	var/turf/target_turf

	var/valid = FALSE

	var/used = FALSE

	var/num_of_splitshots = 2

/obj/projectile/bullet/coin/Initialize(mapload, turf/the_target, list/parent_ignored_coins)
	. = ..()
	target_turf = the_target
	target_turf?.color = COLOR_RED
	//range = get_dist()

/obj/projectile/bullet/coin/Destroy()
	target_turf?.color = null
	return ..()

/obj/projectile/bullet/coin/fire(angle, atom/direct_target)
	. = ..()
	range = get_dist(starting, direct_target)

/obj/projectile/bullet/coin/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!valid && get_dist(loc, target_turf) <= 1)
		playsound(src, 'sound/machines/ping.ogg', 30)
		valid = TRUE
		color = COLOR_YELLOW

/obj/projectile/bullet/coin/proc/shot_at(mob/living/shooter, obj/projectile/incoming_shot, forced = FALSE)
	if(!forced && get_dist(src, target_turf) > 1)
		return FALSE

	testing("coin hit!")
	used = TRUE
	var/turf/cur_tur = get_turf(src)
	cur_tur.visible_message(span_nicegreen("[incoming_shot] impacts [src]!"))
	splitshot(shooter, incoming_shot)
	QDEL_IN(src, 0.25 SECONDS)

/obj/projectile/bullet/coin/proc/splitshot(mob/living/shooter, obj/projectile/incoming_shot)
	testing("splitshot! num of ss's [num_of_splitshots]")
	for(var/i in 1 to num_of_splitshots)
		testing("splitshot [i] of [num_of_splitshots]")
		var/atom/next_target = find_next_target() //////////////////////////////// < if this is a coin, do coin_check.shot_at(firer, src) / Impact() or whatever
		testing("found next target: [next_target]")
		fire_splitshot(next_target, incoming_shot)
		testing("finished splitshot [i]!")

/// Minor convenience function for creating each shrapnel piece with circle explosions, mostly stolen from the MIRV component
/obj/projectile/bullet/coin/proc/fire_splitshot(atom/target, obj/projectile/incoming_shot)
	if(!istype(target))
		return

	ADD_TRAIT(target, TRAIT_RECENTLY_COINED, ABSTRACT_ITEM_TRAIT)
	addtimer(TRAIT_CALLBACK_REMOVE(target, TRAIT_RECENTLY_COINED, ABSTRACT_ITEM_TRAIT), 0.5 SECONDS)
	var/projectile_type = incoming_shot.type
	var/obj/projectile/new_splitshot = new projectile_type(get_turf(src))

	//Shooting Code:
	new_splitshot.original = target
	new_splitshot.fired_from = incoming_shot.fired_from
	new_splitshot.firer = incoming_shot.firer
	new_splitshot.preparePixelProjectile(target, src)
	new_splitshot.fire()
	new_splitshot.damage *= 1.5

	if(istype(target, /obj/projectile/bullet/coin))
		var/obj/projectile/bullet/coin/our_coin = target
		our_coin.shot_at(incoming_shot.firer, new_splitshot, forced = TRUE)

/// Minor convenience function for creating each shrapnel piece with circle explosions, mostly stolen from the MIRV component
/obj/projectile/bullet/coin/proc/find_next_target()
	var/list/valid_targets = (oview(4, src.loc))
	valid_targets -= firer
	testing("Finding next target- len: [valid_targets.len]")

	for(var/obj/projectile/bullet/coin/iter_coin in valid_targets)
		if(!iter_coin.used) // this will prevent shooting itself as well
			return iter_coin

	testing("no coin found to rico, try living")
	var/list/possible_victims = list()

	for(var/mob/living/iter_living in valid_targets)
		if(!HAS_TRAIT(iter_living, TRAIT_RECENTLY_COINED))
			if(get_dist(src, iter_living) <= 2)
				testing("got close person!")
				return iter_living
			possible_victims += iter_living

	if(possible_victims.len)
		testing("got mob!")
		return pick(possible_victims)

	for(var/atom/last_ditch in valid_targets)
		if(!HAS_TRAIT(last_ditch, TRAIT_RECENTLY_COINED))
			testing("did last ditch")
			return last_ditch
