/obj/item/organ/internal/liver/golem
	name = "porous rock"
	desc = "A spongy rock capable of absorbing chemicals."
	icon_state = "liver-p"
	status = ORGAN_MINERAL
	color = COLOR_GOLEM_GRAY

/obj/item/organ/internal/liver/golem/handle_chemical(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick, times_fired)
	. = ..()
	// parent returned COMSIG_MOB_STOP_REAGENT_CHECK or we are failing
	if(. || (organ_flags & ORGAN_FAILING))
		return
	// golems can only eat minerals
	if(istype(chem, /datum/reagent/consumable) && !istype(chem, /datum/reagent/consumable/nutriment/mineral))
		var/datum/reagent/consumable/yummy_chem = chem
		yummy_chem.nutriment_factor = 0
