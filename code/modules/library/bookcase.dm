#define BOOKCASE_UNANCHORED 0
#define BOOKCASE_ANCHORED 1
#define BOOKCASE_FINISHED 2

/*
 * Bookcase
 */
/obj/structure/bookcase
	name = "bookcase"
	icon = 'icons/obj/library.dmi'
	icon_state = "bookempty"
	desc = "A great place for storing knowledge."
	anchored = FALSE
	density = TRUE
	opacity = FALSE
	resistance_flags = FLAMMABLE
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 0)
	var/state = BOOKCASE_UNANCHORED
	/// When enabled, books_to_load number of random books will be generated for this bookcase when first interacted with.
	var/load_random_books = FALSE
	/// The category of books to pick from when populating random books.
	var/random_category = null
	/// How many random books to generate.
	var/books_to_load = 0

/obj/structure/bookcase/examine(mob/user)
	. = ..()
	if(!anchored)
		. += span_notice("The <i>bolts</i> on the bottom are unsecured.")
	else
		. += span_notice("It's secured in place with <b>bolts</b>.")
	switch(state)
		if(BOOKCASE_UNANCHORED)
			. += span_notice("There's a <b>small crack</b> visible on the back panel.")
		if(BOOKCASE_ANCHORED)
			. += span_notice("There's space inside for a <i>wooden</i> shelf.")
		if(BOOKCASE_FINISHED)
			. += span_notice("There's a <b>small crack</b> visible on the shelf.")

/obj/structure/bookcase/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	set_anchored(TRUE)
	state = BOOKCASE_FINISHED
	for(var/obj/item/I in loc)
		if(!isbook(I))
			continue
		I.forceMove(src)
	update_appearance()

/obj/structure/bookcase/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	state = anchorvalue
	if(!anchorvalue) //in case we were vareditted or uprooted by a hostile mob, ensure we drop all our books instead of having them disappear till we're rebuild.
		var/atom/Tsec = drop_location()
		for(var/obj/I in contents)
			if(!isbook(I))
				continue
			I.forceMove(Tsec)
	update_appearance()

/obj/structure/bookcase/attackby(obj/item/I, mob/user, params)
	switch(state)
		if(BOOKCASE_UNANCHORED)
			if(I.tool_behaviour == TOOL_WRENCH)
				if(I.use_tool(src, user, 20, volume=50))
					to_chat(user, span_notice("You wrench the frame into place."))
					set_anchored(TRUE)
			else if(I.tool_behaviour == TOOL_CROWBAR)
				if(I.use_tool(src, user, 20, volume=50))
					to_chat(user, span_notice("You pry the frame apart."))
					deconstruct(TRUE)

		if(BOOKCASE_ANCHORED)
			if(istype(I, /obj/item/stack/sheet/mineral/wood))
				var/obj/item/stack/sheet/mineral/wood/W = I
				if(W.get_amount() >= 2)
					W.use(2)
					to_chat(user, span_notice("You add a shelf."))
					state = BOOKCASE_FINISHED
					update_appearance()
			else if(I.tool_behaviour == TOOL_WRENCH)
				I.play_tool_sound(src, 100)
				to_chat(user, span_notice("You unwrench the frame."))
				set_anchored(FALSE)

		if(BOOKCASE_FINISHED)
			var/datum/component/storage/STR = I.GetComponent(/datum/component/storage)
			if(isbook(I))
				if(!user.transferItemToLoc(I, src))
					return
				update_appearance()
			else if(STR)
				for(var/obj/item/T in I.contents)
					if(istype(T, /obj/item/book) || istype(T, /obj/item/spellbook))
						STR.remove_from_storage(T, src)
				to_chat(user, span_notice("You empty \the [I] into \the [src]."))
				update_appearance()
			else if(istype(I, /obj/item/pen))
				if(!user.is_literate())
					to_chat(user, span_notice("You scribble illegibly on the side of [src]!"))
					return
				var/newname = tgui_input_text(user, "What would you like to title this bookshelf?", "Bookshelf Renaming", max_length = MAX_NAME_LEN)
				if(!user.canUseTopic(src, BE_CLOSE))
					return
				if(!newname)
					return
				else
					name = "bookcase ([sanitize(newname)])"
			else if(I.tool_behaviour == TOOL_CROWBAR)
				if(length(contents))
					to_chat(user, span_warning("You need to remove the books first!"))
				else
					I.play_tool_sound(src, 100)
					to_chat(user, span_notice("You pry the shelf out."))
					new /obj/item/stack/sheet/mineral/wood(drop_location(), 2)
					state = BOOKCASE_ANCHORED
					update_appearance()
			else
				return ..()


/obj/structure/bookcase/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!istype(user))
		return
	if(load_random_books)
		create_random_books(books_to_load, src, FALSE, random_category)
		load_random_books = FALSE
	if(!length(contents))
		return
	var/obj/item/book/choice = tgui_input_list(user, "Book to remove from the shelf", "Remove Book", sort_names(contents.Copy()))
	if(isnull(choice))
		return
	if(!(user.mobility_flags & MOBILITY_USE) || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !in_range(loc, user))
		return
	if(ishuman(user))
		if(!user.get_active_held_item())
			user.put_in_hands(choice)
	else
		choice.forceMove(drop_location())
	update_appearance()


/obj/structure/bookcase/deconstruct(disassembled = TRUE)
	var/atom/Tsec = drop_location()
	new /obj/item/stack/sheet/mineral/wood(Tsec, 4)
	for(var/obj/item/I in contents)
		if(!isbook(I))
			continue
		I.forceMove(Tsec)
	return ..()


/obj/structure/bookcase/update_icon_state()
	if(state == BOOKCASE_UNANCHORED || state == BOOKCASE_ANCHORED)
		icon_state = "bookempty"
		return ..()
	var/amount = length(contents)
	if(load_random_books)
		amount += books_to_load
	icon_state = "book-[clamp(amount, 0, 5)]"
	return ..()


/obj/structure/bookcase/manuals/engineering
	name = "engineering manuals bookcase"

/obj/structure/bookcase/manuals/engineering/Initialize(mapload)
	. = ..()
	new /obj/item/book/manual/wiki/engineering_construction(src)
	new /obj/item/book/manual/wiki/engineering_hacking(src)
	new /obj/item/book/manual/wiki/engineering_guide(src)
	new /obj/item/book/manual/wiki/robotics_cyborgs(src)
	update_appearance()


/obj/structure/bookcase/manuals/research_and_development
	name = "\improper R&D manuals bookcase"

/obj/structure/bookcase/manuals/research_and_development/Initialize(mapload)
	. = ..()
	new /obj/item/book/manual/wiki/research_and_development(src)
	update_appearance()

#undef BOOKCASE_UNANCHORED
#undef BOOKCASE_ANCHORED
#undef BOOKCASE_FINISHED
