/*
The /tg/ codebase currently requires you to have 7 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside this file will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1

current as of 2014/11/24
z1 = station
z2 = centcomm
z3 = derelict telecomms satellite
z4 = derelict station
z5 = mining
z6 = empty space
z7 = empty space
*/

#if !defined(MAP_FILE)

	#define TITLESCREEN "title" //Add an image in misc/fullscreen.dmi, and set this define to the icon_state, to set a custom titlescreen for your map

	#define LAVALAND_ENABLED 1

	#include "map_files\DreamStation\dreamstation04.dmm"
	#include "map_files\generic\z2.dmm"
	#include "map_files\generic\z3.dmm"
	#include "map_files\generic\z4.dmm"
	#if (LAVALAND_ENABLED == 1)
		#include "map_files\generic\lavaland.dmm"
	#else
		#include "map_files\DreamStation\z5.dmm"
	#endif
	#include "map_files\generic\z6.dmm"
	#include "map_files\generic\z7.dmm"

	#define MAP_PATH "map_files/DreamStation"
	#define MAP_FILE "dreamstation04.dmm"
	#define MAP_NAME "DreamStation"

	#if (LAVALAND_ENABLED == 1)
		#define MAP_TRANSITION_CONFIG	list(MAIN_STATION = CROSSLINKED, CENTCOMM = SELFLOOPING, ABANDONED_SATELLITE = CROSSLINKED, DERELICT = CROSSLINKED, MINING = SELFLOOPING, EMPTY_AREA_1 = CROSSLINKED, EMPTY_AREA_2 = CROSSLINKED)
	#else
		#define MAP_TRANSITION_CONFIG	list(MAIN_STATION = CROSSLINKED, CENTCOMM = SELFLOOPING, ABANDONED_SATELLITE = CROSSLINKED, DERELICT = CROSSLINKED, MINING = CROSSLINKED, EMPTY_AREA_1 = CROSSLINKED, EMPTY_AREA_2 = CROSSLINKED)
	#endif

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring DreamStation.

#endif