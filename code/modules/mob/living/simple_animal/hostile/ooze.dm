///Oozes are slime-esque creatures unlike xenobio slimes that feed off of a lot of things.
/mob/living/simple_animal/hostile/ooze
	name = "Ooze"
	icon = 'icons/mob/vatgrowing.dmi'
	icon_state = "gelatinous"
	icon_dead = "gelatinous_dead"
	mob_biotypes = MOB_ORGANIC
	pass_flags = PASSTABLE | PASSGRILLE
	ventcrawler = VENTCRAWLER_ALWAYS
	gender = NEUTER
	emote_see = list("jiggles", "bounces in place")
	speak_emote = list("blorbles")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	hud_type = /datum/hud/ooze
	//minbodytemp = 250
	//maxbodytemp = 350
	//healable = FALSE

	//speak_chance = 0
	//maxHealth = 100
	//health = 100

	//harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	//attack_verb_continuous = "bites"
	//attack_verb_simple = "bite"
	//attack_sound = 'sound/hallucinations/growl1.ogg'
	a_intent = INTENT_HARM

	///Oozes have their own nutrition. Changes based on them eating
	var/ooze_nutrition = 50
	var/ooze_nutrition_loss = 0.15
	var/ooze_metabolism_modifier = 2

/mob/living/simple_animal/hostile/ooze/Initialize()
	. = ..()
	create_reagents(300)

/mob/living/simple_animal/hostile/ooze/attacked_by(obj/item/I, mob/living/user)
	if(!check_edible(I))
		return ..()
	eat_atom(I)

/mob/living/simple_animal/hostile/ooze/AttackingTarget(atom/A)
	. = ..()
	if(!check_edible(A))
		return ..()
	eat_atom(A)

///Handles nutrition gain/loss of mob and also makes it take damage if it's too low on nutrition, only happens for sentient mobs.
/mob/living/simple_animal/hostile/ooze/Life()
	. = ..()

	if(!mind)//no mind no change
		return

	var/nutrition_change

	//Eat a bit of all the reagents we have. Gaining nutrition for actual nutritional ones.
	for(var/i in reagents.reagent_list)
		var/datum/reagent/R = i
		var/consumption_amount = min(reagents.get_reagent_amount(R.type), ooze_metabolism_modifier * REAGENTS_METABOLISM)
		if(istype(R, /datum/reagent/consumable))
			var/datum/reagent/consumable/consumable = R
			nutrition_change += consumption_amount * consumable.nutriment_factor
		reagents.remove_reagent(R.type, consumption_amount)
	nutrition_change -= 0.15
	adjust_ooze_nutrition(nutrition_change)

	if(ooze_nutrition <= 0)
		adjustBruteLoss(0.5)

