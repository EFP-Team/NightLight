/obj/item/organ/heart/gland/spiderman
	true_name = "araneae cloister accelerator. Makes the abductee exhale spider pheromones and spawn spiderlings."
	cooldown_low = 450
	cooldown_high = 900
	uses = -1
	icon_state = "spider"
	mind_control_uses = 2
	mind_control_duration = 2400

/obj/item/organ/heart/gland/spiderman/activate()
	to_chat(owner, span_warning("You feel something crawling in your skin."))
	owner.faction |= "spiders"
	var/obj/structure/spider/spiderling/S = new(owner.drop_location())
	S.directive = "Protect your nest inside [owner.real_name]."
