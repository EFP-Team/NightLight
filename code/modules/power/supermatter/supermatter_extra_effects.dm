// Any power past this number will be clamped down
#define MAX_ACCEPTED_POWER_OUTPUT 5000

// At the highest power output, assuming no integrity changes, the threshold will be 0.
#define THRESHOLD_EQUATION_SLOPE (-1 / MAX_ACCEPTED_POWER_OUTPUT)

// The higher this number, the faster low integrity will drop threshold
// I would've named this "power", but y'know. :P
#define INTEGRITY_EXPONENTIAL_DEGREE 2

// At INTEGRITY_MIN_NUDGABLE_AMOUNT, the power will be treated as, at most, INTEGRITY_MAX_POWER_NUDGE.
// Any lower integrity will result in INTEGRITY_MAX_POWER_NUDGE.
#define INTEGRITY_MAX_POWER_NUDGE 1500
#define INTEGRITY_MIN_NUDGABLE_AMOUNT 0.7

#define RADIATION_CHANCE_AT_FULL_INTEGRITY 0.03
#define RADIATION_CHANCE_AT_ZERO_INTEGRITY 0.4
#define CHANCE_EQUATION_SLOPE (RADIATION_CHANCE_AT_ZERO_INTEGRITY - RADIATION_CHANCE_AT_FULL_INTEGRITY)

/obj/machinery/power/supermatter_crystal/proc/emit_radiation()
	// As power goes up, rads go up.
	// A standard N2 SM seems to produce a value of around 1,500.
	var/power_factor = min(internal_energy, MAX_ACCEPTED_POWER_OUTPUT)

	var/integrity = 1 - CLAMP01(damage / explosion_point)

	// When integrity goes down, the threshold (from an observable point of view, rads) go up.
	// However, the power factor must go up as well, otherwise turning off the emitters
	// on a delaminating SM would stop radiation from escaping.
	// To fix this, lower integrities raise the power factor to a minimum.
	var/integrity_power_nudge = LERP(INTEGRITY_MAX_POWER_NUDGE, 0, CLAMP01((integrity - INTEGRITY_MIN_NUDGABLE_AMOUNT) / (1 - INTEGRITY_MIN_NUDGABLE_AMOUNT)))

	power_factor = max(power_factor, integrity_power_nudge)

	// At the "normal" N2 power output (with max integrity), this is 0.7, which is enough to be stopped
	// by the walls or the radation shutters.
	// As integrity does down, rads go up.
	var/threshold
	switch(integrity)
		if(0)
			threshold = power_factor ? 0 : 1
		if(1)
			threshold = (THRESHOLD_EQUATION_SLOPE * power_factor + 1)
		else
			threshold = (THRESHOLD_EQUATION_SLOPE * power_factor + 1) ** ((1 / integrity) ** INTEGRITY_EXPONENTIAL_DEGREE)

	// Calculating chance is done entirely on integrity, so that actively delaminating SMs feel more dangerous
	var/chance = (CHANCE_EQUATION_SLOPE * (1 - integrity)) + RADIATION_CHANCE_AT_FULL_INTEGRITY

	radiation_pulse(
		src,
		max_range = 8,
		threshold = threshold,
		chance = chance * 100,
	)

/obj/machinery/power/supermatter_crystal/proc/processing_sound()
	if(internal_energy || hypermatter_state)
		var/volume_amount = hypermatter_state ? 0 : (internal_energy / 100)
		soundloop.volume = clamp((50 + volume_amount), 50, 100)
	if(damage >= 300)
		soundloop.mid_sounds = list('sound/machines/sm/loops/delamming.ogg' = 1)
	else
		soundloop.mid_sounds = list('sound/machines/sm/loops/calm.ogg' = 1)

	//We play delam/neutral sounds at a rate determined by power and damage
	if(last_accent_sound >= world.time || !prob(20))
		return
	var/aggression = hypermatter_state ? rand(25, 75) : min(((damage / 800) * (internal_energy / 2500)), 1.0) * 100
	if(damage >= 300)
		playsound(src, SFX_SM_DELAM, max(50, aggression), FALSE, 40, 30, falloff_distance = 10)
	else
		playsound(src, SFX_SM_CALM, max(50, aggression), FALSE, 25, 25, falloff_distance = 10)
	var/next_sound = round((100 - aggression) * 5)
	last_accent_sound = world.time + max(SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN, next_sound)

