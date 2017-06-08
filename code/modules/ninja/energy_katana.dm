/obj/item/weapon/dash
	name = "energy katana"
	var/max_charges = 3
	var/current_charges = 3
	var/charge_rate = 30 //In deciseconds
	var/dash_toggled = FALSE

/obj/item/weapon/dash/proc/charge()
	current_charges = Clamp(current_charges + 1, 0, max_charges)
	if(istype(loc, /mob/living))
		to_chat(loc, "<span class='notice'>[src] now has [current_charges]/[max_charges] charges.</span>")

/obj/item/weapon/dash/attack_self(mob/user)
	dash_toggled = !dash_toggled
	if(dash_toggled)
		to_chat(loc, "<span class='notice'>[src] is now in dash mode.</span>")
	else
		to_chat(loc, "<span class='notice'>You disable the dash function on [src].</span>")

/obj/item/weapon/dash/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(dash_toggled)
		dash(user, target)
		return

/obj/item/weapon/dash/proc/dash(mob/user, atom/target)
	if(!current_charges)
		return

	if(isliving(target))
		return

	if(target.density)
		return

	var/turf/T = get_turf(target)
	if(target in view(user.client.view, get_turf(user)))
		var/obj/spot1 = new /obj/effect/temp_visual/dir_setting/ninja/phase/out(get_turf(user), user.dir)
		user.forceMove(T)
		playsound(T, 'sound/magic/blink.ogg', 25, 1)
		playsound(T, "sparks", 50, 1)
		var/obj/spot2 = new /obj/effect/temp_visual/dir_setting/ninja/phase(get_turf(user), user.dir)
		var/chain = spot1.Beam(spot2,"blur",time=15)
		current_charges--
		addtimer(CALLBACK(src, .proc/charge), charge_rate)
		sleep(2)
		qdel(spot1)
		qdel(spot2)
		qdel(chain)


/obj/item/weapon/dash/energy_katana
	name = "energy katana"
	desc = "A katana infused with strong energy."
	icon_state = "energy_katana"
	item_state = "energy_katana"
	force = 40
	throwforce = 20
	armour_penetration = 50
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 50
	sharpness = IS_SHARP
	obj_integrity = 200
	max_integrity = 200
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/datum/effect_system/spark_spread/spark_system

/obj/item/weapon/dash/energy_katana/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(dash_toggled)
		..()
	else
		if(proximity_flag)
			if(isobj(target) || issilicon(target))
				spark_system.start()
				playsound(user, "sparks", 50, 1)
				playsound(user, 'sound/weapons/blade1.ogg', 50, 1)
				target.emag_act(user)


//If we hit the Ninja who owns this Katana, they catch it.
//Works for if the Ninja throws it or it throws itself or someone tries
//To throw it at the ninja
/obj/item/weapon/dash/energy_katana/throw_impact(atom/hit_atom)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		if(istype(H.wear_suit, /obj/item/clothing/suit/space/space_ninja))
			var/obj/item/clothing/suit/space/space_ninja/SN = H.wear_suit
			if(SN.energyKatana == src)
				returnToOwner(H, 0, 1)
				return

	..()

/obj/item/weapon/dash/energy_katana/proc/returnToOwner(mob/living/carbon/human/user, doSpark = 1, caught = 0)
	if(!istype(user))
		return
	forceMove(get_turf(user))

	if(doSpark)
		spark_system.start()
		playsound(get_turf(src), "sparks", 50, 1)

	var/msg = ""

	if(user.put_in_hands(src))
		msg = "Your Energy Katana teleports into your hand!"
	else if(user.equip_to_slot_if_possible(src, slot_belt, 0, 1, 1))
		msg = "Your Energy Katana teleports back to you, sheathing itself as it does so!</span>"
	else
		msg = "Your Energy Katana teleports to your location!"

	if(caught)
		if(loc == user)
			msg = "You catch your Energy Katana!"
		else
			msg = "Your Energy Katana lands at your feet!"

	if(msg)
		to_chat(user, "<span class='notice'>[msg]</span>")

/obj/item/weapon/dash/energy_katana/New()
	..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/weapon/dash/energy_katana/Destroy()
	qdel(spark_system)
	spark_system = null
	return ..()