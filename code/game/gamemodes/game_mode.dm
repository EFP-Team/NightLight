

/*
 * GAMEMODES (by Rastaf0)
 *
 * In the new mode system all special roles are fully supported.
 * You can have proper wizards/traitors/changelings/cultists during any mode.
 * Only two things really depends on gamemode:
 * 1. Starting roles, equipment and preparations
 * 2. Conditions of finishing the round.
 *
 */


/datum/game_mode
	/// Self explanitory, name of the game mode.
	var/name = "invalid"
	/// Used for tracking where the nuke hit. Changes cinematic if the nuke is deployed off station zlevel.
	var/nuke_off_station = FALSE

	/// List of available station goals for the crew to be working on, built into the round-type.
	var/list/datum/station_goal/station_goals = list()
	///Is the gamemode all set up and ready to start checking for ending conditions.
	var/gamemode_ready = FALSE

	/// Associative list of current players, in order: living players, living antagonists, dead players and observers.
	var/list/list/current_players = list(CURRENT_LIVING_PLAYERS = list(), CURRENT_LIVING_ANTAGS = list(), CURRENT_DEAD_PLAYERS = list(), CURRENT_OBSERVERS = list())

///Attempts to select players for special roles the mode might have.
/datum/game_mode/proc/pre_setup()
	return TRUE

///Everyone should now be on the station and have their normal gear.  This is the place to give the special roles extra things
/datum/game_mode/proc/post_setup(report) //Gamemodes can override the intercept report. Passing TRUE as the argument will force a report.
	if(!report)
		report = !CONFIG_GET(flag/no_intercept_report)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/display_roundstart_logout_report), ROUNDSTART_LOGOUT_REPORT_TIME)

	if(CONFIG_GET(flag/reopen_roundstart_suicide_roles))
		var/delay = CONFIG_GET(number/reopen_roundstart_suicide_roles_delay)
		if(delay)
			delay = (delay SECONDS)
		else
			delay = (4 MINUTES) //default to 4 minutes if the delay isn't defined.
		addtimer(CALLBACK(GLOBAL_PROC, .proc/reopen_roundstart_suicide_roles), delay)

	if(SSdbcore.Connect())
		var/list/to_set = list()
		var/arguments = list()
		if(SSticker.mode)
			to_set += "game_mode = :game_mode"
			arguments["game_mode"] = SSticker.mode
		if(GLOB.revdata.originmastercommit)
			to_set += "commit_hash = :commit_hash"
			arguments["commit_hash"] = GLOB.revdata.originmastercommit
		if(to_set.len)
			arguments["round_id"] = GLOB.round_id
			var/datum/db_query/query_round_game_mode = SSdbcore.NewQuery(
				"UPDATE [format_table_name("round")] SET [to_set.Join(", ")] WHERE id = :round_id",
				arguments
			)
			query_round_game_mode.Execute()
			qdel(query_round_game_mode)
	generate_station_goals()
	gamemode_ready = TRUE
	return TRUE


///Handles late-join antag assignments
/datum/game_mode/proc/make_antag_chance(mob/living/carbon/human/character)
	return

///Called by the gameSSticker
/datum/game_mode/process()
	return

/datum/game_mode/proc/check_finished(force_ending) //to be called by SSticker
	if(!SSticker.setup_done || !gamemode_ready)
		return FALSE
	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(GLOB.station_was_nuked)
		return TRUE
	if(force_ending)
		return TRUE

/*
 * Generate a list of station goals available to purchase to report to the crew.
 *
 * Returns a formatted string all station goals that are available to the station.
 */
/datum/game_mode/proc/generate_station_goal_report()
	if(!station_goals.len)
		return
	. = "<hr><b>Special Orders for [station_name()]:</b><BR>"
	for(var/datum/station_goal/station_goal in station_goals)
		station_goal.on_report()
		. += station_goal.get_report()
	return

/*
 * Generate a list of active station traits to report to the crew.
 *
 * Returns a formatted string of all station traits (that are shown) affecting the station.
 */
/datum/game_mode/proc/generate_station_trait_report()
	if(!SSstation.station_traits.len)
		return
	. = "<hr><b>Identified shift divergencies:</b><BR>"
	for(var/datum/station_trait/station_trait as anything in SSstation.station_traits)
		if(!station_trait.show_in_report)
			continue
		. += "[station_trait.get_report()]<BR>"
	return

