/obj/item/inducer_cell
	name = "\improper Cybersun Flash Inducer Cell"
	desc = "A single-use device that recharges all power cells carried by a person - even those in a weapon or device. Do not drop when in use."
	icon = 'icons/obj/devices/syndie_gadget.dmi'
	icon_state = "inducer_cell_off"
	inhand_icon_state = "flashtool"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	//Has this already been used?
	var/burntout = FALSE
	//Amount of time this takes between charge pulses.
	var/cycle_time = 0.5 SECONDS
	//How many times this will charge your gear and emit sparks
	var/pulse_amount = 4
	//Upper and lower bounds for how much of a cell is charged per pulse. This is a percentage.
	var/charge_upper = 30
	var/charge_lower = 20
	//With default settings, this will charge between 80% and 110% of every chargable item on you. Unless you drop it or something.

/obj/item/inducer_cell/interact(mob/user)
	if(!burntout)
		inductive_charge()
	return ..()

/obj/item/inducer_cell/proc/inductive_charge(mob/user)
	burntout = TRUE
	if(src.loc != user.loc)
		return
	icon_state = "inducer_cell"
	do_sparks(number = 2, source = src)
	src.Shake(2, 1, cycle_time)
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	pulse_amount--
	if(pulse_amount <= 0)
		addtimer(CALLBACK(src, PROC_REF(inductive_charge)), cycle_time)
	var/list/chargables = list()
	for(var/obj/item/stock_parts/power_store/cells in user.get_all_contents())
		if(cells.charge < cells.maxcharge)
			chargables += cells
	if(chargables.len)
		var/obj/item/stock_parts/power_store/charging = pick(chargables)
		charging.charge += min(charging.maxcharge - charging.charge, charging.maxcharge/(rand(charge_lower, charge_upper)))
