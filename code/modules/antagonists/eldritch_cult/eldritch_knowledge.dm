
/**
  * #Eldritch Knwoledge
  *
  * Datum that makes eldritch cultist interesting.
  *
  * Eldritch knowledge aren't instantiated anywhere roundstart, and are initalized and destroyed as the round goes on.
  */
/datum/eldritch_knowledge
	///Name of the knowledge
	var/name = "Basic knowledge"
	///Description of the knowledge
	var/desc = "Basic knowledge of forbidden arts."
	///What shows up
	var/gain_text = ""
	///Cost of knowledge in souls
	var/cost = 0
	///Next knowledge in the research tree
	var/list/next_knowledge = list()
	///What knowledge is incompatible with this. This will simply make it impossible to research knowledges that are in banned_knowledge once this gets researched.
	var/list/banned_knowledge = list()
	///Used with rituals, how many items this needs
	var/list/required_atoms = list()
	///What do we get out of this
	var/list/result_atoms = list()
	///What path is this on defaults to "Side"
	var/route = "Side"

/datum/eldritch_knowledge/New()
	. = ..()
	var/list/temp_list
	for(var/X in required_atoms)
		var/atom/A = X
		temp_list += list(typesof(A))
	required_atoms = temp_list

/**
  * What happens when this is assigned to an antag datum
  *
  * This proc is called whenever a new eldritch knowledge is added to an antag datum
  */
/datum/eldritch_knowledge/proc/on_gain(mob/user)
	to_chat(user, "<span class='warning'>[gain_text]</span>")
	return
/**
  * What happens when you loose this
  *
  * This proc is called whenever antagonist looses his antag datum, put cleanup code in here
  */
/datum/eldritch_knowledge/proc/on_lose(mob/user)
	return
/**
  * What happens every tick
  *
  * This proc is called on SSprocess in eldritch cultist antag datum. SSprocess happens roughly every second
  */
/datum/eldritch_knowledge/proc/on_life(mob/user)
	return

/**
  * Special check for recipes
  *
  * If you are adding a more complex summoning or something that requires a special check that parses through all the atoms in an area override this.
  */
/datum/eldritch_knowledge/proc/recipe_snowflake_check(list/atoms,loc)
	return TRUE

/**
  * What happens once the recipe is succesfully finished
  *
  * By default this proc creates atoms from result_atoms list. Override this is you want something else to happen.
  */
/datum/eldritch_knowledge/proc/on_finished_recipe(mob/living/user,list/atoms,loc)
	if(result_atoms.len == 0)
		return FALSE

	for(var/X in result_atoms)
		var/atom/A = X
		new A(loc)

	return TRUE

/**
  * Used atom cleanup
  *
  * Overide this proc if you dont want ALL ATOMS to be destroyed. useful in many situations.
  */
/datum/eldritch_knowledge/proc/cleanup_atoms(list/atoms)
	for(var/X in atoms)
		var/atom/A = X
		if(!isliving(A))
			qdel(A)
	return

/**
  * Mansus grasp act
  *
  * Gives addtional effects to mansus grasp spell
  */
/datum/eldritch_knowledge/proc/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	return


/**
  * Sickly blade act
  *
  * Gives addtional effects to sickly blade weapon
  */
/datum/eldritch_knowledge/proc/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	return

//////////////
///Subtypes///
//////////////

/datum/eldritch_knowledge/spell
	var/obj/effect/proc_holder/spell/spell_to_add

/datum/eldritch_knowledge/spell/on_gain(mob/user)
	var/obj/effect/proc_holder/S = new spell_to_add
	user.mind.AddSpell(S)
	return ..()

/datum/eldritch_knowledge/spell/on_lose(mob/user)
	user.mind.RemoveSpell(spell_to_add)
	return ..()

/datum/eldritch_knowledge/curse
	var/timer = 5 MINUTES
	var/list/fingerprints = list()

/datum/eldritch_knowledge/curse/recipe_snowflake_check(list/atoms, loc)
	fingerprints = list()
	for(var/X in atoms)
		var/atom/A = X
		fingerprints |= A.return_fingerprints()
	listclearnulls(fingerprints)
	if(fingerprints.len == 0)
		return FALSE
	return TRUE

