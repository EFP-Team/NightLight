/obj/machinery/robotic_fabricator
	name = "robotic fabricator"
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	density = TRUE
	anchored = TRUE
	var/metal_amount = 0
	var/operating = FALSE
	var/obj/item/being_built = null
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 5000

/obj/machinery/robotic_fabricator/attackby(obj/item/O, mob/living/user, params)
	if (istype(O, /obj/item/stack/sheet/metal))
		if (metal_amount < 150000)
			add_overlay("fab-load-metal")
			addtimer(CALLBACK(src, .proc/FinishLoadingMetal, O, user), 15)
		else
			to_chat(user, "\The [src] is full.")
	else
		return ..()

/obj/machinery/robotic_fabricator/proc/FinishLoadingMetal(obj/item/stack/sheet/metal/M, mob/living/user)
	cut_overlay("fab-load-metal")
	if(QDELETED(M) || QDELETED(user))
		return
	var/count = 0
	while(metal_amount < 150000 && !QDELETED(M))
		metal_amount += M.materials[MAT_METAL]
		M.use(1)
		count++

	to_chat(user, "<span class='notice'>You insert [count] metal sheet\s into \the [src].</span>")
	updateDialog()

/obj/machinery/robotic_fabricator/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

/obj/machinery/robotic_fabricator/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/robotic_fabricator/attack_hand(mob/user)
	var/dat
	if (..())
		return

	if (operating)
		dat = {"
<TT>Building [being_built.name].<BR>
Please wait until completion...</TT><BR>
<BR>
"}
	else
		dat = {"
<B>Metal Amount:</B> [min(150000, metal_amount)] cm<sup>3</sup> (MAX: 150,000)<BR><HR>
<BR>
<A href='?src=\ref[src];make=1'>Left Arm (25,000 cc metal.)<BR>
<A href='?src=\ref[src];make=2'>Right Arm (25,000 cc metal.)<BR>
<A href='?src=\ref[src];make=3'>Left Leg (25,000 cc metal.)<BR>
<A href='?src=\ref[src];make=4'>Right Leg (25,000 cc metal).<BR>
<A href='?src=\ref[src];make=5'>Chest (50,000 cc metal).<BR>
<A href='?src=\ref[src];make=6'>Head (50,000 cc metal).<BR>
<A href='?src=\ref[src];make=7'>Robot Frame (75,000 cc metal).<BR>
"}

	user << browse("<HEAD><TITLE>Robotic Fabricator Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=robot_fabricator")
	onclose(user, "robot_fabricator")
	return

/obj/machinery/robotic_fabricator/Topic(href, href_list)
	if (..())
		return

	usr.set_machine(src)
	add_fingerprint(usr)

	if (href_list["make"])
		if (!operating)
			var/part_type = text2num(href_list["make"])

			var/build_type = ""
			var/build_time = 200
			var/build_cost = 25000

			switch (part_type)
				if (1)
					build_type = "/obj/item/bodypart/l_arm/robot"
					build_time = 200
					build_cost = 10000

				if (2)
					build_type = "/obj/item/bodypart/r_arm/robot"
					build_time = 200
					build_cost = 10000

				if (3)
					build_type = "/obj/item/bodypart/l_leg/robot"
					build_time = 200
					build_cost = 10000

				if (4)
					build_type = "/obj/item/bodypart/r_leg/robot"
					build_time = 200
					build_cost = 10000

				if (5)
					build_type = "/obj/item/bodypart/chest/robot"
					build_time = 350
					build_cost = 40000

				if (6)
					build_type = "/obj/item/bodypart/head/robot"
					build_time = 350
					build_cost = 5000

				if (7)
					build_type = "/obj/item/robot_suit"
					build_time = 600
					build_cost = 15000

			var/building = text2path(build_type)
			if (!isnull(building))
				if (metal_amount >= build_cost)
					operating = TRUE
					use_power = ACTIVE_POWER_USE

					metal_amount = max(0, metal_amount - build_cost)

					being_built = new building(src)

					add_overlay("fab-active")
					updateUsrDialog()

					spawn (build_time)
						if (!isnull(being_built))
							being_built.loc = get_turf(src)
							being_built = null
						use_power = IDLE_POWER_USE
						operating = FALSE
						cut_overlay("fab-active")
		return

	updateUsrDialog()
