/obj/effect/proc_holder/alien/hide
	name = "Hide"
	desc = "Allows aliens to hide beneath tables or certain items. Toggled on or off."
	plasma_cost = 0

	action_icon_state = "alien_hide"

/obj/effect/proc_holder/alien/hide/fire(mob/living/carbon/human/species/alien/user)
	if(user.stat != CONSCIOUS)
		return

	if (user.layer != ABOVE_NORMAL_TURF_LAYER)
		user.layer = ABOVE_NORMAL_TURF_LAYER
		user.visible_message(span_name("[user] scurries to the ground!"), \
						span_noticealien("You are now hiding."))
	else
		user.layer = MOB_LAYER
		user.visible_message(span_notice("[user] slowly peeks up from the ground..."), \
					span_noticealien("You stop hiding."))
	return 1


/obj/effect/proc_holder/alien/larva_evolve
	name = "Evolve"
	desc = "Evolve into a higher alien caste."
	plasma_cost = 0

	action_icon_state = "alien_evolve_larva"

/obj/effect/proc_holder/alien/larva_evolve/fire(mob/living/carbon/human/species/alien/user)
	if(!islarva(user))
		return
	var/mob/living/carbon/human/species/alien/larva/L = user

	if(L.handcuffed || L.legcuffed) // Cuffing larvas ? Eh ?
		to_chat(user, span_warning("You cannot evolve when you are cuffed!"))
		return

	if(L.amount_grown >= L.max_grown) //TODO ~Carn
		to_chat(L, span_name("You are growing into a beautiful alien! It is time to choose a caste."))
		to_chat(L, span_info("There are three to choose from:"))
		to_chat(L, span_name("Hunters</span> <span class='info'>are the most agile caste, tasked with hunting for hosts. They are faster than a human and can even pounce, but are not much tougher than a drone."))
		to_chat(L, span_name("Sentinels</span> <span class='info'>are tasked with protecting the hive. With their ranged spit, invisibility, and high health, they make formidable guardians and acceptable secondhand hunters."))
		to_chat(L, span_name("Drones</span> <span class='info'>are the weakest and slowest of the castes, but can grow into a praetorian and then queen if no queen exists, and are vital to maintaining a hive with their resin secretion abilities."))
		var/alien_caste = tgui_alert(L, "Please choose which alien caste you shall belong to.",,list("Hunter","Sentinel","Drone"))

		if(L.movement_type & VENTCRAWLING)
			to_chat(user, span_warning("You cannot evolve while ventcrawling!"))
			return

		if(user.incapacitated()) //something happened to us while we were choosing.
			return

		var/mob/living/carbon/human/species/alien/new_xeno
		switch(alien_caste)
			if("Hunter")
				new_xeno = new /mob/living/carbon/human/species/alien/hunter(L.loc)
			if("Sentinel")
				new_xeno = new /mob/living/carbon/human/species/alien/sentinel(L.loc)
			if("Drone")
				new_xeno = new /mob/living/carbon/human/species/alien/drone(L.loc)

		L.alien_evolve(new_xeno)
		return
	else
		to_chat(user, span_warning("You are not fully grown!"))
		return
