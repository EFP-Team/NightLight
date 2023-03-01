/datum/team/xeno
	name = "\improper Aliens"

//Simply lists them.
/datum/team/xeno/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>The [name] were:</span>"
	parts += printplayerlist(members)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/antagonist/xeno
	name = "\improper Xenomorph"
	job_rank = ROLE_ALIEN
	show_in_antagpanel = FALSE
	antagpanel_category = ANTAG_GROUP_XENOS
	prevent_roundtype_conversion = FALSE
	show_to_ghosts = TRUE
	var/datum/team/xeno/xeno_team

/datum/antagonist/xeno/create_team(datum/team/xeno/new_team)
	if(!new_team)
		for(var/datum/antagonist/xeno/X in GLOB.antagonists)
			if(!X.owner || !X.xeno_team)
				continue
			xeno_team = X.xeno_team
			return
		xeno_team = new
	else
		if(!istype(new_team))
			CRASH("Wrong xeno team type provided to create_team")
		xeno_team = new_team

/datum/antagonist/xeno/get_team()
	return xeno_team

/datum/antagonist/xeno/get_preview_icon()
	return finish_preview_icon(icon('icons/mob/nonhuman-player/alien.dmi', "alienh"))

/datum/antagonist/xeno/captive
	name = "\improper Captive Xenomorph"
	var/datum/team/xeno/captive/captive_team

/datum/antagonist/xeno/captive/create_team(datum/team/xeno/captive/new_team)
	if(!new_team)
		for(var/datum/antagonist/xeno/captive/captive_xeno in GLOB.antagonists)
			if(!captive_xeno.owner || !captive_xeno.captive_team)
				continue
			captive_team = captive_xeno.captive_team
			return
		captive_team = new
		captive_team.progenitor = owner
	else
		if(!istype(new_team))
			CRASH("Wrong xeno team type provided to create_team")
		captive_team = new_team

/datum/team/xeno/captive
	name = "\improper Captive Aliens"
	///The first member of this team, presumably the queen.
	var/progenitor

//Ensures
/datum/team/xeno/captive/roundend_report()
	var/list/parts = list()

	if(istype(get_area(progenitor), /area/station/science/xenobiology))
		parts += span_red("")
	else
		parts += span_nicegreen("")

	for(var/datum/mind/alien_mind in members)
		if(istype(get_area(alien_mind.current), /area/station/science/xenobiology))

	parts += printplayerlist(members)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"


//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
	if(!mind.has_antag_datum(/datum/antagonist/xeno))
		if(SScommunications.xenomorph_egg_delivered && istype(get_area(src), /area/station/science/xenobiology)) //Captivity check
			mind.add_antag_datum(/datum/antagonist/xeno/captive)
		else
			mind.add_antag_datum(/datum/antagonist/xeno)

		mind.set_assigned_role(SSjob.GetJobType(/datum/job/xenomorph))
		mind.special_role = ROLE_ALIEN

/mob/living/carbon/alien/on_wabbajacked(mob/living/new_mob)
	. = ..()
	if(!mind)
		return
	if(isalien(new_mob))
		return
	mind.remove_antag_datum(/datum/antagonist/xeno)
	mind.set_assigned_role(SSjob.GetJobType(/datum/job/unassigned))
	mind.special_role = null
