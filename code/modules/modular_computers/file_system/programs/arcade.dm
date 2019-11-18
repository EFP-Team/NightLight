/datum/computer_file/program/arcade
	filename = "arcade"
	filedesc = "Nanotransen Micro Arcade"
	ui_header = "smmon_0.gif"
	program_icon_state = "arcade"
	extended_desc = "This port of the classic game 'Outbomb Cuban Pete', redesigned to run on tablets, with thrilling graphics and chilling storytelling."
	requires_ntnet = FALSE
	network_destination = "arcade network"
	size = 6
	tgui_id = "ntos_arcade"
	ui_x = 600
	ui_y = 400

	var/game_active = TRUE //Checks to see if a game is in progress.
	var/pause_state = FALSE //This disables buttons in order to prevent multiple actions before the opponent's actions.
	var/boss_hp = 45
	var/boss_mp = 15
	var/player_hp = 30
	var/player_mp = 10
	var/ticket_count = 0
	var/heads_up = "Nanotrasen says, winners make us money."//Shows the active display text for the app

/datum/computer_file/program/arcade/proc/game_check(mob/user)
	sleep(5)
	if(boss_hp <= 0)
		heads_up = "You have crushed the forces of evil! Rejoyce!"
		playsound(computer.loc, 'sound/arcade/win.ogg', 50, TRUE, extrarange = -3, falloff = 10)
		game_active = 0
		program_icon_state = "arcade_off"
		if(istype(computer))
			computer.update_icon()
		ticket_count += 1
		sleep(10)
		return
	else if(player_hp <= 0 || player_mp <= 0)
		heads_up = "You have been defeated... how will the station survive?"
		playsound(computer.loc, 'sound/arcade/lose.ogg', 50, TRUE, extrarange = -3, falloff = 10)
		game_active = 0
		program_icon_state = "arcade_off"
		if(istype(computer))
			computer.update_icon()
		sleep(10)
		return
	return

/datum/computer_file/program/arcade/proc/enemy_check(mob/user)
	var/boss_attackamt = 0 //Spam protection from boss attacks as well.
	var/boss_mpamt = 0
	var/bossheal = 0
	if(pause_state == FALSE)
		boss_attackamt = rand(3,6)
		boss_mpamt = rand (2,4)
		bossheal = rand (4,6)
	if(game_active == 0)
		return
	if (boss_mp <= 5)
		heads_up = "[boss_mpamt] magic power has been stolen from you!"
		playsound(computer.loc, 'sound/arcade/steal.ogg', 50, TRUE, extrarange = -3, falloff = 10)
		player_mp -= boss_mpamt
		boss_mp += boss_mpamt
		game_check()
		return
	else if(boss_mp > 5 && boss_hp <12)
		heads_up = "The evil guy heals for [bossheal] health!"
		playsound(computer.loc, 'sound/arcade/heal.ogg', 50, TRUE, extrarange = -3, falloff = 10)
		boss_hp += bossheal
		boss_mp -= boss_mpamt
		game_check()
		return
	else
		heads_up = "The mean guy slams you for [boss_attackamt]!"
		playsound(computer.loc, 'sound/arcade/hit.ogg', 50, TRUE, extrarange = -3, falloff = 10)
		player_hp -= boss_attackamt
		game_check()
		return
	return

/datum/computer_file/program/arcade/ui_data(mob/user)
	var/list/data = get_header_data()

	data["Hitpoints"] = boss_hp
	data["PlayerHitpoints"] = player_hp
	data["PlayerMP"] = player_mp
	data["TicketCount"] = ticket_count
	data["Name"] = "[user.name] the guy"
	data["GameActive"] = game_active
	data["PauseState"] = pause_state
	data["Status"] = heads_up
	return data

/datum/computer_file/program/arcade/ui_act(action, params, mob/user)
	if(..())
		return TRUE
	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	switch(action)
		if("Attack")
			var/attackamt = 0 //Spam prevention.
			if(pause_state == FALSE)
				attackamt = rand(2,6)
			pause_state = TRUE
			heads_up = "You attack for [attackamt] damage."
			playsound(computer.loc, 'sound/arcade/hit.ogg', 50, TRUE, extrarange = -3, falloff = 10)
			boss_hp -= attackamt
			sleep(10)
			game_check()
			enemy_check()
			pause_state = FALSE
			return TRUE
		if("Heal")
			var/healamt = 0 //More Spam Prevention.
			var/healcost = 0
			if(pause_state == FALSE)
				healamt = rand(6,8)
				healcost = rand(1,3)
			pause_state = TRUE
			heads_up = "You heal for [healamt] damage."
			playsound(computer.loc, 'sound/arcade/heal.ogg', 50, TRUE, extrarange = -3, falloff = 10)
			player_hp += healamt
			player_mp -= healcost
			sleep(10)
			game_check()
			enemy_check()
			pause_state = FALSE
			return TRUE
		if("Recharge_Power")
			var/rechargeamt = 0 //As above.
			if(pause_state == FALSE)
				rechargeamt = rand(4,7)
			pause_state = TRUE
			heads_up = "You regain [rechargeamt] magic power."
			playsound(computer.loc, 'sound/arcade/mana.ogg', 50, TRUE, extrarange = -3, falloff = 10)
			player_mp += rechargeamt
			sleep(10)
			game_check()
			enemy_check()
			pause_state = FALSE
			return TRUE
		if("Dispense_Tickets")
			if(!printer)
				to_chat(usr, "<span class='notice'>Hardware error: A printer is required to redeem tickets.</span>")
				return
			if(printer.stored_paper <= 0)
				to_chat(usr, "<span class='notice'>Hardware error: Printer is out of paper.</span>")
				return
			else
				computer.visible_message("<span class='notice'>\The [computer] prints out paper.</span>")
				if(ticket_count >= 1)
					new /obj/item/stack/arcadeticket((get_turf(computer)), 1)
					to_chat(user, "<span class='notice'>[src] dispenses a ticket!</span>")
					ticket_count -= 1
					printer.stored_paper -= 1
				else
					to_chat(user, "<span class='notice'>You don't have any stored tickets!</span>")
				return TRUE
		if("Start_Game")
			game_active = 1
			boss_hp = 45
			player_hp = 30
			player_mp = 10
			heads_up = "GAME START"
			program_icon_state = "arcade"
			if(istype(computer))
				computer.update_icon()
