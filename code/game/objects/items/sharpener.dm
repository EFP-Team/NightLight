/obj/item/sharpener
	name = "whetstone"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "sharpener"
	desc = "A block that makes things sharp."
	force = 5
	var/used = 0
	var/increment = 4
	var/max = 30
	var/prefix = "sharpened"
	var/requires_sharpness = 1


/obj/item/sharpener/attackby(obj/item/I, mob/user, params)
	if(used)
		to_chat(user, "<span class='warning'>The sharpening block is too worn to use again!</span>")
		return
	if(I.force >= max || I.throwforce >= max)//no esword sharpening
		to_chat(user, "<span class='warning'>[I] is much too powerful to sharpen further!</span>")
		return
	if(requires_sharpness && !I.get_sharpness())
		to_chat(user, "<span class='warning'>You can only sharpen items that are already sharp, such as knives!</span>")
		return
	if(istype(I, /obj/item/melee/transforming/energy))
		to_chat(user, "<span class='warning'>You don't think \the [I] will be the thing getting modified if you use it on \the [src]!</span>")
		return

	// some two handed items should still be sharpenable, but handle force differently. therefore this stuff is needed
	if(SEND_SIGNAL(I, COMSIG_IS_TWOHANDED))
		var/force_wielded = SEND_SIGNAL(src, COMSIG_TWOHANDED_GET_FORCEWIELDED)
		if(force_wielded >= max)
			to_chat(user, "<span class='warning'>[I] is much too powerful to sharpen further!</span>")
			return
		if(SEND_SIGNAL(I, COMSIG_IS_TWOHANDED_WIELDED))
			to_chat(user, "<span class='warning'>[I] must be unwielded before it can be sharpened!</span>")
			return
		SEND_SIGNAL(src, COMSIG_TWOHANDED_SET_FORCEWIELDED, CLAMP(force_wielded + increment, 0, max)) //wieldforce is increased since normal force wont stay
	if(I.force > initial(I.force))
		to_chat(user, "<span class='warning'>[I] has already been refined before. It cannot be sharpened further!</span>")
		return
	user.visible_message("<span class='notice'>[user] sharpens [I] with [src]!</span>", "<span class='notice'>You sharpen [I], making it much more deadly than before.</span>")
	playsound(src, 'sound/items/unsheath.ogg', 25, TRUE)
	I.sharpness = IS_SHARP_ACCURATE
	I.force = clamp(I.force + increment, 0, max)
	I.throwforce = clamp(I.throwforce + increment, 0, max)
	I.name = "[prefix] [I.name]"
	name = "worn out [name]"
	desc = "[desc] At least, it used to."
	used = 1
	update_icon()

/obj/item/sharpener/super
	name = "super whetstone"
	desc = "A block that will make your weapon sharper than Einstein on adderall."
	increment = 200
	max = 200
	prefix = "super-sharpened"
	requires_sharpness = 0