/datum/eldritch_knowledge/curse/on_finished_recipe(mob/living/user,list/atoms,loc)

	var/list/compiled_list = list()

	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(fingerprints[md5(H.dna.uni_identity)])
			compiled_list |= H.real_name
			compiled_list[H.real_name] = H

	if(compiled_list.len == 0)
		to_chat(user, "<span class='warning'>The items don't posses required fingerprints.</span>")
		return

	var/chosen_mob = input("Select the person you wish to curse","Your target") as null|anything in sortList(compiled_list, /proc/cmp_mob_realname_dsc)
	if(!chosen_mob)
		return ..()
	curse(compiled_list[chosen_mob])
	addtimer(CALLBACK(src, .proc/uncurse, compiled_list[chosen_mob]),timer)
	return ..()

/datum/eldritch_knowledge/curse/proc/curse(mob/living/chosen_mob)
	return

/datum/eldritch_knowledge/curse/proc/uncurse(mob/living/chosen_mob)
	return

/datum/eldritch_knowledge/summon
	var/mob/living/mob_to_summon


/datum/eldritch_knowledge/summon/on_finished_recipe(mob/living/user,list/atoms,loc)
	message_admins("[initial(mob_to_summon.name)] is being summoned by [user.real_name] in [loc]")
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [initial(mob_to_summon.real_name)]", ROLE_HERETIC, null, ROLE_HERETIC, 50,initial(mob_to_summon))
	if(!LAZYLEN(candidates))
		to_chat(user,"<span class='warning'>No ghost could be found...</span>")
		return
	var/mob/living/summoned = new mob_to_summon(loc)
	var/mob/dead/observer/C = pick(candidates)
	message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(summoned)]).")
	summoned.ghostize(0)
	summoned.key = C.key

	to_chat(summoned,"<span class='warning'>You are bound to [user.real_name]'s' will! Don't let your master die, protect him at all cost!</span>")
///////////////
///Base lore///
///////////////

/datum/eldritch_knowledge/spell/basic
	name = "Break of dawn"
	desc = "Starts your journey in the mansus. Allows you to get a select a target using a living heart on a transmutation rune."
	gain_text = "Gates of mansus open up to your mind."
	next_knowledge = list(/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh)
	cost = 0
	spell_to_add = /obj/effect/proc_holder/spell/targeted/touch/mansus_grasp
	required_atoms = list(/obj/item/living_heart)
	route = "Start"

/datum/eldritch_knowledge/spell/basic/recipe_snowflake_check(list/atoms, loc)
	. = ..()
	for(var/obj/item/living_heart/LH in atoms)
		if(!LH.target)
			return TRUE
		if(LH.target.current in atoms)
			return TRUE
	return FALSE

/datum/eldritch_knowledge/spell/basic/on_finished_recipe(mob/living/user, list/atoms, loc)

	for(var/obj/item/living_heart/LH in atoms)

		if(LH.target && LH.target.current && LH.target.current.stat == DEAD)
			to_chat(user,"<span class='danger'>Your patrons accepts your offer..</span>")
			var/mob/living/carbon/human/H = LH.target.current
			H.gib()
			var/datum/antagonist/e_cult/EC = user.mind.has_antag_datum(/datum/antagonist/e_cult)

			EC.total_sacrifices++
			for(var/X in user.GetAllContents())
				if(!istype(X,/obj/item/forbidden_book))
					continue
				var/obj/item/forbidden_book/FB = X
				FB.charge++
				break

		if(!LH.target)
			var/datum/objective/A = new
			A.owner = user.mind
			LH.target = A.find_target()//easy way, i dont feel like copy pasting that entire block of code
			qdel(A)
			if(LH.target)
				to_chat(user,"<span class='warning'>Your new target has been selected, go and sacrifice [LH.target.current.real_name]!</span>")
			else
				to_chat(user,"<span class='warning'>target could not be found for living heart.</span>")

/datum/eldritch_knowledge/spell/basic/cleanup_atoms(list/atoms)
	return

/datum/eldritch_knowledge/living_heart
	name = "Living Heart"
	desc = "Allows you to create additional living hearts, using a heart, a pool of blood and a poppy. Living hearts when used on a transmutation rune will grant you a person to hunt and sacrifice on the rune. Every sacrifice gives you an additional charge in the book."
	gain_text = "Gates of mansus open up to your mind."
	cost = 0
	required_atoms = list(/obj/item/organ/heart,/obj/effect/decal/cleanable/blood,/obj/item/reagent_containers/food/snacks/grown/poppy)
	result_atoms = list(/obj/item/living_heart)
	route = "Start"
