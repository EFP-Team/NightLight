// Admin Tab - Fun Verbs

ADMIN_CONTEXT_ENTRY(context_atom_explosion, "Explosion", R_ADMIN, atom/target as obj|mob|turf in world)
	var/devastation = input("Range of total devastation. -1 to none", text("Input"))  as num|null
	if(devastation == null)
		return
	var/heavy = input("Range of heavy impact. -1 to none", text("Input"))  as num|null
	if(heavy == null)
		return
	var/light = input("Range of light impact. -1 to none", text("Input"))  as num|null
	if(light == null)
		return
	var/flash = input("Range of flash. -1 to none", text("Input"))  as num|null
	if(flash == null)
		return
	var/flames = input("Range of flames. -1 to none", text("Input"))  as num|null
	if(flames == null)
		return

	if ((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1) || (flames != -1))
		if ((devastation > 20) || (heavy > 20) || (light > 20) || (flames > 20))
			if (tgui_alert(usr, "Are you sure you want to do this? It will laaag.", "Confirmation", list("Yes", "No")) == "No")
				return

		explosion(O, devastation, heavy, light, flames, flash, explosion_cause = mob)
		log_admin("[key_name(usr)] created an explosion ([devastation],[heavy],[light],[flames]) at [AREACOORD(O)]")
		message_admins("[key_name_admin(usr)] created an explosion ([devastation],[heavy],[light],[flames]) at [AREACOORD(O)]")

