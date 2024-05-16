// This file should contain every single global trait in the game in a type-based list, as well as any additional trait-related information that's useful to have on a global basis.
// This file is used in linting, so make sure to add everything alphabetically and what-not.
// Do consider adding your trait entry to the similar list in `admin_tooling.dm` if you want it to be accessible to admins (which is probably the case for 75% of traits).

// Please do note that there is absolutely no bearing on what traits are added to what subtype of `/datum`, this is just an easily referenceable list sorted by type.
// The only thing that truly matters about traits is the code that is built to handle the traits, and where that code is located. Nothing else.

GLOBAL_LIST_INIT(traits_by_type, list(
	/atom = list(
		"TRAIT_AI_PAUSED" = TRAIT_AI_PAUSED,
		"TRAIT_BANNED_FROM_CARGO_SHUTTLE" = TRAIT_BANNED_FROM_CARGO_SHUTTLE,
		"TRAIT_BEING_SHOCKED" = TRAIT_BEING_SHOCKED,
		"TRAIT_COMMISSIONED" = TRAIT_COMMISSIONED,
		"TRAIT_CLIMBABLE" = TRAIT_CLIMBABLE,
		"TRAIT_CURRENTLY_CLEANING" = TRAIT_CURRENTLY_CLEANING,
		"TRAIT_CUSTOMIZABLE_REAGENT_HOLDER" = TRAIT_CUSTOMIZABLE_REAGENT_HOLDER,
		"TRAIT_DO_NOT_SPLASH" = TRAIT_DO_NOT_SPLASH,
		"TRAIT_DRIED" = TRAIT_DRIED,
		"TRAIT_DRYABLE" = TRAIT_DRYABLE,
		"TRAIT_FOOD_CHEF_MADE" = TRAIT_FOOD_CHEF_MADE,
		"TRAIT_FOOD_FRIED" = TRAIT_FOOD_FRIED,
		"TRAIT_FOOD_SILVER" = TRAIT_FOOD_SILVER,
		"TRAIT_KEEP_TOGETHER" = TRAIT_KEEP_TOGETHER,
		"TRAIT_LIGHTING_DEBUGGED" = TRAIT_LIGHTING_DEBUGGED,
		"TRAIT_RECENTLY_COINED" = TRAIT_RECENTLY_COINED,
		"TRAIT_RUSTY" = TRAIT_RUSTY,
		"TRAIT_SPINNING" = TRAIT_SPINNING,
		"TRAIT_STICKERED" = TRAIT_STICKERED,
		"TRAIT_UNHITTABLE_BY_PROJECTILES" = TRAIT_UNHITTABLE_BY_PROJECTILES,
	),
	/atom/movable = list(
		"TRAIT_ACTIVE_STORAGE" = TRAIT_ACTIVE_STORAGE,
		"TRAIT_AREA_SENSITIVE" = TRAIT_AREA_SENSITIVE,
		"TRAIT_ASHSTORM_IMMUNE" = TRAIT_ASHSTORM_IMMUNE,
		"TRAIT_BLOCKING_EXPLOSIVES" = TRAIT_BLOCKING_EXPLOSIVES,
		"TRAIT_BOULDER_BREAKER" = TRAIT_BOULDER_BREAKER,
		"TRAIT_CASTABLE_LOC" = TRAIT_CASTABLE_LOC,
		"TRAIT_DEL_ON_SPACE_DUMP" = TRAIT_DEL_ON_SPACE_DUMP,
		"TRAIT_FISH_CASE_COMPATIBILE" = TRAIT_FISH_CASE_COMPATIBILE,
		"TRAIT_FISH_SAFE_STORAGE" = TRAIT_FISH_SAFE_STORAGE,
		"TRAIT_FROZEN" = TRAIT_FROZEN,
		"TRAIT_HAS_LABEL" = TRAIT_HAS_LABEL,
		"TRAIT_HEARING_SENSITIVE" = TRAIT_HEARING_SENSITIVE,
		"TRAIT_HYPERSPACED" = TRAIT_HYPERSPACED,
		"TRAIT_IMMERSED" = TRAIT_IMMERSED,
		"TRAIT_IRRADIATED" = TRAIT_IRRADIATED,
		"TRAIT_LAVA_IMMUNE" = TRAIT_LAVA_IMMUNE,
		"TRAIT_MOVE_FLOATING" = TRAIT_MOVE_FLOATING,
		"TRAIT_MOVE_FLYING" = TRAIT_MOVE_FLYING,
		"TRAIT_MOVE_GROUND" = TRAIT_MOVE_GROUND,
		"TRAIT_MOVE_PHASING" = TRAIT_MOVE_PHASING,
		"TRAIT_MOVE_VENTCRAWLING" = TRAIT_MOVE_VENTCRAWLING,
		"TRAIT_MOVE_UPSIDE_DOWN" = TRAIT_MOVE_UPSIDE_DOWN,
		"TRAIT_NO_FLOATING_ANIM" = TRAIT_NO_FLOATING_ANIM,
		"TRAIT_NO_MANIFEST_CONTENTS_ERROR" = TRAIT_NO_MANIFEST_CONTENTS_ERROR,
		"TRAIT_NO_MISSING_ITEM_ERROR" = TRAIT_NO_MISSING_ITEM_ERROR,
		"TRAIT_NO_THROW_HITPUSH" = TRAIT_NO_THROW_HITPUSH,
		"TRAIT_NOT_ENGRAVABLE" = TRAIT_NOT_ENGRAVABLE,
		"TRAIT_SPELLS_TRANSFER_TO_LOC" = TRAIT_SPELLS_TRANSFER_TO_LOC,
		"TRAIT_ODD_CUSTOMIZABLE_FOOD_INGREDIENT" = TRAIT_ODD_CUSTOMIZABLE_FOOD_INGREDIENT,
		"TRAIT_RUNECHAT_HIDDEN" = TRAIT_RUNECHAT_HIDDEN,
		"TRAIT_SECLUDED_LOCATION" = TRAIT_SECLUDED_LOCATION,
		"TRAIT_SNOWSTORM_IMMUNE" = TRAIT_SNOWSTORM_IMMUNE,
		"TRAIT_TELEKINESIS_CONTROLLED" = TRAIT_TELEKINESIS_CONTROLLED,
		"TRAIT_UNDERFLOOR" = TRAIT_UNDERFLOOR,
		"TRAIT_UNIQUE_IMMERSE" = TRAIT_UNIQUE_IMMERSE,
		"TRAIT_VOIDSTORM_IMMUNE" = TRAIT_VOIDSTORM_IMMUNE,
		"TRAIT_WAS_RENAMED" = TRAIT_WAS_RENAMED,
		"TRAIT_WADDLING" = TRAIT_WADDLING,
		"TRAIT_WEATHER_IMMUNE" = TRAIT_WEATHER_IMMUNE,
		"TRAIT_CHASM_STOPPER" = TRAIT_CHASM_STOPPER,
	),
	/datum/controller/subsystem/economy = list(
		"TRAIT_MARKET_CRASHING" = TRAIT_MARKET_CRASHING,
	),
	// AKA SSstation
	/datum/controller/subsystem/processing/station = list(
		"STATION_TRAIT_ASSISTANT_GIMMICKS" = STATION_TRAIT_ASSISTANT_GIMMICKS,
		"STATION_TRAIT_BANANIUM_SHIPMENTS" = STATION_TRAIT_BANANIUM_SHIPMENTS,
		"STATION_TRAIT_BIGGER_PODS" = STATION_TRAIT_BIGGER_PODS,
		"STATION_TRAIT_BIRTHDAY" = STATION_TRAIT_BIRTHDAY,
		"STATION_TRAIT_BOTS_GLITCHED" = STATION_TRAIT_BOTS_GLITCHED,
		"STATION_TRAIT_BRIGHT_DAY" = STATION_TRAIT_BRIGHT_DAY,
		"STATION_TRAIT_CARP_INFESTATION" = STATION_TRAIT_CARP_INFESTATION,
		"STATION_TRAIT_CYBERNETIC_REVOLUTION" = STATION_TRAIT_CYBERNETIC_REVOLUTION,
		"STATION_TRAIT_EMPTY_MAINT" = STATION_TRAIT_EMPTY_MAINT,
		"STATION_TRAIT_FILLED_MAINT" = STATION_TRAIT_FILLED_MAINT,
		"STATION_TRAIT_FORESTED" = STATION_TRAIT_FORESTED,
		"STATION_TRAIT_HANGOVER" = STATION_TRAIT_HANGOVER,
		"STATION_TRAIT_HUMAN_AI" = STATION_TRAIT_HUMAN_AI,
		"STATION_TRAIT_LATE_ARRIVALS" = STATION_TRAIT_LATE_ARRIVALS,
		"STATION_TRAIT_LOANER_SHUTTLE" = STATION_TRAIT_LOANER_SHUTTLE,
		"STATION_TRAIT_MEDBOT_MANIA" = STATION_TRAIT_MEDBOT_MANIA,
		"STATION_TRAIT_PDA_GLITCHED" = STATION_TRAIT_PDA_GLITCHED,
		"STATION_TRAIT_PREMIUM_INTERNALS" = STATION_TRAIT_PREMIUM_INTERNALS,
		"STATION_TRAIT_RADIOACTIVE_NEBULA" = STATION_TRAIT_RADIOACTIVE_NEBULA,
		"STATION_TRAIT_RANDOM_ARRIVALS" = STATION_TRAIT_RANDOM_ARRIVALS,
		"STATION_TRAIT_REVOLUTIONARY_TRASHING" = STATION_TRAIT_REVOLUTIONARY_TRASHING,
		"STATION_TRAIT_SHUTTLE_SALE" = STATION_TRAIT_SHUTTLE_SALE,
		"STATION_TRAIT_SMALLER_PODS" = STATION_TRAIT_SMALLER_PODS,
		"STATION_TRAIT_SPIDER_INFESTATION" = STATION_TRAIT_SPIDER_INFESTATION,
		"STATION_TRAIT_UNIQUE_AI" = STATION_TRAIT_UNIQUE_AI,
		"STATION_TRAIT_UNNATURAL_ATMOSPHERE" = STATION_TRAIT_UNNATURAL_ATMOSPHERE,
		"STATION_TRAIT_VENDING_SHORTAGE" = STATION_TRAIT_VENDING_SHORTAGE,
	),
	/datum/deathmatch_lobby = list(
		"TRAIT_DEATHMATCH_EXPLOSIVE_IMPLANTS" = TRAIT_DEATHMATCH_EXPLOSIVE_IMPLANTS,
	),
	/datum/wound = list(
		"TRAIT_WOUND_SCANNED" = TRAIT_WOUND_SCANNED,
	),
	/obj = list(
		"TRAIT_WALLMOUNTED" = TRAIT_WALLMOUNTED,
	),
	/mob = list(
		"TRAIT_ABDUCTOR_SCIENTIST_TRAINING" = TRAIT_ABDUCTOR_SCIENTIST_TRAINING,
		"TRAIT_ABDUCTOR_TRAINING" = TRAIT_ABDUCTOR_TRAINING,
		"TRAIT_ADAMANTINE_EXTRACT_ARMOR" = TRAIT_ADAMANTINE_EXTRACT_ARMOR,
		"TRAIT_ADVANCEDTOOLUSER" = TRAIT_ADVANCEDTOOLUSER,
		"TRAIT_AGENDER" = TRAIT_AGENDER,
		"TRAIT_AGEUSIA" = TRAIT_AGEUSIA,
		"TRAIT_AIRLOCK_SHOCKIMMUNE" = TRAIT_AIRLOCK_SHOCKIMMUNE,
		"TRAIT_AI_BAGATTACK" = TRAIT_AI_BAGATTACK,
		"TRAIT_ALCOHOL_TOLERANCE" = TRAIT_ALCOHOL_TOLERANCE,
		"TRAIT_ALLOWED_HONORBOUND_ATTACK" = TRAIT_ALLOWED_HONORBOUND_ATTACK,
		"TRAIT_ALLOW_HERETIC_CASTING" = TRAIT_ALLOW_HERETIC_CASTING,
		"TRAIT_ALWAYS_NO_ACCESS" = TRAIT_ALWAYS_NO_ACCESS,
		"TRAIT_ALWAYS_WANTED" = TRAIT_ALWAYS_WANTED,
		"TRAIT_ANALGESIA" = TRAIT_ANALGESIA,
		"TRAIT_ANGELIC" = TRAIT_ANGELIC,
		"TRAIT_ANOSMIA" = TRAIT_ANOSMIA,
		"TRAIT_ANTENNAE" = TRAIT_ANTENNAE,
		"TRAIT_ANTICONVULSANT" = TRAIT_ANTICONVULSANT,
		"TRAIT_ANTIMAGIC" = TRAIT_ANTIMAGIC,
		"TRAIT_ANTIMAGIC_NO_SELFBLOCK" = TRAIT_ANTIMAGIC_NO_SELFBLOCK,
		"TRAIT_ANXIOUS" = TRAIT_ANXIOUS,
		"TRAIT_BADDNA" = TRAIT_BADDNA,
		"TRAIT_BADTOUCH" = TRAIT_BADTOUCH,
		"TRAIT_BALD" = TRAIT_BALD,
		"TRAIT_BALLOON_SUTRA" = TRAIT_BALLOON_SUTRA,
		"TRAIT_BATON_RESISTANCE" = TRAIT_BATON_RESISTANCE,
		"TRAIT_BEING_BLADE_SHIELDED" = TRAIT_BEING_BLADE_SHIELDED,
		"TRAIT_BLOB_ALLY" = TRAIT_BLOB_ALLY,
		"TRAIT_BLOODSHOT_EYES" = TRAIT_BLOODSHOT_EYES,
		"TRAIT_BLOODY_MESS" = TRAIT_BLOODY_MESS,
		"TRAIT_BLOOD_CLANS" = TRAIT_BLOOD_CLANS,
		"TRAIT_BOMBIMMUNE" = TRAIT_BOMBIMMUNE,
		"TRAIT_BONSAI" = TRAIT_BONSAI,
		"TRAIT_BOOZE_SLIDER" = TRAIT_BOOZE_SLIDER,
		"TRAIT_BOXING_READY" = TRAIT_BOXING_READY,
		"TRAIT_BRAINWASHING" = TRAIT_BRAINWASHING,
		"TRAIT_BRAWLING_KNOCKDOWN_BLOCKED" = TRAIT_BRAWLING_KNOCKDOWN_BLOCKED,
		"TRAIT_BYPASS_EARLY_IRRADIATED_CHECK" = TRAIT_BYPASS_EARLY_IRRADIATED_CHECK,
		"TRAIT_BYPASS_MEASURES" = TRAIT_BYPASS_MEASURES,
		"TRAIT_CANNOT_BE_UNBUCKLED" = TRAIT_CANNOT_BE_UNBUCKLED,
		"TRAIT_CANNOT_CRYSTALIZE" = TRAIT_CANNOT_CRYSTALIZE,
		"TRAIT_CANNOT_OPEN_PRESENTS" = TRAIT_CANNOT_OPEN_PRESENTS,
		"TRAIT_CANT_RIDE" = TRAIT_CANT_RIDE,
		"TRAIT_CAN_HOLD_ITEMS" = TRAIT_CAN_HOLD_ITEMS,
		"TRAIT_CAN_SIGN_ON_COMMS" = TRAIT_CAN_SIGN_ON_COMMS,
		"TRAIT_CAN_STRIP" = TRAIT_CAN_STRIP,
		"TRAIT_CAN_USE_NUKE" = TRAIT_CAN_USE_NUKE,
		"TRAIT_CATLIKE_GRACE" = TRAIT_CATLIKE_GRACE,
		"TRAIT_CHANGELING_HIVEMIND_MUTE" = TRAIT_CHANGELING_HIVEMIND_MUTE,
		"TRAIT_CHASM_DESTROYED" = TRAIT_CHASM_DESTROYED,
		"TRAIT_CHEF_KISS" = TRAIT_CHEF_KISS,
		"TRAIT_CHUNKYFINGERS" = TRAIT_CHUNKYFINGERS,
		"TRAIT_CHUNKYFINGERS_IGNORE_BATON" = TRAIT_CHUNKYFINGERS_IGNORE_BATON,
		"TRAIT_CLEANBOT_WHISPERER" = TRAIT_CLEANBOT_WHISPERER,
		"TRAIT_CLIFF_WALKER" = TRAIT_CLIFF_WALKER,
		"TRAIT_CLOWN_ENJOYER" = TRAIT_CLOWN_ENJOYER,
		"TRAIT_CLUMSY" = TRAIT_CLUMSY,
		"TRAIT_COAGULATING" = TRAIT_COAGULATING,
		"TRAIT_CORPSELOCKED" = TRAIT_CORPSELOCKED,
		"TRAIT_CRITICAL_CONDITION" = TRAIT_CRITICAL_CONDITION,
		"TRAIT_CULT_HALO" = TRAIT_CULT_HALO,
		"TRAIT_CURSED" = TRAIT_CURSED,
		"TRAIT_DEAF" = TRAIT_DEAF,
		"TRAIT_DEATHCOMA" = TRAIT_DEATHCOMA,
		"TRAIT_DEFIB_BLACKLISTED" = TRAIT_DEFIB_BLACKLISTED,
		"TRAIT_DEPRESSION" = TRAIT_DEPRESSION,
		"TRAIT_DETECT_STORM" = TRAIT_DETECT_STORM,
		"TRAIT_DIAGNOSTIC_HUD" = TRAIT_DIAGNOSTIC_HUD,
		"TRAIT_DISCOORDINATED_TOOL_USER" = TRAIT_DISCOORDINATED_TOOL_USER,
		"TRAIT_DISEASELIKE_SEVERITY_MEDIUM" = TRAIT_DISEASELIKE_SEVERITY_MEDIUM,
		"TRAIT_DISFIGURED" = TRAIT_DISFIGURED,
		"TRAIT_DISGUISED" = TRAIT_DISGUISED,
		"DISPLAYS_JOB_IN_BINARY" = DISPLAYS_JOB_IN_BINARY,
		"TRAIT_DISK_VERIFIER" = TRAIT_DISK_VERIFIER,
		"TRAIT_DISSECTED" = TRAIT_DISSECTED,
		"TRAIT_DONT_WRITE_MEMORY" = TRAIT_DONT_WRITE_MEMORY,
		"TRAIT_DOUBLE_TAP" = TRAIT_DOUBLE_TAP,
		"TRAIT_DREAMING" = TRAIT_DREAMING,
		"TRAIT_DRINKS_BLOOD" = TRAIT_DRINKS_BLOOD,
		"TRAIT_DUMB" = TRAIT_DUMB,
		"TRAIT_DWARF" = TRAIT_DWARF,
		"TRAIT_EASILY_WOUNDED" = TRAIT_EASILY_WOUNDED,
		"TRAIT_EASYBLEED" = TRAIT_EASYBLEED,
		"TRAIT_EASYDISMEMBER" = TRAIT_EASYDISMEMBER,
		"TRAIT_ECHOLOCATION_EXTRA_RANGE" = TRAIT_ECHOLOCATION_EXTRA_RANGE,
		"TRAIT_ECHOLOCATION_RECEIVER" = TRAIT_ECHOLOCATION_RECEIVER,
		"TRAIT_ELDRITCH_PAINTING_EXAMINE" = TRAIT_ELDRITCH_PAINTING_EXAMINE,
		"TRAIT_ELITE_CHALLENGER" = TRAIT_ELITE_CHALLENGER,
		"TRAIT_EMOTEMUTE " = TRAIT_EMOTEMUTE,
		"TRAIT_EMOTEMUTE" = TRAIT_EMOTEMUTE,
		"TRAIT_EMPATH" = TRAIT_EMPATH,
		"TRAIT_ENTRAILS_READER" = TRAIT_ENTRAILS_READER,
		"TRAIT_EXAMINE_FISHING_SPOT" = TRAIT_EXAMINE_FISHING_SPOT,
		"TRAIT_EXAMINE_FITNESS" = TRAIT_EXAMINE_FITNESS,
		"TRAIT_EXPANDED_FOV" = TRAIT_EXPANDED_FOV,
		"TRAIT_EXTROVERT" = TRAIT_EXTROVERT,
		"TRAIT_FAKEDEATH" = TRAIT_FAKEDEATH,
		"TRAIT_FASTMED" = TRAIT_FASTMED,
		"TRAIT_FAST_CUFFING" = TRAIT_FAST_CUFFING,
		"TRAIT_FAST_TYING" = TRAIT_FAST_TYING,
		"TRAIT_FAT" = TRAIT_FAT,
		"TRAIT_FEARLESS" = TRAIT_FEARLESS,
		"TRAIT_FENCE_CLIMBER" = TRAIT_FENCE_CLIMBER,
		"TRAIT_FINGERPRINT_PASSTHROUGH" = TRAIT_FINGERPRINT_PASSTHROUGH,
		"TRAIT_FIST_MINING" = TRAIT_FIST_MINING,
		"TRAIT_FIXED_HAIRCOLOR" = TRAIT_FIXED_HAIRCOLOR,
		"TRAIT_FIXED_MUTANT_COLORS" = TRAIT_FIXED_MUTANT_COLORS,
		"TRAIT_FLESH_DESIRE" = TRAIT_FLESH_DESIRE,
		"TRAIT_FLOORED" = TRAIT_FLOORED,
		"TRAIT_FORBID_MINING_SHUTTLE_CONSOLE_OUTSIDE_STATION" = TRAIT_FORBID_MINING_SHUTTLE_CONSOLE_OUTSIDE_STATION,
		"TRAIT_FORCED_GRAVITY" = TRAIT_FORCED_GRAVITY,
		"TRAIT_FORCED_STANDING" = TRAIT_FORCED_STANDING,
		"TRAIT_FOV_APPLIED" = TRAIT_FOV_APPLIED,
		"TRAIT_FREERUNNING" = TRAIT_FREERUNNING,
		"TRAIT_FREE_FLOAT_MOVEMENT" = TRAIT_FREE_FLOAT_MOVEMENT,
		"TRAIT_FREE_HYPERSPACE_MOVEMENT" = TRAIT_FREE_HYPERSPACE_MOVEMENT,
		"TRAIT_FREE_HYPERSPACE_SOFTCORDON_MOVEMENT" = TRAIT_FREE_HYPERSPACE_SOFTCORDON_MOVEMENT,
		"TRAIT_FRIENDLY" = TRAIT_FRIENDLY,
		"TRAIT_FUGU_GLANDED" = TRAIT_FUGU_GLANDED,
		"TRAIT_GAMER" = TRAIT_GAMER,
		"TRAIT_GAMERGOD" = TRAIT_GAMERGOD,
		"TRAIT_GARLIC_BREATH" = TRAIT_GARLIC_BREATH,
		"TRAIT_GENELESS" = TRAIT_GENELESS,
		"TRAIT_GIANT" = TRAIT_GIANT,
		"TRAIT_GONE_FISHING" = TRAIT_GONE_FISHING,
		"TRAIT_GOOD_HEARING" = TRAIT_GOOD_HEARING,
		"TRAIT_GRABWEAKNESS" = TRAIT_GRABWEAKNESS,
		"TRAIT_GREENTEXT_CURSED" = TRAIT_GREENTEXT_CURSED,
		"TRAIT_GUNFLIP" = TRAIT_GUNFLIP,
		"TRAIT_GUN_NATURAL" = TRAIT_GUN_NATURAL,
		"TRAIT_HALT_RADIATION_EFFECTS" = TRAIT_HALT_RADIATION_EFFECTS,
		"TRAIT_HANDS_BLOCKED" = TRAIT_HANDS_BLOCKED,
		"TRAIT_HARDLY_WOUNDED" = TRAIT_HARDLY_WOUNDED,
		"TRAIT_HAS_BEEN_KIDNAPPED" = TRAIT_HAS_BEEN_KIDNAPPED,
		"TRAIT_HAS_CRANIAL_FISSURE" = TRAIT_HAS_CRANIAL_FISSURE,
		"TRAIT_HAS_MARKINGS" = TRAIT_HAS_MARKINGS,
		"TRAIT_HATED_BY_DOGS" = TRAIT_HATED_BY_DOGS,
		"TRAIT_HEAD_INJURY_BLOCKED" = TRAIT_HEAD_INJURY_BLOCKED,
		"TRAIT_HEALS_FROM_CARP_RIFTS" = TRAIT_HEALS_FROM_CARP_RIFTS,
		"TRAIT_HEALS_FROM_CULT_PYLONS" = TRAIT_HEALS_FROM_CULT_PYLONS,
		"TRAIT_HEAR_THROUGH_DARKNESS" = TRAIT_HEAR_THROUGH_DARKNESS,
		"TRAIT_HEAVY_DRINKER" = TRAIT_HEAVY_DRINKER,
		"TRAIT_HEAVY_SLEEPER" = TRAIT_HEAVY_SLEEPER,
		"TRAIT_HIDE_EXTERNAL_ORGANS" = TRAIT_HIDE_EXTERNAL_ORGANS,
		"TRAIT_HIGH_VALUE_RANSOM" = TRAIT_HIGH_VALUE_RANSOM,
		"TRAIT_HOLY" = TRAIT_HOLY,
		"TRAIT_HOPELESSLY_ADDICTED" = TRAIT_HOPELESSLY_ADDICTED,
		"TRAIT_HOT_SPRING_CURSED" = TRAIT_HOT_SPRING_CURSED,
		"TRAIT_HULK" = TRAIT_HULK,
		"TRAIT_HUSK" = TRAIT_HUSK,
		"TRAIT_ID_APPRAISER" = TRAIT_ID_APPRAISER,
		"TRAIT_IGNORE_ELEVATION" = TRAIT_IGNORE_ELEVATION,
		"TRAIT_IGNOREDAMAGESLOWDOWN" = TRAIT_IGNOREDAMAGESLOWDOWN,
		"TRAIT_IGNORESLOWDOWN" = TRAIT_IGNORESLOWDOWN,
		"TRAIT_IGNORING_GRAVITY" = TRAIT_IGNORING_GRAVITY,
		"TRAIT_ILLITERATE" = TRAIT_ILLITERATE,
		"TRAIT_IMMOBILIZED" = TRAIT_IMMOBILIZED,
		"TRAIT_INCAPACITATED" = TRAIT_INCAPACITATED,
		"TRAIT_INTROVERT" = TRAIT_INTROVERT,
		"TRAIT_INVISIBLE_MAN" = TRAIT_INVISIBLE_MAN,
		"TRAIT_INVISIMIN" = TRAIT_INVISIMIN,
		"TRAIT_IN_CALL" = TRAIT_IN_CALL,
		"TRAIT_IWASBATONED" = TRAIT_IWASBATONED,
		"TRAIT_JOLLY" = TRAIT_JOLLY,
		"TRAIT_KISS_OF_DEATH" = TRAIT_KISS_OF_DEATH,
		"TRAIT_KNOCKEDOUT" = TRAIT_KNOCKEDOUT,
		"TRAIT_KNOW_ENGI_WIRES" = TRAIT_KNOW_ENGI_WIRES,
		"TRAIT_KNOW_ROBO_WIRES" = TRAIT_KNOW_ROBO_WIRES,
		"TRAIT_LIGHTBULB_REMOVER" = TRAIT_LIGHTBULB_REMOVER,
		"TRAIT_LIGHT_DRINKER" = TRAIT_LIGHT_DRINKER,
		"TRAIT_LIGHT_STEP" = TRAIT_LIGHT_STEP,
		"TRAIT_LIMBATTACHMENT" = TRAIT_LIMBATTACHMENT,
		"TRAIT_LITERATE" = TRAIT_LITERATE,
		"TRAIT_LIVERLESS_METABOLISM" = TRAIT_LIVERLESS_METABOLISM,
		"TRAIT_MADNESS_IMMUNE" = TRAIT_MADNESS_IMMUNE,
		"TRAIT_MAGICALLY_GIFTED" = TRAIT_MAGICALLY_GIFTED,
		"TRAIT_MAGICALLY_PHASED" = TRAIT_MAGICALLY_PHASED,
		"TRAIT_MARTIAL_ARTS_IMMUNE" = TRAIT_MARTIAL_ARTS_IMMUNE,
		"TRAIT_MANSUS_TOUCHED" = TRAIT_MANSUS_TOUCHED,
		"TRAIT_MEDIBOTCOMINGTHROUGH" = TRAIT_MEDIBOTCOMINGTHROUGH,
		"TRAIT_MEDICAL_HUD" = TRAIT_MEDICAL_HUD,
		"TRAIT_MESON_VISION" = TRAIT_MESON_VISION,
		"TRAIT_MIME_FAN" = TRAIT_MIME_FAN,
		"TRAIT_MIMING" = TRAIT_MIMING,
		"TRAIT_MINDSHIELD" = TRAIT_MINDSHIELD,
		"TRAIT_MIND_TEMPORARILY_GONE" = TRAIT_MIND_TEMPORARILY_GONE,
		"TRAIT_MOB_BREEDER" = TRAIT_MOB_BREEDER,
		"TRAIT_MOB_EATER" = TRAIT_MOB_EATER,
		"TRAIT_MOB_TIPPED" = TRAIT_MOB_TIPPED,
		"TRAIT_MORBID" = TRAIT_MORBID,
		"TRAIT_MULTIZ_SUIT_SENSORS" = TRAIT_MULTIZ_SUIT_SENSORS,
		"TRAIT_MUSICIAN" = TRAIT_MUSICIAN,
		"TRAIT_MUTANT_COLORS" = TRAIT_MUTANT_COLORS,
		"TRAIT_MUTE" = TRAIT_MUTE,
		"TRAIT_NAIVE" = TRAIT_NAIVE,
		"TRAIT_NEARSIGHTED_CORRECTED" = TRAIT_NEARSIGHTED_CORRECTED,
		"TRAIT_NEGATES_GRAVITY" = TRAIT_NEGATES_GRAVITY,
		"TRAIT_NEVER_WOUNDED" = TRAIT_NEVER_WOUNDED,
		"TRAIT_NICE_SHOT" = TRAIT_NICE_SHOT,
		"TRAIT_NIGHT_VISION" = TRAIT_NIGHT_VISION,
		"TRAIT_NOBLOOD" = TRAIT_NOBLOOD,
		"TRAIT_NOBREATH" = TRAIT_NOBREATH,
		"TRAIT_NOCRITDAMAGE" = TRAIT_NOCRITDAMAGE,
		"TRAIT_NOCRITOVERLAY" = TRAIT_NOCRITOVERLAY,
		"TRAIT_NODEATH" = TRAIT_NODEATH,
		"TRAIT_NODISMEMBER" = TRAIT_NODISMEMBER,
		"TRAIT_NOFAT" = TRAIT_NOFAT,
		"TRAIT_NOFEAR_HOLDUPS" = TRAIT_NOFEAR_HOLDUPS,
		"TRAIT_NOFIRE" = TRAIT_NOFIRE,
		"TRAIT_NOFIRE_SPREAD" = TRAIT_NOFIRE_SPREAD,
		"TRAIT_NOFLASH" = TRAIT_NOFLASH,
		"TRAIT_NOGUNS" = TRAIT_NOGUNS,
		"TRAIT_NOHARDCRIT" = TRAIT_NOHARDCRIT,
		"TRAIT_NOHUNGER" = TRAIT_NOHUNGER,
		"TRAIT_NOLIMBDISABLE" = TRAIT_NOLIMBDISABLE,
		"TRAIT_NOMOBSWAP" = TRAIT_NOMOBSWAP,
		"TRAIT_NOSELFIGNITION_HEAD_ONLY" = TRAIT_NOSELFIGNITION_HEAD_ONLY,
		"TRAIT_NOSOFTCRIT" = TRAIT_NOSOFTCRIT,
		"TRAIT_NO_AUGMENTS" = TRAIT_NO_AUGMENTS,
		"TRAIT_NO_BLOOD_OVERLAY" = TRAIT_NO_BLOOD_OVERLAY,
		"TRAIT_NO_DEBRAIN_OVERLAY" = TRAIT_NO_DEBRAIN_OVERLAY,
		"TRAIT_NO_DNA_COPY" = TRAIT_NO_DNA_COPY,
		"TRAIT_NO_DNA_SCRAMBLE" = TRAIT_NO_DNA_SCRAMBLE,
		"TRAIT_NO_EXTINGUISH" = TRAIT_NO_EXTINGUISH,
		"TRAIT_NO_FLOATING_ANIM" = TRAIT_NO_FLOATING_ANIM,
		"TRAIT_NO_GLIDE" = TRAIT_NO_GLIDE,
		"TRAIT_NO_GUN_AKIMBO" = TRAIT_NO_GUN_AKIMBO,
		"TRAIT_NO_IMMOBILIZE" = TRAIT_NO_IMMOBILIZE,
		"TRAIT_NO_JUMPSUIT" = TRAIT_NO_JUMPSUIT,
		"TRAIT_NO_MINDSWAP" = TRAIT_NO_MINDSWAP,
		"TRAIT_NO_MIRROR_REFLECTION" = TRAIT_NO_MIRROR_REFLECTION,
		"TRAIT_NO_PLASMA_TRANSFORM" = TRAIT_NO_PLASMA_TRANSFORM,
		"TRAIT_NO_SLIP_ALL" = TRAIT_NO_SLIP_ALL,
		"TRAIT_NO_SLIP_ICE" = TRAIT_NO_SLIP_ICE,
		"TRAIT_NO_SLIP_SLIDE" = TRAIT_NO_SLIP_SLIDE,
		"TRAIT_NO_SLIP_WATER" = TRAIT_NO_SLIP_WATER,
		"TRAIT_NO_SOUL" = TRAIT_NO_SOUL,
		"TRAIT_NO_STAGGER" = TRAIT_NO_STAGGER,
		"TRAIT_NO_STRIP" = TRAIT_NO_STRIP,
		"TRAIT_NO_TRANSFORM" = TRAIT_NO_TRANSFORM,
		"TRAIT_NO_TWOHANDING" = TRAIT_NO_TWOHANDING,
		"TRAIT_NO_UNDERWEAR" = TRAIT_NO_UNDERWEAR,
		"TRAIT_NO_ZOMBIFY" = TRAIT_NO_ZOMBIFY,
		"TRAIT_NUKEIMMUNE" = TRAIT_NUKEIMMUNE,
		"TRAIT_OFF_BALANCE_TACKLER" = TRAIT_OFF_BALANCE_TACKLER,
		"TRAIT_OIL_FRIED" = TRAIT_OIL_FRIED,
		"TRAIT_ON_ELEVATED_SURFACE" = TRAIT_ON_ELEVATED_SURFACE,
		"TRAIT_ORBITING_FORBIDDEN" = TRAIT_ORBITING_FORBIDDEN,
		"TRAIT_OVERDOSEIMMUNE" = TRAIT_OVERDOSEIMMUNE,
		"TRAIT_OVERWATCHED" = TRAIT_OVERWATCHED,
		"TRAIT_OVERWATCH_IMMUNE" = TRAIT_OVERWATCH_IMMUNE,
		"TRAIT_PACIFISM" = TRAIT_PACIFISM,
		"TRAIT_PAPER_MASTER" = TRAIT_PAPER_MASTER,
		"TRAIT_PARALYSIS_L_ARM" = TRAIT_PARALYSIS_L_ARM,
		"TRAIT_PARALYSIS_L_LEG" = TRAIT_PARALYSIS_L_LEG,
		"TRAIT_PARALYSIS_R_ARM" = TRAIT_PARALYSIS_R_ARM,
		"TRAIT_PARALYSIS_R_LEG" = TRAIT_PARALYSIS_R_LEG,
		"TRAIT_PARROT_PERCHED" = TRAIT_PARROT_PERCHED,
		"TRAIT_PASSTABLE" = TRAIT_PASSTABLE,
		"TRAIT_PASSWINDOW" = TRAIT_PASSWINDOW,
		"TRAIT_PERFECT_ATTACKER" = TRAIT_PERFECT_ATTACKER,
		"TRAIT_PERMANENTLY_MORTAL" = TRAIT_PERMANENTLY_MORTAL,
		"TRAIT_PHOTOGRAPHER" = TRAIT_PHOTOGRAPHER,
		"TRAIT_PIERCEIMMUNE" = TRAIT_PIERCEIMMUNE,
		"TRAIT_PLANT_SAFE" = TRAIT_PLANT_SAFE,
		"TRAIT_PLASMA_LOVER_METABOLISM" = TRAIT_PLASMA_LOVER_METABOLISM,
		"TRAIT_POSTERBOY" = TRAIT_POSTERBOY,
		"TRAIT_PRESENT_VISION" = TRAIT_PRESENT_VISION,
		"TRAIT_PRESERVE_UI_WITHOUT_CLIENT" = TRAIT_PRESERVE_UI_WITHOUT_CLIENT,
		"TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION" = TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION,
		"TRAIT_PRIMITIVE" = TRAIT_PRIMITIVE, //unable to use mechs. Given to Ash Walkers
		"TRAIT_PROSOPAGNOSIA" = TRAIT_PROSOPAGNOSIA,
		"TRAIT_PULL_BLOCKED" = TRAIT_PULL_BLOCKED,
		"TRAIT_PUSHIMMUNE" = TRAIT_PUSHIMMUNE,
		"TRAIT_QUICKER_CARRY" = TRAIT_QUICKER_CARRY,
		"TRAIT_QUICK_BUILD" = TRAIT_QUICK_BUILD,
		"TRAIT_QUICK_CARRY" = TRAIT_QUICK_CARRY,
		"TRAIT_RADIMMUNE" = TRAIT_RADIMMUNE,
		"TRAIT_RDS_SUPPRESSED" = TRAIT_RDS_SUPPRESSED,
		"TRAIT_REAGENT_SCANNER" = TRAIT_REAGENT_SCANNER,
		"TRAIT_RECENTLY_BLOCKED_MAGIC" = TRAIT_RECENTLY_BLOCKED_MAGIC,
		"TRAIT_REGEN_SHIELD" = TRAIT_REGEN_SHIELD,
		"TRAIT_RELAYING_ATTACKER" = TRAIT_RELAYING_ATTACKER,
		"TRAIT_REMOTE_TASTING" = TRAIT_REMOTE_TASTING,
		"TRAIT_RESEARCH_SCANNER" = TRAIT_RESEARCH_SCANNER,
		"TRAIT_RESISTCOLD" = TRAIT_RESISTCOLD,
		"TRAIT_RESISTHEAT" = TRAIT_RESISTHEAT,
		"TRAIT_RESISTHEATHANDS" = TRAIT_RESISTHEATHANDS,
		"TRAIT_RESISTHIGHPRESSURE" = TRAIT_RESISTHIGHPRESSURE,
		"TRAIT_RESISTLOWPRESSURE" = TRAIT_RESISTLOWPRESSURE,
		"TRAIT_RESTRAINED" = TRAIT_RESTRAINED,
		"TRAIT_REVEAL_FISH" = TRAIT_REVEAL_FISH,
		"TRAIT_REVENANT_INHIBITED" = TRAIT_REVENANT_INHIBITED,
		"TRAIT_REVENANT_REVEALED" = TRAIT_REVENANT_REVEALED,
		"TRAIT_RIFT_FAILURE" = TRAIT_RIFT_FAILURE,
		"TRAIT_ROCK_EATER" = TRAIT_ROCK_EATER,
		"TRAIT_ROCK_METAMORPHIC" = TRAIT_ROCK_METAMORPHIC,
		"TRAIT_ROCK_STONER" = TRAIT_ROCK_STONER,
		"TRAIT_ROD_SUPLEX" = TRAIT_ROD_SUPLEX,
		"TRAIT_SABRAGE_PRO" = TRAIT_SABRAGE_PRO,
		"TRAIT_SECURITY_HUD" = TRAIT_SECURITY_HUD,
		"TRAIT_SEE_GLASS_COLORS" = TRAIT_SEE_GLASS_COLORS,
		"TRAIT_SELF_AWARE" = TRAIT_SELF_AWARE,
		"TRAIT_SETTLER" = TRAIT_SETTLER,
		"TRAIT_SHAVED" = TRAIT_SHAVED,
		"TRAIT_SHIFTY_EYES" = TRAIT_SHIFTY_EYES,
		"TRAIT_SHOCKIMMUNE" = TRAIT_SHOCKIMMUNE,
		"TRAIT_SIGN_LANG" = TRAIT_SIGN_LANG,
		"TRAIT_SILENT_FOOTSTEPS" = TRAIT_SILENT_FOOTSTEPS,
		"TRAIT_SIXTHSENSE" = TRAIT_SIXTHSENSE,
		"TRAIT_SKITTISH" = TRAIT_SKITTISH,
		"TRAIT_SLEEPIMMUNE" = TRAIT_SLEEPIMMUNE,
		"TRAIT_SMOKER" = TRAIT_SMOKER,
		"TRAIT_SNEAK" = TRAIT_SNEAK,
		"TRAIT_SNOB" = TRAIT_SNOB,
		"TRAIT_SOFTSPOKEN" = TRAIT_SOFTSPOKEN,
		"TRAIT_SOOTHED_THROAT" = TRAIT_SOOTHED_THROAT,
		"TRAIT_SPACEWALK" = TRAIT_SPACEWALK,
		"TRAIT_SPARRING" = TRAIT_SPARRING,
		"TRAIT_SPEAKS_CLEARLY" = TRAIT_SPEAKS_CLEARLY,
		"TRAIT_SPECIAL_TRAUMA_BOOST" = TRAIT_SPECIAL_TRAUMA_BOOST,
		"TRAIT_SPIDER_CONSUMED" = TRAIT_SPIDER_CONSUMED,
		"TRAIT_SPIRITUAL" = TRAIT_SPIRITUAL,
		"TRAIT_SPRAY_PAINTABLE" = TRAIT_SPRAY_PAINTABLE,
		"TRAIT_STABLEHEART" = TRAIT_STABLEHEART,
		"TRAIT_STABLELIVER" = TRAIT_STABLELIVER,
		"TRAIT_STASIS" = TRAIT_STASIS,
		"TRAIT_STIMULATED" = TRAIT_STIMULATED,
		"TRAIT_STRONG_GRABBER" = TRAIT_STRONG_GRABBER,
		"TRAIT_STRONG_STOMACH" = TRAIT_STRONG_STOMACH,
		"TRAIT_STUNIMMUNE" = TRAIT_STUNIMMUNE,
		"TRAIT_SUCCUMB_OVERRIDE" = TRAIT_SUCCUMB_OVERRIDE,
		"TRAIT_SUICIDED" = TRAIT_SUICIDED,
		"TRAIT_SUPERMATTER_SOOTHER" = TRAIT_SUPERMATTER_SOOTHER,
		"TRAIT_SURGEON" = TRAIT_SURGEON,
		"TRAIT_SURGICALLY_ANALYZED" = TRAIT_SURGICALLY_ANALYZED,
		"TRAIT_TACKLING_FRAIL_ATTACKER" = TRAIT_TACKLING_FRAIL_ATTACKER,
		"TRAIT_TACKLING_TAILED_DEFENDER" = TRAIT_TACKLING_TAILED_DEFENDER,
		"TRAIT_TACKLING_WINGED_ATTACKER" = TRAIT_TACKLING_WINGED_ATTACKER,
		"TRAIT_TACTICALLY_CAMOUFLAGED" = TRAIT_TACTICALLY_CAMOUFLAGED,
		"TRAIT_TAGGER" = TRAIT_TAGGER,
		"TRAIT_TEMPORARY_BODY" = TRAIT_TEMPORARY_BODY,
		"TRAIT_TENACIOUS" = TRAIT_TENACIOUS,
		"TRAIT_TENTACLE_IMMUNE" = TRAIT_TENTACLE_IMMUNE,
		"TRAIT_TESLA_SHOCKIMMUNE" = TRAIT_TESLA_SHOCKIMMUNE,
		"TRAIT_THERMAL_VISION" = TRAIT_THERMAL_VISION,
		"TRAIT_THINKING_IN_CHARACTER" = TRAIT_THINKING_IN_CHARACTER,
		"TRAIT_THROWINGARM" = TRAIT_THROWINGARM,
		"TRAIT_TIME_STOP_IMMUNE" = TRAIT_TIME_STOP_IMMUNE,
		"TRAIT_TOWER_OF_BABEL" = TRAIT_TOWER_OF_BABEL,
		"TRAIT_TOXIMMUNE" = TRAIT_TOXIMMUNE,
		"TRAIT_TOXINLOVER" = TRAIT_TOXINLOVER,
		"TRAIT_TRUE_NIGHT_VISION" = TRAIT_TRUE_NIGHT_VISION,
		"TRAIT_TUMOR_SUPPRESSED" = TRAIT_TUMOR_SUPPRESSED,
		"TRAIT_TUMOR_SUPPRESSION" = TRAIT_TUMOR_SUPPRESSED,
		"TRAIT_UI_BLOCKED" = TRAIT_UI_BLOCKED,
		"TRAIT_UNBREAKABLE" = TRAIT_UNBREAKABLE,
		"TRAIT_UNDENSE" = TRAIT_UNDENSE,
		"TRAIT_UNDERWATER_BASKETWEAVING_KNOWLEDGE" = TRAIT_UNDERWATER_BASKETWEAVING_KNOWLEDGE,
		"TRAIT_UNHUSKABLE" = TRAIT_UNHUSKABLE,
		"TRAIT_UNINTELLIGIBLE_SPEECH" = TRAIT_UNINTELLIGIBLE_SPEECH,
		"TRAIT_UNKNOWN" = TRAIT_UNKNOWN,
		"TRAIT_UNNATURAL_RED_GLOWY_EYES" = TRAIT_UNNATURAL_RED_GLOWY_EYES,
		"TRAIT_UNOBSERVANT" = TRAIT_UNOBSERVANT,
		"TRAIT_UNSTABLE" = TRAIT_UNSTABLE,
		"TRAIT_USED_DNA_VAULT" = TRAIT_USED_DNA_VAULT,
		"TRAIT_USER_SCOPED" = TRAIT_USER_SCOPED,
		"TRAIT_USES_SKINTONES" = TRAIT_USES_SKINTONES,
		"TRAIT_VATGROWN" = TRAIT_VATGROWN,
		"TRAIT_VENTCRAWLER_ALWAYS" = TRAIT_VENTCRAWLER_ALWAYS,
		"TRAIT_VENTCRAWLER_NUDE" = TRAIT_VENTCRAWLER_NUDE,
		"TRAIT_VIRUSIMMUNE" = TRAIT_VIRUSIMMUNE,
		"TRAIT_VIRUS_RESISTANCE" = TRAIT_VIRUS_RESISTANCE,
		"TRAIT_VORACIOUS" = TRAIT_VORACIOUS,
		"TRAIT_WAS_EVOLVED" = TRAIT_WAS_EVOLVED,
		"TRAIT_WEAK_SOUL" = TRAIT_WEAK_SOUL,
		"TRAIT_WEB_SURFER" = TRAIT_WEB_SURFER,
		"TRAIT_WEB_WEAVER" = TRAIT_WEB_WEAVER,
		"TRAIT_WINE_TASTER" = TRAIT_WINE_TASTER,
		"TRAIT_WING_BUFFET" = TRAIT_WING_BUFFET,
		"TRAIT_WING_BUFFET_TIRED" = TRAIT_WING_BUFFET_TIRED,
		"TRAIT_XENO_HOST" = TRAIT_XENO_HOST,
		"TRAIT_XENO_IMMUNE" = TRAIT_XENO_IMMUNE,
		"TRAIT_XRAY_HEARING" = TRAIT_XRAY_HEARING,
		"TRAIT_XRAY_VISION" = TRAIT_XRAY_VISION,
		"TRAIT_DISCO_DANCER" = TRAIT_DISCO_DANCER,
		"TRAIT_MAFIAINITIATE" = TRAIT_MAFIAINITIATE,
		"TRAIT_STRENGTH" = TRAIT_STRENGTH,
		"TRAIT_STIMMED" = TRAIT_STIMMED,
	),
	/obj/item = list(
		"TRAIT_APC_SHOCKING" = TRAIT_APC_SHOCKING,
		"TRAIT_BASIC_QUALITY_BAIT" = TRAIT_BASIC_QUALITY_BAIT,
		"TRAIT_BLIND_TOOL" = TRAIT_BLIND_TOOL,
		"TRAIT_CUSTOM_TAP_SOUND" = TRAIT_CUSTOM_TAP_SOUND,
		"TRAIT_DANGEROUS_OBJECT" = TRAIT_DANGEROUS_OBJECT,
		"TRAIT_FISHING_BAIT" = TRAIT_FISHING_BAIT,
		"TRAIT_GERM_SENSITIVE" = TRAIT_GERM_SENSITIVE,
		"TRAIT_GOOD_QUALITY_BAIT" = TRAIT_GOOD_QUALITY_BAIT,
		"TRAIT_GREAT_QUALITY_BAIT" = TRAIT_GREAT_QUALITY_BAIT,
		"TRAIT_HAUNTED" = TRAIT_HAUNTED,
		"TRAIT_HONKSPAMMING" = TRAIT_HONKSPAMMING,
		"TRAIT_INNATELY_FANTASTICAL_ITEM" = TRAIT_INNATELY_FANTASTICAL_ITEM,
		"TRAIT_NEEDS_TWO_HANDS" = TRAIT_NEEDS_TWO_HANDS,
		"TRAIT_NO_BARCODES" = TRAIT_NO_BARCODES,
		"TRAIT_NO_STORAGE_INSERT" = TRAIT_NO_STORAGE_INSERT,
		"TRAIT_NO_TELEPORT" = TRAIT_NO_TELEPORT,
		"TRAIT_NODROP" = TRAIT_NODROP,
		"TRAIT_OMNI_BAIT" = TRAIT_OMNI_BAIT,
		"TRAIT_PLANT_WILDMUTATE" = TRAIT_PLANT_WILDMUTATE,
		"TRAIT_T_RAY_VISIBLE" = TRAIT_T_RAY_VISIBLE,
		"TRAIT_TRANSFORM_ACTIVE" = TRAIT_TRANSFORM_ACTIVE,
		"TRAIT_UNCATCHABLE" = TRAIT_UNCATCHABLE,
		"TRAIT_WIELDED" = TRAIT_WIELDED,
		"TRAIT_BAKEABLE" = TRAIT_BAKEABLE,
		"TRAIT_INSTANTLY_PROCESSES_BOULDERS" = TRAIT_INSTANTLY_PROCESSES_BOULDERS,
	),
	/obj/item/ammo_casing = list(
		"TRAIT_DART_HAS_INSERT" = TRAIT_DART_HAS_INSERT,
	),
	/obj/item/bodypart = list(
		"TRAIT_DISABLED_BY_WOUND" = TRAIT_DISABLED_BY_WOUND,
		"TRAIT_IGNORED_BY_LIVING_FLESH" = TRAIT_IGNORED_BY_LIVING_FLESH,
		"TRAIT_IMMUNE_TO_CRANIAL_FISSURE" = TRAIT_IMMUNE_TO_CRANIAL_FISSURE,
	),
	/obj/item/bodypart = list(
		"TRAIT_PARALYSIS" = TRAIT_PARALYSIS,
	),
	/obj/item/card/id = list(
		"TRAIT_JOB_FIRST_ID_CARD" = TRAIT_JOB_FIRST_ID_CARD,
		"TRAIT_MAGNETIC_ID_CARD" = TRAIT_MAGNETIC_ID_CARD,
		"TRAIT_TASTEFULLY_THICK_ID_CARD" = TRAIT_TASTEFULLY_THICK_ID_CARD,
	),
	/obj/item/clothing = list(
		"TRAIT_RADIATION_PROTECTED_CLOTHING" = TRAIT_RADIATION_PROTECTED_CLOTHING,
	),
	/obj/item/fish = list(
		"TRAIT_FISH_AMPHIBIOUS" = TRAIT_FISH_AMPHIBIOUS,
		"TRAIT_FISH_CROSSBREEDER" = TRAIT_FISH_CROSSBREEDER,
		"TRAIT_FISH_FED_LUBE" = TRAIT_FISH_FED_LUBE,
		"TRAIT_FISH_FROM_CASE" = TRAIT_FISH_FROM_CASE,
		"TRAIT_FISH_NO_HUNGER" = TRAIT_FISH_NO_HUNGER,
		"TRAIT_FISH_NO_MATING" = TRAIT_FISH_NO_MATING,
		"TRAIT_FISH_SELF_REPRODUCE" = TRAIT_FISH_SELF_REPRODUCE,
		"TRAIT_FISH_TOXIN_IMMUNE" = TRAIT_FISH_TOXIN_IMMUNE,
		"TRAIT_RESIST_EMULSIFY" = TRAIT_RESIST_EMULSIFY,
		"TRAIT_YUCKY_FISH" = TRAIT_YUCKY_FISH,
	),
	/obj/item/integrated_circuit = list(
		"TRAIT_CIRCUIT_UI_OPEN" = TRAIT_CIRCUIT_UI_OPEN,
		"TRAIT_CIRCUIT_UNDUPABLE" = TRAIT_CIRCUIT_UNDUPABLE,
		"TRAIT_COMPONENT_MMI" = TRAIT_COMPONENT_MMI,
	),
	/obj/item/modular_computer = list(
		"TRAIT_MODPC_HALVED_DOWNLOAD_SPEED" = TRAIT_MODPC_HALVED_DOWNLOAD_SPEED,
		"TRAIT_PDA_CAN_EXPLODE" = TRAIT_PDA_CAN_EXPLODE,
		"TRAIT_PDA_MESSAGE_MENU_RIGGED" = TRAIT_PDA_MESSAGE_MENU_RIGGED,
	),
	/obj/item/organ = list(
		"TRAIT_LIVING_HEART" = TRAIT_LIVING_HEART,
	),
	/obj/item/organ/internal/liver = list(
		"TRAIT_BALLMER_SCIENTIST" = TRAIT_BALLMER_SCIENTIST,
		"TRAIT_COMEDY_METABOLISM" = TRAIT_COMEDY_METABOLISM,
		"TRAIT_CORONER_METABOLISM" = TRAIT_CORONER_METABOLISM,
		"TRAIT_CULINARY_METABOLISM" = TRAIT_CULINARY_METABOLISM,
		"TRAIT_ENGINEER_METABOLISM" = TRAIT_ENGINEER_METABOLISM,
		"TRAIT_HUMAN_AI_METABOLISM" = TRAIT_HUMAN_AI_METABOLISM,
		"TRAIT_LAW_ENFORCEMENT_METABOLISM" = TRAIT_LAW_ENFORCEMENT_METABOLISM,
		"TRAIT_MAINTENANCE_METABOLISM" = TRAIT_MAINTENANCE_METABOLISM,
		"TRAIT_MEDICAL_METABOLISM" = TRAIT_MEDICAL_METABOLISM,
		"TRAIT_PRETENDER_ROYAL_METABOLISM" = TRAIT_PRETENDER_ROYAL_METABOLISM,
		"TRAIT_ROYAL_METABOLISM" = TRAIT_ROYAL_METABOLISM,
	),
	/obj/item/organ/internal/lungs = list(
		"TRAIT_SPACEBREATHING" = TRAIT_SPACEBREATHING,
	),
	/obj/machinery/modular_computer = list(
		"TRAIT_MODPC_INTERACTING_WITH_FRAME" = TRAIT_MODPC_INTERACTING_WITH_FRAME,
	),
	/obj/projectile = list(
		"TRAIT_ALWAYS_HIT_ZONE" = TRAIT_ALWAYS_HIT_ZONE,
	),
	/obj/structure = list(
		"TRAIT_RADSTORM_IMMUNE" = TRAIT_RADSTORM_IMMUNE,
	),
	/obj/vehicle = list(
		"TRAIT_OREBOX_FUNCTIONAL" = TRAIT_OREBOX_FUNCTIONAL,
	),
	/obj/vehicle/sealed/mecha = list(
		"TRAIT_MECHA_CREATED_NORMALLY" = TRAIT_MECHA_CREATED_NORMALLY
	),
	/turf = list(
		"TRAIT_CHASM_STOPPED" = TRAIT_CHASM_STOPPED,
		"TRAIT_CONTAINMENT_FIELD" = TRAIT_CONTAINMENT_FIELD,
		"TRAIT_FIREDOOR_STOP" = TRAIT_FIREDOOR_STOP,
		"TRAIT_HYPERSPACE_STOPPED" = TRAIT_HYPERSPACE_STOPPED,
		"TRAIT_IMMERSE_STOPPED" = TRAIT_IMMERSE_STOPPED,
		"TRAIT_LAVA_STOPPED" = TRAIT_LAVA_STOPPED,
		"TRAIT_SPINNING_WEB_TURF" = TRAIT_SPINNING_WEB_TURF,
		"TRAIT_TURF_IGNORE_SLIPPERY" = TRAIT_TURF_IGNORE_SLIPPERY,
		"TRAIT_TURF_IGNORE_SLOWDOWN" = TRAIT_TURF_IGNORE_SLOWDOWN,
		"TRAIT_ELEVATED_TURF" = TRAIT_ELEVATED_TURF,
	),
))

