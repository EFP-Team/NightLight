/datum/infection_upgrade
	// display stuff
	var/name = ""
	var/description = ""

	// application
	var/cost = 0
	var/increasing_cost = 0 // the amount the cost increases every time the upgrade is purchased
	var/times = 1 // times the upgrade can be bought
	var/bought = 0 // how many times the upgrade has been bought

/datum/infection_upgrade/proc/do_upgrade(atom/parent)
	times--
	bought++
	cost += increasing_cost
	upgrade_effect(parent)
	return

/datum/infection_upgrade/proc/upgrade_effect(atom/parent)
	return

///////////////////////
// Overmind Upgrades //
///////////////////////

/datum/infection_upgrade/overmind
	var/action_type // action type to unlock and add to the commander (if there is one)

/datum/infection_upgrade/overmind/upgrade_effect(mob/camera/commander/parentcommander)
	var/datum/action/cooldown/infection/add_action = new action_type()
	add_action.Grant(parentcommander)

/datum/infection_upgrade/overmind/turret
	name = "Turret Infection"
	description = "Gives you the ability to create turret infection. These automically target any hostile creatures around them, and have various effects to deal with many types of intruders."
	action_type = /datum/action/cooldown/infection/creator/turret
	cost = 1

/datum/infection_upgrade/overmind/freecam
	name = "Full Vision"
	description = "Allows you to see the entire station with no restrictions on the movement of your camera."
	action_type = /datum/action/cooldown/infection/freecam
	cost = 1

/datum/infection_upgrade/overmind/emppulse
	name = "Electromagnetic Pulse"
	description = "Generates an EMP in an area around your camera. Charges up for a period of time overlaying the area it will EMP before doing so."
	action_type = /datum/action/cooldown/infection/emppulse
	cost = 1

/datum/infection_upgrade/overmind/medical
	name = "Medical Diagnostics System"
	description = "Allows you to see the health of allies and enemies alike, giving you even greater strategical planning power with your forces."
	action_type = /datum/action/cooldown/infection/medicalhud
	cost = 1

///////////////////////////////
// Spore Type Change Upgrades//
///////////////////////////////

/datum/infection_upgrade/spore_type_change
	cost = 200
	var/new_type

/datum/infection_upgrade/spore_type_change/upgrade_effect(mob/living/simple_animal/hostile/infection/infectionspore/sentient/parentspore)
	parentspore.transfer_to_type(new_type)

/datum/infection_upgrade/spore_type_change/myconid_spore
	name = "Myconid Spore"
	description = "Has the capability to pass beacon walls and cause trouble for humans hiding behind them. Can upgrade to be able to grab humans."
	new_type = /mob/living/simple_animal/hostile/infection/infectionspore/sentient/myconid

/datum/infection_upgrade/spore_type_change/infector_spore
	name = "Infector Spore"
	description = "An underboss of the infection. Can upgrade to repair buildings around it, and can create spore possessed humans with dead bodies. "
	new_type = /mob/living/simple_animal/hostile/infection/infectionspore/sentient/infector

/datum/infection_upgrade/spore_type_change/hunter_spore
	name = "Hunter Spore"
	description = "A fast spore with abilities useful for hunting down humans. Works well with myconid spores that can grab humans past the beacon walls."
	new_type = /mob/living/simple_animal/hostile/infection/infectionspore/sentient/hunter

/datum/infection_upgrade/spore_type_change/destructive_spore
	name = "Destructive Spore"
	description = "A generally slow, tanky, and damaging spore useful for destroying structures. Effective for defending and advancing infectious structures."
	new_type = /mob/living/simple_animal/hostile/infection/infectionspore/sentient/destructive

///////////////////////////
// Myconid Spore Upgrades//
///////////////////////////

/datum/infection_upgrade/myconid

////////////////////////////
// Infector Spore Upgrades//
////////////////////////////

/datum/infection_upgrade/infector

//////////////////////////
// Hunter Spore Upgrades//
//////////////////////////

/datum/infection_upgrade/hunter/lifesteal
	name = "Lifesteal"
	description = "Does true damage to living targets by sapping health directly from them as well as healing you."
	cost = 200

/datum/infection_upgrade/hunter/lifesteal/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/lifesteal, 5)

///////////////////////////////
// Destructive Spore Upgrades//
///////////////////////////////

/datum/infection_upgrade/destructive/hydraulic_fists
	name = "Hydraulic Fists"
	description = "The compressed fluid in your arms allows you to deal much greater impacts which throw hit objects backward."
	cost = 200

/datum/infection_upgrade/destructive/hydraulic_fists/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/knockback, 4)

////////////////////////////////
// Turret Type Change Upgrades//
////////////////////////////////

/datum/infection_upgrade/turret_type_change
	cost = 30
	var/new_type
	var/upgrade_wait_time = 0

/datum/infection_upgrade/turret_type_change/upgrade_effect(obj/structure/infection/turret/parentturret)
	parentturret.change_to(new_type, parentturret.overmind, upgrade_wait_time)

