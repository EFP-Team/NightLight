/**
 * ## On Hit Effect Component!
 *
 * Component for other elements/components to rely on for on-hit effects without duplicating the on-hit code.
 * See Lifesteal, or bane for examples.
 */
/datum/element/on_hit_effect

/datum/element/on_hit_effect/Attach(datum/target)
	. = ..()
	if(!HAS_TRAIT(target, TRAIT_WADDLING))
		stack_trace("[type] added to [target] without adding TRAIT_ON_HIT_EFFECT first. Please use AddElementTrait instead.")
	if(ismachinery(target) || isstructure(target) || isgun(target) || isprojectilespell(target))
		RegisterSignal(target, COMSIG_PROJECTILE_ON_HIT, PROC_REF(on_projectile_hit))
	else if(isitem(target))
		RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(item_afterattack))
	else if(isanimal_or_basicmob(target))
		RegisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(hostile_attackingtarget))
	else if(isprojectile(target))
		RegisterSignal(target, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_projectile_self_hit))
	else
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(on_thrown_hit))

/datum/element/on_hit_effect/Detach(datum/source)
	UnregisterSignal(source, list(
		COMSIG_PROJECTILE_ON_HIT,
		COMSIG_ITEM_AFTERATTACK,
		COMSIG_HOSTILE_POST_ATTACKINGTARGET,
		COMSIG_PROJECTILE_SELF_ON_HIT,
		COMSIG_MOVABLE_IMPACT,
	))
	return ..()

/datum/element/on_hit_effect/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return

	send_signal(source, user, target, user.zone_selected)

/datum/element/on_hit_effect/proc/hostile_attackingtarget(mob/living/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success)
		return

	send_signal(attacker, attacker, target, attacker.zone_selected)

/datum/element/on_hit_effect/proc/on_projectile_hit(datum/fired_from, atom/movable/firer, atom/target, angle, body_zone)
	SIGNAL_HANDLER
	send_signal(fired_from, firer, target, body_zone)

/datum/element/on_hit_effect/proc/on_projectile_self_hit(datum/source, mob/firer, atom/target, angle, body_zone)
	SIGNAL_HANDLER
	send_signal(source, firer, target, body_zone)

/datum/element/on_hit_effect/proc/on_thrown_hit(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	send_signal(source, source, hit_atom, null, TRUE)

/datum/element/on_hit_effect/proc/send_signal(atom/source, atom/movable/attacker, atom/target, body_zone, throw_hit = FALSE)
	SEND_SIGNAL(source, COMSIG_ON_HIT_EFFECT, attacker, target, body_zone, throw_hit)