///Returns whether or not the supplied movable atom is edible.
/mob/living/simple_animal/hostile/ooze/proc/check_edible(atom/movable/AM)
	if(ismob(AM))
		return FALSE
	var/foodtype
	if(istype(AM, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/meal = AM
		foodtype = meal.foodtype
	return foodtype & MEAT //Dont forget to add edible component compat here later

///Does ooze_nutrition + supplied amount and clamps it within 0 and 500
/mob/living/simple_animal/hostile/ooze/proc/adjust_ooze_nutrition(amount)
	ooze_nutrition = clamp(ooze_nutrition + amount, 0, 500)
	updateNutritionDisplay()

///Tries to transfer the atoms reagents then delete it
/mob/living/simple_animal/hostile/ooze/proc/eat_atom(obj/item/A)
	A.reagents.trans_to(src, A.reagents.total_volume, transfered_by = src)
	src.visible_message("<span class='warning>[src] eats [A]!</span>", "<span class='notice'>You eat [A].</span>")
	playsound(loc,'sound/items/eatfood.ogg', rand(30,50), TRUE)
	qdel(A)

///Updates the display that shows the mobs nutrition
/mob/living/simple_animal/hostile/ooze/proc/updateNutritionDisplay()
	if(hud_used) //clientless oozes
		hud_used.alien_plasma_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='green'>[round(ooze_nutrition)]</font></div>"


///* Gelatinious Ooze code below *\\\\


///Child of the ooze mob which is fast and is more suited for assassin esque behavior.
/mob/living/simple_animal/hostile/ooze/gelatinous
	name = "Gelatinous Cube"
	desc = "It's a gummy cube, it's a gummy cube, it's a gummy gummy gummy gummy gummy cube."
	speed = 1
	///The ability to give yourself a metabolic speed boost which raises heat
	var/datum/action/cooldown/metabolicboost/boost
	///The ability to consume mobs
	var/datum/action/consume/consume

///Initializes the mobs abilities and gives them to the mob
/mob/living/simple_animal/hostile/ooze/gelatinous/Initialize()
	. = ..()
	boost = new
	boost.Grant(src)
	consume = new
	consume.Grant(src)

///If this mob gets resisted by something, its trying to escape consumption.
/mob/living/simple_animal/hostile/ooze/gelatinous/resist_act(mob/living/user)
	. = ..()
	if(!do_after(user, 60)) //6 second struggle
		return FALSE
	consume.stop_consuming()

///This ability lets the gelatinious ooze speed up for a little bit
/datum/action/cooldown/metabolicboost
	name = "Metabolic boost"
	desc = "Gain a temporary speed boost. Costs 10 nutrition and slowly raises your temperature"
	background_icon_state = "bg_hive"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "metabolic_boost"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_STUN
	cooldown_time = 240
	var/nutrition_cost = 10
	var/active = FALSE


///Mob needs to have enough nutrition
/datum/action/cooldown/metabolicboost/IsAvailable()
	. = ..()
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	if(. && ooze.ooze_nutrition >= nutrition_cost && !active)
		return TRUE

///Give the mob a speed boost, heat it up every second, and end the ability in 6 seconds
/datum/action/cooldown/metabolicboost/Trigger()
	. = ..()
	if(!.)
		return
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	ooze.add_movespeed_modifier(/datum/movespeed_modifier/metabolicboost)
	var/timerid = addtimer(CALLBACK(src, .proc/HeatUp), 1 SECONDS, TIMER_STOPPABLE) //Heat up every second
	addtimer(CALLBACK(src, .proc/FinishSpeedup, timerid), 6 SECONDS)
	to_chat(ooze, "<span class='notice>You start feel a lot quicker.</span>")
	ooze.adjust_ooze_nutrition(-10)

///Heat up the mob a little
/datum/action/cooldown/metabolicboost/proc/HeatUp()
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	ooze.adjust_bodytemperature(5)

///Remove the speed modifier and delete the timer for heating up
/datum/action/cooldown/metabolicboost/proc/FinishSpeedup(timerid)
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	ooze.remove_movespeed_modifier(/datum/movespeed_modifier/metabolicboost)
	to_chat(ooze, "<span class='notice>You start slowing down again.</span>")
	deltimer(timerid)


///This action lets you consume the mob you're currently pulling. I'M GONNA CONSUUUUUME (this is considered one of the funny memes in the 2019-2020 era)
/datum/action/consume
	name = "Consume"
	desc = "Consume a mob that you are dragging to gain nutrition from them"
	background_icon_state = "bg_hive"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "consume"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_STUN
	///The mob thats being consumed by this creature
	var/mob/living/vored_mob

///Register for owner death
/datum/action/consume/New(Target)
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_DEATH, .proc/on_owner_death)

///Try to consume the pulled mob
/datum/action/consume/Trigger()
	. = ..()
	if(!.)
		return
	var/mob/living/simple_animal/hostile/ooze/gelatinous/ooze = owner
	if(!ooze.pulling)
		to_chat(src, "<span class='warning'>You need to be pulling a creature for this to work!</span>")
		return FALSE
	if(!isliving(ooze.pulling))
		to_chat(src, "<span class='warning'>You need to be pulling a creature for this to work!</span>")
		return FALSE
	if(vored_mob)
		to_chat(src, "<span class='warning'>You are already consuming another creature!</span>")
		return FALSE
	owner.visible_message("<span class='warning>[ooze] starts attempting to devour [target]!</span>", "<span class='notice'>You start attempting to devour [target].</span>")
	if(!do_after(ooze, 15, target = ooze.pulling))
		return FALSE
	var/mob/living/eat_target = ooze.pulling

	if(!(eat_target.mob_biotypes & MOB_ORGANIC) || eat_target.stat == DEAD)
		to_chat(src, "<span class='warning'>This creature isn't to my tastes!</span>")
		return FALSE
	start_consuming(eat_target)

///Start allowing this datum to process to handle the damage done to  this mob.
/datum/action/consume/proc/start_consuming(mob/living/target)
	vored_mob = target
	vored_mob.forceMove(owner) ///AAAAAAAAAAAAAAAAAAAAAAHHH!!! VORE!!!!
	playsound(owner,'sound/items/eatfood.ogg', rand(30,50), TRUE)
	owner.visible_message("<span class='warning>[src] devours [target]!</span>", "<span class='notice'>You devour [target].</span>")
	START_PROCESSING(SSprocessing, src)

///Stop consuming the mob; dump them on the floor
/datum/action/consume/proc/stop_consuming()
	STOP_PROCESSING(SSprocessing, src)
	vored_mob.forceMove(get_turf(owner))
	playsound(get_turf(owner), 'sound/effects/splat.ogg', 50, TRUE)
	owner.visible_message("<span class='warning>[owner] pukes out [vored_mob]!</span>", "<span class='notice'>You puke out [vored_mob].</span>")
	vored_mob = null

///Gain health for the consumption and dump some clone loss on the target.
/datum/action/consume/process()
	var/mob/living/simple_animal/hostile/ooze/gelatinous/ooze = owner
	vored_mob.adjustCloneLoss(6)
	ooze.heal_ordered_damage((ooze.maxHealth * 0.03), list(BRUTE, BURN, OXY)) ///Heal 6% of these specific damage types each process
	ooze.adjust_ooze_nutrition(3)

	///Dump em at 200 cloneloss.
	if(vored_mob.getCloneLoss() >= 200)
		stop_consuming()

///On owner death dump the current vored mob
/datum/action/consume/proc/on_owner_death()
	stop_consuming()


///* Gelatinious Grapes code below *\\\\

///Child of the ooze mob which is orientated at being a support role with minor healing capabilities
/mob/living/simple_animal/hostile/ooze/grapes
	name = "Sholean grapes"
	desc = "It's a gummy cube, it's a gummy cube, it's a gummy gummy gummy gummy gummy cube."
	icon_state = "grapes"
	icon_dead = "grapes_dead"
	speed = 1
	///The ability to give yourself a metabolic speed boost which raises heat
	var/datum/action/cooldown/gel_cocoon/gel_cocoon
	///The ability to consume mobs
	var/obj/effect/proc_holder/globules/globules

/mob/living/simple_animal/hostile/ooze/grapes/Initialize()
	. = ..()
	globules = new
	AddAbility(globules)
	gel_cocoon = new
	gel_cocoon.Grant(src)


/mob/living/simple_animal/hostile/ooze/grapes/check_edible(atom/movable/AM)
	if(ismob(AM))
		return FALSE
	var/foodtype
	if(istype(AM, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/meal = AM
		foodtype = meal.foodtype
	return foodtype & MEAT || foodtype & VEGETABLES //Dont forget to add edible component compat here later


///Ability that allows the owner to fire healing globules at mobs, targetting specific limbs.
/obj/effect/proc_holder/globules
	name = "Fire Mending globule"
	desc = "Fires a mending globule at someone, healing a specific limb of theirs."
	active = FALSE
	action_icon = 'icons/mob/actions/actions_slime.dmi'
	action_icon_state = "globules"
	action_background_icon_state = "bg_hive"
	var/cooldown = 5 SECONDS
	var/current_cooldown = 0

/obj/effect/proc_holder/globules/Click(location, control, params)
	. = ..()
	if(!isliving(usr))
		return TRUE
	var/mob/living/user = usr
	fire(user)

/obj/effect/proc_holder/globules/fire(mob/living/carbon/user)
	var/message
	if(current_cooldown > world.time)
		to_chat(user, "<span class='notice'>This ability is still on cooldown.</span>")
		return
	if(active)
		message = "<span class='notice'>You stop preparing your mending globules.</span>"
		remove_ranged_ability(message)
	else
		message = "<span class='notice'>You prepare to launch a mending globule. <B>Left-click to fire at a target!</B></span>"
		add_ranged_ability(user, message, TRUE)

/obj/effect/proc_holder/globules/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(!istype(ranged_ability_user, /mob/living/simple_animal/hostile/ooze) || ranged_ability_user.stat)
		remove_ranged_ability()
		return

	var/mob/living/simple_animal/hostile/ooze/ooze = ranged_ability_user

	if(ooze.ooze_nutrition < 5)
		to_chat(ooze, "<span class='warning'>You need at least 5 nutrition to launch a mending globule.</span>")
		remove_ranged_ability()
		return

	ooze.visible_message("<span class='nicegreen>[ooze] launches a mending globule!</span>", "<span class='notice'>You launch a mending globule.</span>")
	var/obj/projectile/globule/globule = new (ooze.loc)
	globule.preparePixelProjectile(target, ooze, params)
	globule.def_zone = ooze.zone_selected
	globule.fire()
	ooze.adjust_ooze_nutrition(-5)
	remove_ranged_ability()
	current_cooldown = world.time + cooldown

	return TRUE

/obj/effect/proc_holder/globules/on_lose(mob/living/carbon/user)
	remove_ranged_ability()

///This projectile embeds into mobs and heals them over time.
/obj/projectile/globule
	name = "mending globule"
	icon_state = "glob_projectile"
	shrapnel_type = /obj/item/mending_globule
	nodamage = TRUE
	damage = 0

///This item is what is embedded into the mob, and actually handles healing of mending globules
/obj/item/mending_globule
	name = "mending globule"
	desc = "It somehow heals those who touch it."
	icon = 'icons/obj/xenobiology/vatgrowing.dmi'
	icon_state = "globule"
	embedding = list("embed_chance" = 100, ignore_throwspeed_threshold = TRUE, "pain_mult" = 0, "jostle_pain_mult" = 0, "fall chance" = 0.5)
	var/mob/living/carbon/human/healing_target
	var/obj/item/bodypart/bodypart
	var/heals_left = 35

/obj/item/mending_globule/embedded(mob/living/carbon/human/embedded_mob)
	. = ..()
	if(!istype(loc, /obj/item/bodypart))
		return
	healing_target = embedded_mob
	START_PROCESSING(SSobj, src)

/obj/item/mending_globule/unembedded()
	. = ..()
	bodypart = null
	STOP_PROCESSING(SSobj, src)

///Handles the healing of the mending globule
/obj/item/mending_globule/process()
	if(!bodypart) //this is fucked
		return FALSE
	bodypart.heal_damage(1,1)
	heals_left--
	if(heals_left <= 0)
		qdel(src)

///This action lets you put a mob inside of a cacoon that will inject it with some chemicals.
/datum/action/cooldown/gel_cocoon
	name = "Gel Cocoon"
	desc = "Puts a mob inside of a cocoon, allowing it to slowly heal."
	background_icon_state = "bg_hive"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "gel_cocoon"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_STUN
	cooldown_time = 10 SECONDS

///Try to put the pulled mob in a cocoon
/datum/action/cooldown/gel_cocoon/Trigger()
	. = ..()
	if(!.)
		return
	var/mob/living/simple_animal/hostile/ooze/gelatinous/ooze = owner
	if(!ooze.pulling)
		to_chat(src, "<span class='warning'>You need to be pulling a creature for this to work!</span>")
		return FALSE
	if(!iscarbon(ooze.pulling))
		to_chat(src, "<span class='warning'>This creature is not advanced enough to be assisted with a cocoon!</span>")
		return FALSE
	owner.visible_message("<span class='nicegreen>[ooze] starts attempting to put [target] into a gel cocoon!</span>", "<span class='notice'>You start attempting to put [target] into a gel cocoon.</span>")
	if(!do_after(ooze, 1.5 SECONDS, target = ooze.pulling))
		return FALSE

	put_in_cocoon(ooze.pulling)
	ooze.adjust_ooze_nutrition(-30)

///Mob needs to have enough nutrition
/datum/action/cooldown/gel_cocoon/IsAvailable()
	. = ..()
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	if(. && ooze.ooze_nutrition >= 30)
		return TRUE

///Puts the mob in the new cocoon
/datum/action/cooldown/gel_cocoon/proc/put_in_cocoon(mob/living/carbon/target)
	var/obj/structure/gel_cocoon/cocoon = new /obj/structure/gel_cocoon(get_turf(target))
	cocoon.insert_target(target)
	owner.visible_message("<span class='nicegreen>[owner] has put [target] into a gel cocoon!</span>", "<span class='notice'>You put [target] into a gel cocoon.</span>")

/obj/structure/gel_cocoon
	name = "gel cocoon"
	desc = "It looks gross, but helpful."
	icon = 'icons/obj/xenobiology/vatgrowing.dmi'
	icon_state = "gel_cocoon"
	max_integrity = 50
	var/mob/living/carbon/inhabitant

/obj/structure/gel_cocoon/Destroy()
	dump_inhabitant(FALSE)
	. = ..()

/obj/structure/gel_cocoon/resist_act(mob/living/user)
	. = ..()
	user.visible_message("<span class='notice'>You see [user] breaking out of [src]!</span>", \
		"<span class='notice'>You start tearing the soft tissue of the gel cocoon</span>")
	if(!do_after(user, 1.5 SECONDS, target = src))
		return FALSE
	dump_inhabitant()

///This proc handles the insertion of a person into the cocoon
/obj/structure/gel_cocoon/proc/insert_target(target)
	inhabitant = target
	inhabitant.forceMove(src)
	START_PROCESSING(SSobj, src)

///This proc dumps the mob and handles associated audiovisual feedback
/obj/structure/gel_cocoon/proc/dump_inhabitant(destroy_after = TRUE)
	inhabitant.forceMove(get_turf(src))
	playsound(get_turf(inhabitant), 'sound/effects/splat.ogg', 50, TRUE)
	inhabitant.Paralyze(10)
	inhabitant.visible_message("<span class='warning>[inhabitant] falls out of [src]!</span>", "<span class='notice'>You fall out of [src].</span>")
	if(destroy_after)
		qdel(src)


/obj/structure/gel_cocoon/process()
	if(inhabitant.reagents.get_reagent_amount(/datum/reagent/medicine/atropine) < 5)
		inhabitant.reagents.add_reagent(/datum/reagent/medicine/atropine, 0.5)

	if(inhabitant.reagents.get_reagent_amount(/datum/reagent/medicine/salglu_solution) < 15)
		inhabitant.reagents.add_reagent(/datum/reagent/medicine/salglu_solution, 1.5)

	if(inhabitant.reagents.get_reagent_amount(/datum/reagent/consumable/milk) < 20)
		inhabitant.reagents.add_reagent(/datum/reagent/consumable/milk, 2)
