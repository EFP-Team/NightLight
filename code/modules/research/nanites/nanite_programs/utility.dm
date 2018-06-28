//Programs that interact with other programs or nanites directly, or have other special purposes.
/datum/nanite_program/viral
	name = "Viral Replica"
	desc = "The nanites constantly send encrypted signals attempting to forcefully copy their own programming into other nanite clusters."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/toxic)
	extra_settings = list("Program Overwrite","Cloud Overwrite")
	
	var/sync_programs = TRUE
	var/sync_overwrite = FALSE
	var/overwrite_cloud = FALSE
	var/set_cloud = 0

/datum/nanite_program/viral/set_extra_setting(user, setting)
	if(setting == "Program Overwrite")
		var/overwrite_type = input("Choose what to do with the target's programs", name) as null|anything in list("Overwrite","Add To","Ignore")
		if(!overwrite_type)
			return
		switch(overwrite_type)
			if("Ignore") //Do not affect programs (if you only want to set the cloud ID)
				sync_programs = FALSE
				sync_overwrite = FALSE
			if("Add To") //Add to existing programs (so the target does not notice theirs are missing)
				sync_programs = TRUE
				sync_overwrite = FALSE
			if("Overwrite") //Replace target's programs with the source
				sync_programs = TRUE
				sync_overwrite = TRUE
	if(setting == "Cloud Overwrite")
		var/overwrite_type = input("Choose what to do with the target's Cloud ID", name) as null|anything in list("Overwrite","Disable","Keep")
		if(!overwrite_type)
			return
		switch(overwrite_type)
			if("Keep") //Don't change the cloud ID
				overwrite_cloud = FALSE
				set_cloud = 0
			if("Disable") //Set the cloud ID to disabled
				overwrite_cloud = TRUE
				set_cloud = 0
			if("Overwrite") //Set the cloud ID to what we choose
				var/new_cloud = input(user, "Choose the Cloud ID to set on infected nanites (1-100)", name, null) as null|num
				if(isnull(new_cloud))
					return
				overwrite_cloud = TRUE
				set_cloud = CLAMP(round(new_code, 1), 1, 100)

/datum/nanite_program/viral/get_extra_setting(setting)
	if(setting == "Program Overwrite")
		if(!sync_programs)
			return "Ignore"
		else if(sync_overwrite)
			return "Overwrite"
		else
			return "Add To"
	if(setting == "Cloud Overwrite")
		if(!overwrite_cloud)
			return "None"
		else if(set_cloud == 0)
			return "Disable"
		else
			return set_cloud

/datum/nanite_program/viral/copy_extra_settings_to(datum/nanite_program/viral/target)
	target.overwrite_cloud = overwrite_cloud
	target.set_cloud = set_cloud
	target.sync_programs = sync_programs
	target.sync_overwrite = sync_overwrite

/datum/nanite_program/viral/active_effect()
	for(var/mob/M in orange(host_mob, 5))
		GET_COMPONENT_FROM(target_nanites, /datum/component/nanites, M)
		if(target_nanites && prob(5))
			if(sync_programs)
				target_nanites.sync(nanites, sync_overwrite) //won't delete non-affected programs
			if(overwrite_cloud)
				target_nanites.cloud_id = set_cloud

/datum/nanite_program/monitoring
	name = "Monitoring"
	desc = "The nanites monitor the host's vitals and location, sending them to the suit sensor network."
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/monitoring/enable_passive_effect()
	..()
	SSnanites.nanite_monitored_mobs |= host_mob
	host_mob.hud_set_nanite_indicator()

/datum/nanite_program/monitoring/disable_passive_effect()
	..()
	SSnanites.nanite_monitored_mobs -= host_mob
	host_mob.hud_set_nanite_indicator()

/datum/nanite_program/stealth
	name = "Stealth"
	desc = "The nanites hide their activity and programming from superficial scans."
	rogue_types = list(/datum/nanite_program/toxic)
	use_rate = 0.2

/datum/nanite_program/stealth/enable_passive_effect()
	..()
	nanites.stealth = TRUE

/datum/nanite_program/stealth/disable_passive_effect()
	..()
	nanites.stealth = FALSE

