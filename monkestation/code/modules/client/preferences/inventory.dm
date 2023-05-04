/datum/preferences/proc/load_inventory(ckey)
	if(!ckey || !SSdbcore.IsConnected())
		return
	var/datum/db_query/query_gear = SSdbcore.NewQuery(
		"SELECT item_id,amount FROM [format_table_name("metacoin_item_purchases")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!query_gear.Execute())
		qdel(query_gear)
		return
	while(query_gear.NextRow())
		var/key = query_gear.item[1]
		inventory += text2path(key)
	qdel(query_gear)


/datum/preferences/proc/load_metacoins(ckey)
	if(!ckey || !SSdbcore.IsConnected())
		metacoins = 5000
		return
	var/datum/db_query/query_get_metacoins = SSdbcore.NewQuery("SELECT metacoins FROM [format_table_name("player")] WHERE ckey = '[ckey]'")
	var/mc_count = 0
	if(query_get_metacoins.warn_execute())
		if(query_get_metacoins.NextRow())
			mc_count = query_get_metacoins.item[1]

	qdel(query_get_metacoins)
	metacoins = text2num(mc_count)


/datum/preferences/proc/adjust_metacoins(ckey, amount, reason = null, announces =TRUE, donator_multipler = TRUE)
	set waitfor = FALSE

	if(!ckey || !SSdbcore.IsConnected())
		return FALSE

	var/datum/db_query/query_inc_metacoins = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET metacoins = metacoins + '[amount]' WHERE ckey = '[ckey]'")
	query_inc_metacoins.warn_execute()

	if(amount > 0 && donator_multipler)
		switch(parent.patreon.access_rank)
			if(ACCESS_COMMAND_RANK)
				amount *= 1.5
			if(ACCESS_TRAITOR_RANK)
				amount *= 1.75
			if(ACCESS_NUKIE_RANK)
				amount *= 2

	amount = round(amount, 1)
	metacoins += amount
	qdel(query_inc_metacoins)
	if(announces)
		if(reason)
			to_chat(parent, "<span class='rose bold'>[abs(amount)] Monkecoins have been [amount >= 0 ? "deposited to" : "withdrawn from"] your account! Reason: [reason]</span>")
		else
			to_chat(parent, "<span class='rose bold'>[abs(amount)] Monkecoins have been [amount >= 0 ? "deposited to" : "withdrawn from"] your account!</span>")
	return TRUE

/datum/preferences/proc/has_coins(amount)
	if(amount > metacoins)
		return FALSE
	return TRUE