ADMIN_CONTEXT_ENTRY(context_atom_emp, "EM Pulse", R_ADMIN, atom/target as obj|mob|turf in world)
	var/heavy = input("Range of heavy pulse.", text("Input"))  as num|null
	if(heavy == null)
		return
	var/light = input("Range of light pulse.", text("Input"))  as num|null
	if(light == null)
		return

	if (heavy || light)
		empulse(O, heavy, light)
		log_admin("[key_name(usr)] created an EM Pulse ([heavy],[light]) at [AREACOORD(O)]")
		message_admins("[key_name_admin(usr)] created an EM Pulse ([heavy],[light]) at [AREACOORD(O)]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "EM Pulse") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_CONTEXT_ENTRY(context_mob_gib, "Gib", R_ADMIN, mob/victim in GLOB.mob_list)
	var/confirm = tgui_alert(usr, "Drop a brain?", "Confirm", list("Yes", "No","Cancel"))
	if(confirm == "Cancel")
		return
	//Due to the delay here its easy for something to have happened to the mob
	if(!victim)
		return

	log_admin("[key_name(usr)] has gibbed [key_name(victim)]")
	message_admins("[key_name_admin(usr)] has gibbed [key_name_admin(victim)]")

	if(isobserver(victim))
		new /obj/effect/gibspawner/generic(get_turf(victim))
		return

	var/mob/living/living_victim = victim
	if (istype(living_victim))
		living_victim.investigate_log("has been gibbed by an admin.", INVESTIGATE_DEATHS)
		if(confirm == "Yes")
			living_victim.gib()
		else
			living_victim.gib(TRUE)

ADMIN_VERB(fun, gibself, "", R_ADMIN)
	if(!isliving(usr))
		to_chat(usr, span_warning("You must be alive to use this!"))
		return

	var/confirm = tgui_alert(usr, "You sure?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes")
		return

	log_admin("[key_name(usr)] used gibself.")
	message_admins(span_adminnotice("[key_name_admin(usr)] used gibself."))
	var/mob/living/ourself = usr
	ourself.gib(TRUE, TRUE, TRUE)

ADMIN_VERB(fun, make_everyone_random, "Make everyone have a random appearance. You can only use this before rounds!", R_FUN)
	if(SSticker.HasRoundStarted())
		to_chat(usr, "Nope you can't do this, the game's already started. This only works before rounds!")
		return

	var/frn = CONFIG_GET(flag/force_random_names)
	if(frn)
		CONFIG_SET(flag/force_random_names, FALSE)
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.")
		to_chat(usr, "Disabled.", confidential = TRUE)
		return

	var/notifyplayers = tgui_alert(usr, "Do you want to notify the players?", "Options", list("Yes", "No", "Cancel"))
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] has forced the players to have random appearances.")

	if(notifyplayers == "Yes")
		to_chat(world, span_adminnotice("Admin [usr.key] has forced the players to have completely random identities!"), confidential = TRUE)

	to_chat(usr, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.", confidential = TRUE)
	CONFIG_SET(flag/force_random_names, TRUE)

ADMIN_VERB(fun, mass_zombie_infection, "Infects all humans with a latent organ that will zombify them upon death", R_FUN)
	var/confirm = tgui_alert(usr, "Please confirm you want to add latent zombie organs in all humans?", "Confirm Zombies", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/mob/living/carbon/human/crewman as anything in GLOB.human_list)
		new /obj/item/organ/internal/zombie_infection/nodamage(crewman)

	message_admins("[key_name_admin(usr)] added a latent zombie infection to all humans.")
	log_admin("[key_name(usr)] added a latent zombie infection to all humans.")

// Infecting everyone needs R_FUN, but curing only needs R_ADMIN
ADMIN_VERB(fun, mass_zombie_cure, "Removes the admin zombie infection from all humans, returning them to normal", R_ADMIN)
	var/confirm = tgui_alert(usr, "Please confirm you want to cure all zombies?", "Confirm Zombie Cure", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/obj/item/organ/internal/zombie_infection/nodamage/organ in GLOB.zombie_infection_list)
		qdel(organ)

	message_admins("[key_name_admin(usr)] cured all zombies.")
	log_admin("[key_name(usr)] cured all zombies.")

ADMIN_VERB(fun, polymorph_all_mobs, "This will prove to be a terrible idea", R_FUN)
	var/confirm = tgui_alert(usr, "Please confirm you want polymorph all mobs?", "Confirm Polymorph", list("Yes", "No"))
	if(confirm != "Yes")
		return

	var/who_did_it = key_name_admin(usr)
	message_admins("[who_did_it)] started polymorphed all living mobs.")
	log_admin("[key_name(usr)] polymorphed all living mobs.")
	for(var/mob/living/wabbajee in shuffle(mobs))
		CHECK_TICK

		if(!wabbajee)
			continue

		wabbajee.audible_message(span_hear("...wabbajack...wabbajack..."))
		playsound(wabbajee.loc, 'sound/magic/staff_change.ogg', 50, TRUE, -1)

		wabbajee.wabbajack()

	message_admins("Mass polymorph started by [who_did_it] is complete.")

ADMIN_VERB(fun, smite, "Begone thot", (R_ADMIN|R_FUN), mob/living/victim as mob in view())
	var/punishment = input("Choose a punishment", "DIVINE SMITING") as null|anything in GLOB.smites

	if(QDELETED(target) || !punishment)
		return

	var/smite_path = GLOB.smites[punishment]
	var/datum/smite/smite = new smite_path
	var/configuration_success = smite.configure(usr)
	if (configuration_success == FALSE)
		return
	smite.effect(usr.client, target)

///"Turns" people into bread. Really, we just add them to the contents of the bread food item.
/proc/breadify(atom/movable/target)
	var/obj/item/food/bread/plain/smite/tomb = new(get_turf(target))
	target.forceMove(tomb)
	target.AddComponent(/datum/component/itembound, tomb)

/**
 * firing_squad is a proc for the :B:erforate smite to shoot each individual bullet at them, so that we can add actual delays without sleep() nonsense
 *
 * Hilariously, if you drag someone away mid smite, the bullets will still chase after them from the original spot, possibly hitting other people. Too funny to fix imo
 *
 * Arguments:
 * * target- guy we're shooting obviously
 * * source_turf- where the bullet begins, preferably on a turf next to the target
 * * body_zone- which bodypart we're aiming for, if there is one there
 * * wound_bonus- the wounding power we're assigning to the bullet, since we don't care about the base one
 * * damage- the damage we're assigning to the bullet, since we don't care about the base one
 */
/proc/firing_squad(mob/living/carbon/target, turf/source_turf, body_zone, wound_bonus, damage)
	if(!target.get_bodypart(body_zone))
		return
	playsound(target, 'sound/weapons/gun/revolver/shot.ogg', 100)
	var/obj/projectile/bullet/smite/divine_wrath = new(source_turf)
	divine_wrath.damage = damage
	divine_wrath.wound_bonus = wound_bonus
	divine_wrath.original = target
	divine_wrath.def_zone = body_zone
	divine_wrath.spread = 0
	divine_wrath.preparePixelProjectile(target, source_turf)
	divine_wrath.fire()

/client/proc/punish_log(whom, punishment)
	var/msg = "[key_name_admin(src)] punished [key_name_admin(whom)] with [punishment]."
	message_admins(msg)
	admin_ticket_log(whom, msg)
	log_admin("[key_name(src)] punished [key_name(whom)] with [punishment].")
