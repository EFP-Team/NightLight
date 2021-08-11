///little tidbits of past events generated by the player doing things. can be used in engravings, dreams, and changeling succs.
///all of those things are supposed to be taken vaguely (engravings crossround and should not include names, dreams and succs are memory goop)
///and as such the generated text of the memory is vague. also, no references held so hard delling isn't an issue, thank god
/datum/memory
	///name of the memory the user sees
	var/name
	///job of the person memorizing the event
	var/memorizer
	///job of the person memorizing the event
	var/datum/mind/memorizer_mind
	///the action done to the target, see memory.dm in _DEFINES
	var/action
	///extra information used in the memories to more accurately describe what happened. Assoc list of key -> string identifying what kind of info it is, value is an atom or string identifying the detail.
	var/list/extra_info
	///mood of the person memorizing the event when it happend. can change the style.
	var/memorizer_mood
	///the value of the mood in it's worth as a story, defines how beautiful art from it can be and whether or not it stays in persistence.
	var/story_value = STORY_VALUE_NONE
	///Flags of any special behavior for the memory
	var/memory_flags = NONE

/datum/memory/New(memorizer_mind, memorizer, action, extra_info, memorizer_mood, story_value, memory_flags)
	. = ..()
	src.memorizer_mind = memorizer_mind
	src.memorizer = memorizer
	src.action = action
	src.extra_info = extra_info
	src.memorizer_mood = memorizer_mood
	src.story_value = story_value
	src.memory_flags = memory_flags

	generate_memory_name()

