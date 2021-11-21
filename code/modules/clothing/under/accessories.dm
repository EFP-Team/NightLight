/obj/item/clothing/accessory //Ties moved to neck slot items, but as there are still things like medals and armbands, this accessory system is being kept as-is
	name = "Accessory"
	desc = "Something has gone wrong!"
	icon = 'icons/obj/clothing/accessories.dmi'
	worn_icon = 'icons/mob/clothing/accessories.dmi'
	icon_state = "plasma"
	inhand_icon_state = "" //no inhands
	slot_flags = 0
	w_class = WEIGHT_CLASS_SMALL
	/// Whether or not the accessory displays through suits and the like.
	var/above_suit = FALSE
	/// TRUE if shown as a small icon in corner, FALSE if overlayed
	var/minimize_when_attached = TRUE
	/// Whether the accessory has any storage to apply to the clothing it's attached to.
	var/datum/component/storage/detached_pockets
	/// What equipment slot the accessory attaches to.
	var/attachment_slot = CHEST

/obj/item/clothing/accessory/Destroy()
	set_detached_pockets(null)
	return ..()

/obj/item/clothing/accessory/proc/can_attach_accessory(obj/item/clothing/U, mob/user)
	if(!attachment_slot || (U && U.body_parts_covered & attachment_slot))
		return TRUE
	if(user)
		to_chat(user, span_warning("There doesn't seem to be anywhere to put [src]..."))

/obj/item/clothing/accessory/proc/attach(obj/item/clothing/under/U, user)
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	if(storage)
		if(SEND_SIGNAL(U, COMSIG_CONTAINS_STORAGE))
			return FALSE
		U.TakeComponent(storage)
		set_detached_pockets(storage)
	U.attached_accessory = src
	forceMove(U)
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	if(minimize_when_attached)
		transform *= 0.5 //halve the size so it doesn't overpower the under
		pixel_x += 8
		pixel_y -= 8
	U.add_overlay(src)

	if (islist(U.armor) || isnull(U.armor)) // This proc can run before /obj/Initialize has run for U and src,
		U.armor = getArmor(arglist(U.armor)) // we have to check that the armor list has been transformed into a datum before we try to call a proc on it
																					// This is safe to do as /obj/Initialize only handles setting up the datum if actually needed.
	if (islist(armor) || isnull(armor))
		armor = getArmor(arglist(armor))

	U.armor = U.armor.attachArmor(armor)

	if(isliving(user))
		on_uniform_equip(U, user)

	return TRUE

/obj/item/clothing/accessory/proc/detach(obj/item/clothing/under/U, user)
	if(detached_pockets && detached_pockets.parent == U)
		TakeComponent(detached_pockets)

	U.armor = U.armor.detachArmor(armor)

	if(isliving(user))
		on_uniform_dropped(U, user)

	if(minimize_when_attached)
		transform *= 2
		pixel_x -= 8
		pixel_y += 8
	layer = initial(layer)
	plane = initial(plane)
	U.cut_overlays()
	U.attached_accessory = null
	U.accessory_overlay = null

/obj/item/clothing/accessory/proc/set_detached_pockets(new_pocket)
	if(detached_pockets)
		UnregisterSignal(detached_pockets, COMSIG_PARENT_QDELETING)
	detached_pockets = new_pocket
	if(detached_pockets)
		RegisterSignal(detached_pockets, COMSIG_PARENT_QDELETING, .proc/handle_pockets_del)

/obj/item/clothing/accessory/proc/handle_pockets_del(datum/source)
	SIGNAL_HANDLER
	set_detached_pockets(null)

/obj/item/clothing/accessory/proc/on_uniform_equip(obj/item/clothing/under/U, user)
	return

/obj/item/clothing/accessory/proc/on_uniform_dropped(obj/item/clothing/under/U, user)
	return

/obj/item/clothing/accessory/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		if(initial(above_suit))
			above_suit = !above_suit
			to_chat(user, "[src] will be worn [above_suit ? "above" : "below"] your suit.")

/obj/item/clothing/accessory/examine(mob/user)
	. = ..()
	. += span_notice("\The [src] can be attached to a uniform. Alt-click to remove it once attached.")
	if(initial(above_suit))
		. += span_notice("\The [src] can be worn above or below your suit. Alt-click to toggle.")

/obj/item/clothing/accessory/waistcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "waistcoat"
	inhand_icon_state = "waistcoat"
	minimize_when_attached = FALSE
	attachment_slot = null

