/datum/disease/fake_gbs
	name = "GBS"
	max_stages = 5
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Synaptizine & Sulfur"
	cures = list("synaptizine","sulfur")
	agent = "Gravitokinetic Bipotential SADS-"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	desc = "If left untreated death will occur."
	severity = BIOHAZARD

/datum/disease/fake_gbs/stage_act()
	..()
	switch(stage)
		if(2)
			if(SSrng.probability(1))
				affected_mob.emote("sneeze")
		if(3)
			if(SSrng.probability(5))
				affected_mob.emote("cough")
			else if(SSrng.probability(5))
				affected_mob.emote("gasp")
			if(SSrng.probability(10))
				to_chat(affected_mob, "<span class='danger'>You're starting to feel very weak...</span>")
		if(4)
			if(SSrng.probability(10))
				affected_mob.emote("cough")

		if(5)
			if(SSrng.probability(10))
				affected_mob.emote("cough")