// This is a frequency selection system. You may imagine it like a raffle where each player can have some number of tickets. The more tickets you have the more likely you are to
// "win". The default is 100 tickets. If no players use any extra tickets (earned with the antagonist rep system) calling this function should be equivalent to calling the normal
// pick() function. By default you may use up to 100 extra tickets per roll, meaning at maximum a player may double their chances compared to a player who has no extra tickets.
//
// The odds of being picked are simply (your_tickets / total_tickets). Suppose you have one player using fifty (50) extra tickets, and one who uses no extra:
//     Player A: 150 tickets
//     Player B: 100 tickets
//        Total: 250 tickets
//
// The odds become:
//     Player A: 150 / 250 = 0.6 = 60%
//     Player B: 100 / 250 = 0.4 = 40%
/datum/game_mode/proc/antag_pick(list/datum/candidates)
	if(!CONFIG_GET(flag/use_antag_rep)) // || candidates.len <= 1)
		return pick(candidates)

	// Tickets start at 100
	var/DEFAULT_ANTAG_TICKETS = CONFIG_GET(number/default_antag_tickets)

	// You may use up to 100 extra tickets (double your odds)
	var/MAX_TICKETS_PER_ROLL = CONFIG_GET(number/max_tickets_per_roll)


	var/total_tickets = 0

	MAX_TICKETS_PER_ROLL += DEFAULT_ANTAG_TICKETS

	var/p_ckey
	var/p_rep

	for(var/datum/mind/mind in candidates)
		p_ckey = ckey(mind.key)
		total_tickets += min(SSpersistence.antag_rep[p_ckey] + DEFAULT_ANTAG_TICKETS, MAX_TICKETS_PER_ROLL)

	var/antag_select = rand(1,total_tickets)
	var/current = 1

	for(var/datum/mind/mind in candidates)
		p_ckey = ckey(mind.key)
		p_rep = SSpersistence.antag_rep[p_ckey]

		var/previous = current
		var/spend = min(p_rep + DEFAULT_ANTAG_TICKETS, MAX_TICKETS_PER_ROLL)
		current += spend

		if(antag_select >= previous && antag_select <= (current-1))
			SSpersistence.antag_rep_change[p_ckey] = -(spend - DEFAULT_ANTAG_TICKETS)

// WARNING("AR_DEBUG: Player [mind.key] won spending [spend] tickets from starting value [SSpersistence.antag_rep[p_ckey]]")

			return mind

	WARNING("Something has gone terribly wrong. /datum/game_mode/proc/antag_pick failed to select a candidate. Falling back to pick()")
	return pick(candidates)

/datum/game_mode/proc/num_players()
	. = 0
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/P = i
		if(P.ready == PLAYER_READY_TO_PLAY)
			. ++

/proc/reopen_roundstart_suicide_roles()
	var/list/valid_positions = list()
	valid_positions += GLOB.engineering_positions
	valid_positions += GLOB.medical_positions
	valid_positions += GLOB.science_positions
	valid_positions += GLOB.supply_positions
	valid_positions += GLOB.service_positions
	valid_positions += GLOB.security_positions
	if(CONFIG_GET(flag/reopen_roundstart_suicide_roles_command_positions))
		valid_positions += GLOB.command_positions //add any remaining command positions
	else
		valid_positions -= GLOB.command_positions //remove all command positions that were added from their respective department positions lists.

	var/list/reopened_jobs = list()
	for(var/X in GLOB.suicided_mob_list)
		if(!isliving(X))
			continue
		var/mob/living/L = X
		if(L.job in valid_positions)
			var/datum/job/J = SSjob.GetJob(L.job)
			if(!J)
				continue
			J.current_positions = max(J.current_positions-1, 0)
			reopened_jobs += L.job

	if(CONFIG_GET(flag/reopen_roundstart_suicide_roles_command_report))
		if(reopened_jobs.len)
			var/reopened_job_report_positions
			for(var/dead_dudes_job in reopened_jobs)
				reopened_job_report_positions = "[reopened_job_report_positions ? "[reopened_job_report_positions]\n":""][dead_dudes_job]"

			var/suicide_command_report = "<font size = 3><b>Central Command Human Resources Board</b><br>\
								Notice of Personnel Change</font><hr>\
								To personnel management staff aboard [station_name()]:<br><br>\
								Our medical staff have detected a series of anomalies in the vital sensors \
								of some of the staff aboard your station.<br><br>\
								Further investigation into the situation on our end resulted in us discovering \
								a series of rather... unforturnate decisions that were made on the part of said staff.<br><br>\
								As such, we have taken the liberty to automatically reopen employment opportunities for the positions of the crew members \
								who have decided not to partake in our research. We will be forwarding their cases to our employment review board \
								to determine their eligibility for continued service with the company (and of course the \
								continued storage of cloning records within the central medical backup server.)<br><br>\
								<i>The following positions have been reopened on our behalf:<br><br>\
								[reopened_job_report_positions]</i>"

			print_command_report(suicide_command_report, "Central Command Personnel Update")

