// this can go anywhere, probably best in the crates file i guess
/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "What could be inside?"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	var/code = null
	var/lastattempt = null
	var/attempts = 3
	locked = 1
	var/min = 1
	var/max = 10

/obj/structure/closet/crate/secure/loot/New()
	..()
	code = rand(min,max)
	var/loot = rand(1,30)
	switch(loot)
		if(1)	//420 get *burp*
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/rum(src)
			new/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus(src)
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey(src)
			new/obj/item/weapon/lighter/zippo(src)
		if(2)	//useful miner stuff
			new/obj/item/weapon/pickaxe/drill(src)
			new/obj/item/device/taperecorder(src)
			new/obj/item/clothing/suit/space/rig(src)
			new/obj/item/clothing/head/helmet/space/rig(src)
		if(3)	//rich as McNano
			for(var/i = 0, i < 12, i++)
				new/obj/item/weapon/coin/diamond(src)
		if(4)	//Clown's Tomb
			new/mob/living/carbon/monkey(src)
			new/obj/item/clothing/shoes/clown_shoes(src)
			new/obj/item/clothing/under/rank/clown(src)
			new/obj/item/clothing/mask/gas/clown_hat(src)
			new/obj/item/weapon/bananapeel(src)
		if(5)	// HAPPY BIRTHDAY
			for(var/i = 0, i < 6, i++)
				new/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake(src)
			new/obj/item/weapon/lighter/zippo(src)
		if(7)
			new/obj/item/weapon/reagent_containers/glass/beaker/old(src)
		if(9)
			for(var/i = 0, i < 5, i++)
				new/obj/item/weapon/ore/diamond(src)
		if(10)
			for(var/i = 0, i < 5, i++)
				new/obj/item/weapon/ore/clown(src)
		if(11)
			return
		if(12)
			new/obj/item/seeds/deathberryseed(src)
			new/obj/item/seeds/deathnettleseed(src)
		if(13)
			new/obj/machinery/hydroponics(src)
		if(14)
			new/obj/item/seeds/cashseed(src)
		if(15)
			for(var/i = 0, i < 3, i++)
				new/obj/item/weapon/reagent_containers/glass/beaker/noreact(src)
			new/obj/item/weapon/reagent_containers/hypospray(src)
		if(16)
			for(var/i = 0, i < 9, i++)
				new/obj/item/bluespace_crystal(src)
		if(17)
			new/obj/item/mecha_parts/mecha_equipment/weapon/honker(src)
			new/obj/item/mecha_parts/chassis/honker(src)
			new/obj/item/mecha_parts/part/honker_torso(src)
			new/obj/item/mecha_parts/part/honker_head(src)
			new/obj/item/mecha_parts/part/honker_left_arm(src)
		if(18)
			return
		if(19)
			for(var/i = 0, i < 4, i++)
				new/obj/item/weapon/melee/classic_baton(src)
		if(20)
			new/obj/item/weapon/storage/lockbox/clusterbang(src)
		if(21)
			new/obj/item/weapon/aiModule/toyAI(src)
			new/obj/item/weapon/aiModule/robocop(src)
		if(22)
			new/obj/item/weapon/gun/projectile/automatic/silenced(src)
			new/obj/item/clothing/under/chameleon(src)
			for(var/i = 0, i < 7, i++)
				new/obj/item/clothing/tie/horrible(src)
		if(23)
			new/obj/item/clothing/under/shorts(src)
			new/obj/item/clothing/under/shorts/red(src)
			new/obj/item/clothing/under/shorts/blue(src)
		//Dummy crates start here.
		if(24 to 29)
			return
		if(8)
			return
		if(6)
			return
		//Dummy crates end here.
		if(30)
			for(var/i = 0, i < 4, i++)
				new/obj/item/weapon/melee/baton(src)

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user as mob)
	if(locked)
		user << "<span class='notice'>The crate is locked with a H.O.N.K-code lock.</span>"
		var/input = input(usr, "Enter digit from [min] to [max].", "Deca-Code Lock", "") as num
		if(in_range(src, user))
			input = Clamp(input, 1, 10)
			if (input == code)
				user << "<span class='notice'>The crate unlocks!</span>"
				locked = 0
			else if (input == null || input > max || input < min)
				user << "<span class='notice'>You leave the crate alone.</span>"
			else
				user << "<span class='danger'>A red light flashes.</span>"
				lastattempt = input
				attempts--
				if (attempts == 0)
					user << "<span class='danger'>The crate's anti-tamper system activates!</span>"
					var/turf/T = get_turf(src.loc)
					explosion(T, 0, 1, 2, 1)
					del(src)
					return
		else
			user << "<span class='notice'>You attempt to interact with the device using a hand gesture, but it appears this crate is from before the DECANECT came out.</span>"
			return
	else
		return ..()

/obj/structure/closet/crate/secure/loot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(locked)
		if (istype(W, /obj/item/weapon/card/emag))
			user << "<span class='notice'>The crate unlocks!</span>"
			locked = 0
		if (istype(W, /obj/item/device/multitool))
			user << "<span class='notice'>H.O.N.K-CODE LOCK REPORT:</span>"
			if (attempts == 1)
				user << "<span class='danger'>* Anti-Tamper Bomb will activate on next failed access attempt.</span>"
			else
				user << "<span class='notice'>* Anti-Tamper Bomb will activate after [src.attempts] failed access attempts.</span>"
			if (lastattempt == null)
				user << "<span class='notice'> has been made to open the crate thus far.</span>"
				return
			// hot and cold
			if (code > lastattempt)
				user << "<span class='notice'>* Last access attempt lower than expected code.</span>"
			else
				user << "<span class='notice'>* Last access attempt higher than expected code.</span>"
		else ..()
	else ..()