/// value -> trait name, list of ALL traits that exist in the game, used for any type of accessing.
GLOBAL_LIST(global_trait_name_map)

/proc/generate_global_trait_name_map()
	. = list()
	for(var/key in GLOB.traits_by_type)
		for(var/tname in GLOB.traits_by_type[key])
			var/val = GLOB.traits_by_type[key][tname]
			.[val] = tname

	return .

GLOBAL_LIST_INIT(movement_type_trait_to_flag, list(
	TRAIT_MOVE_GROUND = GROUND,
	TRAIT_MOVE_FLYING = FLYING,
	TRAIT_MOVE_VENTCRAWLING = VENTCRAWLING,
	TRAIT_MOVE_FLOATING = FLOATING,
	TRAIT_MOVE_PHASING = PHASING,
	TRAIT_MOVE_UPSIDE_DOWN = UPSIDE_DOWN,
))

GLOBAL_LIST_INIT(movement_type_addtrait_signals, set_movement_type_addtrait_signals())
GLOBAL_LIST_INIT(movement_type_removetrait_signals, set_movement_type_removetrait_signals())

/proc/set_movement_type_addtrait_signals(signal_prefix)
	. = list()
	for(var/trait in GLOB.movement_type_trait_to_flag)
		. += SIGNAL_ADDTRAIT(trait)

	return .

/proc/set_movement_type_removetrait_signals(signal_prefix)
	. = list()
	for(var/trait in GLOB.movement_type_trait_to_flag)
		. += SIGNAL_REMOVETRAIT(trait)

	return .
