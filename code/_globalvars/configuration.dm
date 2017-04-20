GLOBAL_REAL(config, /datum/configuration)

GLOBAL_DATUM_INIT(revdata, /datum/getrev, new)

GLOBAL_VAR(host)
GLOBAL_VAR(join_motd)
GLOBAL_VAR(station_name)
GLOBAL_VAR_INIT(game_version, "/tg/ Station 13")
GLOBAL_VAR_INIT(changelog_hash, "")

GLOBAL_VAR_INIT(ooc_allowed, TRUE)	// used with admin verbs to disable ooc - not a config option apparently
GLOBAL_VAR_INIT(dooc_allowed, TRUE)
GLOBAL_VAR_INIT(abandon_allowed, TRUE)
GLOBAL_VAR_INIT(enter_allowed, TRUE)
GLOBAL_VAR_INIT(guests_allowed, TRUE)
GLOBAL_VAR_INIT(shuttle_frozen, FALSE)
GLOBAL_VAR_INIT(shuttle_left, FALSE)
GLOBAL_VAR_INIT(tinted_weldhelh, TRUE)


// Debug is used exactly once (in living.dm) but is commented out in a lot of places.  It is not set anywhere and only checked.
// Debug2 is used in conjunction with a lot of admin verbs and therefore is actually legit.
GLOBAL_VAR_INIT(Debug, FALSE)	// global debug switch
GLOBAL_VAR_INIT(Debug2, FALSE)
