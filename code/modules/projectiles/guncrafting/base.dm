/obj/item/weapon/gun_attachment/base
	name = "base"
	var/internal = 0
	var/mag_type = /obj/item/ammo_box/magazine/m10mm
	var/list/energy_type = list(/obj/item/ammo_casing/energy/laser)
	var/obj/item/ammo_casing/energy/energy_ref
	var/the_item_state = "laser"
	not_okay = /obj/item/weapon/gun_attachment/base

/obj/item/weapon/gun_attachment/base/on_attach(var/obj/item/weapon/gun/owner)
	..()
	if(owner.chambered)
		qdel(owner.chambered)
	owner.base = src
	switch(gun_type)
		if(CUSTOMIZABLE_REVOLVER)
			var/obj/item/weapon/gun/ballistic/O = owner
			O.mag_type = mag_type
			if(internal)
				O.magazine = new mag_type(O)
				O.uses_internal = 1
			else
				O.uses_internal = 0
			if(O.chambered)
				qdel(O.chambered)
			O.chamber_round()
			if mag_type == /obj/item/ammo_box/magazine/internal/cylinder/rev38
				name = ".38 Revolver"
			else
				if mag_type == /obj/item/ammo_box/magazine/internal/cylinder
				name = ".357 Revolver"
		if(CUSTOMIZABLE_PROJECTILE)
			var/obj/item/weapon/gun/ballistic/O = owner
			O.mag_type = mag_type
			if(internal)
				O.magazine = new mag_type(O)
				O.uses_internal = 1
			else
				O.uses_internal = 0
			if(O.chambered)
				qdel(O.chambered)
			O.chamber_round()
			if mag_type == /obj/item/ammo_box/magazine/guncrafting_ar
				name == "Assault Rifle"
			if mag_type == /obj/item/ammo_box/magazine/guncrafting_pistol
				name == "10mm Pistol"
			if mag_type == /obj/item/ammo_box/magazine/internal/shot/guncrafting
				name == "Shotgun"
			if mag_type == /obj/item/ammo_box/magazine/internal/shot/dual
				name == "Dual Barrled Shotgun"
				
		if(CUSTOMIZABLE_ENERGY)
			var/obj/item/weapon/gun/energy/E = owner
			for(var/EN in energy_type)
				var/obj/item/ammo_casing/energy/energy_casing = EN
				energy_ref = new energy_casing
				E.ammo_type += energy_ref
			E.recharge_newshot()
			E.fire_sound = E.chambered.fire_sound
	owner.item_state = the_item_state
	if(istype(owner.loc, /mob/living/carbon))
		var/mob/living/carbon/C = owner.loc
		C.update_inv_hands()
		if(obj/item/ammo_casing/energy/ion in energy_type)
			name == "Ion Gun"
		if(obj/item/ammo_casing/energy/bee in energy_type)
			name == "Bee Gun"
		if(obj/item/ammo_casing/energy/tesla_revolver in energy_type)
			name == "Tesla Revolver"
		if(obj/item/ammo_casing/energy/xray in energy_type)
			name == "Xray Gun"
		if(obj/item/ammo_casing/energy/lasergun in energy_type)
			name == "Laser Gun
		if(obj/item/ammo_casing/energy/disabler in energy_type)
			name == "Disabler Gun"
		if(obj/item/ammo_casing/energy/electrode in energy_type)
			name == "Stun Gun"
		if(obj/item/ammo_casing/energy/lasergun in energy_type)	&& if (obj/item/ammo_casing/energy/disabler in energy_type)
			name == "Hybrid Taser Gun"
		if(obj/item/ammo_casing/energy/disabler in energy_type) && if(obj/item/ammo_casing/energy/electrode in energy_type)
			name == "Energy Gun"
			

/obj/item/weapon/gun_attachment/base/on_remove(var/obj/item/weapon/gun/owner)
	..()
	switch(gun_type)
		if(CUSTOMIZABLE_PROJECTILE || CUSTOMIZABLE_REVOLVER)
			var/obj/item/weapon/gun/ballistic/O = owner
			O.mag_type = null
			if(O.magazine)
				qdel(O.magazine)
			if(O.chambered)
				qdel(O.chambered)
			if(O.uses_internal)
				O.uses_internal = 0
		if(CUSTOMIZABLE_ENERGY)
			var/obj/item/weapon/gun/energy/E = owner
			E.ammo_type = list()
			if(!E.power_supply)
				if(E.cell_type)
					E.power_supply = new E.cell_type(E)
				else
					E.power_supply = new(E)
	owner.base = null
	owner.item_state = initial(owner.item_state)
	if(istype(owner.loc, /mob/living/carbon))
		var/mob/living/carbon/C = owner.loc
		C.update_inv_hands()
