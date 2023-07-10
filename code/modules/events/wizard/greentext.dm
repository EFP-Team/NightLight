/datum/round_event_control/wizard/greentext //Gotta have it!
	name = "Greentext"
	weight = 4
	typepath = /datum/round_event/wizard/greentext
	max_occurrences = 1
	earliest_start = 0 MINUTES
	description = "The Green Text appears on the station, tempting people to try and pick it up."
	min_wizard_trigger_potency = 5
	max_wizard_trigger_potency = 7

/datum/round_event/wizard/greentext/start()

	var/list/holder_canadates = GLOB.player_list.Copy()
	for(var/mob/M in holder_canadates)
		if(!ishuman(M))
			holder_canadates -= M
	if(!holder_canadates) //Very unlikely, but just in case
		return FALSE

	var/mob/living/carbon/human/H = pick(holder_canadates)
	new /obj/item/greentext(H.loc)
	to_chat(H, "<font color='green'>The mythical greentext appear at your feet! Pick it up if you dare...</font>")


/obj/item/greentext
	name = "greentext"
	desc = "No one knows what this massive tome does, but it feels <i><font color='green'>desirable</font></i> all the same..."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/obj/wizard.dmi'
	icon_state = "greentext"
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	///The last person to touch the greentext, used for failures.
	var/mob/living/last_holder
	///The current holder of the greentext.
	var/mob/living/new_holder
	///Every person who has touched the greentext, having their colors changed by it.
	var/list/color_altered_mobs
	///The callback at the end of a round to check if the greentext has been completed.
	var/datum/callback/roundend_callback
	///Boolean on whether to announce the greentext's destruction to all mobs.
	var/quiet = FALSE

/obj/item/greentext/quiet
	quiet = TRUE

/obj/item/greentext/Initialize(mapload)
	. = ..()
	SSpoints_of_interest.make_point_of_interest(src)
	roundend_callback = CALLBACK(src, PROC_REF(check_winner))
	SSticker.OnRoundend(roundend_callback)

/obj/item/greentext/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	to_chat(user, span_green("So long as you leave this place with greentext in hand you know will be happy..."))
	var/list/other_objectives = user.mind.get_all_objectives()
	if(user.mind && other_objectives.len > 0)
		to_chat(user, span_warning("... so long as you still perform your other objectives that is!"))
	new_holder = user
	if(!last_holder)
		last_holder = user
	if(!HAS_TRAIT(user, TRAIT_GREENTEXT_CURSED))
		LAZYOR(color_altered_mobs, WEAKREF(user))
		ADD_TRAIT(user, TRAIT_GREENTEXT_CURSED, REF(src))
	user.add_atom_colour("#00ff00", ADMIN_COLOUR_PRIORITY)
	START_PROCESSING(SSobj, src)

/obj/item/greentext/dropped(mob/user, silent = FALSE)
	if(HAS_TRAIT(user, TRAIT_GREENTEXT_CURSED))
		to_chat(user, span_warning("A sudden wave of failure washes over you..."))
		user.add_atom_colour("#ff0000", ADMIN_COLOUR_PRIORITY) //ya blew it
	STOP_PROCESSING(SSobj, src)
	last_holder = null
	new_holder = null
	return ..()

/obj/item/greentext/process()
	if(last_holder && last_holder != new_holder) //Somehow it was swiped without ever getting dropped
		to_chat(last_holder, span_warning("A sudden wave of failure washes over you..."))
		last_holder.add_atom_colour("#ff0000", ADMIN_COLOUR_PRIORITY)
		last_holder = new_holder //long live the king

/obj/item/greentext/Destroy(force)
	LAZYREMOVE(SSticker.round_end_events, roundend_callback)
	QDEL_NULL(roundend_callback) //This ought to free the callback datum, and prevent us from harddeling
	INVOKE_ASYNC(src, PROC_REF(release_victims), color_altered_mobs)
	return ..()

/obj/item/greentext/proc/release_victims()
	var/list/victims = list()
	for (var/datum/weakref/player_ref as anything in color_altered_mobs)
		var/mob/player_mob = player_ref.resolve()
		if (player_mob)
			victims += player_mob

	var/list/announce_list = quiet ? victims : GLOB.player_list
	for(var/mob/player as anything in announce_list)
		var/list/messages = list(span_warning("A dark temptation has passed from this world!"))
		if(HAS_TRAIT(player, TRAIT_GREENTEXT_CURSED))
			messages += span_green("You're finally able to forgive yourself...")
		to_chat(player, messages.Join("\n"))
	for(var/mob/player as anything in victims)
		REMOVE_TRAIT(player, TRAIT_GREENTEXT_CURSED, REF(src))
		if (!HAS_TRAIT(player, TRAIT_GREENTEXT_CURSED))
			player.remove_atom_colour(ADMIN_COLOUR_PRIORITY)


/obj/item/greentext/proc/check_winner()
	if(!new_holder)
		return
	if(!is_centcom_level(new_holder.z)) //you're winner!
		return

	to_chat(new_holder, "<font color='green'>At last it feels like victory is assured!</font>")
	new_holder.mind.add_antag_datum(/datum/antagonist/greentext)
	new_holder.log_message("won with greentext!!!", LOG_ATTACK, color = "green")
	LAZYREMOVE(color_altered_mobs, WEAKREF(new_holder))
	REMOVE_TRAIT(new_holder, TRAIT_GREENTEXT_CURSED, REF(src))
	resistance_flags |= ON_FIRE
	qdel(src)
