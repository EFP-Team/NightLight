/*
It's like a regular ol' straight pipe, but you can turn it on and off.
*/

/obj/machinery/atmospherics/components/binary/valve
	icon_state = "mvalve_map"
	name = "manual valve"
	desc = "A pipe with a valve that can be used to disable flow of gas through it."

	can_unwrench = TRUE

	var/frequency = 0
	var/id = null

	var/open = FALSE
	var/valve_type = "m" //lets us have a nice, clean, OOP update_icon_nopipes()

	construction_type = /obj/item/pipe/binary
	pipe_state = "mvalve"

/obj/machinery/atmospherics/components/binary/valve/open
	open = TRUE

/obj/machinery/atmospherics/components/binary/valve/update_icon_nopipes(animation = 0)
	normalize_dir()
	if(animation)
		flick("[valve_type]valve_[open][!open]",src)
	icon_state = "[valve_type]valve_[open?"on":"off"]"

/obj/machinery/atmospherics/components/binary/valve/proc/open()
	open = TRUE
	update_icon_nopipes()
	reconcile_parents()
	investigate_log("was opened by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/components/binary/valve/proc/close()
	open = FALSE
	update_icon_nopipes()
	investigate_log("was closed by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/components/binary/valve/proc/normalize_dir()
	if(dir==SOUTH)
		setDir(NORTH)
	else if(dir==WEST)
		setDir(EAST)

/obj/machinery/atmospherics/components/binary/valve/attack_ai(mob/user)
	return

/obj/machinery/atmospherics/components/binary/valve/attack_hand(mob/user)
	add_fingerprint(usr)
	update_icon_nopipes(1)
	sleep(10)
	if(open)
		close()
		return
	open()

/obj/machinery/atmospherics/components/binary/valve/digital		// can be controlled by AI
	name = "digital valve"
	desc = "A digitally controlled valve."
	icon_state = "dvalve_map"
	valve_type = "d"
	pipe_state = "dvalve"

/obj/machinery/atmospherics/components/binary/valve/digital/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/atmospherics/components/binary/valve/digital/update_icon_nopipes(animation)
	if(!is_operational())
		normalize_dir()
		icon_state = "dvalve_nopower"
		return
	..()
