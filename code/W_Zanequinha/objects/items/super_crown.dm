 obj/item/zaneq/supercrown
	name = "Super Crown"
	desc = "Genderbend time!"
	icon_state = "super_crown"

	proc/femininify(var/mob/living/M)
		if(!isliving(M))
			return
		if(M.gender && M.gender == MALE)
			M.visible_message("<span class='notice'>\The [M] starts to get feminine!.</span>")
			sleep(10)
			M.gender = FEMALE
			if(ishuman(M))
				M.replace_identification_name(M.name,(M.name += "ette!"))
				M.name = M.name += "ette!"
				M.regenerate_icons()
			del src
		else
			to_chat(M, "<span class='warning'>The crown only works on males!</span>")
			..()

/obj/item/zaneq/supercrown/attack_self(mob/user)
	femininify(user)
	..()

/obj/item/zaneq/supercrown/attack(mob/living/carbon/M, mob/living/carbon/user)
	femininify(M)
	..()