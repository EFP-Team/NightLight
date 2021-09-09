/datum/sparring_match
	var/mob/living/carbon/human/chaplain
	var/mob/living/carbon/human/opponent
	///what weapons will be allowed during the sparring match
	var/weapons_condition
	///area instance the participants must stay in
	var/area/arena_condition
	///what stakes the fight will have
	var/stakes_condition
	///cheats from the chaplain
	var/chaplain_violations_allowed = 2
	///cheats from the non-chaplain
	var/opponent_violations_allowed = 2
	///outside interventions that ruin the match
	var/flubs = 2

/datum/sparring_match/New(weapons_condition, arena_condition, stakes_condition, mob/living/carbon/human/chaplain, mob/living/carbon/human/opponent)
	. = ..()
	src.weapons_condition = weapons_condition
	src.arena_condition = arena_condition
	src.stakes_condition = stakes_condition
	src.chaplain = chaplain
	src.opponent = opponent
	hook_signals(chaplain)
	hook_signals(opponent)
	chaplain.add_filter("sparring_outline", 9, list("type" = "outline", "color" = "#e02200"))
	opponent.add_filter("sparring_outline", 9, list("type" = "outline", "color" = "#004ee0"))
	//arena conditions
	RegisterSignal(arena_condition, COMSIG_AREA_EXITED, .proc/check_for_quitters)

/datum/sparring_match/proc/hook_signals(mob/living/carbon/human/sparring)
	//weapon conditions
	if(weapons_condition < ANY_WEAPON)
		RegisterSignal(sparring, COMSIG_MOB_FIRED_GUN, .proc/gun_violation)
		RegisterSignal(sparring, COMSIG_MOB_GRENADE_ARMED, .proc/grenade_violation)
	if(weapons_condition < MELEE_ONLY)
		RegisterSignal(sparring, COMSIG_MOB_ITEM_ATTACK, .proc/melee_violation)
	//severe violations (insta violation win for other party) conditions
	RegisterSignal(sparring, COMSIG_MOVABLE_TELEPORTED, .proc/teleport_violation)
	//win conditions
	RegisterSignal(sparring, COMSIG_MOB_STATCHANGE, .proc/check_for_victory)
	//flub conditions
	RegisterSignal(sparring, COMSIG_PROJECTILE_HIT_BY, .proc/projectile_interference)
	RegisterSignal(sparring, COMSIG_LIVING_DEATH, .proc/death_flub)
	RegisterSignal(sparring, COMSIG_PARENT_QDELETING, .proc/deletion_flub)

/datum/sparring_match/proc/unhook_signals(mob/living/carbon/human/sparring)
	if(!sparring)
		return
	UnregisterSignal(sparring, list(
		COMSIG_MOB_FIRED_GUN,
		COMSIG_MOB_GRENADE_ARMED,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_MOVABLE_TELEPORTED,
		COMSIG_MOB_STATCHANGE,
		COMSIG_PROJECTILE_HIT_BY,
		COMSIG_LIVING_DEATH,
		COMSIG_PARENT_QDELETING,
	))

///someone is changing health state, end the fight in crit
/datum/sparring_match/proc/check_for_victory(datum/participant, new_stat)
	SIGNAL_HANDLER

	if(new_stat != HARD_CRIT)
		return
	if(participant == chaplain)
		end_match(opponent, chaplain)
	else
		end_match(chaplain, opponent)

/datum/sparring_match/proc/projectile_interference(datum/hit_by, atom/movable/firer)
	SIGNAL_HANDLER
	if(firer == chaplain || firer == opponent)
		//oh, well that's allowed. or maybe it isn't. doesn't matter because firing the gun will trigger a violation, so no additional violation needed
		return

	if(isliving(firer))
		var/mob/living/interfering = firer
		switch(rand(1,3))
			if(1)
				to_chat(interfering, span_warning("You get a bad feeling... for interfering with [chaplain]'s sparring match..."))
				interfering.AddComponent(/datum/component/omen, TRUE, null, FALSE)
			if(2)
				to_chat(interfering, span_warning("[GLOB.deity] has punished you for interfering with [chaplain]'s sparring match!"))
				lightningbolt(interfering)
			if(3)
				to_chat(interfering, span_warning("[GLOB.deity]'s whispers echo through your mind for interfering with [chaplain]'s sparring match!!"))
				SEND_SOUND(interfering, sound('sound/hallucinations/behind_you1.ogg'))
				interfering.add_confusion(15)
	flub()


///someone randomly fucking died
/datum/sparring_match/proc/death_flub(datum/deceased)
	SIGNAL_HANDLER

	flubbed_match()

///someone randomly fucking deleted
/datum/sparring_match/proc/deletion_flub(datum/qdeleting)
	SIGNAL_HANDLER

	flubbed_match()

///someone used a gun
/datum/sparring_match/proc/gun_violation(datum/offender)
	SIGNAL_HANDLER
	violation(offender, "using guns")

///someone used a grenade
/datum/sparring_match/proc/grenade_violation(datum/offender)
	SIGNAL_HANDLER
	violation(offender, "using grenades")

