/mob/living/silicon/pai
	name = "pAI"
	var/network = "SS13"
	var/obj/machinery/camera/current = null
	icon = 'icons/mob/pai.dmi'
	icon_state = "repairbot"
	mouse_opacity = 1
	density = 0
	ventcrawler = 2
	luminosity = 0
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	desc = "A generic pAI mobile hard-light holographics emitter. It seems to be deactivated."
	weather_immunities = list("ash")
	health = 500
	maxHealth = 500

	var/ram = 100	// Used as currency to purchase different abilities
	var/list/software = list()
	var/userDNA		// The DNA string of our assigned user
	var/obj/item/device/paicard/card	// The card we inhabit

	var/speakStatement = "states"
	var/speakExclamation = "declares"
	var/speakDoubleExclamation = "alarms"
	var/speakQuery = "queries"

	var/obj/item/weapon/pai_cable/cable		// The cable we produce and use when door or camera jacking

	var/master				// Name of the one who commands us
	var/master_dna			// DNA string for owner verification

	var/silence_time			// Timestamp when we were silenced (normally via EMP burst), set to null after silence has faded

// Various software-specific vars

	var/temp				// General error reporting text contained here will typically be shown once and cleared
	var/screen				// Which screen our main window displays
	var/subscreen			// Which specific function of the main screen is being displayed

	var/obj/item/device/pda/ai/pai/pda = null

	var/secHUD = 0			// Toggles whether the Security HUD is active or not
	var/medHUD = 0			// Toggles whether the Medical  HUD is active or not

	var/datum/data/record/medicalActive1		// Datacore record declarations for record software
	var/datum/data/record/medicalActive2

	var/datum/data/record/securityActive1		// Could probably just combine all these into one
	var/datum/data/record/securityActive2

	var/obj/machinery/door/hackdoor		// The airlock being hacked
	var/hackprogress = 0				// Possible values: 0 - 100, >= 100 means the hack is complete and will be reset upon next check

	var/obj/item/radio/integrated/signal/sradio // AI's signaller

	var/holoform = FALSE
	var/canholo = TRUE
	var/obj/item/weapon/card/id/access_card = null
	var/chassis = "repairbot"
	var/list/possible_chassis = list("cat", "mouse", "monkey", "corgi", "fox", "repairbot")

	var/emitterhealth = 50
	var/emittermaxhealth = 50
	var/emitterregen = 1
	var/emittercd = 10
	var/emittersemicd = FALSE

	var/overload_ventcrawl = 0
	var/overload_bulletblock = 0	//Why is this a good idea?
	var/overload_maxhealth = 0
	canmove = FALSE

/mob/living/silicon/pai/Destroy()
	pai_list -= src
	..()

/mob/living/silicon/pai/New(var/obj/item/device/paicard/P)
	START_PROCESSING(SSfastprocess, src)
	pai_list += src
	make_laws()
	canmove = 0
	if(!istype(P)) //when manually spawning a pai, we create a card to put it into.
		var/newcardloc = P
		P = new /obj/item/device/paicard(newcardloc)
		P.setPersonality(src)
	loc = P
	card = P
	sradio = new(src)
	if(!radio)
		radio = new /obj/item/device/radio/borg(src)

	//PDA
	pda = new(src)
	spawn(5)
		pda.ownjob = "pAI Messenger"
		pda.owner = text("[]", src)
		pda.name = pda.owner + " (" + pda.ownjob + ")"

	..()

	var/datum/action/innate/pai/shell/AS = new /datum/action/innate/pai/shell
	var/datum/action/innate/pai/chassis/AC = new /datum/action/innate/pai/chassis
	var/datum/action/innate/pai/rest/AR = new /datum/action/innate/pai/rest
	AS.Grant(src)
	AC.Grant(src)
	AR.Grant(src)


/mob/living/silicon/pai/proc/pai_ui_action(action)
	if(istype(action, /datum/action/innate/pai/shell))
		if(holoform)
			fold_in(0)
		else
			fold_out()
	if(istype(action, /datum/action/innate/pai/chassis))
		choose_chassis()
	if(istype(action, /datum/action/innate/pai/rest))
		lay_down()

/mob/living/silicon/pai/make_laws()
	laws = new /datum/ai_laws/pai()
	return TRUE

/mob/living/silicon/pai/Login()
	..()
	usr << browse_rsc('html/paigrid.png')			// Go ahead and cache the interface resources as early as possible
	if(client)
		client.perspective = EYE_PERSPECTIVE
		if(holoform)
			client.eye = src
		else
			client.eye = card

/mob/living/silicon/pai/Stat()
	..()
	if(statpanel("Status"))
		if(src.silence_time)
			var/timeleft = round((silence_time - world.timeofday)/10 ,1)
			stat(null, "Communications system reboot in -[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")
		if(!src.stat)
			stat(null, text("System integrity: [(src.health+100)/2]%"))
		else
			stat(null, text("Systems nonfunctional"))

/mob/living/silicon/pai/restrained(ignore_grab)
	. = FALSE

// See software.dm for Topic()

/mob/living/silicon/pai/canUseTopic(atom/movable/M)
	return TRUE

/mob/living/silicon/pai/process()
	emitterhealth = Clamp((emitterhealth + emitterregen), -50, emittermaxhealth)

/mob/proc/makePAI(delold)
	var/obj/item/device/paicard/card = new /obj/item/device/paicard(get_turf(src))
	var/mob/living/silicon/pai/pai = new /mob/living/silicon/pai(card)
	pai.key = src.key
	pai.name = src.name
	card.setPersonality(pai)
	if(delold)
		qdel(src)

/datum/action/innate/pai/Trigger()
	if(ispAI(owner))
		var/mob/living/silicon/pai/P = owner
		P.pai_ui_action(src)

/datum/action/innate/pai/shell
	name = "Toggle Holoform"
	button_icon_state = "pai_holoform"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/chassis
	name = "Holochassis Appearence Composite"
	button_icon_state = "pai_chassis"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/rest
	name = "Rest"
	button_icon_state = "pai_rest"
	background_icon_state = "bg_tech"
