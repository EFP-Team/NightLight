/*
//////////////////////////////////////

Dizziness

	Hidden.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmittability
	Intense Level.

Bonus
	Shakes the affected mob's screen for short periods.

//////////////////////////////////////
*/

/datum/symptom/dizzy // Not the egg

	name = "Dizziness"
	stealth = 3
	resistance = -1
	stage_speed = -2
	transmittable = 0
	level = 4
	severity = 2

/datum/symptom/dizzy/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				M << "<span class='warning'>[pick("You feel dizzy.", "Your head spins.")]</span>"
			else
				M << "<span class='userdanger'>A wave of dizziness washes over you!</span>"
				M.Dizzy(5)
	return
