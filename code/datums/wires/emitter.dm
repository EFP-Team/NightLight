
/datum/wires/emitter
	holder_type = /obj/machinery/power/emitter

/datum/wires/emitter/New(atom/holder)
	wires = list(WIRE_ZAP,WIRE_HACK,WIRE_TOGGLE)
	..()

/datum/wires/emitter/on_pulse(wire)
	var/obj/machinery/power/emitter/E = holder
	switch(wire)
		if(WIRE_ZAP)
			E.fire_beam_pulse()
		if(WIRE_HACK)
			E.mode = !E.mode
			E.set_projectile()
		if(WIRE_TOGGLE)
			if(E.active == TRUE)
				E.active = FALSE
			else
				E.interact(usr)
	..()
