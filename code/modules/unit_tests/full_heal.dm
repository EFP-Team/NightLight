/// Tests the fully heal flag [HEAL_ORGANS].
/datum/unit_test/full_heal_heals_organs

/datum/unit_test/full_heal_heals_organs/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	for(var/obj/item/organ/internal/organ in dummy.internal_organs)
		organ.applyOrganDamage(50)

	dummy.fully_heal(HEAL_ORGANS)

	for(var/obj/item/organ/internal/organ in dummy.internal_organs)
		if(organ.damage <= 0)
			continue
		TEST_FAIL("Organ [organ] did not get healed by fullyheal flag HEAL_ORGANS.")

/// Tests the fully heal flag [HEAL_REFRESH_ORGANS].
/datum/unit_test/full_heal_regenerates_organs

/datum/unit_test/full_heal_regenerates_organs/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	var/list/we_started_with = list()

	for(var/obj/item/organ/internal/organ in dummy.internal_organs)
		we_started_with += organ.type
		qdel(organ)

	dummy.fully_heal(HEAL_REFRESH_ORGANS)

	for(var/obj/item/organ/organ_type as anything in we_started_with)
		if(dummy.get_organ(organ_type))
			continue
		TEST_FAIL("Organ [initial(organ_type.name)] didn't regenerate in the dummy after fullyheal flag HEAL_REFRESH_ORGANS.")

/// Tests the fully heal combination flag [HEAL_DAMAGE].
/datum/unit_test/full_heal_damage_types

/datum/unit_test/full_heal_damage_types/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	dummy.apply_damages(brute = 10, burn = 10, tox = 10, oxy = 10, clone = 10, stamina = 10)
	dummy.fully_heal(HEAL_DAMAGE)

	if(dummy_health == dummy.maxHealth)
		// Success case
		return

	// Fail case if they still have damage
	// Go into detail as to why now
	TEST_FAIL("After a fully heal  with flag HEAL_DAMAGE, not all damage was healed:")

	if(dummy.getBruteLoss())
		TEST_FAIL("The dummy still had brute damage!")
	if(dummy.getFireLoss())
		TEST_FAIL("The dummy still had burn damage!")
	if(dummy.getToxLoss())
		TEST_FAIL("The dummy still had toxins damage!")
	if(dummy.getOxyLoss())
		TEST_FAIL("The dummy still had oxy damage!")
	if(dummy.getCloneLoss())
		TEST_FAIL("The dummy still had clone damage!")
	if(dummy.getStaminaLoss())
		TEST_FAIL("The dummy still had stamina damage!")
