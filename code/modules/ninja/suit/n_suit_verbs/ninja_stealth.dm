
/*

Contents:
- Stealth Verbs
- Stealth Icon Stuff

*/


/obj/item/clothing/suit/space/space_ninja/proc/toggle_stealth()
	var/mob/living/carbon/human/U = affecting
	if(!U)
		return
	if(s_active)
		cancel_stealth()
	else
		if(cell.charge <= 0)
			U << "<span class='warning'>You don't have enough power to enable Stealth!</span>"
			return
		s_active=!s_active
		animate(U, U.alpha = 0,time = 15)
		U.visible_message("<span class='warning'>[U.name] vanishes into thin air!</span>", \
						"<span class='notice'>You are now invisible to normal detection.</span>")
	return


/obj/item/clothing/suit/space/space_ninja/proc/cancel_stealth()
	var/mob/living/carbon/human/U = affecting
	if(!U)
		return 0
	if(s_active)
		s_active=!s_active
		animate(U, U.alpha = 255, time = 15)
		U.visible_message("<span class='warning'>[U.name] appears from thin air!</span>", \
						"<span class='notice'>You are now visible.</span>")
		return 1
	return 0


/obj/item/clothing/suit/space/space_ninja/proc/stealth()
	set name = "Toggle Stealth"
	set desc = "Utilize the internal CLOAK-tech device to activate or deactivate stealth-camo."
	set category = "Ninja Equip"

	if(!s_busy)
		toggle_stealth()
	else
		affecting << "<span class='danger'>Stealth does not appear to work!</span>"


//When ninja steal malfunctions.
/mob/proc/NinjaStealthMalf()
	invisibility = 0//Set ninja invis to 0.
	overlays += image("icon"='icons/effects/effects.dmi',"icon_state" ="electricity","layer" = layer+0.9)
	playsound(loc, 'sound/effects/stealthoff.ogg', 75, 1)