/obj/machinery/power/supermatter_crystal/proc/psychological_examination()
	// Defaults to a value less than 1. Over time the psy_coeff goes to 0 if
	// no supermatter soothers are nearby.
	var/psy_coeff_diff = -0.05
	for(var/mob/living/carbon/human/seen_by_sm in view(src, SM_HALLUCINATION_RANGE(internal_energy)))
		// Someone (generally a Psychologist), when looking at the SM within hallucination range makes it easier to manage.
		if(HAS_TRAIT(seen_by_sm, TRAIT_SUPERMATTER_SOOTHER) || (seen_by_sm.mind && HAS_TRAIT(seen_by_sm.mind, TRAIT_SUPERMATTER_SOOTHER)))
			psy_coeff_diff = 0.05
	visible_hallucination_pulse(
		center = src,
		radius = SM_HALLUCINATION_RANGE(internal_energy),
		hallucination_duration = internal_energy * hallucination_power,
		hallucination_max_duration = 400 SECONDS,
	)
	psy_coeff = clamp(psy_coeff + psy_coeff_diff, 0, 1)

/obj/machinery/power/supermatter_crystal/proc/handle_high_power()
	if(internal_energy <= POWER_PENALTY_THRESHOLD && damage <= danger_point) //If the power is above 5000 or if the damage is above 550
		return
	var/range = 4
	zap_cutoff = 1500
	var/total_moles = absorbed_gasmix.total_moles()
	var/pressure = absorbed_gasmix.return_pressure()
	var/temp = absorbed_gasmix.temperature
	if(pressure > 0 && temp > 0)
		//You may be able to freeze the zapstate of the engine with good planning, we'll see
		zap_cutoff = clamp(3000 - (internal_energy * total_moles / 10) / temp, 350, 3000)//If the core is cold, it's easier to jump, ditto if there are a lot of mols
		//We should always be able to zap our way out of the default enclosure
		//See supermatter_zap() for more details
		range = clamp(internal_energy / pressure * 10, 2, 7)
	var/flags = ZAP_SUPERMATTER_FLAGS
	var/zap_count = 0
	//Deal with power zaps
	switch(internal_energy)
		if(POWER_PENALTY_THRESHOLD to SEVERE_POWER_PENALTY_THRESHOLD)
			zap_icon = DEFAULT_ZAP_ICON_STATE
			zap_count = 2
		if(SEVERE_POWER_PENALTY_THRESHOLD to CRITICAL_POWER_PENALTY_THRESHOLD)
			zap_icon = SLIGHTLY_CHARGED_ZAP_ICON_STATE
			//Uncaps the zap damage, it's maxed by the input power
			//Objects take damage now
			flags |= (ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
			zap_count = 3
		if(CRITICAL_POWER_PENALTY_THRESHOLD to INFINITY)
			zap_icon = OVER_9000_ZAP_ICON_STATE
			//It'll stun more now, and damage will hit harder, gloves are no garentee.
			//Machines go boom
			flags |= (ZAP_MOB_STUN | ZAP_MACHINE_EXPLOSIVE | ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
			zap_count = 4
	//Now we deal with damage shit
	if (damage > danger_point && prob(20))
		zap_count += 1

	if(zap_count >= 1)
		playsound(loc, 'sound/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
		for(var/i in 1 to zap_count)
			supermatter_zap(src, range, clamp(internal_energy*2, 4000, 20000), flags, zap_cutoff = src.zap_cutoff, power_level = internal_energy, zap_icon = src.zap_icon)

	if(prob(5))
		supermatter_anomaly_gen(src, FLUX_ANOMALY, rand(5, 10))
	if(prob(5))
		supermatter_anomaly_gen(src, HALLUCINATION_ANOMALY, rand(5, 10))
	if(internal_energy > SEVERE_POWER_PENALTY_THRESHOLD && prob(5) || prob(1))
		supermatter_anomaly_gen(src, GRAVITATIONAL_ANOMALY, rand(5, 10))
	if((internal_energy > SEVERE_POWER_PENALTY_THRESHOLD && prob(2)) || (prob(0.3) && internal_energy > POWER_PENALTY_THRESHOLD))
		supermatter_anomaly_gen(src, PYRO_ANOMALY, rand(5, 10))

/obj/machinery/power/supermatter_crystal/proc/supermatter_pull(turf/center, pull_range = 3)
	playsound(center, 'sound/weapons/marauder.ogg', 100, TRUE, extrarange = pull_range - world.view)
	for(var/atom/movable/movable_atom in orange(pull_range,center))
		if((movable_atom.anchored || movable_atom.move_resist >= MOVE_FORCE_EXTREMELY_STRONG)) //move resist memes.
			if(istype(movable_atom, /obj/structure/closet))
				var/obj/structure/closet/closet = movable_atom
				closet.open(force = TRUE)
			continue
		if(ismob(movable_atom))
			var/mob/pulled_mob = movable_atom
			if(pulled_mob.mob_negates_gravity())
				continue //You can't pull someone nailed to the deck
		step_towards(movable_atom,center)

/proc/supermatter_anomaly_gen(turf/anomalycenter, type = FLUX_ANOMALY, anomalyrange = 5, has_changed_lifespan = TRUE)
	var/turf/local_turf = pick(orange(anomalyrange, anomalycenter))
	if(!local_turf)
		return
	switch(type)
		if(FLUX_ANOMALY)
			var/explosive = has_changed_lifespan ? FLUX_NO_EXPLOSION : FLUX_LOW_EXPLOSIVE
			new /obj/effect/anomaly/flux(local_turf, has_changed_lifespan ? rand(250, 350) : null, FALSE, explosive)
		if(GRAVITATIONAL_ANOMALY)
			new /obj/effect/anomaly/grav(local_turf, has_changed_lifespan ? rand(200, 300) : null, FALSE)
		if(PYRO_ANOMALY)
			new /obj/effect/anomaly/pyro(local_turf, has_changed_lifespan ? rand(150, 250) : null, FALSE)
		if(HALLUCINATION_ANOMALY)
			new /obj/effect/anomaly/hallucination(local_turf, has_changed_lifespan ? rand(150, 250) : null, FALSE)
		if(VORTEX_ANOMALY)
			new /obj/effect/anomaly/bhole(local_turf, 20, FALSE)
		if(BIOSCRAMBLER_ANOMALY)
			new /obj/effect/anomaly/bioscrambler(local_turf, null, FALSE)

/**
 * Handles the main process of the Hypermatter
 *
 * The Hypermatter state is a state where the crystal shuts down any gas process and instead starts to shoot out radiation particles
 * that have an internal energy of 1000 kJ. This energy can be increased by reflecting those particles onto reflectors made with
 * plastitanium glass and they can be reflected back into the crystal to increase its energy.
 *
 * This state can be achieved in two ways:
 * - By feeding the SM plasma coated metallic hydrogen
 * - By using the nuclear emitter onto the crystal (a device that shoots a beam towards the SM and consumes 1 MW per shoot, charge
 * rate fixed at 20 kW/tick)
 *
 * This state is temporary and will revert back to normal SM after a maximum of 5 minutes and can be increased only to maximum 5 minutes.
 * If a particle that has more than 5000 kJ of internal energy is reflected back into the crystal, it will increase it's time by 10 seconds
 *
 * For each particle shot the hypermatter energy is decreased by a tenth of the energy of the particle.
 * For each particle that hit the crystal the hypermatter energy is increased by a tenth of the energy of the particle.
 *
 * The particles can be also sent to the nuclear acculumator to be used into power generation, the higher energy they have
 * the more power they can generate.
 */
/obj/machinery/power/supermatter_crystal/proc/handle_hypermatter_state()
	if(!anchored) //Don't unanchor the shards
		damage += 150
		internal_energy = hypermatter_power_amount
		for(var/_ in 1 to rand(2, 5))
			supermatter_zap(
				zapstart = src,
				range = 3,
				zap_str = internal_energy,
				zap_flags = ZAP_SUPERMATTER_FLAGS,
				zap_cutoff = 300,
				power_level = internal_energy,
			)
		hypermatter_state = FALSE
		update_appearance()
		return

	var/static/list/angles_to_shoot = list(0, 45, 90, 135, 180, 225, 270, 315, 360)

	if(internal_energy)
		var/particles_increase = max(round(internal_energy * 0.0005), 0)
		for(var/_ in 1 to rand(1 + particles_increase, 4 + particles_increase))
			if(hypermatter_power_amount < HYPERMATTER_PARTICLE_BASE_POWER)
				break
			var/angle_to_shoot = pick(angles_to_shoot)
			fire_nuclear_particle(angle_to_shoot, HYPERMATTER_PARTICLE_BASE_POWER * 0.003, HYPERMATTER_PARTICLE_BASE_POWER, "tesla_projectile", dangerous = TRUE)
			hypermatter_power_amount = max(hypermatter_power_amount - 100, 0)
	else
		hypermatter_power_amount = max(hypermatter_power_amount - 200, 0)


	if(prob(5))
		fire_nuclear_particle()

		supermatter_zap(
			zapstart = src,
			range = 3,
			zap_str = 5 * internal_energy,
			zap_flags = ZAP_SUPERMATTER_FLAGS,
			zap_cutoff = 300,
			power_level = internal_energy,
		)
	if(hypermatter_power_amount < 1000)
		COOLDOWN_REMOVE_TIME(src, hypermatter_cooldown, 5 SECONDS)

#undef CHANCE_EQUATION_SLOPE
#undef INTEGRITY_EXPONENTIAL_DEGREE
#undef INTEGRITY_MAX_POWER_NUDGE
#undef INTEGRITY_MIN_NUDGABLE_AMOUNT
#undef MAX_ACCEPTED_POWER_OUTPUT
#undef RADIATION_CHANCE_AT_FULL_INTEGRITY
#undef RADIATION_CHANCE_AT_ZERO_INTEGRITY
#undef THRESHOLD_EQUATION_SLOPE
