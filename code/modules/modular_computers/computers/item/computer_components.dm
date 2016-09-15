/obj/item/device/modular_computer/proc/can_install_component(obj/item/weapon/computer_hardware/H, mob/living/user = null)
	if(!H.can_install(src, user))
		return FALSE

	if(H.w_class > max_hardware_size)
		user << "<span class='warning'>This component is too large for \the [src]!</span>"
		return FALSE

	if(all_components[H.device_type])
		user << "<span class='warning'>This computer's hardware slot is already occupied by \the [all_components[H.device_type]].</span>"
		return FALSE
	return TRUE


// Installs component.
/obj/item/device/modular_computer/proc/install_component(obj/item/weapon/computer_hardware/H, mob/living/user = null)
	if(!can_install_component(H, user))
		return FALSE

	if(user && !user.unEquip(H))
		return FALSE

	all_components[H.device_type] = H

	user << "<span class='notice'>You install \the [H] into \the [src].</span>"
	H.forceMove(src)
	H.holder = src
	H.on_install(src, user)
	return H


// Uninstalls component.
/obj/item/device/modular_computer/proc/uninstall_component(obj/item/weapon/computer_hardware/H, mob/living/user = null)
	if(H.holder != src) // Not our component at all.
		return FALSE

	all_components.Remove(H.device_type)

	user << "<span class='notice'>You remove \the [H] from \the [src].</span>"

	H.forceMove(get_turf(src))
	H.holder = null
	H.on_remove(src, user)
	if(enabled && !use_power())
		shutdown_computer()
	update_icon()
	return H


// Checks all hardware pieces to determine if name matches, if yes, returns the hardware piece, otherwise returns null
/obj/item/device/modular_computer/proc/find_hardware_by_name(name)
	for(var/i in all_components)
		var/obj/O = all_components[i]
		if(O.name == name)
			return O
	return null
