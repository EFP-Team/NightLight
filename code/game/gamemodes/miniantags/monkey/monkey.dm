/datum/game_mode
	var/list/ape_infectees = list()
	var/list/ape_leaders = list()

/datum/game_mode/monkey
	name = "monkey"
	config_tag = "monkey"
	antag_flag = ROLE_MONKEY
	false_report_weight = 1

	required_players = 20
	required_enemies = 1
	recommended_enemies = 1

	restricted_jobs = list("Cyborg", "AI")

	var/carriers_to_make = 1
	var/list/carriers = list()

	var/monkeys_to_win = 1
	var/escaped_monkeys = 0

	var/players_per_carrier = 30


/datum/game_mode/monkey/pre_setup()
	carriers_to_make = max(round(num_players()/players_per_carrier, 1), 1)

	for(var/j = 0, j < carriers_to_make, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/carrier = pick(antag_candidates)
		carriers += carrier
		carrier.special_role = "Monkey Leader"
		carrier.restricted_roles = restricted_jobs
		log_game("[carrier.key] (ckey) has been selected as a Jungle Fever carrier")
		antag_candidates -= carrier

	if(!carriers.len)
		return FALSE
	return TRUE


/datum/game_mode/monkey/announce()
	to_chat(world, "<B>The current game mode is - Monkey!</B>")
	to_chat(world, "<B>One or more crewmembers have been infected with Jungle Fever! Crew: Contain the outbreak. None of the infected monkeys may escape alive to CentCom. Monkeys: Ensure that your kind lives on! Rise up against your captors!</B>")

/datum/game_mode/monkey/post_setup()
	for(var/datum/mind/carriermind in carriers)
		add_monkey_leader(carriermind)
	return ..()

/datum/game_mode/monkey/check_finished()
	if((SSshuttle.emergency.mode == SHUTTLE_ENDGAME) || station_was_nuked)
		return TRUE

	if(!round_converted)
		for(var/datum/mind/monkey_mind in ape_infectees)
			continuous_sanity_checked = TRUE
			if(monkey_mind.current && monkey_mind.current.stat != DEAD)
				return FALSE

		var/datum/disease/D = new /datum/disease/transformation/jungle_fever() //ugly but unfortunately needed
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(!(H.z in GLOB.station_z_levels))
				continue
			if(H.mind && H.client && H.stat != DEAD)
				if(H.HasDisease(D))
					return FALSE

	return ..()

/datum/game_mode/monkey/proc/check_monkey_victory()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return FALSE
	var/datum/disease/D = new /datum/disease/transformation/jungle_fever()
	for(var/mob/living/carbon/monkey/M in GLOB.alive_mob_list)
		if (M.HasDisease(D))
			if(M.onCentCom() || M.onSyndieBase())
				escaped_monkeys++
	if(escaped_monkeys >= monkeys_to_win)
		return TRUE
	else
		return FALSE


/datum/game_mode/monkey/declare_completion()
	if(check_monkey_victory())
		SSticker.mode_result = "win - monkey win"
		to_chat(world, "<span class='userdanger'>The monkeys have overthrown their captors! Eeek eeeek!!</span>")
	else
		SSticker.mode_result = "loss - staff stopped the monkeys"
		to_chat(world, "<span class='userdanger'>The staff managed to contain the monkey infestation!</span>")

/datum/game_mode/monkey/generate_report()
	return "Reports of an ancient [pick("retrovirus", "flesh eating bacteria", "disease", "magical curse blamed on viruses", "banana blight")] outbreak that turn humans into monkeys has been reported in your quadrant.  Any such infections may be treated with banana juice.  If an outbreak occurs, ensure the station is quarantined to prevent a largescale outbreak at CentCom."


/proc/add_monkey(datum/mind/monkey_mind)
	SSticker.mode.ape_infectees |= monkey_mind
	monkey_mind.special_role = "Infected Monkey"

/proc/add_monkey_leader(datum/mind/monkey_mind)
	SSticker.mode.ape_infectees |= monkey_mind
	SSticker.mode.ape_leaders |= monkey_mind
	monkey_mind.special_role = "Monkey Leader"

	var/obj/item/organ/heart/freedom/F = new /obj/item/organ/heart/freedom
	F.Insert(monkey_mind.current, drop_if_replaced = FALSE)


	var/datum/disease/D = new /datum/disease/transformation/jungle_fever
	D.visibility_flags = HIDDEN_SCANNER|HIDDEN_PANDEMIC
	D.affected_mob = monkey_mind.current
	monkey_mind.current.viruses += D

	to_chat(monkey_mind, "<B><span class='notice'>You are the Jungle Fever patient zero!!</B></span>")
	to_chat(monkey_mind, "<b>You have been planted onto this station by the Animal Rights Consortium.</b>")
	to_chat(monkey_mind, "<b>Soon the disease will transform you into an ape. Afterwards, you will be able spread the infection to others with a bite.</b>")
	to_chat(monkey_mind, "<b>While your infection strain is undetectable by scanners, any other infectees will show up on medical equipment.</b>")
	to_chat(monkey_mind, "<b>Your mission will be deemed a success if any of the live infected monkeys reach CentCom.</b>")
	to_chat(monkey_mind, "<b>As an initial infectee, you will be considered a 'leader' by your fellow monkeys.</b>")
	to_chat(monkey_mind, "<b>You can use :k to talk to fellow monkeys!</b>")
	SEND_SOUND(monkey_mind.current, sound('sound/ambience/antag/monkey.ogg'))

/proc/remove_monkey(datum/mind/monkey_mind)
	SSticker.mode.ape_infectees -= monkey_mind
	monkey_mind.special_role = null