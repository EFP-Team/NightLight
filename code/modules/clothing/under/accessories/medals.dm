/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)
	resistance_flags = FIRE_PROOF
	/// Sprite used for medalbox
	var/medaltype = "medal"
	/// Has this been use for a commendation?
	var/commendation_message
	/// Who was first given this medal
	var/awarded_to
	/// Who gave out this medal
	var/awarder

/// Callback for do_after to check if we can still be pinned
/obj/item/clothing/accessory/medal/proc/pin_checks(mob/living/pinner, mob/living/carbon/human/pinning_on)
	if(QDELETED(src) || QDELETED(pinner) || QDELETED(pinning_on))
		return FALSE
	if(!pinner.is_holding(src) || !pinner.Adjacent(pinning_on))
		return FALSE
	var/obj/item/clothing/under/pinning_on_uniform = pinning_on.w_uniform
	if(!istype(pinning_on_uniform) || !can_attach_accessory(pinning_on_uniform, pinner))
		return FALSE
	return TRUE

/obj/item/clothing/accessory/medal/pre_attack(atom/target, mob/living/user, params)
	. = ..()
	if(.)
		return
	if(!ishuman(target) || target == user)
		return

	. = TRUE // no attack chain please

	var/mob/living/carbon/human/distinguished = target
	var/obj/item/clothing/under/distinguished_uniform = distinguished.w_uniform
	if(!istype(distinguished_uniform))
		distinguished.balloon_alert(user, "no uniform to pin on!")
		return .
	if(!can_attach_accessory(distinguished_uniform, user))
		// Check handles feedback messages and etc
		return .

	user.visible_message(
		span_notice("[user] tries to pin [src] on [distinguished]'s chest."),
		span_notice("You try to pin [src] on [distinguished]'s chest."),
	)

	commendation_message = tgui_input_text(user, "Reason for this commendation? It will be recorded by Nanotrasen.", "Commendation", max_length = 140)
	if(!commendation_message || !pin_checks(user, distinguished))
		return .
	if(!do_after(user, 2 SECONDS, distinguished, extra_checks = CALLBACK(src, PROC_REF(pin_checks), user, distinguished)))
		return .

	if(distinguished_uniform.attach_accessory(src, user))
		user.visible_message(
			span_notice("[user] pins [src] on [distinguished]'s chest."),
			span_notice("You pin [src] on [distinguished]'s chest."),
		)
	else
		user.visible_message(
			span_warning("[user] fails to pin [src] on [distinguished]'s chest, seemingly unable to part with it."),
			span_warning("You fail to pin [src] on [distinguished]'s chest."),
		)

	return .

/obj/item/clothing/accessory/medal/attach(obj/item/clothing/under/attach_to, mob/living/attacher)
	var/mob/living/distinguished = attach_to.loc
	if(isnull(attacher) || !istype(distinguished) || distinguished == attacher || awarded_to)
		// You can't be awarded by nothing, you can't award yourself, and you can't be awarded someone else's medal
		return ..()

	awarder = attacher.real_name
	awarded_to = distinguished.real_name

	update_appearance(UPDATE_DESC)
	add_memory_in_range(distinguished, 7, /datum/memory/received_medal, protagonist = distinguished, deuteragonist = attacher, medal_type = src, medal_text = commendation_message)
	distinguished.log_message("was given the following commendation by <b>[key_name(attacher)]</b>: [commendation_message]", LOG_GAME, color = "green")
	message_admins("<b>[key_name_admin(distinguished)]</b> was given the following commendation by <b>[key_name_admin(attacher)]</b>: [commendation_message]")
	GLOB.commendations += "[awarder] awarded <b>[awarded_to]</b> the <span class='medaltext'>[name]</span>! \n- [commendation_message]"
	SSblackbox.record_feedback("associative", "commendation", 1, list("commender" = "[awarder]", "commendee" = "[awarded_to]", "medal" = "[src]", "reason" = commendation_message))

	return ..()

/obj/item/clothing/accessory/medal/update_desc(updates)
	. = ..()
	if(commendation_message && awarded_to && awarder)
		desc += span_info("<br>The inscription reads: [commendation_message] - Awarded to [awarded_to] by [awarder]")

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
	custom_materials = list(/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT)

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
	custom_materials = list(/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT)

/obj/item/clothing/accessory/medal/med_medal
	name = "exemplary performance medal"
	desc = "A medal awarded to those who have shown distinguished conduct, performance, and initiative within the medical department."
	icon_state = "med_medal"

/obj/item/clothing/accessory/medal/med_medal2
	name = "excellence in medicine medal"
	desc = "A medal awarded to those who have shown legendary performance, competence, and initiative beyond all expectations within the medical department."
	icon_state = "med_medal2"

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
	custom_materials = list(/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT)

/obj/item/clothing/accessory/medal/plasma/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/item/clothing/accessory/medal/plasma/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/item/clothing/accessory/medal/plasma/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	atmos_spawn_air("[GAS_PLASMA]=20;[TURF_TEMPERATURE(exposed_temperature)]")
	visible_message(span_danger("\The [src] bursts into flame!"), span_userdanger("Your [src] bursts into flame!"))
	qdel(src)

/obj/item/clothing/accessory/medal/plasma/nobel_science
	name = "nobel sciences award"
	desc = "A plasma medal which represents significant contributions to the field of science or engineering."