/datum/memory/proc/generate_story(story_type, story_flags)
	var/list/story_pieces = list()

	//entirely independent vars (not related to the action or story type)

	var/list/something_pool = list(
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/hostile/bear,
		/mob/living/simple_animal/hostile/mushroom,
		/mob/living/simple_animal/hostile/statue,
		/mob/living/simple_animal/hostile/retaliate/bat,
		/mob/living/simple_animal/hostile/retaliate/goat,
		/mob/living/simple_animal/hostile/killertomato,
		/mob/living/simple_animal/hostile/giant_spider,
		/mob/living/simple_animal/hostile/giant_spider/hunter,
		/mob/living/simple_animal/hostile/blob/blobbernaut/independent,
		/mob/living/simple_animal/hostile/carp/ranged,
		/mob/living/simple_animal/hostile/carp/ranged/chaos,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher,
		/mob/living/simple_animal/hostile/asteroid/goliath/beast,
		/mob/living/simple_animal/hostile/headcrab,
		/mob/living/simple_animal/hostile/morph,
		/mob/living/simple_animal/hostile/stickman,
		/mob/living/simple_animal/hostile/stickman/dog,
		/mob/living/simple_animal/hostile/megafauna/dragon/lesser,
		/mob/living/simple_animal/hostile/gorilla,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/crab,
		/mob/living/simple_animal/pet/dog/pug,
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/hostile/lizard,
		/mob/living/simple_animal/pet/fox,
		/mob/living/simple_animal/butterfly,
		/mob/living/simple_animal/pet/cat/cak,
		/mob/living/simple_animal/chick,
		/mob/living/simple_animal/cow/wisdom,
		/obj/item/skub
	)

	var/list/forewords = strings(MEMORY_FILE, story_type + "_forewords")
	var/list/somethings =strings(MEMORY_FILE, story_type + "_somethings")
	//changeling absorbing does not have styles
	var/list/styles = story_type == STORY_CHANGELING_ABSORB ? null : strings(MEMORY_FILE, story_type + "styles")
	var/list/wheres = strings(MEMORY_FILE, "where")

	//story action vars (surgery)
	var/list/story_starts = strings(MEMORY_FILE, action + "_starts")
	var/list/story_moods


	var/victim_mood = extra_info[DETAIL_PROTAGONIST_MOOD]

	if(victim_mood != MOODLESS_MEMORY) //How the victim felt when it all happend.
		switch(victim_mood)
			if(MOOD_LEVEL_HAPPY4 to MOOD_LEVEL_HAPPY2)
				story_moods = strings(MEMORY_FILE, "happy")
				if("[action]sad" in GLOB.string_cache[MEMORY_FILE])
					story_moods += strings(MEMORY_FILE, "[action]happy")
			if(MOOD_LEVEL_HAPPY2-1 to MOOD_LEVEL_SAD2+1)
				story_moods = strings(MEMORY_FILE, "neutral")
				if("[action]sad" in GLOB.string_cache[MEMORY_FILE])
					story_moods += strings(MEMORY_FILE, "[action]neutral")
			if(MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD4)
				story_moods = strings(MEMORY_FILE, "sad")
				if("[action]sad" in GLOB.string_cache[MEMORY_FILE])
					story_moods += strings(MEMORY_FILE, "[action]sad")

	//storybuilding

	//The forewords for this specific type of story (E.g. This engraving depicts)
	story_pieces.Add(pick(forewords))
	//The story start for this specific action. (E.g. The Chef carving into The Clown)
	story_pieces.Add(pick(story_starts))
	//The location it happend, which isn't always included, but commonly is. (E.g. in Space, while in the Bar)
	if(extra_info[DETAIL_WHERE])
		story_pieces.Add(pick(wheres))
	//Shows how the protagonist felt about it all (E.g. The Chef is looking sad as they tear into The Clown.)
	if(LAZYLEN(story_moods))
		story_pieces.Add(pick(story_moods))
	//A nonsensical addition, using the memorizer, protagonist or even random crew / things (E.g. in the meantime, the Clown is being arrested, clutching a skub.")
	if(prob(75))
		story_pieces.Add(pick(somethings))
	//Explains any unique styling the art has. e.g. (The engraving has a cubist style.)
	if(styles && prob(75))
		story_pieces.Add(pick(styles))


	var/parsed_story = ""

	var/mob/living/crew_member

	var/atom/something = pick(something_pool) //Pick a something for the potential something line

	var/datum/antagonist/obsessed/creeper = memorizer_mind.has_antag_datum(/datum/antagonist/obsessed)
	if(creeper && creeper.trauma.obsession)
		crew_member = creeper.trauma.obsession //ALWAYS ENGRAVE MY OBSESSION!

	var/list/crew_members = list()
	for(var/mob/living/carbon/human/potential_crew_member as anything in GLOB.player_list)
		if(potential_crew_member?.mind.assigned_role.job_flags & JOB_CREW_MEMBER)
			crew_members += potential_crew_member

	if(crew_members.len)
		crew_member = pick(crew_members)
	else
		crew_member = "an unknown crewmember"

	for(var/line in story_pieces)
		for(var/key in extra_info)
			var/detail = extra_info[key]
			line = replacetext(line, "%[key]", "[detail]")

		line = replacetext(line, "%PROPER", "\proper")
		line = replacetext(line, "%MEMORIZER", "[memorizer]")
		line = replacetext(line, "%MOOD", pick(story_moods))
		line = replacetext(line, "%SOMETHING", initial(something.name))
		line = replacetext(line, "%CREWMEMBER", memorizer_mind.build_story_mob(crew_member))

		parsed_story += "[line] "

	//after replacement section for performance
	if(story_flags & STORY_FLAG_DATED)
		if(memory_flags & MEMORY_FLAG_NOSTATIONNAME)
			parsed_story += "This took place in [time2text(world.realtime, "Month")] of [GLOB.year_integer+540]."
		else
			parsed_story += "This took place in [time2text(world.realtime, "Month")] of [GLOB.year_integer+540] on [station_name()]."

	return parsed_story

/datum/memory/proc/generate_memory_name()
	var/names = strings(MEMORY_FILE, action + "_names")
	var/line = pick(names)
	line = replacetext(line, "%PROTAGONIST", "[memorizer]")
	for(var/key in extra_info)
		var/detail = extra_info[key]
		line = replacetext(line, "%[key]", "[detail]")
	name = line


