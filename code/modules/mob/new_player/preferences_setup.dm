
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override)
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE,FEMALE)
	underwear = random_underwear(gender)
	undershirt = random_undershirt(gender)
	skin_tone = random_skin_tone()
	hair_style = random_hair_style(gender)
	facial_hair_style = random_facial_hair_style(gender)
	hair_color = random_short_color()
	facial_hair_color = hair_color
	eye_color = random_eye_color()
	pref_species = new /datum/species/human()
	backbag = 2
	age = rand(AGE_MIN,AGE_MAX)

/datum/preferences/proc/update_preview_icon()		//seriously. This is horrendous.
	del(preview_icon_front)
	del(preview_icon_side)
	var/icon/preview_icon = null

	var/g = "m"
	if(gender == FEMALE)	g = "f"

	if(pref_species.id == "human" || !config.mutant_races)
		preview_icon = new /icon('icons/mob/human.dmi', "[skin_tone]_[g]_s")
	else
		preview_icon = new /icon('icons/mob/human.dmi', "[pref_species.id]_[g]_s")
		preview_icon.Blend("#[mutant_color]", ICON_MULTIPLY)

	var/datum/sprite_accessory/S
	if(underwear)
		S = underwear_list[underwear]
		if(S)
			preview_icon.Blend(new /icon(S.icon, "[S.icon_state]_s"), ICON_OVERLAY)

	if(undershirt)
		S = undershirt_list[undershirt]
		if(S)
			preview_icon.Blend(new /icon(S.icon, "[S.icon_state]_s"), ICON_OVERLAY)

	var/icon/eyes_s = new/icon()
	if(EYECOLOR in pref_species.specflags)
		eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[pref_species.eyes]_s")
		eyes_s.Blend("#[eye_color]", ICON_MULTIPLY)

	S = hair_styles_list[hair_style]
	if(S && (HAIR in pref_species.specflags))
		var/icon/hair_s = new/icon("icon" = S.icon, "icon_state" = "[S.icon_state]_s")
		hair_s.Blend("#[hair_color]", ICON_MULTIPLY)
		eyes_s.Blend(hair_s, ICON_OVERLAY)

	S = facial_hair_styles_list[facial_hair_style]
	if(S && (FACEHAIR in pref_species.specflags))
		var/icon/facial_s = new/icon("icon" = S.icon, "icon_state" = "[S.icon_state]_s")
		facial_s.Blend("#[facial_hair_color]", ICON_MULTIPLY)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

	var/icon/clothes_s = null
	if(job_civilian_low & ASSISTANT)//This gives the preview icon clothes depending on which job(if any) is set to 'high'
		clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "grey_s_e")
		clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "black_shoes"), ICON_UNDERLAY)
		if(backbag == 2)
			clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
		else if(backbag == 3)
			clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)

	else if(job_civilian_high)//I hate how this looks, but there's no reason to go through this switch if it's empty
		switch(job_civilian_high)
			if(HOP)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "hop_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "brown_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/hats.dmi', "hopcap_head"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				else if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(BARTENDER)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "ba_suit_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "black_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "armor_e"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				else if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(BOTANIST)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "hydroponics_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "black_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/gloves.dmi', "ggloves_gloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "apron_e"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				else if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(CHEF)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "chef_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "black_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/hats.dmi', "chef_head"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "chef_e"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(JANITOR)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "janitor_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "black_shoes"), ICON_UNDERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(LIBRARIAN)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "red_suit_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "black_shoes"), ICON_UNDERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(QUARTERMASTER)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "qm_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "brown_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/glasses.dmi', "sun_eyes"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/bureaucracy.dmi', "clipboard_l"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(CARGOTECH)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "cargo_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "black_shoes"), ICON_UNDERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(MINER)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "miner_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "black_shoes"), ICON_UNDERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "engiepack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-eng_back"), ICON_OVERLAY)
			if(LAWYER)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "bluesuit_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "brown_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "suitjacket_blue_open_e"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/storage.dmi', "briefcase_l"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(CHAPLAIN)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "chapblack_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "black_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/storage.dmi', "bible_r"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(CLOWN)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "clown_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "clown_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/masks.dmi', "clown_mask"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "clownpack_back"), ICON_OVERLAY)
			if(MIME)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "mime_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "black_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/gloves.dmi', "lgloves_gloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/masks.dmi', "mime_mask"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/hats.dmi', "beret_head"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "suspenders_e"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "mimepack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)

	else if(job_medsci_high)
		switch(job_medsci_high)
			if(RD)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "director_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "brown_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "labcoat_open_e"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/bureaucracy.dmi', "clipboard_l"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(SCIENTIST)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "toxinswhite_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "white_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "labcoat_tox_open_e"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(CHEMIST)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "chemistrywhite_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "white_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "labcoat_chem_open_e"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(CMO)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "cmo_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "brown_sheos"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "labcoat_cmo_open_e"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/storage.dmi', "firstaid_l"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "medicalpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-med_back"), ICON_OVERLAY)
			if(DOCTOR)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "medical_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "white_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "labcoat_open_e"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/storage.dmi', "firstaid_l"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "medicalpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-med_back"), ICON_OVERLAY)
			if(GENETICIST)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "geneticswhite_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "white_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "labcoat_gen_open_e"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(VIROLOGIST)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "virologywhite_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "white_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/masks.dmi', "sterile_mask"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "labcoat_vir_open_e"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "medicalpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-med_back"), ICON_OVERLAY)
			if(ROBOTICIST)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "robotics_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "black_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "labcoat_open_e"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/storage.dmi', "toolbox_blue_l"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)

	else if(job_engsec_high)
		switch(job_engsec_high)
			if(CAPTAIN)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "captain_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "brown_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/hats.dmi', "captain_head"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/glasses.dmi', "sun_eyes"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "capcarapace_e"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "captainpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-cap_back"), ICON_OVERLAY)
			if(HOS)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "hosred_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "jackboots_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/gloves.dmi', "bgloves_gloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/hats.dmi', "hoscap_head"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/glasses.dmi', "sunhud_eyes"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "hos_e"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "securitypack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-sec_back"), ICON_OVERLAY)
			if(WARDEN)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "warden_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "jackboots_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/gloves.dmi', "bgloves_gloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/hats.dmi', "policehelm_head"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/glasses.dmi', "sunhud_eyes"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "warden_jacket_e"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "securitypack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-sec_back"), ICON_OVERLAY)
			if(DETECTIVE)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "detective_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "brown_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/gloves.dmi', "bgloves_gloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/cigarettes.dmi', "cigaron_mask"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/hats.dmi', "detective_head"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "detective_e"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)
			if(OFFICER)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "secred_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "jackboots_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/hats.dmi', "helmet_head"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/suits.dmi', "armor_e"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "securitypack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-sec_back"), ICON_OVERLAY)
			if(CHIEF)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "chief_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "brown_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/gloves.dmi', "bgloves_gloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/belts.dmi', "utility_belt"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/cigarettes.dmi', "cigaron_mask"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/hats.dmi', "hardhat0_white_head"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "engiepack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-eng_back"), ICON_OVERLAY)
			if(ENGINEER)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "engine_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "orange_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/belts.dmi', "utility_belt"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/hats.dmi', "hardhat0_yellow_head"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "engiepack_back"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-eng_back"), ICON_OVERLAY)
			if(ATMOSTECH)
				clothes_s = new /icon('icons/obj/clothing/uniforms.dmi', "atmos_s_e")
				clothes_s.Blend(new /icon('icons/obj/clothing/shoes.dmi', "black_shoes"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/obj/clothing/belts.dmi', "utility_belt"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "backpack_back"), ICON_OVERLAY)
				else if(backbag == 3)
					clothes_s.Blend(new /icon('icons/obj/clothing/back.dmi', "satchel-norm_back"), ICON_OVERLAY)

	preview_icon.Blend(eyes_s, ICON_OVERLAY)
	if(clothes_s)
		preview_icon.Blend(clothes_s, ICON_OVERLAY)
	preview_icon_front = new(preview_icon, dir = SOUTH)
	preview_icon_side = new(preview_icon, dir = WEST)

	del(preview_icon)
	del(eyes_s)
	del(clothes_s)
