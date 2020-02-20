/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/dualsaber
	icon = 'icons/obj/transforming_energy.dmi'
	icon_state = "dualsaber0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/w_class_on = WEIGHT_CLASS_BULKY
	hitsound = "swing_hit"
	armour_penetration = 35
	var/saber_color = "green"
	light_color = "#00ff00"//green
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 75
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70)
	resistance_flags = FIRE_PROOF
	var/hacked = FALSE
	var/brightness_on = 6 //TWICE AS BRIGHT AS A REGULAR ESWORD
	var/list/possible_colors = list("red", "blue", "green", "purple")

/obj/item/dualsaber/ComponentInitialize()
	. = ..()
	add_twohanded_comp()

/obj/item/dualsaber/proc/add_twohanded_comp()
	AddComponent(/datum/component/two_handed, force_unwielded=3, force_wielded=34, , \
					iconstate_wielded="dualsaber[saber_color]1", iconstate_unwielded="dualsaber0", \
					wieldsound='sound/weapons/saberon.ogg', unwieldsound='sound/weapons/saberoff.ogg')

/obj/item/dualsaber/suicide_act(mob/living/carbon/user)
	if(SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_WIELDED))
		user.visible_message("<span class='suicide'>[user] begins spinning way too fast! It looks like [user.p_theyre()] trying to commit suicide!</span>")

		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)//stole from chainsaw code
		var/obj/item/organ/brain/B = user.getorganslot(ORGAN_SLOT_BRAIN)
		B.organ_flags &= ~ORGAN_VITAL	//this cant possibly be a good idea
		var/randdir
		for(var/i in 1 to 24)//like a headless chicken!
			if(user.is_holding(src))
				randdir = pick(GLOB.alldirs)
				user.Move(get_step(user, randdir),randdir)
				user.emote("spin")
				if (i == 3 && myhead)
					myhead.drop_limb()
				sleep(3)
			else
				user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
				return OXYLOSS

	else
		user.visible_message("<span class='suicide'>[user] begins beating [user.p_them()]self to death with \the [src]'s handle! It probably would've been cooler if [user.p_they()] turned it on first!</span>")
	return BRUTELOSS

/obj/item/dualsaber/Initialize()
	. = ..()
	if(LAZYLEN(possible_colors))
		saber_color = pick(possible_colors)
		switch(saber_color)
			if("red")
				light_color = LIGHT_COLOR_RED
			if("green")
				light_color = LIGHT_COLOR_GREEN
			if("blue")
				light_color = LIGHT_COLOR_LIGHT_CYAN
			if("purple")
				light_color = LIGHT_COLOR_LAVENDER

/obj/item/dualsaber/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/dualsaber/attack(mob/target, mob/living/carbon/human/user)
	if(user.has_dna())
		if(user.dna.check_mutation(HULK))
			to_chat(user, "<span class='warning'>You grip the blade too hard and accidentally close it!</span>")
			if(SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_WIELDED))
				SEND_SIGNAL(src, COMSIG_TRY_TWOHANDED_UNWIELD, user)
				return
	..()
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_WIELDED) && prob(40))
		impale(user)
		return
	if(SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_WIELDED) && prob(50))
		INVOKE_ASYNC(src, .proc/jedi_spin, user)

/obj/item/dualsaber/proc/jedi_spin(mob/living/user)
	dance_rotate(user, CALLBACK(user, /mob.proc/dance_flip))

/obj/item/dualsaber/proc/impale(mob/living/user)
	to_chat(user, "<span class='warning'>You twirl around a bit before losing your balance and impaling yourself on [src].</span>")
	if(SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_WIELDED))
		user.take_bodypart_damage(20,25,check_armor = TRUE)
	else
		user.adjustStaminaLoss(25)

/obj/item/dualsaber/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_WIELDED))
		return ..()
	return 0

// Specific hulk checks due to reflection chance for balance issues and switches hitsounds.
/obj/item/dualsaber/attack_self(mob/living/carbon/user)
	if(user && user.has_dna())
		if(user.dna.check_mutation(HULK))
			to_chat(user, "<span class='warning'>You lack the grace to wield this!</span>")
			return
	..()
	if(SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_WIELDED))
		sharpness = IS_SHARP
		w_class = w_class_on
		hitsound = 'sound/weapons/blade1.ogg'
		START_PROCESSING(SSobj, src)
		set_light(brightness_on)
	else
		unwield()

/obj/item/dualsaber/equipped(mob/user, slot)
	. = ..()
	if(!SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_WIELDED))
		unwield()

/obj/item/dualsaber/dropped(mob/user)
	. = ..()
	unwield()

// switch hitsounds
/obj/item/dualsaber/proc/unwield()
	sharpness = initial(sharpness)
	w_class = initial(w_class)
	hitsound = "swing_hit"
	STOP_PROCESSING(SSobj, src)
	set_light(0)

/obj/item/dualsaber/process()
	if(SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_WIELDED))
		if(hacked)
			light_color = pick(LIGHT_COLOR_RED, LIGHT_COLOR_GREEN, LIGHT_COLOR_LIGHT_CYAN, LIGHT_COLOR_LAVENDER)
		open_flame()
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/dualsaber/IsReflect()
	if(SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_WIELDED))
		return 1

/obj/item/dualsaber/ignition_effect(atom/A, mob/user)
	// same as /obj/item/melee/transforming/energy, mostly
	if(!SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_WIELDED))
		return ""
	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask)
			in_mouth = ", barely missing [user.p_their()] nose"
	. = "<span class='warning'>[user] swings [user.p_their()] [name][in_mouth]. [user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [A.name] in the process.</span>"
	playsound(loc, hitsound, get_clamped_volume(), TRUE, -1)
	add_fingerprint(user)
	// Light your candles while spinning around the room
	INVOKE_ASYNC(src, .proc/jedi_spin, user)

/obj/item/dualsaber/green
	possible_colors = list("green")

/obj/item/dualsaber/red
	possible_colors = list("red")

/obj/item/dualsaber/blue
	possible_colors = list("blue")

/obj/item/dualsaber/purple
	possible_colors = list("purple")

/obj/item/dualsaber/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!hacked)
			hacked = TRUE
			to_chat(user, "<span class='warning'>2XRNBW_ENGAGE</span>")
			saber_color = "rainbow"
			add_twohanded_comp()
			update_icon()
		else
			to_chat(user, "<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")
	else
		return ..()
