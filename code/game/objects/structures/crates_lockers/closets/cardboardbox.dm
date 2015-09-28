/obj/structure/closet/cardboard
	name = "large cardboard box"
	desc = "Just a box..."
	icon_state = "cardboard"
	health = 10
	mob_storage_capacity = 1
	burntime = 20
	can_weld_shut = 0
	cutting_tool = /obj/item/weapon/wirecutters
	open_sound = 'sound/effects/rustle2.ogg'
	cutting_sound = 'sound/items/poster_ripped.ogg'
	material_drop = /obj/item/stack/sheet/cardboard
	var/move_delay = 0
	var/egg_cooldown = 0

/obj/structure/closet/cardboard/initialize()
	if(prob(10))
		var/summon_path = pick(/obj/item/clothing/head/collectable/bandana, /obj/item/clothing/under/sneaking_suit, /obj/item/clothing/mask/cigarette/cigar, /obj/item/robot_parts/l_arm)
		new summon_path(src)
	..()

/obj/structure/closet/cardboard/relaymove(mob/user, direction)
	if(opened || move_delay || user.stat || user.stunned || user.weakened || user.paralysis || !isturf(loc) || !has_gravity(loc))
		return
	step(src, direction)
	move_delay = 1
	spawn(config.walk_speed)
		move_delay = 0

/obj/structure/closet/cardboard/open()
	if(opened || !can_open())
		return 0
	if(!egg_cooldown)
		var/mob/living/Snake = null
		for(var/mob/living/L in src.contents)
			Snake = L
			break
		if(Snake)
			var/list/alerted = viewers(7,src)
			if(alerted)
				for(var/mob/living/L in alerted)
					if(!L.stat)
						L.do_alert_animation(L)
				alerted << sound('sound/machines/chime.ogg')
				egg_cooldown = 1
				spawn(3000)
					egg_cooldown = 0
	..()

/mob/living/proc/do_alert_animation(atom/A)
	var/image/I
	I = image('icons/obj/closet.dmi', A, "cardboard_special", A.layer+1)
	var/list/viewing = list()
	for(var/mob/M in viewers(A))
		if(M.client)
			viewing |= M.client
	flick_overlay(I,viewing,8)
	I.alpha = 0
	animate(I, pixel_z = 32, alpha = 255, time = 5, easing = ELASTIC_EASING)