///someone used melee weapons
/datum/sparring_match/proc/melee_violation(datum/offender)
	SIGNAL_HANDLER
	violation(offender, "using melee weapons")

/datum/sparring_match/proc/teleport_violation(datum/offender)
	SIGNAL_HANDLER
	if(offender == chaplain)
		end_match(opponent, chaplain, violation_victory = TRUE)
	else
		end_match(chaplain, opponent, violation_victory = TRUE)

///someone tried to leave
/datum/sparring_match/proc/check_for_quitters(datum/arena, atom/movable/left_area, direction)
	SIGNAL_HANDLER
	if(left_area == chaplain || left_area == opponent)
		violation(left_area, "leaving the arena")
		var/atom/throw_target = get_edge_target_turf(left_area, REVERSE_DIR(direction))
		left_area.throw_at(throw_target, 6, 4)

/datum/sparring_match/proc/violation(mob/living/carbon/human/offender, reason)
	SIGNAL_HANDLER

	to_chat(offender, span_danger("Violation! No [reason]!"))
	if(offender == chaplain)
		chaplain_violations_allowed--
		if(!chaplain_violations_allowed)
			end_match(opponent, chaplain, violation_victory = TRUE)
	else
		opponent_violations_allowed--
		if(!opponent_violations_allowed)
			end_match(chaplain, opponent, violation_victory = TRUE)

/datum/sparring_match/proc/flub()
	flubs--
	if(!flubs) //too many interferences
		flubbed_match()

///this match was interfered on, nobody wins or loses anything, just end
/datum/sparring_match/proc/flubbed_match()
	unhook_signals(chaplain)
	unhook_signals(opponent)
	chaplain.remove_filter("burden_outline")
	opponent.remove_filter("burden_outline")
	if(chaplain) //flubing means we don't know who is still standing
		to_chat(chaplain, span_boldannounce("The match was flub'd! No winners, no losers. You may restart the match with another contract."))
	if(opponent)
		to_chat(opponent, span_boldannounce("The match was flub'd! No winners, no losers."))
	qdel(src)

/datum/sparring_match/proc/end_match(mob/living/carbon/human/winner, mob/living/carbon/human/loser, violation_victory = FALSE)
	unhook_signals(chaplain)
	unhook_signals(opponent)
	chaplain.remove_filter("burden_outline")
	opponent.remove_filter("burden_outline")
	to_chat(chaplain, span_boldannounce("[winner] HAS WON!"))
	to_chat(opponent, span_boldannounce("[winner] HAS WON!"))
	win(winner, loser, violation_victory)
	lose(loser, winner)
	if(stakes_condition != YOUR_SOUL)
		to_chat(winner, span_notice("You may want to heal up the loser now."))
	qdel(src)

///most of the effects are handled on `lose()` instead.
/datum/sparring_match/proc/win(mob/living/carbon/human/winner, mob/living/carbon/human/loser, violation_victory)
	switch(stakes_condition)
		if(STANDARD_STAKES)
			if(winner == chaplain)
				if(violation_victory)
					to_chat(winner, span_warning("[GLOB.deity] is not entertained from a matched decided by violations. No favor awarded..."))
				else
					to_chat(winner, span_nicegreen("You've won favor with [GLOB.deity]!"))
				var/datum/religion_sect/spar/sect = GLOB.religious_sect
				sect.adjust_favor(1, winner)
				sect.past_opponents += WEAKREF(loser)
		if(MONEY_MATCH)
			to_chat(winner, span_nicegreen("You've won all of [loser]'s money!"))
		if(YOUR_SOUL)
			to_chat(winner, span_nicegreen("You've won [loser]'s SOUL!"))

/datum/sparring_match/proc/lose(mob/living/carbon/human/loser, mob/living/carbon/human/winner)
	switch(stakes_condition)
		if(STANDARD_STAKES)
			if(loser == chaplain)
				var/datum/religion_sect/spar/sect = GLOB.religious_sect
				sect.matches_lost++
				if(sect.matches_lost < 3)
					to_chat(loser, span_userdanger("[GLOB.deity] is angry you lost in their name!"))
					return
				to_chat(loser, span_userdanger("[GLOB.deity] is enraged by your lackluster sparring record!"))
				lightningbolt(loser)
				SEND_SIGNAL(loser, COMSIG_ADD_MOOD_EVENT, "sparring", /datum/mood_event/banished)
				loser.mind.holy_role = NONE
				to_chat(loser, span_userdanger("You have been excommunicated! You are no longer holy!"))
		if(MONEY_MATCH)
			to_chat(loser, span_userdanger("You've lost all your money to [winner]!"))
			var/datum/bank_account/loser_account = loser.get_bank_account()
			var/datum/bank_account/winner_account = winner.get_bank_account()
			if(!loser_account || !winner_account)//the winner is pretty owned in this case but whatever shoulda read the fine print of the contract
				return
			winner_account.transfer_money(loser_account, loser_account.account_balance)
		if(YOUR_SOUL)
			to_chat(loser, span_userdanger("You've lost ownership over your soul to [winner]!"))
			var/obj/item/soulstone/anybody/sparring/shard = new(get_turf(loser))
			shard.capture_soul(loser, winner, forced = TRUE)
