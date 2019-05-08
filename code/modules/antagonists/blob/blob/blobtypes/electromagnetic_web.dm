//does burn damage and EMPs, slightly fragile
/datum/blobtype/reagent/electromagnetic_web
	name = "Electromagnetic Web"
	complementary_color = "#EC8383"
	reagent = /datum/reagent/blob/electromagnetic_web

/datum/blobtype/reagent/electromagnetic_web/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage_type == BRUTE) //take full brute
		switch(B.brute_resist)
			if(0.5)
				return damage * 2
			if(0.25)
				return damage * 4
			if(0.1)
				return damage * 10
	return damage * 1.25 //a laser will do 25 damage, which will kill any normal blob

/datum/blobtype/reagent/electromagnetic_web/death_reaction(obj/structure/blob/B, damage_flag)
	if(damage_flag == "melee" || damage_flag == "bullet" || damage_flag == "laser")
		empulse(B.loc, 1, 3) //less than screen range, so you can stand out of range to avoid it

/datum/reagent/blob/electromagnetic_web
	name = "Electromagnetic Web"
	id = "electromagnetic_web"
	taste_description = "pop rocks"
	color = "#83ECEC"

/datum/reagent/blob/electromagnetic_web/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(prob(reac_volume*2))
		M.emp_act(EMP_LIGHT)
	if(M)
		M.apply_damage(reac_volume, BURN)
