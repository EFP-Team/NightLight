/datum/action/cooldown/spell/pointed/projectile/moon_parade
	name = "Lunar parade"
	desc = "This unleashes the parade towards a target."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "moon_parade"
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'sound/magic/cosmic_energy.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "L'N'R P'RAD"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	active_msg = "You prepare to make them join the parade!"
	deactive_msg = "You stop the music and halt the parade... for now."
	cast_range = 12
	projectile_type = /obj/projectile/moon_parade


/obj/projectile/moon_parade
	name = "Lunar parade"
	icon_state = "lunar_parade"
	damage = 0
	damage_type = BURN
	speed = 1
	range = 75
	ricochets_max = 40
	ricochet_chance = 500
	ricochet_incidence_leeway = 0
	pixel_speed_multiplier = 0.2
	projectile_piercing = PASSMOB|PASSVEHICLE
	///looping sound datum for our projectile.
	var/datum/looping_sound/moon_parade/soundloop
	// A list of the people we hit
	var/list/mobs_hit = list()

/obj/projectile/moon_parade/Initialize(mapload)
	. = ..()
	soundloop = new(src,  TRUE)

/obj/projectile/moon_parade/prehit_pierce(atom/A)
	. = ..()

	var/mob/living/caster = firer
	var/mob/living/victim = A

	if(caster == victim)
		return PROJECTILE_PIERCE_PHASE

	if(!caster.mind)
		return PROJECTILE_PIERCE_HIT

	var/datum/antagonist/heretic_monster/monster = victim.mind?.has_antag_datum(/datum/antagonist/heretic_monster)
	if(monster?.master == caster.mind)
		return PROJECTILE_PIERCE_PHASE

	var/datum/antagonist/lunatic/lunatic = victim.mind?.has_antag_datum(/datum/antagonist/lunatic)
	if(lunatic?.ascended_heretic == caster.mind)
		return PROJECTILE_PIERCE_PHASE

	// Anti-magic destroys the projectile for consistency and counterplay
	if(victim.can_block_magic(MAGIC_RESISTANCE))
		visible_message(span_warning("The parade hits [victim] and a sudden wave of clarity comes over you!"))
		return PROJECTILE_DELETE_WITHOUT_HITTING


/obj/projectile/moon_parade/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/victim = target

	RegisterSignal(victim, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(moon_block_move), override=TRUE)

	victim.AddComponent(/datum/component/leash, src, distance = 1)
	victim.balloon_alert(victim,"you feel unable to move away from the parade!")
	victim.add_mood_event("Moon Insanity", /datum/mood_event/moon_insanity)
	victim.cause_hallucination(/datum/hallucination/delusion/preset/moon, "delusion/preset/moon hallucination caused by lunar parade")

	//Lowers sanity
	victim.mob_mood.set_sanity(victim.mob_mood.sanity - 20)

	// Uses weakref to prevent qdeleting them
	mobs_hit |= WEAKREF(victim)

/obj/projectile/moon_parade/Destroy()
	for(var/datum/weakref/mob_ref in mobs_hit)
		var/mob/living/real_mob = mob_ref.resolve()
		UnregisterSignal(real_mob, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE)
	mobs_hit.Cut()
	soundloop.stop()
	return ..()

// Blocks movement in order to make it appear like the character is transfixed to the projectile and wandering after it
// Coded this way because its a simple way to hold the illusion compared to other methods
/obj/projectile/moon_parade/proc/moon_block_move(datum/source)
	SIGNAL_HANDLER
	return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE
