/obj/item/device/meeseeks_box
	name = "Meeseeks Box"
	desc = "A blue box with a button on top. You hear a faint voice from inside desperate to help you."
	icon = 'icons/obj/objects.dmi'
	icon_state = "meeseeks_box"
	origin_tech = "programming=2;materials=3;bluespace=4"
	var/meeseeks = null  //The Meeseeks spawned from this box
	var/datum/species/golem/meeseeks/SM //the species of the meeseeks
	var/request = "Nothing"     //The Law passed on to the Meeseeks

/obj/item/device/meeseeks_box/New()    //Doesn't do anything for now
	return



/obj/item/device/meeseeks_box/attack_self(mob/user)
	var/time_passed = world.time
	if(!meeseeks)

		//var/list/candidates = get_candidates(BE_PAI)
		var/list/mob/dead/observer/candidates = list()
		var/mob/dead/observer/C = null

		for(var/mob/dead/observer/G in player_list)
			if(!jobban_isbanned(G, "pAI") && !jobban_isbanned(G, "posibrain"))
				spawn(0)
					switch(alert(G, "Do you wish to become Mr. Meeseeks and fulfill a task?","Please answer in 30 seconds!","Yes","No"))
						if("Yes")
							if((world.time-time_passed)>300)//If more than 30 game seconds passed.
								return
							candidates += G
						if("No")
							return
						else
							return

		if(candidates.len)
			C = pick(candidates)
			var/mob/living/carbon/human/M = new /mob/living/carbon/human
			hardset_dna(M, null, null, null, null, /datum/species/golem/meeseeks)
			M.set_cloned_appearance()
			M.real_name = text("Mr. Meeseeks ([rand(1, 1000)])")
			M.dna.species.auto_equip(M)
			M.loc = user.loc
			M.key = C.key
			meeseeks = M //store the meeseeks, so we can delete it later
			SM = M.dna.species
			SM.master = user

			playsound(loc, 'sound/voice/meeseeks/meeseeksspawn.ogg', 40, 0, 1)
			request = input("How should Mr. Meeseeks help you today?")
			playsound(loc, 'sound/voice/meeseeks/cando.ogg', 40, 0, 1)

			M << "<span class='notice'>Your master, [user] has given you a command:"
			M << "<span class='notice'><b> [request].</b>"
			M << "<span class='notice'>Try to accomplish it as fast as possible!</span>"
			M.mind.store_memory("Your master has given you this command:")
			M.mind.store_memory("[request]")

		else
			usr << "<span class='notice'>The box is silent. Maybe you should try again in a few minutes.</span>"


	else
		usr << "<span class='notice'>A Mr. Meeseeks has already left this box!</span>"
		switch(alert(user, "Do you wish to send Mr.Meeseeks away?","Mr. Meeseeks dismissal.","Yes","No"))
			if("Yes")
				if(SM.stage<3)
					SM.master = null
					meeseeks = null
					request = "Nothing"
					usr << "<span class='notice'>The box makes a weird pop sound and Mr. Meeseeks is gone.</span>"
				else
					usr << "<span class='danger'>Mr. Meeseeks is too desperate! He can't go away!</span>"
			if("No")
				return
			else
				return

