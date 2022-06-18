/datum/element/earhealing
	element_flags = ELEMENT_DETACH
	var/list/user_by_item = list()

/datum/element/earhealing/New()
	START_PROCESSING(SSdcs, src)

/datum/element/earhealing/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/equippedChanged)

/datum/element/earhealing/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	user_by_item -= target

/datum/element/earhealing/proc/equippedChanged(datum/source, mob/living/carbon/user, slot)
	SIGNAL_HANDLER

	if(slot == ITEM_SLOT_EARS && istype(user))
		user_by_item[source] = user
	else
		user_by_item -= source

/datum/element/earhealing/process(delta_time)
	for(var/i in user_by_item)
		var/mob/living/carbon/user = user_by_item[i]
		var/obj/item/organ/internal/ears/ears = user.getorganslot(ORGAN_SLOT_EARS)
		if(!ears || HAS_TRAIT_NOT_FROM(user, TRAIT_DEAF, EAR_DAMAGE))
			continue
		ears.deaf = max(ears.deaf - 0.25 * delta_time, (ears.damage < ears.maxHealth ? 0 : 1)) // Do not clear deafness if our ears are too damaged
		ears.applyOrganDamage(-0.025 * delta_time, 0)
		CHECK_TICK