//////////////////////////
//Reports player logouts//
//////////////////////////
/proc/display_roundstart_logout_report()
	var/list/msg = list("<span class='boldnotice'>Roundstart logout report</span>\n\n")
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		var/mob/living/carbon/C = L
		if (istype(C) && !C.last_mind)
			continue  // never had a client

		if(L.ckey && !GLOB.directory[L.ckey])
			msg += "<b>[L.name]</b> ([L.key]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(L.ckey && L.client)
			var/failed = FALSE
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2)) //Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.key]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				failed = TRUE //AFK client
			if(!failed && L.stat)
				if(L.suiciding) //Suicider
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] (<span class='boldannounce'>Suicide</span>)\n"
					failed = TRUE //Disconnected client
				if(!failed && (L.stat == UNCONSCIOUS || L.stat == HARD_CRIT))
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] (Dying)\n"
					failed = TRUE //Unconscious
				if(!failed && L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] (Dead)\n"
					failed = TRUE //Dead

			var/p_ckey = L.client.ckey
// WARNING("AR_DEBUG: [p_ckey]: failed - [failed], antag_rep_change: [SSpersistence.antag_rep_change[p_ckey]]")

			// people who died or left should not gain any reputation
			// people who rolled antagonist still lose it
			if(failed && SSpersistence.antag_rep_change[p_ckey] > 0)
// WARNING("AR_DEBUG: Zeroed [p_ckey]'s antag_rep_change")
				SSpersistence.antag_rep_change[p_ckey] = 0

			continue //Happy connected client
		for(var/mob/dead/observer/D in GLOB.dead_mob_list)
			if(D.mind && D.mind.current == L)
				if(L.stat == DEAD)
					if(L.suiciding) //Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<span class='boldannounce'>Suicide</span>)\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						continue //Adminghost, or cult/wizard ghost
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<span class='boldannounce'>Ghosted</span>)\n"
						continue //Ghosted while alive


	for (var/C in GLOB.admins)
		to_chat(C, msg.Join())

/datum/game_mode/proc/remove_antag_for_borging(datum/mind/newborgie)
	newborgie.remove_antag_datum(/datum/antagonist/cult)
	var/datum/antagonist/rev/rev = newborgie.has_antag_datum(/datum/antagonist/rev)
	if(rev)
		rev.remove_revolutionary(TRUE)

/datum/game_mode/proc/generate_station_goals()
	var/list/possible = subtypesof(/datum/station_goal)
	var/goal_weights = 0
	while(possible.len && goal_weights < STATION_GOAL_BUDGET)
		var/datum/station_goal/picked = pick_n_take(possible)
		goal_weights += initial(picked.weight)
		station_goals += new picked


/datum/game_mode/proc/generate_report() //Generates a small text blurb for the gamemode in centcom report
	return "Gamemode report for [name] not set.  Contact a coder."

//Additional report section in roundend report
/datum/game_mode/proc/special_report()
	return

//Set result and news report here
/datum/game_mode/proc/set_round_result()
	SSticker.mode_result = "undefined"
	if(GLOB.station_was_nuked)
		SSticker.news_report = STATION_DESTROYED_NUKE
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		SSticker.news_report = STATION_EVACUATED
		if(SSshuttle.emergency.is_hijacked())
			SSticker.news_report = SHUTTLE_HIJACK

/// Mode specific admin panel.
/datum/game_mode/proc/admin_panel()
	return
