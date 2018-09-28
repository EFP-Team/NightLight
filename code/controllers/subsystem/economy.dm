SUBSYSTEM_DEF(economy)
	name = "Economy"
	wait = 5 MINUTES
	init_order = INIT_ORDER_ECONOMY
	runlevels = RUNLEVEL_GAME
	var/roundstart_paychecks = 5
	var/initial_station_budget = 20000
	var/department_budget_pool = 28000
	var/datum/bank_account/department/station/station_budget
	var/list/department_accounts = list(ACCOUNT_CIV = ACCOUNT_CIV_NAME,
										ACCOUNT_ENG = ACCOUNT_ENG_NAME,
										ACCOUNT_SCI = ACCOUNT_SCI_NAME,
										ACCOUNT_MED = ACCOUNT_MED_NAME,
										ACCOUNT_SRV = ACCOUNT_SRV_NAME,
										ACCOUNT_CAR = ACCOUNT_CAR_NAME,
										ACCOUNT_SEC = ACCOUNT_SEC_NAME)
	var/list/generated_accounts = list()
	var/full_ancap = FALSE // Enables extra money charges for things that normally would be free, such as sleepers/cryo/cloning.
							//Take care when enabling, as players will NOT respond well if the economy is set up for low cash flows.
				
	//How the periodic station budget is automatically distributed - Modifiable by an accounting console
	var/list/income_distribution = list()
	var/starting_station_tax = 30 //Percentage of income remaining on the station's account at roundstart
										
	var/base_station_income = 15000
	var/next_income_bonus = 0 //Gives extra credits on the next station pay cycle, modified by external factors (bounties etc.)
	var/last_income = 15000 //Used for accounting consoles to track last income
	var/datum/station_state/engineering_check = new /datum/station_state()
	var/alive_humans_bounty = 100 //Credits given for every living human on station
	var/mood_bounty = 100	//Credits given for every happy human on station
	var/crew_safety_bounty = 1500 //Bounty for keeping people alive, multiplied by the current survival rate
	var/sensors_bounty = 150	//Humans detected in suit sensor network
	var/crew_sensors_bounty = 250 //Registered crew in suit sensor network
	var/surveillance_bounty = 200 	//Crew with location tracking in suit sensor network
	var/techweb_coeff = 0.05		//Point to credits ratio for researched nodes
	var/list/bank_accounts = list()
	var/list/dep_cards = list()

/datum/controller/subsystem/economy/Initialize(timeofday)
	station_budget = new(null, initial_station_budget)
	income_distribution[station_budget.department_id] = starting_station_tax
	var/budget_to_hand_out = round(department_budget_pool / department_accounts.len)
	for(var/A in department_accounts)
		var/datum/bank_account/department/D = new(A, budget_to_hand_out)
		income_distribution[D.department_id] = (100 - starting_station_tax) / department_accounts.len
	return ..()

/datum/controller/subsystem/economy/fire(resumed = 0)
	var/centcomm_fund = base_station_income
	centcomm_fund += maintenance_bonus()  //Bonus for keeping the station intact.
	centcomm_fund += research_bonus() //Bonus for researched nodes.
	centcomm_fund += crew_status_bonus() //Bonus based on crew safety, health, and mood.
	centcomm_fund += crew_monitor_bonus() //Bonus for tracking people with sensors/nanites.
	centcomm_fund += next_income_bonus
	last_income = centcomm_fund
	next_income_bonus = 0
	
	distribute_income()
	for(var/A in bank_accounts)
		var/datum/bank_account/B = A
		B.payday(1)

/datum/controller/subsystem/economy/proc/distribute_income(income)
	station_budget.adjust_money(income * income_distribution[station_budget.department_id])
	for(var/X in generated_accounts)
		var/datum/bank_account/department/B = X
		B.adjust_money(income * income_distribution[B.department_id])	

//Change a department's income distribution. The remaining income is given to the station's account.
/datum/controller/subsystem/economy/proc/change_distribution(datum/bank_account/department/D, new_value)
	var/set_value = CLAMP(Round(new_value), 0, 100)
	var/current_value = income_distribution[D.department_id]
	if(D == station_budget) //This is what's left, and isn't modified directly
		return FALSE
	if(set_value == current_value) //that was easy
		return TRUE
	else if(set_value < current_value)
		var/difference = current_value - set_value
		income_distribution[D.department_id] -= difference
		income_distribution[station_budget.department_id] += difference
		return TRUE
	else
		var/difference = set_value - current_value
		if(income_distribution[station_budget.department_id] >= difference)
			income_distribution[D.department_id] += difference
			income_distribution[station_budget.department_id] -= difference
			return TRUE
		else
			return FALSE //out of budget
		
/datum/controller/subsystem/economy/proc/get_dep_account(dep_id)
	for(var/datum/bank_account/department/D in generated_accounts)
		if(D.department_id == dep_id)
			return D

/datum/controller/subsystem/economy/proc/maintenance_bonus()
	var/engineering_cash = 3000
	engineering_check.count()
	var/station_integrity = min(PERCENT(GLOB.start_state.score(engineering_check)), 100)
	station_integrity *= 0.01
	engineering_cash *= station_integrity
	return engineering_cash

/datum/controller/subsystem/economy/proc/crew_status_bonus()
	var/crew
	var/alive_crew
	var/cash_to_grant = 0
	for(var/mob/m in GLOB.mob_list)
		if(isnewplayer(m))
			continue
		if(m.mind)
			if(isbrain(m) || iscameramob(m))
				continue
			if(ishuman(m))
				var/mob/living/carbon/human/H = m
				crew++
				if(H.stat != DEAD)
					alive_crew++
					GET_COMPONENT_FROM(mood, /datum/component/mood, H)
					var/medical_cash = (H.health / H.maxHealth) * alive_humans_bounty
					if(mood)
						var/mood_dosh = (mood.mood_level / 9) * mood_bounty
						cash_to_grant += mood_dosh
						medical_cash *= (mood.sanity / 100)
					cash_to_grant += medical_cash
		CHECK_TICK
	var/aliveness = alive_crew / crew
	cash_to_grant += (crew_safety_bounty * aliveness)
	return cash_to_grant
	
/datum/controller/subsystem/economy/proc/crew_monitor_bonus()
	var/cash_to_grant = 0
	var/list/crew_list = list()
	for(var/Z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		crew_list += GLOB.crewmonitor.update_data(Z)
	
	for(var/list/crewmember in crew_list)
		var/cash_value = 0
		if(crewmember["life_status"])
			cash_value += sensors_bounty
			if(crewmember["assignment"] && crewmember["ijob"] < 70) //Only counts real, non centcomm jobs
				cash_value += crew_sensors_bounty
			if(crewmember["can_track"])
				cash_value += surveillance_bounty
		cash_to_grant += cash_value
	return cash_to_grant

/datum/controller/subsystem/economy/proc/research_bonus()
	var/science_bounty = 0
	for(var/X in SSresearch.science_tech.researched_nodes)
		var/value = 0
		var/datum/techweb_node/TN = X
		for(var/Y in TN.research_costs)
			value += (Y * techweb_coeff) //100 per 2000 research points spent
		science_bounty += value
	return science_bounty