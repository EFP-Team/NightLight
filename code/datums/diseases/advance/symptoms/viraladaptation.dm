/*
//////////////////////////////////////
Viral adaptation

	Moderate stealth boost.
	Major Increases to resistance.
	Reduces stage speed.
	No change to transmission
	Critical Level.

BONUS
	Extremely useful for buffing viruses

//////////////////////////////////////
*/

/datum/symptom/viraladaptation

	name = "Viral self-adaptation"
	stealth = 3
	resistance = 5
	stage_speed = -3
	transmittable = 0
	level = 3

/datum/symptom/youth/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1)
				H << "<span class='notice'>You feel off, but no different from before.</span>"
			if(5)
				H << "<span class='notice'>You feel better, but nothing interesting happens.</span>"

	return