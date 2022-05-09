//CONTAINS: Suit fibers and Detective's Scanning Computer

/atom/proc/return_fingerprints()
	if (forensics)
		return forensics.fingerprints

/atom/proc/return_hiddenprints()
	if (forensics)
		return forensics.hiddenprints

/atom/proc/return_blood_DNA()
	if (forensics)
		return forensics.blood_DNA

/atom/proc/blood_DNA_length()
	if (forensics)
		return length(forensics.blood_DNA)

/atom/proc/return_fibers()
	if (forensics)
		return forensics.fibers

/atom/proc/add_fingerprint_list(list/fingerprints_to_add) //ASSOC LIST FINGERPRINT = FINGERPRINT
	if (isnull(fingerprints_to_add))
		return
	if (forensics)
		forensics.inherit_new(fingerprints = fingerprints_to_add)
	else
		forensics = new(src, fingerprints = fingerprints_to_add)
	return TRUE

//Set ignoregloves to add prints irrespective of the mob having gloves on.
/atom/proc/add_fingerprint(mob/suspect, ignoregloves = FALSE)
	if (QDELING(src))
		return
	if (isnull(forensics))
		forensics = new(src)
	forensics.add_fingerprint(suspect, ignoregloves)
	return TRUE

/atom/proc/add_fiber_list(list/fibers_to_add) //ASSOC LIST FIBERTEXT = FIBERTEXT
	if (isnull(fibers_to_add))
		return
	if (forensics)
		forensics.inherit_new(fibers = fibers_to_add)
	else
		forensics = new(src, fibers = fibers_to_add)
	return TRUE

/atom/proc/add_fibers(mob/living/carbon/human/suspect)
	var/old = 0
	if(suspect.gloves && istype(suspect.gloves, /obj/item/clothing))
		var/obj/item/clothing/gloves/suspect_gloves = suspect.gloves
		old = length(suspect_gloves.return_blood_DNA())
		if(suspect_gloves.transfer_blood > 1) //bloodied gloves transfer blood to touched objects
			if(add_blood_DNA(suspect_gloves.return_blood_DNA()) && suspect_gloves.blood_DNA_length() > old) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				suspect_gloves.transfer_blood -= 1
	else if(suspect.blood_in_hands > 1)
		old = length(suspect.return_blood_DNA())
		if(add_blood_DNA(suspect.return_blood_DNA()) && suspect.blood_DNA_length() > old)
			suspect.blood_in_hands -= 1
	if (isnull(forensics))
		forensics = new(src)
	forensics.add_fibers(suspect)
	return TRUE

/atom/proc/add_hiddenprint_list(list/hiddenprints_to_add) //NOTE: THIS IS FOR ADMINISTRATION FINGERPRINTS, YOU MUST CUSTOM SET THIS TO INCLUDE CKEY/REAL NAMES! CHECK FORENSICS.DM
	if (isnull(hiddenprints_to_add))
		return
	if (forensics)
		forensics.inherit_new(hiddenprints = hiddenprints_to_add)
	else
		forensics = new(src, hiddenprints = hiddenprints_to_add)
	return TRUE

/atom/proc/add_hiddenprint(mob/suspect)
	if (isnull(forensics))
		forensics = new(src)
	forensics.add_hiddenprint(suspect)
	return TRUE

/atom/proc/add_blood_DNA(list/blood_DNA_to_add) //ASSOC LIST DNA = BLOODTYPE
	return FALSE

/obj/add_blood_DNA(list/blood_DNA_to_add)
	. = ..()
	if (isnull(blood_DNA_to_add))
		return .
	if (forensics)
		forensics.inherit_new(blood_DNA = blood_DNA_to_add)
	else
		forensics = new(src, blood_DNA = blood_DNA_to_add)
	return TRUE

/obj/item/clothing/gloves/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	transfer_blood = rand(2, 4)
	return ..()

/turf/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	var/obj/effect/decal/cleanable/blood/splatter/blood_splatter = locate() in src
	if(!blood_splatter)
		blood_splatter = new /obj/effect/decal/cleanable/blood/splatter(src, diseases)
	if(!QDELETED(blood_splatter))
		blood_splatter.add_blood_DNA(blood_dna) //give blood info to the blood decal.
		return TRUE //we bloodied the floor
	return FALSE

/mob/living/carbon/human/add_blood_DNA(list/blood_DNA_to_add, list/datum/disease/diseases)
	if(wear_suit)
		wear_suit.add_blood_DNA(blood_DNA_to_add)
		update_inv_wear_suit()
	else if(w_uniform)
		w_uniform.add_blood_DNA(blood_DNA_to_add)
		update_inv_w_uniform()
	if(gloves)
		var/obj/item/clothing/gloves/mob_gloves = gloves
		mob_gloves.add_blood_DNA(blood_DNA_to_add)
	else if(length(blood_DNA_to_add))
		if (isnull(forensics))
			forensics = new(src)
		forensics.inherit_new(blood_DNA = blood_DNA_to_add)
		blood_in_hands = rand(2, 4)
	update_inv_gloves()
	return TRUE

/*
 * Transfer all the fingerprints and hidden prints from [src] to [transfer_to].
 */
/atom/proc/transfer_fingerprints_to(atom/transfer_to)
	transfer_to.add_fingerprint_list(return_fingerprints())
	transfer_to.add_hiddenprint_list(return_hiddenprints())
	transfer_to.fingerprintslast = fingerprintslast

/*
 * Transfer all the fibers from [src] to [transfer_to].
 */
/atom/proc/transfer_fibers_to(atom/transfer_to)
	transfer_to.add_fiber_list(return_fibers())
