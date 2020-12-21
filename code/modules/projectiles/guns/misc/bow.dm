
/obj/item/gun/ballistic/bow
	name = "longbow"
	desc = "While pretty finely crafted, surely you can find something better to use in the current year."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "bow"
	load_sound = null
	fire_sound = null
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	force = 15
	attack_verb_continuous = list("whipped", "cracked")
	attack_verb_simple = list("whip", "crack")
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	internal_magazine = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT
	var/drawn = FALSE

/obj/item/gun/ballistic/bow/dropped(mob/user)
	. = ..()
	drop_arrow()

/obj/item/gun/ballistic/bow/update_icon()
	. = ..()
	if(!chambered)
		icon_state = "bow"
	else
		icon_state = "bow_[drawn]"

/obj/item/gun/ballistic/bow/proc/drop_arrow()
	drawn = FALSE
	chambered = magazine.get_round()
	if(!chambered)
		return
	chambered.forceMove(drop_location())

/obj/item/gun/ballistic/bow/chamber_round()
	if(chambered || !magazine)
		return
	if(magazine.ammo_count())
		chambered = magazine.get_round(TRUE)
		chambered.forceMove(src)

/obj/item/gun/ballistic/bow/attack_self(mob/user)
	if(chambered)
		to_chat(user, "<span class='notice'>You [drawn ? "release the tension on" : "draw the string on"] [src].</span>")
		drawn = !drawn
	update_icon()

/obj/item/gun/ballistic/bow/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	if(!drawn)
		to_chat(user, "<span clasas='warning'>Without drawing the bow, the arrow uselessly falls to the ground.</span>")
		drop_arrow()
		update_icon()
		return
	drawn = FALSE
	. = ..() //fires, removing the arrow
	update_icon()

/obj/item/gun/ballistic/bow/shoot_with_empty_chamber(mob/living/user)
	return //so clicking sounds please

/obj/item/ammo_box/magazine/internal/bow
	name = "bowstring"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	max_ammo = 1
	start_empty = TRUE
	caliber = "arrow"

/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Stabby Stabman!"
	icon_state = "arrow"
	flags_1 = NONE
	throwforce = 1
	projectile_type = /obj/projectile/bullet/reusable/arrow
	firing_effect_type = null
	caliber = "arrow"
	heavy_metal = FALSE

/obj/projectile/bullet/reusable/arrow
	name = "arrow"
	desc = "Ow! Get it out of me!"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	damage = 25
	speed = 0.8
	range = 25

/obj/item/storage/bag/quiver
	name = "quiver"
	desc = "Holds arrows for your bow. Good, because while pocketing arrows is possible, it surely can't be pleasant."
	icon_state = "quiver"
	inhand_icon_state = "quiver"
	worn_icon_state = "harpoon_quiver"

/obj/item/storage/bag/quiver/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_TINY
	STR.max_items = 40
	STR.max_combined_w_class = 100
	STR.set_holdable(list(
		/obj/item/ammo_casing/caseless/arrow
		))

/obj/item/storage/bag/quiver/PopulateContents()
	. = ..()
	for(var/i in 1 to 10)
		new /obj/item/ammo_casing/caseless/arrow(src)
