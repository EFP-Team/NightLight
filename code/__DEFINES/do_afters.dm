#define DOAFTER_SOURCE_SURGERY "doafter_surgery"
#define DOAFTER_SOURCE_MECHADRILL "doafter_mechadrill"
#define DOAFTER_SOURCE_SURVIVALPEN "doafter_survivalpen"
#define DOAFTER_SOURCE_GETTING_UP "doafter_gettingup"
#define DOAFTER_SOURCE_CLIMBING_LADDER "doafter_climbingladder"
#define DOAFTER_SOURCE_SPIDER "doafter_spider"
#define DOAFTER_SOURCE_HEAL_TOUCH "doafter_heal_touch"
#define DOAFTER_SOURCE_PLANTING_DEVICE "doafter_planting_device"
#define DOAFTER_SOURCE_CHARGE_CRANKRECHARGE "doafter_charge_crank_recharge"

/**
 * Cache of output of atom/proc/get_oversized_icon_offsets to avoid repeating icon operations
 * Used to offset do_after bars appropriately for large icons
 */
GLOBAL_LIST_EMPTY(oversized_atom_icon_offsets)