/datum/nanite_program/relay
	name = "Relay"
	desc = "The nanites receive and relay long-range nanite signals."
	rogue_types = list(/datum/nanite_program/toxic)
	
	extra_settings = list("Relay Channel")
	var/relay_channel = 1

/datum/nanite_program/relay/set_extra_setting(user, setting)
	if(setting == "Relay Channel")
		var/new_channel = input(user, "Set the relay channel (1-9999):", name, null) as null|num
		if(isnull(new_channel))
			return
		relay_channel = CLAMP(round(new_channel, 1), 1, 9999)

/datum/nanite_program/relay/get_extra_setting(setting)
	if(setting == "Relay Channel")
		return relay_channel

/datum/nanite_program/relay/copy_extra_settings_to(datum/nanite_program/relay/target)
	target.relay_channel = relay_channel	
	
/datum/nanite_program/relay/enable_passive_effect()
	..()
	SSnanites.nanite_relays |= src

/datum/nanite_program/relay/disable_passive_effect()
	..()
	SSnanites.nanite_relays -= src

/datum/nanite_program/relay/proc/relay_signal(code, relay_code, source)
	if(!activated)
		return
	if(!host_mob)
		return
	if(relay_code != relay_channel)
		return
	SEND_SIGNAL(host_mob, COMSIG_NANITE_SIGNAL, code, source)

/datum/nanite_program/metabolic_synthesis
	name = "Metabolic Synthesis"
	desc = "The nanites use the metabolic cycle of the host to speed up their replication rate, using their extra nutrition as fuel."
	use_rate = -0.5 //generates nanites
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/metabolic_synthesis/check_conditions()
	if(!iscarbon(host_mob))
		return FALSE
	var/mob/living/carbon/C = host_mob
	if(C.nutrition <= NUTRITION_LEVEL_WELL_FED)
		return FALSE
	return ..()

/datum/nanite_program/metabolic_synthesis/active_effect()
	host_mob.nutrition -= 0.5

/datum/nanite_program/triggered/access
	name = "Subdermal ID"
	desc = "The nanites store the host's ID access rights in a subdermal magnetic strip. Updates when triggered, copying the host's current access."
	rogue_types = list(/datum/nanite_program/skin_decay)
	var/access = list()

//Syncs the nanites with the cumulative current mob's access level. Can potentially wipe existing access.
/datum/nanite_program/triggered/access/trigger()
	var/list/new_access = list()
	var/obj/item/current_item
	current_item = host_mob.get_active_held_item()
	if(current_item)
		new_access += current_item.GetAccess()
	current_item = host_mob.get_inactive_held_item()
	if(current_item)
		new_access += current_item.GetAccess()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		current_item = H.wear_id
		if(current_item)
			new_access += current_item.GetAccess()
	else if(isanimal(host_mob))
		var/mob/living/simple_animal/A = host_mob
		current_item = A.access_card
		if(current_item)
			new_access += current_item.GetAccess()
	access = new_access

/datum/nanite_program/spreading
	name = "Infective Exo-Locomotion"
	desc = "The nanites gain the ability to survive for brief periods outside of the human body, as well as the ability to start new colonies without an integration process; \
			resulting in an extremely infective strain of nanites."
	use_rate = 1.50
	rogue_types = list(/datum/nanite_program/aggressive_replication, /datum/nanite_program/necrotic)

/datum/nanite_program/spreading/active_effect()
	if(prob(10))
		var/list/mob/living/target_hosts = list()
		for(var/mob/living/L in oview(5, host_mob))
			target_hosts += L
		var/mob/living/infectee = pick(target_hosts)
		if(prob(infectee.get_permeability_protection() * 100))
			//this will potentially take over existing nanites!
			infectee.AddComponent(/datum/component/nanites, 10)
			GET_COMPONENT_FROM(target_nanites, /datum/component/nanites, infectee)
			if(target_nanites)
				infectee.investigate_log("[key_name(infectee)] was infected by spreading nanites by [key_name(host_mob)]", INVESTIGATE_NANITES)
				target_nanites.sync(nanites)