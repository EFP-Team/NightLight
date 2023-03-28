/datum/minigames_menu
	var/mob/dead/observer/owner

/datum/minigames_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/minigames_menu/Destroy()
	owner = null
	return ..()

/datum/minigames_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/minigames_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MinigamesMenu")
		ui.open()

/datum/minigames_menu/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("mafia")
			ui.close()
			mafia()
			return TRUE
		if("ctf")
			ui.close()
			ctf()
			return TRUE
		if("basketball")
			ui.close()
			basketball()
			return TRUE

/datum/minigames_menu/proc/mafia()
	var/datum/mafia_controller/game = GLOB.mafia_game //this needs to change if you want multiple mafia games up at once.
	if(!game)
		game = create_mafia_game("mafia")
	game.ui_interact(usr)

/datum/minigames_menu/proc/ctf()
	var/datum/ctf_panel/ctf_panel
	var/datum/ctf_controller/game = GLOB.ctf_games["centcom"] //Attention maintainers, if namelessfairy PRs this and you see this tell them its still here, we already support multiple player CTF, this code cannot exist here, its just here for initial testing.
	if(!game)
		game = create_ctf_game("centcom") //TODO (IMPORTANT) MOVE THIS TO THE MAPLOADING SYSTEM, CTF NEEDS TO KNOW WHAT MAP ITS LOADING AND THATS THE ONLY AREA I CAN PUT IT TO MAKE THIS ACTUALLY PRODUCTIVE, THE VOTING DATUM IS SEPERATE AND WILL JUST HAVE TO STAY THAT WAY
	if(!ctf_panel)
		ctf_panel = new(src)
	ctf_panel.ui_interact(usr)

/datum/minigames_menu/proc/basketball()
	var/datum/basketball_controller/game = GLOB.basketball_game
	if(!game)
		game = create_basketball_game()
	game.ui_interact(usr)
