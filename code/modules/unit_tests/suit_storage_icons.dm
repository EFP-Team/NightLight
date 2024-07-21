/// Makes sure suit slot items aren't using CS:S fallbacks.
/datum/unit_test/suit_storage_icons
	///These types need to be done, but it's been years so lets just grandfather them in until we get sprites made.
	var/list/explicit_types_to_ignore = list(
		/obj/item/storage/bag/rebar_quiver,
		/obj/item/climbing_hook,
		/obj/item/climbing_hook/syndicate,
		/obj/item/grapple_gun,
		/obj/item/knife/combat,
		/obj/item/knife/combat/survival,
		/obj/item/organ/internal/monster_core,
		/obj/item/organ/internal/monster_core/brimdust_sac,
		/obj/item/organ/internal/monster_core/regenerative_core/legion,
		/obj/item/organ/internal/monster_core/rush_gland,
		/obj/item/experi_scanner,
		/obj/item/assembly/flash,
		/obj/item/assembly/flash/memorizer,
		/obj/item/melee/baton/security/cattleprod/telecrystalprod,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana/bombanana,
		/obj/item/food/grown/banana/mime,
		/obj/item/food/grown/banana/bluespace,
		/obj/item/food/grown/banana/bunch,
		/obj/item/food/grown/banana/bunch/monkeybomb,
		/obj/item/grown/bananapeel,
		/obj/item/grown/bananapeel/bombanana,
		/obj/item/grown/bananapeel/mimanapeel,
		/obj/item/grown/bananapeel/bluespace,
		/obj/item/grown/bananapeel/specialpeel,
		/obj/item/instrument/violin,
		/obj/item/instrument/violin/golden,
		/obj/item/instrument/violin/festival,
		/obj/item/instrument/banjo,
		/obj/item/instrument/guitar,
		/obj/item/instrument/eguitar,
		/obj/item/instrument/glockenspiel,
		/obj/item/instrument/accordion,
		/obj/item/instrument/trumpet,
		/obj/item/instrument/trumpet/spectral,
		/obj/item/instrument/saxophone,
		/obj/item/instrument/trombone,
		/obj/item/instrument/recorder,
		/obj/item/instrument/harmonica,
		/obj/item/instrument/bikehorn,
		/obj/item/instrument/musicalmoth,
		/obj/item/instrument/piano_synth,
		/obj/item/instrument/bilehorn,
		/obj/item/melee/energy/sword,
		/obj/item/melee/energy/sword/cyborg/saw,
		/obj/item/melee/energy/sword/pirate,
		/obj/item/shield/energy,
		/obj/item/shield/energy/advanced,
		/obj/item/shield/energy/bananium,
		/obj/item/gun/magic/staff/chaos/true_wabbajack,
		/obj/item/gun/magic/staff/locker,
		/obj/item/gun/magic/staff/flying,
		/obj/item/gun/magic/staff/shrink,
		/obj/item/gun/ballistic/shotgun/hook,
		/obj/item/gun/ballistic/automatic/surplus,
		/obj/item/climbing_hook/emergency,
		/obj/item/knife/combat/cyborg,
		/obj/item/organ/internal/monster_core/regenerative_core,
		/obj/item/assembly/flash/cyborg,
		/obj/item/instrument/saxophone/spectral,
		/obj/item/instrument/trombone/spectral,
		/obj/item/melee/energy/sword/cyborg,
	)

/datum/unit_test/suit_storage_icons/Run()
	var/list/wearable_item_paths = list()

	for(var/obj/item/item_path as anything in subtypesof(/obj/item))
		var/cached_slot_flags = initial(item_path.slot_flags)
		if(!(cached_slot_flags & ITEM_SLOT_SUITSTORE) || (initial(item_path.item_flags) & ABSTRACT))
			continue
		wearable_item_paths |= item_path

	for(var/obj/item/clothing/clothing_path in (subtypesof(/obj/item/clothing) - typesof(/obj/item/clothing/head/mob_holder) - typesof(/obj/item/clothing/suit/space/santa))) //mob_holder is a psuedo abstract item. santa suit is a VERY SNOWFLAKE admin spawn suit that can hold /every/ possible item.
		for(var/path in clothing_path::allowed) //find all usable suit storage stuff.
			wearable_item_paths |= path

	for(var/datum/mod_theme/mod_theme as anything in GLOB.mod_themes)
		mod_theme = GLOB.mod_themes[mod_theme]
		wearable_item_paths |= mod_theme.allowed_suit_storage

	var/list/already_warned_icons = list()
	for(var/obj/item/item_path as anything in typecacheof(wearable_item_paths))
		if(initial(item_path.item_flags) & ABSTRACT)
			continue
		if(item_path in explicit_types_to_ignore) //Temporarily disabled checking on these paths.
			continue

		var/worn_icon = initial(item_path.worn_icon) //override icon file. where our sprite is contained if set. (ie modularity stuff)
		var/worn_icon_state = initial(item_path.worn_icon_state) //overrides icon_state.
		var/icon_state = worn_icon_state || initial(item_path.icon_state) //icon_state. what sprite name we are looking for.


		if(isnull(icon_state))
			continue //no sprite for the item.
		if(icon_state in already_warned_icons)
			continue

		if(worn_icon) //easiest to check since we override everything.
			if(!(icon_state in icon_states(worn_icon)))
				TEST_FAIL("[item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\" in worn_icon override file, '[worn_icon]'")
			continue

		if(!(icon_state in icon_states('icons/mob/clothing/belt_mirror.dmi')))
			already_warned_icons += icon_state
			TEST_FAIL("[item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\"")
