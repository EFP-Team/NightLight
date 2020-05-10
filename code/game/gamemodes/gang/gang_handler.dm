//so, families has (had?) a lot of gamemode-level computations that aren't folded into the antag datum for various reasons.
//if these were kept in the gamemode datum, then the dynamic ruleset datum would have a lot of copy-pasted code, which is hard to maintain.
//the solution, of course, is snowflake code. in this case, a special handler that stores all of the procs and has a var that references
//a gamemode-level list. both the families gamemode standalone and the families dynamic ruleset instance the datum, pass it the necessary lists,
//and call its procs. this way, all the code is centralized in one place. it's terrible, and i'm sorry.

#define LOWPOP_FAMILIES_COUNT 50

#define TWO_STARS_HIGHPOP 11
#define THREE_STARS_HIGHPOP 16
#define FOUR_STARS_HIGHPOP 21
#define FIVE_STARS_HIGHPOP 31

#define TWO_STARS_LOW 6
#define THREE_STARS_LOW 9
#define FOUR_STARS_LOW 12
#define FIVE_STARS_LOW 15

#define CREW_SIZE_MIN 4
#define CREW_SIZE_MAX 8


GLOBAL_VAR_INIT(deaths_during_shift, 0)

/datum/gang_handler
	var/restricted_jobs = list("Cyborg", "AI", "Prisoner","Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")//N O

	var/check_counter = 0
	var/endtime = null
	var/start_time = null
	var/fuckingdone = FALSE
	var/time_to_end = 60 MINUTES
	var/gangs_to_generate = 3
	var/list/gangs_to_use
	var/list/datum/mind/gangbangers = list()
	var/list/datum/mind/pigs = list()
	var/list/datum/mind/undercover_cops = list()
	var/list/gangs = list()
	var/gangs_still_alive = 0
	var/sent_announcement = FALSE
	var/sent_second_announcement = FALSE
	var/list/gang_locations = list()
	var/cops_arrived = FALSE
	var/gang_balance_cap = 5
	var/wanted_level = 0

	var/midround_ruleset = FALSE

	var/list/datum/mind/antag_candidates


/datum/gang_handler/New(/list/datum/mind/L) // takes the list of antag candidates and makes it its own. since lists are passed by reference this is literally the list and not just a copy
	antag_candidates = L

/datum/gang_handler/warriors
	gangs_to_generate = 11
	gang_balance_cap = 3

/datum/gang_handler/warriors/pre_setup_analogue()
	gangs_to_use = subtypesof(/datum/antagonist/gang)
	gangs_to_generate = gangs_to_use.len
	. = ..()

