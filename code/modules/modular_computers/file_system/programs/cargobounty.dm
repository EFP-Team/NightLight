/datum/computer_file/program/bounty
	filename = "bounty"
	filedesc = "Nanotrasen Bounty Application"
	program_icon_state = "bounty"
	extended_desc = "A basic interface for supply personnel to check and claim bounties."
	requires_ntnet = TRUE
	transfer_access = ACCESS_CARGO
	network_destination = "cargo claims interface"
	size = 10
	tgui_id = "NtosBountyConsole"
	ui_x = 750
	ui_y = 600
	///cooldown var for printing paper sheets.
	var/printer_ready = 0
	///The cargo account for grabbing the cargo account's credits.
	var/static/datum/bank_account/cargocash

/datum/computer_file/program/bounty/proc/print_paper()
	new /obj/item/paper/bounty_printout(get_turf(computer))

/datum/computer_file/program/bounty/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	if(!GLOB.bounties_list.len)
		setup_bounties()
	printer_ready = world.time + PRINTER_TIMEOUT
	cargocash = SSeconomy.get_dep_account(ACCOUNT_CAR)
	. = ..()

/datum/computer_file/program/bounty/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/bountyinfo = list()
	for(var/datum/bounty/B in GLOB.bounties_list)
		bountyinfo += list(list("name" = B.name, "description" = B.description, "reward_string" = B.reward_string(), "completion_string" = B.completion_string() , "claimed" = B.claimed, "priority" = B.high_priority, "bounty_ref" = REF(B)))
	data["stored_cash"] = cargocash.account_balance
	data["bountydata"] = bountyinfo
	return data

/datum/computer_file/program/bounty/ui_act(action,params)
	if(..())
		return
	var/datum/bounty/cashmoney = locate(params["bounty"]) in GLOB.bounties_list
	switch(action)
		if("ClaimBounty")
			if(cashmoney)
				cashmoney.claim()
			return
		if("Print")
			if(printer_ready < world.time)
				printer_ready = world.time + PRINTER_TIMEOUT
				print_paper()
				return
	. = TRUE
