/datum/pollution
	/// Reference to the turf we're on
	var/turf/open/my_turf
	/// List of all pollutant types to their amount
	var/list/pollutants = list()
	/// Total amount
	var/total_amount = 0
	/// Height of the pollution, used to create a sandpiling effect
	var/height = 0
	/// The overlay we are managing
	var/mutable_appearance/managed_overlay

/datum/pollution/New(turf/open/passed_turf)
	. = ..()
	my_turf = passed_turf
	my_turf.pollution = src
	REGISTER_POLLUTION(src)

/datum/pollution/proc/TouchAct(mob/living/carbon/victim)
	if(!victim.can_inject())
		return
	var/list/singleton_cache = SSpollution.singletons
	for(var/type in pollutants)
		var/datum/pollutant/pollutant = singleton_cache[type]
		if(!(pollutant.pollutant_flags & POLLUTANT_TOUCH_ACT))
			continue
		var/amount = pollutants[type]
		pollutant.TouchAct(victim, amount)

/datum/pollution/proc/BreatheAct(mob/living/carbon/victim)
	var/list/singleton_cache = SSpollution.singletons
	for(var/type in pollutants)
		var/datum/pollutant/pollutant = singleton_cache[type]
		if(!(pollutant.pollutant_flags & POLLUTANT_BREATHE_ACT))
			continue
		var/amount = pollutants[type]
		pollutant.BreatheAct(victim, amount)

/// When a user smells this pollution
/datum/pollution/proc/SmellAct(mob/living/sniffer)
	var/list/singleton_cache = SSpollution.singletons
	var/datum/pollutant/dominant_pollutant
	var/dominiant_smell_power
	for(var/type in pollutants)
		var/datum/pollutant/pollutant = singleton_cache[type]
		if(!(pollutant.pollutant_flags & POLLUTANT_SMELL))
			continue
		var/smelly_power = pollutant.smell_intensity * pollutants[type]
		if(smelly_power < POLLUTANT_SMELL_THRESHOLD)
			continue
		if(!dominant_pollutant || smelly_power > dominiant_smell_power)
			dominant_pollutant = pollutant
			dominiant_smell_power = smelly_power
	if(!dominant_pollutant)
		return

	var/smell_string
	switch(dominiant_smell_power)
		if(0 to POLLUTANT_SMELL_NORMAL)
			if(sniffer.mob_biotypes & MOB_ROBOTIC)
				smell_string = "Your sensors detect trace amounts of [dominant_pollutant.scent] in the air."
			else
				smell_string = "The subtle [dominant_pollutant.descriptor] of [dominant_pollutant.scent] tickles your nose..."
		if(POLLUTANT_SMELL_NORMAL to POLLUTANT_SMELL_STRONG)
			if(sniffer.mob_biotypes & MOB_ROBOTIC)
				smell_string = "Your sensors pick up the presence of [dominant_pollutant.scent] in the air."
			else
				smell_string = "The [dominant_pollutant.descriptor] of [dominant_pollutant.scent] fills the air."
		if(POLLUTANT_SMELL_STRONG to INFINITY)
			if(sniffer.mob_biotypes & MOB_ROBOTIC)
				smell_string = "Your sensors pick up an intense concentration of [dominant_pollutant.scent]."
			else
				smell_string = "The unmistakable [dominant_pollutant.descriptor] of [dominant_pollutant.scent] bombards your nostrils."

	if(dominant_pollutant.descriptor == SCENT_DESC_ODOR)
		to_chat(sniffer, span_warning(smell_string))
	else
		to_chat(sniffer, span_notice(smell_string))

/datum/pollution/proc/ScrubAmount(amount_to_scrub, update_active = TRUE, planetary_multiplier = FALSE)
	if(amount_to_scrub >= total_amount)
		qdel(src)
		return
	if(planetary_multiplier && my_turf.planetary_atmos) //Dissipate faster on planetary atmos
		amount_to_scrub *= 2
	for(var/type in pollutants)
		pollutants[type] -= amount_to_scrub * pollutants[type] / total_amount
	total_amount -= amount_to_scrub
	UpdateHeight()
	HandleOverlay()
	if(update_active)
		my_turf.UpdateAdjacentPollutants()

/datum/pollution/proc/AddPollutant(polutant_type, amount)
	if(!pollutants[polutant_type])
		pollutants[polutant_type] = 0
	pollutants[polutant_type] += amount
	total_amount += amount
	UpdateHeight()
	HandleOverlay()
	SET_ACTIVE_POLLUTION(src)

/datum/pollution/proc/AddPollutantList(list/passed_pollutants)
	for(var/polutant_type in passed_pollutants)
		if(!pollutants[polutant_type])
			pollutants[polutant_type] = 0
		pollutants[polutant_type] += passed_pollutants[polutant_type]
		total_amount += passed_pollutants[polutant_type]
	UpdateHeight()
	HandleOverlay()
	SET_ACTIVE_POLLUTION(src)

/datum/pollution/proc/UpdateHeight()
	height = CalculateHeight(total_amount)

/datum/pollution/proc/CalculateHeight(passed_amount)
	return CEILING(passed_amount / POLLUTION_HEIGHT_DIVISOR, 1)