/datum/gang_handler/proc/pre_setup_analogue() // EXTERNAL pre_setup equivalent
	gangs_to_use = subtypesof(/datum/antagonist/gang)
	for(var/j = 0, j < gangs_to_generate, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/gangbanger = pick_n_take(antag_candidates) //original used antag_pick, a game_mode proc, but dynamic rulesets use pick_n_take, a global proc, so hopefully this is okay
		gangbangers += gangbanger
		gangbanger.restricted_roles = restricted_jobs
		log_game("[key_name(gangbanger)] has been selected as a starting gangster!")
		antag_candidates.Remove(gangbanger)
	for(var/j = 0, j < gangs_to_generate, j++)
		if(!antag_candidates.len)
			break
		var/datum/mind/one_eight_seven_on_an_undercover_cop = pick_n_take(antag_candidates)
		pigs += one_eight_seven_on_an_undercover_cop
		undercover_cops += one_eight_seven_on_an_undercover_cop
		one_eight_seven_on_an_undercover_cop.restricted_roles = restricted_jobs
		log_game("[key_name(one_eight_seven_on_an_undercover_cop)] has been selected as a starting undercover cop!")
		antag_candidates.Remove(one_eight_seven_on_an_undercover_cop)
	time_to_end /= (midround_ruleset ? 2 : 1)
	endtime = world.time + time_to_end
	start_time = world.time
	return TRUE

/datum/gang_handler/proc/post_setup_analogue() // EXTERNAL post_setup equivalent transfer parts to antag datums
	var/replacement_gangsters = 0
	var/replacement_cops = 0
	for(var/datum/mind/gangbanger in gangbangers)
		if(!ishuman(gangbanger.current))
			gangbangers.Remove(gangbanger)
			log_game("[gangbanger] was not a human, and thus has lost their gangster role.")
			replacement_gangsters++
	if(replacement_gangsters)
		for(var/j = 0, j < replacement_gangsters, j++)
			if(!antag_candidates.len)
				log_game("Unable to find more replacement gangsters. Not all of the gangs will spawn.")
				break
			var/datum/mind/gangbanger = pick_n_take(antag_candidates)
			gangbangers += gangbanger
			log_game("[key_name(gangbanger)] has been selected as a replacement gangster!")
	for(var/datum/mind/undercover_cop in undercover_cops)
		if(!ishuman(undercover_cop.current))
			undercover_cops.Remove(undercover_cop)
			pigs.Remove(undercover_cop)
			log_game("[undercover_cop] was not a human, and thus has lost their undercover cop role.")
			replacement_cops++
	if(replacement_cops)
		for(var/j = 0, j < replacement_cops, j++)
			if(!antag_candidates.len)
				log_game("Unable to find more replacement undercover cops. Not all of the gangs will spawn.")
				break
			var/datum/mind/undercover_cop = pick_n_take(antag_candidates)
			undercover_cops += undercover_cop
			pigs += undercover_cop
			log_game("[key_name(undercover_cop)] has been selected as a replacement undercover cop!")
	for(var/datum/mind/undercover_cop in undercover_cops)
		var/datum/antagonist/ert/families/undercover_cop/one_eight_seven_on_an_undercover_cop = new()
		undercover_cop.add_antag_datum(one_eight_seven_on_an_undercover_cop)

	for(var/datum/mind/gangbanger in gangbangers)
		var/gang_to_use = pick_n_take(gangs_to_use)
		var/datum/antagonist/gang/new_gangster = new gang_to_use()
		var/datum/team/gang/ballas = new /datum/team/gang()
		new_gangster.handler = src
		new_gangster.my_gang = ballas
		new_gangster.starter_gangster = TRUE
		gangs += ballas
		ballas.add_member(gangbanger)
		ballas.name = new_gangster.gang_name

		ballas.acceptable_clothes = new_gangster.acceptable_clothes.Copy()
		ballas.free_clothes = new_gangster.free_clothes.Copy()
		ballas.my_gang_datum = new_gangster

		gangbanger.add_antag_datum(new_gangster)

	addtimer(CALLBACK(src, .proc/announce_gang_locations), 5 MINUTES)
	SSshuttle.registerHostileEnvironment(src)
	gamemode_ready = TRUE
	..()

/datum/gang_handler/proc/announce_gang_locations()
	var/list/readable_gang_names = list()
	for(var/GG in gangs)
		var/datum/team/gang/G = GG
		readable_gang_names += "[G.name]"
	var/finalized_gang_names = english_list(readable_gang_names)
	priority_announce("Julio G coming to you live from Radio Los Spess! We've been hearing reports of gang activity on [station_name()], with the [finalized_gang_names] duking it out, looking for fresh territory and drugs to sling! Stay safe out there for the hour 'till the space cops get there, and keep it cool, yeah?\n\n The local jump gates are shut down for about an hour due to some maintenance troubles, so if you wanna split from the area you're gonna have to wait an hour. \n Play music, not gunshots, I say. Peace out!", "Radio Los Spess", 'sound/voice/beepsky/radio.ogg')
	sent_announcement = TRUE

/datum/gang_handler/proc/five_minute_warning()
	priority_announce("Julio G coming to you live from Radio Los Spess! The space cops are closing in on [station_name()] and will arrive in about 5 minutes! Better clear on out of there if you don't want to get hurt!", "Radio Los Spess", 'sound/voice/beepsky/radio.ogg')
	sent_second_announcement = TRUE

/datum/gang_handler/proc/set_round_result_analogue()
	var/alive_gangsters = 0
	var/alive_cops = 0
	for(var/datum/mind/gangbanger in gangbangers)
		if(!ishuman(gangbanger.current))
			continue
		var/mob/living/carbon/human/H = gangbanger.current
		if(H.stat)
			continue
		alive_gangsters++
	for(var/datum/mind/bacon in pigs)
		if(!ishuman(bacon.current)) // always returns false
			continue
		var/mob/living/carbon/human/H = bacon.current
		if(H.stat)
			continue
		alive_cops++
	if(alive_gangsters > alive_cops)
		SSticker.mode_result = "win - gangs survived"
		SSticker.news_report = GANG_OPERATING
		return TRUE
	SSticker.mode_result = "loss - police destroyed the gangs"
	SSticker.news_report = GANG_DESTROYED
	return FALSE

/datum/gang_handler/proc/process_analogue() // EXTERNAL process() equivalent
	check_wanted_level()
	check_counter++
	if(check_counter >= 5)
		if(world.time > (endtime - 5 MINUTES) && !sent_second_announcement)
			five_minute_warning()
			addtimer(CALLBACK(src, .proc/send_in_the_fuzz), 5 MINUTES)

		check_counter = 0

		check_tagged_turfs()
		check_gang_clothes()
		check_rollin_with_crews()

///Checks if our wanted level has changed. Only actually does something post the initial announcement and until the cops show up. After that its locked.
/datum/gang_handler/proc/check_wanted_level()
	if(!sent_announcement || fuckingdone)
		return
	var/new_wanted_level
	if(GLOB.joined_player_list.len > LOWPOP_FAMILIES_COUNT)
		switch(GLOB.deaths_during_shift)
			if(0 to TWO_STARS_HIGHPOP-1)
				new_wanted_level = 1
			if(TWO_STARS_HIGHPOP to THREE_STARS_HIGHPOP-1)
				new_wanted_level = 2
			if(THREE_STARS_HIGHPOP to FOUR_STARS_HIGHPOP-1)
				new_wanted_level = 3
			if(FOUR_STARS_HIGHPOP to FIVE_STARS_HIGHPOP-1)
				new_wanted_level = 4
			if(FIVE_STARS_HIGHPOP to INFINITY)
				new_wanted_level = 5
	else
		switch(GLOB.deaths_during_shift)
			if(0 to TWO_STARS_LOW-1)
				new_wanted_level = 1
			if(TWO_STARS_LOW to THREE_STARS_LOW-1)
				new_wanted_level = 2
			if(THREE_STARS_LOW to FOUR_STARS_LOW-1)
				new_wanted_level = 3
			if(FOUR_STARS_LOW to FIVE_STARS_LOW-1)
				new_wanted_level = 4
			if(FIVE_STARS_LOW to INFINITY)
				new_wanted_level = 5
	update_wanted_level(new_wanted_level)

///Updates the icon states for everyone and sends outs announcements regarding the police.
/datum/gang_handler/proc/update_wanted_level(newlevel)
	if(newlevel > wanted_level)
		on_gain_wanted_level(newlevel)
	else if (newlevel < wanted_level)
		on_lower_wanted_level(newlevel)
	wanted_level = newlevel
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(!M.hud_used?.wanted_lvl)
			continue
		var/datum/hud/H = M.hud_used
		H.wanted_lvl.level = newlevel
		H.wanted_lvl.cops_arrived = cops_arrived
		H.wanted_lvl.update_icon()

/datum/gang_handler/proc/on_gain_wanted_level(newlevel)
	var/announcement_message
	switch(newlevel)
		if(2)
			if(!sent_second_announcement)
				time_to_end = 50 MINUTES / (midround_ruleset ? 2 : 1)
			announcement_message = "Small amount of police vehicles have been spotted en route towards [station_name()]."
		if(3)
			if(!sent_second_announcement)
				time_to_end = 40 MINUTES / (midround_ruleset ? 2 : 1)
			announcement_message = "A large detachment police vehicles have been spotted en route towards [station_name()]."
		if(4)
			if(!sent_second_announcement)
				time_to_end = 35 MINUTES / (midround_ruleset ? 2 : 1)
			announcement_message = "A detachment of top-trained agents has been spotted on their way to [station_name()]."
		if(5)
			if(!sent_second_announcement)
				time_to_end = 30 MINUTES / (midround_ruleset ? 2 : 1)
			announcement_message = "The fleet enroute to [station_name()] now consists of national guard personnel."
	if(!midround_ruleset)
		var/adjusted_end_time = time_to_end / 1 MINUTES
		announcement_message += "  They will arrive at the [num2text(adjusted_end_time)] minute mark."
	endtime = start_time + time_to_end
	priority_announce(announcement_message, "Station Spaceship Detection Systems")

/datum/gang_handler/proc/on_lower_wanted_level(newlevel)
	var/announcement_message
	switch(newlevel)
		if(1)
			if(!sent_second_announcement)
				time_to_end = 60 MINUTES / (midround_ruleset ? 2 : 1)
			announcement_message = "There are now only a few police vehicle headed towards [station_name()]."
		if(2)
			if(!sent_second_announcement)
				time_to_end = 50 MINUTES / (midround_ruleset ? 2 : 1)
			announcement_message = "There seem to be fewer police vehicles headed towards [station_name()]."
		if(3)
			if(!sent_second_announcement)
				time_to_end = 40 MINUTES / (midround_ruleset ? 2 : 1)
			announcement_message = "There are no longer top-trained agents in the fleet headed towards [station_name()]."
		if(4)
			if(!sent_second_announcement)
				time_to_end = 35 MINUTES / (midround_ruleset ? 2 : 1)
			announcement_message = "The convoy enroute to [station_name()] seems to no longer consist of national guard personnel."
	if(!midround_ruleset)
		var/adjusted_end_time = time_to_end / 1 MINUTES
		announcement_message += "  They will arrive at the [num2text(adjusted_end_time)] minute mark."
	endtime = start_time + time_to_end
	priority_announce(announcement_message, "Station Spaceship Detection Systems")

/datum/gang_handler/proc/send_in_the_fuzz()
	fuckingdone = TRUE
	var/team_size
	var/cops_to_send
	var/announcement_message = "PUNK ASS BALLA BITCH"
	var/announcer = "Spinward Stellar Coalition"
	if(GLOB.joined_player_list.len > LOWPOP_FAMILIES_COUNT)
		switch(wanted_level)
			if(1)
				team_size = 8
				cops_to_send = /datum/antagonist/ert/families/beatcop
				announcement_message = "Hello, crewmembers of [station_name()]! We've received a few calls about some potential violent gang activity on board your station, so we're sending some beat cops to check things out. Nothing extreme, just a courtesy call. However, while they check things out for about 10 minutes, we're going to have to ask that you keep your escape shuttle parked.\n\nHave a pleasant day!"
				announcer = "Spinward Stellar Coalition Police Department"
			if(2)
				team_size = 9
				cops_to_send = /datum/antagonist/ert/families/beatcop/armored
				announcement_message = "Crewmembers of [station_name()]. We have received confirmed reports of violent gang activity from your station. We are dispatching some armed officers to help keep the peace and investigate matters. Do not get in their way, and comply with any and all requests from them. We have blockaded the local warp gate, and your shuttle cannot depart for another 10 minutes.\n\nHave a secure day."
				announcer = "Spinward Stellar Coalition Police Department"
			if(3)
				team_size = 10
				cops_to_send = /datum/antagonist/ert/families/beatcop/swat
				announcement_message = "Crewmembers of [station_name()]. We have received confirmed reports of extreme gang activity from your station resulting in heavy civilian casualties. The Spinward Stellar Coalition does not tolerate abuse towards our citizens, and we will be responding in force to keep the peace and reduce civilian casualties. We have your station surrounded, and all gangsters must drop their weapons and surrender peacefully.\n\nHave a secure day."
				announcer = "Spinward Stellar Coalition Police Department"
			if(4)
				team_size = 11
				cops_to_send = /datum/antagonist/ert/families/beatcop/fbi
				announcement_message = "We are dispatching our top agents to [station_name()] at the request of the Spinward Stellar Coalition government due to an extreme terrorist level threat against this Nanotrasen owned station. All gangsters must surrender IMMEDIATELY. Failure to comply can and will result in death. We have blockaded your warp gates and will not allow any escape until the situation is resolved within our standard response time of 10 minutes.\n\nSurrender now or face the consequences of your actions."
				announcer = "Federal Bureau of Investigation"
			if(5)
				team_size = 12
				cops_to_send = /datum/antagonist/ert/families/beatcop/military
				announcement_message = "Due to an insane level of civilian casualties aboard [station_name()], we have dispatched the National Guard to curb any and all gang activity on board the station. We have heavy cruisers watching the shuttle. Attempt to leave before we allow you to, and we will obliterate your station and your escape shuttle.\n\nYou brought this on yourselves by murdering so many civilians."
				announcer = "Spinward Stellar Coalition National Guard"
	else
		switch(wanted_level)
			if(1)
				team_size = 5
				cops_to_send = /datum/antagonist/ert/families/beatcop
				announcement_message = "Hello, crewmembers of [station_name()]! We've received a few calls about some potential violent gang activity on board your station, so we're sending some beat cops to check things out. Nothing extreme, just a courtesy call. However, while they check things out for about 10 minutes, we're going to have to ask that you keep your escape shuttle parked.\n\nHave a pleasant day!"
				announcer = "Spinward Stellar Coalition Police Department"
			if(2)
				team_size = 6
				cops_to_send = /datum/antagonist/ert/families/beatcop/armored
				announcement_message = "Crewmembers of [station_name()]. We have received confirmed reports of violent gang activity from your station. We are dispatching some armed officers to help keep the peace and investigate matters. Do not get in their way, and comply with any and all requests from them. We have blockaded the local warp gate, and your shuttle cannot depart for another 10 minutes.\n\nHave a secure day."
				announcer = "Spinward Stellar Coalition Police Department"
			if(3)
				team_size = 7
				cops_to_send = /datum/antagonist/ert/families/beatcop/swat
				announcement_message = "Crewmembers of [station_name()]. We have received confirmed reports of extreme gang activity from your station resulting in heavy civilian casualties. The Spinward Stellar Coalition does not tolerate abuse towards our citizens, and we will be responding in force to keep the peace and reduce civilian casualties. We have your station surrounded, and all gangsters must drop their weapons and surrender peacefully.\n\nHave a secure day."
				announcer = "Spinward Stellar Coalition Police Department"
			if(4)
				team_size = 8
				cops_to_send = /datum/antagonist/ert/families/beatcop/fbi
				announcement_message = "We are dispatching our top agents to [station_name()] at the request of the Spinward Stellar Coalition government due to an extreme terrorist level threat against this Nanotrasen owned station. All gangsters must surrender IMMEDIATELY. Failure to comply can and will result in death. We have blockaded your warp gates and will not allow any escape until the situation is resolved within our standard response time of 10 minutes.\n\nSurrender now or face the consequences of your actions."
				announcer = "Federal Bureau of Investigation"
			if(5)
				team_size = 10
				cops_to_send = /datum/antagonist/ert/families/beatcop/military
				announcement_message = "Due to an insane level of civilian casualties aboard [station_name()], we have dispatched the National Guard to curb any and all gang activity on board the station. We have heavy cruisers watching the shuttle. Attempt to leave before we allow you to, and we will obliterate your station and your escape shuttle.\n\nYou brought this on yourselves by murdering so many civilians."
				announcer = "Spinward Stellar Coalition National Guard"

	priority_announce(announcement_message, announcer, 'sound/effects/families_police.ogg')
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to help clean up crime on this station?", "deathsquad", null)


	if(candidates.len)
		//Pick the (un)lucky players
		var/numagents = min(team_size,candidates.len)

		var/list/spawnpoints = GLOB.emergencyresponseteamspawn
		var/index = 0
		while(numagents && candidates.len)
			var/spawnloc = spawnpoints[index+1]
			//loop through spawnpoints one at a time
			index = (index + 1) % spawnpoints.len
			var/mob/dead/observer/chosen_candidate = pick(candidates)
			candidates -= chosen_candidate
			if(!chosen_candidate.key)
				continue

			//Spawn the body
			var/mob/living/carbon/human/cop = new(spawnloc)
			chosen_candidate.client.prefs.copy_to(cop)
			cop.key = chosen_candidate.key

			//Give antag datum
			var/datum/antagonist/ert/ert_antag = new cops_to_send

			cop.mind.add_antag_datum(ert_antag)
			cop.mind.assigned_role = ert_antag.name
			SSjob.SendToLateJoin(cop)

			//Logging and cleanup
			log_game("[key_name(cop)] has been selected as an [ert_antag.name]")
			numagents--
	cops_arrived = TRUE
	update_wanted_level()
	addtimer(CALLBACK(src, .proc/end_hostile_sit), 10 MINUTES)
	return TRUE

/datum/gang_handler/proc/end_hostile_sit()
	SSshuttle.clearHostileEnvironment(src)


/datum/gang_handler/proc/check_tagged_turfs()
	for(var/T in GLOB.gang_tags)
		var/obj/effect/decal/cleanable/crayon/gang/tag = T
		if(tag.my_gang)
			tag.my_gang.adjust_points(50)
		CHECK_TICK

/datum/gang_handler/proc/check_gang_clothes() // TODO: make this grab the sprite itself, average out what the primary color would be, then compare how close it is to the gang color so I don't have to manually fill shit out for 5 years for every gang type
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!H.mind || !H.client)
			continue
		var/datum/antagonist/gang/is_gangster = H.mind.has_antag_datum(/datum/antagonist/gang)
		for(var/clothing in list(H.head, H.wear_mask, H.wear_suit, H.w_uniform, H.back, H.gloves, H.shoes, H.belt, H.s_store, H.glasses, H.ears, H.wear_id))
			if(is_gangster)
				if(is_type_in_list(clothing, is_gangster.acceptable_clothes))
					is_gangster.add_gang_points(10)
			else
				for(var/G in gangs)
					var/datum/team/gang/gang_clothes = G
					if(is_type_in_list(clothing, gang_clothes.acceptable_clothes))
						gang_clothes.adjust_points(5)

		CHECK_TICK

