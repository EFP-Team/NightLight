/*
/client/verb/sim_donate()
	set name = "Simulate donation"

	var/ckey = input("Ckey") as text
	var/money = input("Money") as num
	GLOB.donations.money[ckey] = money
	GLOB.donations.money_max[ckey] = money
	return
*/

GLOBAL_DATUM_INIT(donations, /datum/donations, new)

/proc/LoadDonators()
	if(!GLOB.donations)
		GLOB.donations = new
	GLOB.donations.load_donators()
	return GLOB.donations.money.len

/datum/donations
	var/list/donat_categoryes = list()
	var/list/money = list()
	var/list/money_max = list()
	var/donation_cached = ""

	New()
		build_prizes_list()

	proc/show(var/mob/user)
		if(!user.ckey || !user.client)
			return

		var/current_money = (user.ckey in money) ? money[user.ckey] : "0"
		var/max_money = (user.ckey in money_max) ? money_max[user.ckey] : "0"

		var/dat = "<title>Donator panel</title>"
		dat += "You have [current_money]/[max_money] points<br>"
		usr << browse(dat+donation_cached, "window=donatorpanel;size=250x400")

	Topic(href, href_list)
		var/datum/donat_stuff/item = locate(href_list["item"])
		if(!istype(item))
			return
		var/mob/living/carbon/human/user = usr
		var/ckey = user.ckey
		if(!istype(user) || user.stat)
			return

		var/current_money = money[ckey]
		var/list/slots = list (
			"backpack" = slot_in_backpack,
			"left pocket" = slot_l_store,
			"right pocket" = slot_r_store
		)

		if(item.cost > current_money)
			user << "<span class='warning'>You don't have enough points.</span>"
			return 0

		money[ckey] = max(0, current_money - item.cost)

		var/obj/spawned = new item.path
		var/where = user.equip_in_one_of_slots(spawned, slots, del_on_fail=0)

		if (!where)
			spawned.loc = user.loc
			user << "<span class='info'>Your [spawned.name] has been spawned!</span>"
		else
			user << "<span class='info'>Your [spawned.name] has been spawned in your [where]!</span>"

		show(user)

	proc/load_donators()
		money.Cut()
		money_max.Cut()
		var/DBConnection/dbcon2 = new()
		dbcon2.Connect("dbi:mysql:forum2:[sqladdress]:[sqlport]","[sqlfdbklogin]","[sqlfdbkpass]")

		if(!dbcon2.IsConnected())
			world.log << "Failed to connect to database [dbcon2.ErrorMsg()] in load_donators()."
			return 0

		var/DBQuery/query = dbcon2.NewQuery("SELECT byond,sum FROM Z_donators")
		query.Execute()
		while(query.NextRow())
			var/ckey  = ckey(query.item[1])
			var/money = round(text2num(query.item[2]))
			money[ckey] = money
			money_max[ckey] = money
		dbcon2.Disconnect()
		return 1

	proc/build_prizes_list()
		for(var/path in subtypesof(/datum/donat_stuff))
			var/datum/donat_stuff/T = path
			if(!initial(T.name))
				continue
			T = new path
			if(!donat_categoryes[T.category])
				donat_categoryes[T.category] = list()
			donat_categoryes[T.category] += T

		donation_cached = null
		var/list/dat = list()
		for(var/cur_cat in donat_categoryes)
			dat += "<hr><b>[cur_cat]</b><br>"
			for(var/datum/donat_stuff/item in donat_categoryes[cur_cat])
				dat += "<a href='?src=\ref[src];item=\ref[item]'>[item.name] : [item.cost]</a><br>"
		donation_cached = jointext(dat, null)

/client
	var/next_donat_check = null

/client/verb/cmd_donator_panel()
	set name = "Donator panel"
	set category = "OOC"

	if(world.time < next_donat_check)
		return
	next_donat_check = world.time + 5


	if(!ishuman(mob))
		alert("Donat stuff only allowed for humans!")
		return

	GLOB.donations.show(mob)