/obj/item/clothing/accessory/maidapron
	name = "maid apron"
	desc = "The best part of a maid costume."
	icon_state = "maidapron"
	inhand_icon_state = "maidapron"
	minimize_when_attached = FALSE
	attachment_slot = null

//////////
//Medals//
//////////

/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	custom_materials = list(/datum/material/iron=1000)
	resistance_flags = FIRE_PROOF
	var/medaltype = "medal" //Sprite used for medalbox
	var/commended = FALSE

//Pinning medals on people
/obj/item/clothing/accessory/medal/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && !user.combat_mode)

		if(M.wear_suit)
			if((M.wear_suit.flags_inv & HIDEJUMPSUIT)) //Check if the jumpsuit is covered
				to_chat(user, span_warning("Medals can only be pinned on jumpsuits."))
				return

		if(M.w_uniform)
			var/obj/item/clothing/under/U = M.w_uniform
			var/delay = 20
			if(user == M)
				delay = 0
			else
				user.visible_message(span_notice("[user] is trying to pin [src] on [M]'s chest."), \
					span_notice("You try to pin [src] on [M]'s chest."))
			var/input
			if(!commended && user != M)
				input = stripped_input(user,"Please input a reason for this commendation, it will be recorded by Nanotrasen.", ,"", 140)
			if(do_after(user, delay, target = M))
				if(U.attach_accessory(src, user, 0)) //Attach it, do not notify the user of the attachment
					if(user == M)
						to_chat(user, span_notice("You attach [src] to [U]."))
					else
						user.visible_message(span_notice("[user] pins \the [src] on [M]'s chest."), \
							span_notice("You pin \the [src] on [M]'s chest."))
						if(input)
							SSblackbox.record_feedback("associative", "commendation", 1, list("commender" = "[user.real_name]", "commendee" = "[M.real_name]", "medal" = "[src]", "reason" = input))
							GLOB.commendations += "[user.real_name] awarded <b>[M.real_name]</b> the <span class='medaltext'>[name]</span>! \n- [input]"
							commended = TRUE
							desc += "<br>The inscription reads: [input] - [user.real_name]"
							log_game("<b>[key_name(M)]</b> was given the following commendation by <b>[key_name(user)]</b>: [input]")
							message_admins("<b>[key_name_admin(M)]</b> was given the following commendation by <b>[key_name_admin(user)]</b>: [input]")
							add_memory_in_range(M, 7, MEMORY_RECEIVED_MEDAL, list(DETAIL_PROTAGONIST = M, DETAIL_MEDAL_TYPE = src, DETAIL_DEUTERAGONIST = user, DETAIL_MEDAL_REASON = input), STORY_VALUE_AMAZING)

		else
			to_chat(user, span_warning("Medals can only be pinned on jumpsuits!"))
	else
		..()

/obj/item/clothing/accessory/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is the most basic award given by Nanotrasen. It is often awarded by a captain to a member of his crew."

/obj/item/clothing/accessory/medal/bronze_heart
	name = "bronze heart medal"
	desc = "A bronze heart-shaped medal awarded for sacrifice. It is often awarded posthumously or for severe injury in the line of duty."
	icon_state = "bronze_heart"

/obj/item/clothing/accessory/medal/ribbon
	name = "ribbon"
	desc = "A ribbon"
	icon_state = "cargo"

/obj/item/clothing/accessory/medal/ribbon/cargo
	name = "\"cargo tech of the shift\" award"
	desc = "An award bestowed only upon those cargotechs who have exhibited devotion to their duty in keeping with the highest traditions of Cargonia."

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	medaltype = "medal-silver"
	custom_materials = list(/datum/material/silver=1000)

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal of valor"
	desc = "A silver medal awarded for acts of exceptional valor."

/obj/item/clothing/accessory/medal/silver/security
	name = "robust security award"
	desc = "An award for distinguished combat and sacrifice in defence of Nanotrasen's commercial interests. Often awarded to security staff."

/obj/item/clothing/accessory/medal/silver/excellence
	name = "\proper the head of personnel award for outstanding achievement in the field of excellence"
	desc = "Nanotrasen's dictionary defines excellence as \"the quality or condition of being excellent\". This is awarded to those rare crewmembers who fit that definition."

/obj/item/clothing/accessory/medal/silver/bureaucracy
	name = "\improper Excellence in Bureaucracy Medal"
	desc = "Awarded for exemplary managerial services rendered while under contract with Nanotrasen."

