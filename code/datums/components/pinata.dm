///Objects or mobs with this componenet will drop items when taking damage.
/datum/component/pinata
	///How much damage does an attack need to do to have a chance to drop "candy"
	var/minimum_damage = 5
	///What is the likelyhood some "candy" should drop when attacked.
	var/drop_chance = 50
	///A list of "candy" items that can be dropped when taking damage
	var/candy = list(/obj/item/food/candy, /obj/item/food/lollipop, /obj/item/food/gumball, /obj/item/food/bubblegum, /obj/item/food/chocolatebar)

/datum/component/pinata/Initialize()
	if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(damage_inflicted))
		RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(pinata_broken))
	else
		RegisterSignal(parent, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(damage_inflicted))
		RegisterSignal(parent, COMSIG_ATOM_DESTRUCTION, PROC_REF(pinata_broken))

/datum/component/pinata/proc/damage_inflicted(obj/target, damage)
	SIGNAL_HANDLER
	if(damage < minimum_damage && prob(drop_chance))
		return
	var/list/turf_options = get_adjacent_open_turfs(parent)
	turf_options += get_turf(parent)
	if(length(turf_options))
		var/dropped_item = pick(candy)
		new dropped_item(pick(turf_options))

/datum/component/pinata/proc/pinata_broken()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/pinata/Destroy(force, silent)
	UnregisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(parent, COMSIG_LIVING_DEATH)
	UnregisterSignal(parent, COMSIG_ATOM_TAKE_DAMAGE)
	UnregisterSignal(parent, COMSIG_ATOM_DESTRUCTION)
	return ..()
