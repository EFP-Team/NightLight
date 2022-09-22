/datum/wires/explosive
	var/duds_number = 2 // All "dud" wires cause an explosion when cut or pulsed
	proper_name = "Explosive Device"
	randomize = TRUE // Prevents wires from showing up on blueprints

/datum/wires/explosive/New(atom/holder)
	add_duds(duds_number) // Duds also explode here.
	..()

/datum/wires/explosive/on_pulse(index)
	explode()

/datum/wires/explosive/on_cut(index, mend)
	explode()

/datum/wires/explosive/proc/explode()
	return

/datum/wires/explosive/chem_grenade
	duds_number = 1
	holder_type = /obj/item/grenade/chem_grenade
	var/fingerprint

/datum/wires/explosive/chem_grenade/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/item/grenade/chem_grenade/G = holder
	if(G.stage == GRENADE_WIRED)
		return TRUE

/datum/wires/explosive/chem_grenade/on_pulse(index)
	var/obj/item/grenade/chem_grenade/grenade = holder
	if(grenade.stage != GRENADE_READY)
		return
	. = ..()

/datum/wires/explosive/chem_grenade/on_cut(index, mend)
	var/obj/item/grenade/chem_grenade/grenade = holder
	if(grenade.stage != GRENADE_READY)
		return
	. = ..()

/datum/wires/explosive/chem_grenade/attach_assembly(color, obj/item/assembly/S)
	if(istype(S,/obj/item/assembly/timer))
		var/obj/item/grenade/chem_grenade/G = holder
		var/obj/item/assembly/timer/T = S
		G.det_time = T.saved_time*10
	else if(istype(S,/obj/item/assembly/prox_sensor))
		var/obj/item/assembly/prox_sensor/sensor = S
		var/obj/item/grenade/chem_grenade/grenade = holder
		grenade.landminemode = sensor
		sensor.proximity_monitor.set_ignore_if_not_on_turf(FALSE)
	else if(istype(S,/obj/item/assembly/health))
		var/obj/item/assembly/health/sensor = S
		if(!sensor.secured)
			sensor.toggle_secure()
		if(!sensor.scanning)
			sensor.toggle_scan()
	fingerprint = S.fingerprintslast
	return ..()

/datum/wires/explosive/chem_grenade/explode()
	var/obj/item/grenade/chem_grenade/grenade = holder
	var/obj/item/assembly/pulser = get_attached(get_wire(1))
	var/message = "\An [pulser] has pulsed [grenade] ([grenade.type]), which was installed by [fingerprint]"
	if(isvoice(pulser))
		var/obj/item/assembly/voice/spoken_trigger = pulser
		message +=  " with the following activation message: \"[spoken_trigger.recorded]\""
	if(!grenade.dud_flags)
		message_admins(message)
	log_game(message)
	var/mob/M = get_mob_by_ckey(fingerprint)
	grenade.log_grenade(M) //Used in arm_grenade() too but this one conveys where the mob who triggered the bomb is
	if(grenade.landminemode)
		grenade.detonate() ///already armed
	else
		grenade.arm_grenade() //The one here conveys where the bomb was when it went boom


/datum/wires/explosive/chem_grenade/detach_assembly(color)
	var/obj/item/assembly/S = get_attached(color)
	if(S && istype(S))
		assemblies -= color
		S.connected = null
		S.forceMove(holder.drop_location())
		var/obj/item/grenade/chem_grenade/G = holder
		G.landminemode = null
		return S

/datum/wires/explosive/c4 // Also includes X4
	holder_type = /obj/item/grenade/c4

/datum/wires/explosive/c4/explode()
	var/obj/item/grenade/c4/P = holder
	P.detonate()

/datum/wires/explosive/pizza
	holder_type = /obj/item/pizzabox

/datum/wires/explosive/pizza/New(atom/holder)
	wires = list(
		WIRE_DISARM
	)
	add_duds(3) // Duds also explode here.
	..()

/datum/wires/explosive/pizza/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/item/pizzabox/P = holder
	if(P.open && P.bomb)
		return TRUE

/datum/wires/explosive/pizza/get_status()
	var/obj/item/pizzabox/P = holder
	var/list/status = list()
	status += "The red light is [P.bomb_active ? "on" : "off"]."
	status += "The green light is [P.bomb_defused ? "on": "off"]."
	return status

/datum/wires/explosive/pizza/on_pulse(wire)
	var/obj/item/pizzabox/P = holder
	switch(wire)
		if(WIRE_DISARM) // Pulse to toggle
			P.bomb_defused = !P.bomb_defused
		else // Boom
			explode()

/datum/wires/explosive/pizza/on_cut(wire, mend)
	var/obj/item/pizzabox/P = holder
	switch(wire)
		if(WIRE_DISARM) // Disarm and untrap the box.
			if(!mend)
				P.bomb_defused = TRUE
		else
			if(!mend && !P.bomb_defused)
				explode()

/datum/wires/explosive/pizza/explode()
	var/obj/item/pizzabox/P = holder
	P.bomb.detonate()


/datum/wires/explosive/gibtonite
	holder_type = /obj/item/gibtonite

/datum/wires/explosive/gibtonite/explode()
	var/obj/item/gibtonite/P = holder
	P.GibtoniteReaction(null, 2)