/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	medaltype = "medal-gold"
	custom_materials = list(/datum/material/gold=1000)


/obj/item/clothing/accessory/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by CentCom. To receive such a medal is the highest honor and as such, very few exist. This medal is almost never awarded to anybody but commanders."

/obj/item/clothing/accessory/medal/plasma
	name = "plasma medal"
	desc = "An eccentric medal made of plasma."
	icon_state = "plasma"
	medaltype = "medal-plasma"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = -10, ACID = 0) //It's made of plasma. Of course it's flammable.
	custom_materials = list(/datum/material/plasma=1000)

/obj/item/clothing/accessory/medal/plasma/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/item/clothing/accessory/medal/plasma/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/item/clothing/accessory/medal/plasma/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	atmos_spawn_air("plasma=20;TEMP=[exposed_temperature]")
	visible_message(span_danger("\The [src] bursts into flame!"), span_userdanger("Your [src] bursts into flame!"))
	qdel(src)

/obj/item/clothing/accessory/medal/plasma/nobel_science
	name = "nobel sciences award"
	desc = "A plasma medal which represents significant contributions to the field of science or engineering."



////////////
//Armbands//
////////////

/obj/item/clothing/accessory/armband
	name = "red armband"
	desc = "A fancy red armband!"
	icon_state = "redband"
	attachment_slot = null

/obj/item/clothing/accessory/armband/deputy
	name = "security deputy armband"
	desc = "An armband, worn by personnel authorized to act as a deputy of station security."

/obj/item/clothing/accessory/armband/cargo
	name = "cargo bay guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is brown."
	icon_state = "cargoband"

/obj/item/clothing/accessory/armband/engine
	name = "engineering guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is orange with a reflective strip!"
	icon_state = "engieband"

/obj/item/clothing/accessory/armband/science
	name = "science guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is purple."
	icon_state = "rndband"

/obj/item/clothing/accessory/armband/hydro
	name = "hydroponics guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is green and blue."
	icon_state = "hydroband"

/obj/item/clothing/accessory/armband/med
	name = "medical guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is white."
	icon_state = "medband"

/obj/item/clothing/accessory/armband/medblue
	name = "medical guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is white and blue."
	icon_state = "medblueband"

//////////////
//OBJECTION!//
//////////////

/obj/item/clothing/accessory/lawyers_badge
	name = "attorney's badge"
	desc = "Fills you with the conviction of JUSTICE. Lawyers tend to want to show it to everyone they meet."
	icon_state = "lawyerbadge"

/obj/item/clothing/accessory/lawyers_badge/attack_self(mob/user)
	if(prob(1))
		user.say("The testimony contradicts the evidence!", forced = "attorney's badge")
	user.visible_message(span_notice("[user] shows [user.p_their()] attorney's badge."), span_notice("You show your attorney's badge."))

/obj/item/clothing/accessory/lawyers_badge/on_uniform_equip(obj/item/clothing/under/U, mob/living/user)
	RegisterSignal(user, COMSIG_LIVING_SLAM_TABLE, .proc/table_slam)
	user.bubble_icon = "lawyer"

/obj/item/clothing/accessory/lawyers_badge/on_uniform_dropped(obj/item/clothing/under/U, mob/living/user)
	UnregisterSignal(user, COMSIG_LIVING_SLAM_TABLE)
	user.bubble_icon = initial(user.bubble_icon)

/obj/item/clothing/accessory/lawyers_badge/proc/table_slam(mob/living/source, obj/structure/table/the_table)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/handle_table_slam, source)

/obj/item/clothing/accessory/lawyers_badge/proc/handle_table_slam(mob/living/user)
	user.say("Objection!!", spans = list(SPAN_YELL), forced=TRUE)

////////////////
//HA HA! NERD!//
////////////////
/obj/item/clothing/accessory/pocketprotector
	name = "pocket protector"
	desc = "Can protect your clothing from ink stains, but you'll look like a nerd if you're using one."
	icon_state = "pocketprotector"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/pocketprotector

/obj/item/clothing/accessory/pocketprotector/full/Initialize(mapload)
	. = ..()
	new /obj/item/pen/red(src)
	new /obj/item/pen(src)
	new /obj/item/pen/blue(src)

/obj/item/clothing/accessory/pocketprotector/cosmetology/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 3)
		new /obj/item/lipstick/random(src)

////////////////
//REAL BIG FAN//
////////////////

