
////////////////
// BASE TYPE ///
////////////////

//Do not spawn
/mob/living/simple_animal/hostile/infection
	icon = 'icons/mob/blob.dmi'
	pass_flags = PASSBLOB
	faction = list(ROLE_INFECTION)
	bubble_icon = "blob"
	speak_emote = null //so we use verb_yell/verb_say/etc
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 360
	unique_name = 1
	a_intent = INTENT_HARM
	stat_attack = DEAD
	var/can_cross_beacons = FALSE
	var/mob/camera/commander/overmind = null
	var/obj/structure/infection/factory/factory = null

/mob/living/simple_animal/hostile/infection/Initialize(mapload, owner_overmind)
	. = ..()
	verbs -= /mob/living/verb/pulled
	if(!can_cross_beacons)
		AddComponent(/datum/component/no_beacon_crossing)

/mob/living/simple_animal/hostile/infection/update_icons()
	if(overmind)
		add_atom_colour(overmind.infection_color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/hostile/infection/Destroy()
	if(overmind)
		overmind.infection_mobs -= src
	return ..()

/mob/living/simple_animal/hostile/infection/blob_act(obj/structure/infection/I)
	if(stat != DEAD && health < maxHealth)
		for(var/i in 1 to 2)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(src)) //hello yes you are being healed
			if(overmind)
				H.color = overmind.color
			else
				H.color = "#000000"
		adjustHealth(-maxHealth*0.0125)

/mob/living/simple_animal/hostile/infection/fire_act(exposed_temperature, exposed_volume)
	..()
	if(istype(src, /mob/living/simple_animal/hostile/infection/infectionspore/sentient))
		return
	if(exposed_temperature)
		adjustFireLoss(CLAMP(0.01 * exposed_temperature, 1, 5))
	else
		adjustFireLoss(5)

/mob/living/simple_animal/hostile/infection/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/structure/infection) || istype(mover, /obj/item/projectile/bullet/infection))
		return 1
	return ..()

/mob/living/simple_animal/hostile/infection/Process_Spacemove(movement_dir = 0)
	for(var/obj/structure/infection/I in range(1, src))
		return 1
	return ..()

/mob/living/simple_animal/hostile/infection/proc/infection_chat(msg)
	var/spanned_message = say_quote(msg, get_spans())
	var/rendered = "<font color=\"#EE4000\"><b>\[Infection Telepathy\] [real_name]</b> [spanned_message]</font>"
	for(var/M in GLOB.mob_list)
		if(iscommander(M) || isinfectionmonster(M))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

/////////////////////
// INFECTION SPORE //
/////////////////////

/mob/living/simple_animal/hostile/infection/infectionspore
	name = "infection spore"
	desc = "A floating, fragile spore."
	icon_state = "blobpod"
	icon_living = "blobpod"
	health = 30
	maxHealth = 30
	verb_say = "psychically pulses"
	verb_ask = "psychically probes"
	verb_exclaim = "psychically yells"
	verb_yell = "psychically screams"
	melee_damage_lower = 2
	melee_damage_upper = 4
	obj_damage = 20
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attacktext = "hits"
	attack_sound = 'sound/weapons/genhit1.ogg'
	movement_type = FLYING
	del_on_death = 1
	deathmessage = "dissapates in the atmosphere!"
	var/mob/living/carbon/human/oldguy
	var/is_zombie = 0

/mob/living/simple_animal/hostile/infection/infectionspore/Initialize(mapload, var/obj/structure/infection/factory/linked_node, commander)
	if(istype(linked_node))
		factory = linked_node
		factory.spores += src
	if(commander)
		overmind = commander
	. = ..()

/mob/living/simple_animal/hostile/infection/infectionspore/Life()
	update_icons()
	if(!is_zombie && isturf(src.loc))
		for(var/mob/living/carbon/human/H in view(src,1)) //Only for corpse right next to/on same tile
			if(H.stat == DEAD)
				Zombify(H)
				break
	if(factory && z != factory.z)
		death()
	..()

/mob/living/simple_animal/hostile/infection/infectionspore/proc/Zombify(mob/living/carbon/human/H)
	is_zombie = 1
	if(H.wear_suit)
		var/obj/item/clothing/suit/armor/A = H.wear_suit
		maxHealth += A.armor.melee //That zombie's got armor, I want armor!
	maxHealth += 40
	health = maxHealth
	name = "infection zombie"
	desc = "A shambling corpse animated by the infection."
	mob_biotypes += MOB_HUMANOID
	melee_damage_lower += 8
	melee_damage_upper += 11
	movement_type = GROUND
	icon = H.icon
	icon_state = "zombie"
	H.hair_style = null
	H.update_hair()
	H.forceMove(src)
	oldguy = H
	update_icons()
	visible_message("<span class='warning'>The corpse of [H.name] suddenly rises!</span>")

/mob/living/simple_animal/hostile/infection/infectionspore/death(gibbed)
	if(factory)
		factory.spore_delay = world.time + factory.spore_cooldown //put the factory on cooldown
	..()

/mob/living/simple_animal/hostile/infection/infectionspore/Destroy()
	if(factory)
		factory.spores -= src
	factory = null
	if(oldguy)
		oldguy.forceMove(get_turf(src))
		oldguy = null
	return ..()

/mob/living/simple_animal/hostile/infection/infectionspore/update_icons()
	if(overmind)
		add_atom_colour(overmind.color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
	if(is_zombie)
		copy_overlays(oldguy, TRUE)
		var/mutable_appearance/infection_head_overlay = mutable_appearance('icons/mob/blob.dmi', "blob_head")
		if(overmind)
			infection_head_overlay.color = overmind.color
		color = initial(color)//looks better.
		add_overlay(infection_head_overlay)

/mob/living/simple_animal/hostile/infection/infectionspore/weak
	name = "fragile blob spore"
	health = 15
	maxHealth = 15
	melee_damage_lower = 1
	melee_damage_upper = 2