/mob/living/carbon/keyDown(_key, client/user)
	switch(_key)
		if("numpad1", "southwest", "r")
			toggle_throw_mode()
		if("numpad7", "northwest", "q")
			if(!get_active_hand())
				src << "<span class='warning'>You have nothing to drop in your hand!</span>"
			else
				drop_item()
		if("1")
			a_intent_change("help")
		if("2")
			a_intent_change("disarm")
		if("3")
			a_intent_change("grab")
		if("4")
			a_intent_change("harm")
	..()