/obj/item/clothing/accessory/clown_enjoyer_pin
	name = "\improper Clown Pin"
	desc = "A pin to show off your appreciation for clowns and clowning!"
	icon_state = "clown_enjoyer_pin"

/obj/item/clothing/accessory/clown_enjoyer_pin/on_uniform_equip(obj/item/clothing/under/U, user)
	var/mob/living/L = user
	if(HAS_TRAIT(L, TRAIT_CLOWN_ENJOYER))
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "clown_enjoyer_pin", /datum/mood_event/clown_enjoyer_pin)

/obj/item/clothing/accessory/clown_enjoyer_pin/on_uniform_dropped(obj/item/clothing/under/U, user)
	var/mob/living/L = user
	if(HAS_TRAIT(L, TRAIT_CLOWN_ENJOYER))
		SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "clown_enjoyer_pin")

/obj/item/clothing/accessory/mime_fan_pin
	name = "\improper Mime Pin"
	desc = "A pin to show off your appreciation for mimes and miming!"
	icon_state = "mime_fan_pin"

/obj/item/clothing/accessory/mime_fan_pin/on_uniform_equip(obj/item/clothing/under/U, user)
	var/mob/living/L = user
	if(HAS_TRAIT(L, TRAIT_MIME_FAN))
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "mime_fan_pin", /datum/mood_event/mime_fan_pin)

/obj/item/clothing/accessory/mime_fan_pin/on_uniform_dropped(obj/item/clothing/under/U, user)
	var/mob/living/L = user
	if(HAS_TRAIT(L, TRAIT_MIME_FAN))
		SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "mime_fan_pin")

////////////////
//OONGA BOONGA//
////////////////

/obj/item/clothing/accessory/talisman
	name = "bone talisman"
	desc = "A hunter's talisman, some say the old gods smile on those who wear it."
	icon_state = "talisman"
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 20, BIO = 20, FIRE = 0, ACID = 25)
	attachment_slot = null

/obj/item/clothing/accessory/skullcodpiece
	name = "skull codpiece"
	desc = "A skull shaped ornament, intended to protect the important things in life."
	icon_state = "skull"
	above_suit = TRUE
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 20, BIO = 20, FIRE = 0, ACID = 25)
	attachment_slot = GROIN

/obj/item/clothing/accessory/skilt
	name = "Sinew Skirt"
	desc = "For the last time. IT'S A KILT not a skirt."
	icon_state = "skilt"
	above_suit = TRUE
	minimize_when_attached = FALSE
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 20, BIO = 20, FIRE = 0, ACID = 25)
	attachment_slot = GROIN

/obj/item/clothing/accessory/allergy_dogtag
	name = "Allergy dogtag"
	desc = "Dogtag with a list of your allergies"
	icon_state = "allergy"
	above_suit = FALSE
	minimize_when_attached = TRUE
	attachment_slot = CHEST
	///Display message
	var/display

/obj/item/clothing/accessory/allergy_dogtag/examine(mob/user)
	. = ..()
	. += "The dogtag has a listing of allergies : [display]"

/obj/item/clothing/accessory/allergy_dogtag/on_uniform_equip(obj/item/clothing/under/U, user)
	. = ..()
	RegisterSignal(U,COMSIG_PARENT_EXAMINE,.proc/on_examine)

/obj/item/clothing/accessory/allergy_dogtag/on_uniform_dropped(obj/item/clothing/under/U, user)
	. = ..()
	UnregisterSignal(U,COMSIG_PARENT_EXAMINE)

///What happens when we examine the uniform
/obj/item/clothing/accessory/allergy_dogtag/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "The dogtag has a listing of allergies : [display]"

/obj/item/clothing/accessory/pride
	name = "rainbow pride pin"
	desc = "A pin to show off your sexuality! Happy pride!"
	icon_state = "pride"

/obj/item/clothing/accessory/pride/bi
	name = "bisexual pin"
	icon_state = "pride_bi"

/obj/item/clothing/accessory/pride/trans
	name = "transgender pin"
	desc = "A pin to show off your solidarity with trans people! Trans rights!"
	icon_state = "pride_trans"

/obj/item/clothing/accessory/pride/pan
	name = "pansexual pin"
	icon_state = "pride_pan"

/obj/item/clothing/accessory/pride/ace
	name = "asexual pin"
	icon_state = "pride_ace"

/obj/item/clothing/accessory/pride/enby
	name = "non-binary pin"
	icon_state = "pride_enby"
	desc = "A pin to show off your chosen gender identity, or in this case, the lack thereof!"
