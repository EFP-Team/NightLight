
/// if you add eyes, switch to the way the rat organ defines work
#define CARP_COLORS "#4caee7"

///bonus of the carp: you can swim through space!
/datum/status_effect/organ_set_bonus/carp
	organs_needed = 4
	bonus_activate_text = "Carp DNA is deeply infused with you! You've learned how to propel yourself through space!"
	bonus_deactivate_text = "Your DNA is once again mostly yours, and so fades your ability to space-swim..."

/datum/status_effect/organ_set_bonus/carp/enable_bonus()
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, REF(src))

/datum/status_effect/organ_set_bonus/carp/disable_bonus()
	. = ..()
	REMOVE_TRAIT(src, TRAIT_SPACEWALK, REF(src))

///Carp lungs! You can breathe in space! Oh... you can't breathe on the station, you need low oxygen environments.
/obj/item/organ/internal/lungs/carp
	name = "mutated carp-lungs"
	desc = "Carp DNA infused into what was once some normal lungs."
	safe_oxygen_max = 16
	safe_oxygen_min = 0

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "lungs"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = CARP_COLORS

/obj/item/organ/internal/lungs/carp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "has odd neck gills.", BODY_ZONE_HEAD)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/carp)

///occasionally sheds carp teeth, stronger melee (bite) attacks, but you can't cover your mouth anymore.
/obj/item/organ/internal/tongue/carp
	name = "mutated carp-jaws"
	desc = "Carp DNA infused into what was once some normal teeth."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "tongue"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = CARP_COLORS

	var/datum/martial_art/carp_jaws/jaws_datum

/obj/item/organ/internal/tongue/carp/Initialize(mapload)
	. = ..()
	jaws_datum = new()

/obj/item/organ/internal/tongue/carp/Insert(mob/living/carbon/tongue_owner, special, drop_if_replaced)
	. = ..()
	jaws_datum.teach(tongue_owner)
	if(!ishuman(tongue_owner))
		return
	var/mob/living/carbon/human/human_reciever = tongue_owner
	var/datum/species/rec_species = human_reciever.dna.species
	if(!(ITEM_SLOT_MASK in rec_species.no_equip))
		rec_species.no_equip += ITEM_SLOT_MASK

/obj/item/organ/internal/tongue/carp/Remove(mob/living/carbon/tongue_owner, special)
	. = ..()
	jaws_datum.remove(tongue_owner)
	if(!ishuman(tongue_owner))
		return
	var/mob/living/carbon/human/human_reciever = tongue_owner
	var/datum/species/rec_species = human_reciever.dna.species
	if(!(ITEM_SLOT_MASK in initial(rec_species.no_equip)))
		rec_species.no_equip -= ITEM_SLOT_MASK

/obj/item/organ/internal/tongue/carp/on_life(delta_time, times_fired)
	. = ..()
	if(!prob(1))
		return
	owner.emote("cough")
	var/turf/tooth_fairy = get_turf(owner)
	if(tooth_fairy)
		new /obj/item/knife/carp(tooth_fairy)

/obj/item/knife/carp
	name = "carp tooth"
	desc = "Looks sharp. Sharp enough to poke someone's eye out. Holy fuck it's big."
	icon_state = "carptooth"

///carp brain. you need to occasionally go to a new zlevel. think of it as... walking your dog!
/obj/item/organ/internal/brain/carp
	name = "mutated carp-brain"
	desc = "Carp DNA infused into what was once a normal brain."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "brain"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = CARP_COLORS

	///Timer counting down. When finished, the owner gets a bad moodlet.
	var/cooldown_timer
	///how much time the timer is given
	var/cooldown_time = 10 MINUTES

/obj/item/organ/internal/brain/carp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "seems unable to stay still.")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/carp)

/obj/item/organ/internal/brain/carp/Insert(mob/living/carbon/brain_owner, special, drop_if_replaced, no_id_transfer)
	. = ..()
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(unsatisfied_nomad)), cooldown_time, TIMER_STOPPABLE|TIMER_OVERRIDE)
	RegisterSignal(brain_owner, COMSIG_MOVABLE_Z_CHANGED, .proc/satisfied_nomad)

//technically you could get around the mood issue by extracting and reimplanting the brain but it will be far easier to just go one z there and back
/obj/item/organ/internal/brain/carp/Remove(mob/living/carbon/brain_owner, special, no_id_transfer)
	. = ..()
	UnregisterSignal(brain_owner)
	deltimer(cooldown_timer)

/obj/item/organ/internal/brain/carp/proc/unsatisfied_nomad()
	owner.add_mood_event("nomad", /datum/mood_event/unsatisfied_nomad)

/obj/item/organ/internal/brain/carp/proc/satisfied_nomad()
	SIGNAL_HANDLER
	owner.clear_mood_event("nomad")
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(unsatisfied_nomad)), cooldown_time, TIMER_STOPPABLE|TIMER_OVERRIDE)

/// makes you cold resistant, but heat-weak.
/obj/item/organ/internal/heart/carp
	name = "mutated carp-heart"
	desc = "Carp DNA infused into what was once a normal heart."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "heart"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = CARP_COLORS

/obj/item/organ/internal/heart/carp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "skin has small patches of scales growing...")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/carp)

/obj/item/organ/internal/heart/carp/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()
	if(!ishuman(reciever))
		return
	var/mob/living/carbon/human/human_reciever = reciever
	var/datum/species/rec_species = human_reciever.dna.species
	rec_species.bodytemp_heat_damage_limit = (BODYTEMP_NORMAL + 1)
	rec_species.bodytemp_cold_damage_limit = (BODYTEMP_NORMAL - 150)
	//considered adding burn but this is supposed to be good at space exploration

/obj/item/organ/internal/heart/carp/Remove(mob/living/carbon/heartless, special)
	. = ..()
	if(!ishuman(heartless))
		return
	var/mob/living/carbon/human/human_heartless = heartless
	human_heartless.dna.remove_mutation(/datum/mutation/human/dwarfism)
	human_heartless.physiology.damage_resistance += 100

#undef CARP_COLORS
