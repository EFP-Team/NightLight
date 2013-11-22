/mob/living/simple_animal/tribble
	name = "tribble"
	desc = "It's a small furry creature that makes a soft trill."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "tribble1"
	icon_living = "tribble1"
	icon_dead = "tribble1_dead"
	speak = list("Prrrrr...")
	speak_emote = list("purrs", "trills")
	emote_hear = list("shuffles", "purrs")
	emote_see = list("trundles around", "rolls")
	speak_chance = 10
	turns_per_move = 5
	maxHealth = 10
	health = 10
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "whacks"
	harm_intent_damage = 5
	var/gestation = 0
	var/maxtribbles = 50
	var/list/tribble_list = list()
	wander = 1

/mob/living/simple_animal/tribble/New()
	..()
	var/list/types = list("tribble1","tribble2","tribble3")
	src.icon_state = pick(types)
	src.icon_living = src.icon_state
	src.icon_dead = "[src.icon_state]_dead"
	tribble_list += src

/obj/item/toy/tribble
	name = "tribble"
	desc = "It's a small furry creature that makes a soft trill."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "tribble1"
	item_state = "tribble1"
	var/gestation = 0

/obj/item/toy/tribble/attack_self(mob/user as mob)
	..()
	new /mob/living/simple_animal/tribble(user.loc)
	for(var/mob/living/simple_animal/tribble/T in user.loc)
		T.icon_state = src.icon_state
		T.icon_living = src.icon_state
		T.icon_dead = "[src.icon_state]_dead"
		T.gestation = src.gestation

	user << "<span class='notice'>You place the tribble on the floor.</span>"
	del(src)

/obj/item/toy/tribble/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	..()
	if(istype(O, /obj/item/weapon/scalpel) && src.gestation != null)
		gestation = null
		user << "<span class='notice'>You neuter the tribble so that it can no longer re-produce.</span>"
	else if (istype(O, /obj/item/weapon/cautery) && src.gestation == null)
		gestation = 0
		user << "<span class='notice'>You fuse some recently cut tubes together, it should be able to reproduce again.</span>"

/mob/living/simple_animal/tribble/attack_hand(mob/user as mob)
	..()
	if(src.stat != DEAD)
		new /obj/item/toy/tribble(user.loc)
		for(var/obj/item/toy/tribble/T in user.loc)
			T.icon_state = src.icon_state
			T.item_state = src.icon_state
			T.gestation = src.gestation
			T.pickup(user)
			user.put_in_active_hand(T)
			del(src)

/mob/living/simple_animal/tribble/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/scalpel))
		gestation = null
		user << "<span class='notice'>You try to neuter the tribble so that it can no longer re-produce, but it's moving too much, and you fail!</span>"
	..()


/mob/living/simple_animal/tribble/proc/procreate()
	..()
	var/totaltribbles = 0
	for(var/mob/living/simple_animal/tribble/T in tribble_list)
		if(T.stat == CONSCIOUS && T.health >= 1)
			totaltribbles++
	if(totaltribbles <= maxtribbles)
		for(var/mob/living/simple_animal/tribble/F in src.loc)
			if(!F || F == src)
				new /mob/living/simple_animal/tribble(src.loc)
				gestation = 0


/mob/living/simple_animal/tribble/Life()
	..()
	if(src.health > 0)
		if(gestation != null)
			if(gestation < 30)
				gestation++
			else if(gestation >= 30)
				if(prob(80))
					src.procreate()