/datum/infection_upgrade/turret_type_change/resistant_turret
	name = "Resistant Turret"
	description = "Triples the structural integrity of your turret."
	new_type = /obj/structure/infection/turret/resistant

/datum/infection_upgrade/turret_type_change/infernal_turret
	name = "Infernal Turret"
	description = "Increases speed of bullets and changes damage to burn."
	new_type = /obj/structure/infection/turret/infernal

/datum/infection_upgrade/turret_type_change/homing_turret
	name = "Homing Turret"
	description = "Shoots spores that have increased range and track their target."
	new_type = /obj/structure/infection/turret/homing

///////////////////////////
// Homing Turret Upgrades//
///////////////////////////

/datum/infection_upgrade/homing/homing_bullets
	name = "Homing Bullets"
	description = "Causes the bullets of this turret to home in on their target."
	times = 0
	bought = 1

/datum/infection_upgrade/homing/homing_bullets/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/homing, 15)

/datum/infection_upgrade/homing/turn_speed
	name = "Turn Speed"
	description = "Increases turn speed of shot homing spores."
	cost = 10
	times = 3

/datum/infection_upgrade/homing/turn_speed/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/homing, 15*(bought+1))

/datum/infection_upgrade/homing/flak_bullets
	name = "Flak Bullets"
	description = "Bullets that hit targets will break into tiny spores that do damage to other living creatures around the target."
	cost = 10
	increasing_cost = 10
	times = 3

/datum/infection_upgrade/homing/flak_bullets/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/shrapnel, /obj/item/projectile/bullet/infection/flak, bought)

/datum/infection_upgrade/homing/stamina_damage
	name = "Stamina Damage"
	description = "Homing spores deal only stamina damage, 1.5x damage bonus."
	cost = 10

/datum/infection_upgrade/homing/stamina_damage/upgrade_effect(obj/structure/infection/turret/parentturret)
	parentturret.projectile_type = /obj/item/projectile/bullet/infection/homing/stamina

/////////////////////////////
// Infernal Turret Upgrades//
/////////////////////////////

/datum/infection_upgrade/infernal/burning_spores
	name = "Burning Spores"
	description = "Sets fire to the target on hit."
	cost = 15

/datum/infection_upgrade/infernal/burning_spores/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/igniter, 4)

/datum/infection_upgrade/infernal/fire_rate
	name = "Fire Rate"
	description = "Increases the fire rate of the turret."
	cost = 15
	times = 3

/datum/infection_upgrade/infernal/fire_rate/upgrade_effect(obj/structure/infection/turret/parentturret)
	parentturret.frequency++

/datum/infection_upgrade/infernal/armour_penetration
	name = "Armour Penetration"
	description = "Increases the armour penetration of the turret."
	cost = 15
	times = 3

/datum/infection_upgrade/infernal/armour_penetration/upgrade_effect(atom/parent)
	return

//////////////////////////////
// Resistant Turret Upgrades//
//////////////////////////////

/datum/infection_upgrade/resistant/knockback
	name = "Knockback Spores"
	description = "Knocks the target back on hit."
	cost = 10

/datum/infection_upgrade/resistant/knockback/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/knockback, 4)

/datum/infection_upgrade/resistant/spore_bullets
	name = "Spore Bullets"
	description = "Has a chance to create infection spores on the target the bullet hits."
	cost = 10

/datum/infection_upgrade/resistant/spore_bullets/upgrade_effect(atom/parent)
	parent.AddComponent(/datum/component/summoning, list(/mob/living/simple_animal/hostile/infection/infectionspore), 10, 4, 0, "forms from the raw energy", 'sound/effects/blobattack.ogg')

//////////////////////
// Resource Upgrades//
//////////////////////

/datum/infection_upgrade/resource/production_rate
	name = "Production Rate"
	description = "Increases the points produced per tick by the resource structure."
	cost = 10
	increasing_cost = 10
	times = 3

/datum/infection_upgrade/resource/production_rate/upgrade_effect(obj/structure/infection/resource/parentresource)
	parentresource.produced++

/datum/infection_upgrade/resource/storage_unit
	name = "Storage Unit"
	description = "Increases the point return of this infection every time it produces, up to a maximum of 100 points. You can remove the structure at any time to claim the extra points."
	cost = 40

/datum/infection_upgrade/resource/storage_unit/upgrade_effect(obj/structure/infection/resource/parentresource)
	parentresource.point_return_gain += 0.25
	return

//////////////////////
// Factory Upgrades///
//////////////////////

/datum/infection_upgrade/factory/royal_guard
	name = "Royal Guard"
	description = "Attempts to produce a spore automatically whenever this structure takes damage. Can only produce 3 more than maximum spores."
	cost = 10

/datum/infection_upgrade/factory/royal_guard/upgrade_effect(atom/parent)
	return

/datum/infection_upgrade/factory/defensive_shield
	name = "Defensive Shield"
	description = "Automatically produces shield infection from all normal infection that are adjacent."
	cost = 20

/datum/infection_upgrade/factory/defensive_shield/upgrade_effect(atom/parent)
	return