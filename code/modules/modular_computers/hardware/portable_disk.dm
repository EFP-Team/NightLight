/obj/item/weapon/computer_hardware/hard_drive/portable
	name = "data disk"
	desc = "Removable disk used to store data."
	power_usage = 10
	icon_state = "datadisk6"
	w_class = 1
	critical = 0
	max_capacity = 16
	origin_tech = "programming=1"
	device_type = "SDD"

/obj/item/weapon/computer_hardware/hard_drive/portable/on_install(obj/item/device/modular_computer/M, mob/living/user = null)
	M.verbs += /obj/item/device/modular_computer/proc/eject_disk

/obj/item/weapon/computer_hardware/hard_drive/portable/on_remove(obj/item/device/modular_computer/M, mob/living/user = null)
	..()
	M.verbs -= /obj/item/device/modular_computer/proc/eject_disk

/obj/item/weapon/computer_hardware/hard_drive/portable/install_default_programs()
	return // Empty by default

/obj/item/weapon/computer_hardware/hard_drive/portable/advanced
	name = "advanced data disk"
	power_usage = 20
	icon_state = "datadisk5"
	max_capacity = 64
	origin_tech = "programming=2"

/obj/item/weapon/computer_hardware/hard_drive/portable/super
	name = "super data disk"
	desc = "Removable disk used to store large amounts of data."
	power_usage = 40
	icon_state = "datadisk3"
	max_capacity = 256
	origin_tech = "programming=4"