/datum/gang_handler/proc/check_rollin_with_crews()
	var/list/areas_to_check = list()
	for(var/G in gangbangers)
		var/datum/mind/gangster = G
		areas_to_check += get_area(gangster.current)
	for(var/AA in areas_to_check)
		var/area/A = AA
		var/list/gang_members = list()
		for(var/mob/living/carbon/human/H in A)
			if(H.stat || !H.mind || !H.client)
				continue
			var/datum/antagonist/gang/is_gangster = H.mind.has_antag_datum(/datum/antagonist/gang)
			if(is_gangster)
				gang_members[is_gangster.my_gang]++
			CHECK_TICK
		if(gang_members.len)
			for(var/datum/team/gang/gangsters in gang_members)
				if(gang_members[gangsters] >= CREW_SIZE_MIN)
					if(gang_members[gangsters] >= CREW_SIZE_MAX)
						gangsters.adjust_points(5) // Discourage larger clumps, spread ur people out
					else
						gangsters.adjust_points(10)


/datum/antagonist/ert/families/beatcop/roundend_report_footer() // hijacks the beatcop's roundend results to say which gang won the round
	var/report = "<div class='panel redborder'>"
	var/highest_point_value = 0
	var/highest_gang = "Leet Like Jeff K"
	var/objective_failures = TRUE

	var/list/datum/team/gang/gangs
	var/list/datum/mind/gangsters
	var/list/datum/mind/cops

	for(var/datum/team/possiblegang in GLOB.antagonist_teams)
		if(istype(possiblegang, /datum/team/gang))
			gangs |= possiblegang

	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		if(istype(A, /datum/antagonist/gang))
			gangsters |= A
			continue
		if(istype(A, /datum/antagonist/ert/families))
			cops |= A
			continue

	for(var/datum/team/gang/GG in gangs)
		if(GG.my_gang_datum.check_gang_objective())
			objective_failures = FALSE
			break
	for(var/datum/team/gang/G in gangs)
		if(!objective_failures)
			if(G.points >= highest_point_value && G.members.len && G.my_gang_datum.check_gang_objective())
				highest_point_value = G.points
				highest_gang = G.name
		else
			if(G.points >= highest_point_value && G.members.len)
				highest_point_value = G.points
				highest_gang = G.name
	var/alive_gangsters = 0
	var/alive_cops = 0
	for(var/datum/mind/gangbanger in gangsters)
		if(gangbanger.current)
			if(!ishuman(gangbanger.current))
				continue
			var/mob/living/carbon/human/H = gangbanger.current
			if(H.stat)
				continue
			alive_gangsters++
	for(var/datum/mind/bacon in cops)
		if(bacon.current)
			if(!ishuman(bacon.current)) // always returns false
				continue
			var/mob/living/carbon/human/H = bacon.current
			if(H.stat)
				continue
			alive_cops++

	if(alive_gangsters > alive_cops)
		if(!objective_failures)
			report = "<span class='header greentext'>[highest_gang] won the round by completing their objective and having the most points!</span>"
		else
			report = "<span class='header greentext'>[highest_gang] won the round by having the most points!</span>"
	else if(alive_gangsters == alive_cops)
		report = "<span class='header redtext'>Legend has it the police and the families are still duking it out to this day!</span>"
	else
		report = "<span class='header greentext'>The police put the boots to the families, medium style!</span>"

	return "</div><div class='panel redborder'>[report]" // </div> at the front not the back because this proc is intended for normal text not a whole new panel