/datum/pollution/Destroy()
	if(managed_overlay)
		if(my_turf)
			my_turf.underlays -= managed_overlay
		qdel(managed_overlay)
		managed_overlay = null
	REMOVE_POLLUTION_CURRENTRUN(src)
	SET_UNACTIVE_POLLUTION(src)
	UNREGISTER_POLLUTION(src)
	if(my_turf)
		my_turf.pollution = null
	return ..()

/datum/pollution/proc/ProcessCell()
	if(height <= 1)
		SET_UNACTIVE_POLLUTION(src)
		return
	var/list/sharing_turfs = list()
	var/list/already_processed_cache = SSpollution.processed_this_run
	var/list/potential_activers = list()
	for(var/turf/open/open_turf as anything in my_turf.atmos_adjacent_turfs)
		if(!already_processed_cache[open_turf])
			if(CanShareWith(open_turf))
				sharing_turfs[open_turf] = TRUE
			else
				potential_activers[open_turf] = TRUE
	if(!sharing_turfs.len)
		SET_UNACTIVE_POLLUTION(src)
		return
	sharing_turfs[my_turf] = TRUE
	//Now we've gotten all the turfs that should share pollution. Gather their total pollutions and split evenly
	var/list/total_share_pollutants = list()
	var/total_share_amount = 0
	for(var/turf/open/open_turf as anything in sharing_turfs)
		if(!open_turf.pollution)
			continue
		var/datum/pollution/cached_pollution = open_turf.pollution
		for(var/type in cached_pollution.pollutants)
			if(!total_share_pollutants[type])
				total_share_pollutants[type] = 0
			total_share_pollutants[type] += cached_pollution.pollutants[type]
			total_share_amount += cached_pollution.pollutants[type]

	for(var/type in total_share_pollutants)
		total_share_pollutants[type] /= sharing_turfs.len
	total_share_amount /= sharing_turfs.len
	var/new_heights = CalculateHeight(total_share_amount)
	var/mutable_appearance/new_overlay = GetOverlay(total_share_pollutants, total_share_amount)
	for(var/turf/open/open_turf as anything in sharing_turfs)
		AssertPollution(open_turf)
		var/datum/pollution/cached_pollution = open_turf.pollution
		if(cached_pollution.managed_overlay)
			cached_pollution.my_turf.underlays -= cached_pollution.managed_overlay
		cached_pollution.managed_overlay = new_overlay
		if(new_overlay)
			cached_pollution.my_turf.underlays += new_overlay
		cached_pollution.pollutants = total_share_pollutants.Copy()
		cached_pollution.total_amount = total_share_amount
		cached_pollution.height = new_heights
		SET_ACTIVE_POLLUTION(cached_pollution)
	for(var/turf/open/open_turf as anything in potential_activers)
		if(open_turf.pollution && open_turf.pollution.CanShareWith(my_turf))
			SET_ACTIVE_POLLUTION(open_turf.pollution)

/datum/pollution/proc/CanShareWith(turf/open/shareto)
	if(!shareto.pollution)
		return TRUE
	if(shareto.pollution.height + 1 < height)
		return TRUE
	return FALSE

/datum/pollution/proc/AssertPollution(turf/open/to_assert)
	if(!to_assert.pollution)
		new /datum/pollution(to_assert)

/datum/pollution/proc/HandleOverlay()
	if(managed_overlay)
		my_turf.underlays -= managed_overlay
	managed_overlay = GetOverlay(pollutants, total_amount)
	if(managed_overlay)
		my_turf.underlays += managed_overlay

///Probably the most costly thing happening here
/datum/pollution/proc/GetOverlay(list/pollutant_list, total_amount)
	var/datum/pollutant/pollutant
	var/total_thickness
	if(pollutant_list.len == 1)
		pollutant = SSpollution.singletons[pollutant_list[1]]
		if(!(pollutant.pollutant_flags & POLLUTANT_APPEARANCE))
			return
		total_thickness = total_amount * pollutant.thickness
	else
		var/list/pollutant_cache = SSpollution.singletons
		var/datum/pollutant/iterated_pollutant
		var/calc_thickness
		for(var/pollutant_type in pollutant_list)
			iterated_pollutant = pollutant_cache[pollutant_type]
			if(!(iterated_pollutant.pollutant_flags & POLLUTANT_APPEARANCE))
				continue
			calc_thickness = pollutant_list[pollutant_type] * iterated_pollutant.thickness
			if(!pollutant || calc_thickness > total_thickness)
				pollutant = iterated_pollutant
				total_thickness = calc_thickness

	if(!total_thickness || total_thickness < POLLUTANT_APPEARANCE_THICKNESS_THRESHOLD)
		return

	var/mutable_appearance/overlay = mutable_appearance('icons/effects/96x96.dmi', "smoke", FLY_LAYER, POLLUTION_PLANE, appearance_flags = KEEP_APART|RESET_TRANSFORM|RESET_COLOR)
	overlay.pixel_x = -32
	overlay.pixel_y = -32
	overlay.alpha = FLOOR(pollutant.alpha * total_thickness * THICKNESS_ALPHA_COEFFICIENT, 1)
	overlay.color = pollutant.color
	return overlay

///Atmos adjacency has been updated on this turf, see if it affects any of our pollutants
/turf/proc/UpdateAdjacentPollutants()
	for(var/turf/open/open_turf as anything in atmos_adjacent_turfs)
		if(open_turf.pollution)
			SET_ACTIVE_POLLUTION(open_turf.pollution)
