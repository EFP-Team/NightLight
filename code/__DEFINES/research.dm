//! Defines for the R&D console, see: [/obj/machinery/computer/rdconsole]
#define RDCONSOLE_UI_MODE_NORMAL 1
#define RDCONSOLE_UI_MODE_EXPERT 2
#define RDCONSOLE_UI_MODE_LIST 3

#define RDSCREEN_MENU 0
#define RDSCREEN_TECHDISK 1
#define RDSCREEN_DESIGNDISK 20
#define RDSCREEN_DESIGNDISK_UPLOAD 21
#define RDSCREEN_SETTINGS 61
#define RDSCREEN_TECHWEB 70
#define RDSCREEN_TECHWEB_NODEVIEW 71
#define RDSCREEN_TECHWEB_DESIGNVIEW 72

#define RDSCREEN_NOBREAK "<NO_HTML_BREAK>"

//! Sanity check defines for when these devices aren't connected or no disk is inserted
#define RDSCREEN_TEXT_NO_PROTOLATHE "<div><h3>No Protolathe Linked!</h3></div><br>"
#define RDSCREEN_TEXT_NO_IMPRINTER "<div><h3>No Circuit Imprinter Linked!</h3></div><br>"
#define RDSCREEN_TEXT_NO_DECONSTRUCT "<div><h3>No Destructive Analyzer Linked!</h3></div><br>"
#define RDSCREEN_TEXT_NO_TDISK "<div><h3>No Technology Disk Inserted!</h3></div><br>"
#define RDSCREEN_TEXT_NO_DDISK "<div><h3>No Design Disk Inserted!</h3></div><br>"
#define RDSCREEN_TEXT_NO_SNODE "<div><h3>No Technology Node Selected!</h3></div><br>"
#define RDSCREEN_TEXT_NO_SDESIGN "<div><h3>No Design Selected!</h3></div><br>"

#define RDSCREEN_UI_LATHE_CHECK if(QDELETED(linked_lathe)) { return RDSCREEN_TEXT_NO_PROTOLATHE }
#define RDSCREEN_UI_IMPRINTER_CHECK if(QDELETED(linked_imprinter)) { return RDSCREEN_TEXT_NO_IMPRINTER }
#define RDSCREEN_UI_DECONSTRUCT_CHECK if(QDELETED(linked_destroy)) { return RDSCREEN_TEXT_NO_DECONSTRUCT }
#define RDSCREEN_UI_TDISK_CHECK if(QDELETED(t_disk)) { return RDSCREEN_TEXT_NO_TDISK }
#define RDSCREEN_UI_DDISK_CHECK if(QDELETED(d_disk)) { return RDSCREEN_TEXT_NO_DDISK }
#define RDSCREEN_UI_SNODE_CHECK if(!selected_node) { return RDSCREEN_TEXT_NO_SNODE }
#define RDSCREEN_UI_SDESIGN_CHECK if(!selected_design) { return RDSCREEN_TEXT_NO_SDESIGN }

//! Defines for the Protolathe screens, see: [/obj/machinery/rnd/production/protolathe]
#define RESEARCH_FABRICATOR_SCREEN_MAIN 1
#define RESEARCH_FABRICATOR_SCREEN_CHEMICALS 2
#define RESEARCH_FABRICATOR_SCREEN_MATERIALS 3
#define RESEARCH_FABRICATOR_SCREEN_SEARCH 4
#define RESEARCH_FABRICATOR_SCREEN_CATEGORYVIEW 5

//! Department flags for techwebs. Defines which department can print what from each protolathe so Cargo can't print guns, etc.
#define DEPARTMENTAL_FLAG_SECURITY		(1<<0)
#define DEPARTMENTAL_FLAG_MEDICAL		(1<<1)
#define DEPARTMENTAL_FLAG_CARGO			(1<<2)
#define DEPARTMENTAL_FLAG_SCIENCE		(1<<3)
#define DEPARTMENTAL_FLAG_ENGINEERING	(1<<4)
#define DEPARTMENTAL_FLAG_SERVICE		(1<<5)

///! Lathe catagories.  Used to sort and order the designs when being displayed or searched
#define CATEGORY_INITIAL        		  	"initial"
#define CATEGORY_HACKED         			"hacked"
#define CATEGORY_TOOLS						"Tools"

#define CATEGORY_DINNERWARE					"Dinnerware"
#define CATEGORY_MISC						"Misc"			// Misc?  So many things here:P
#define CATEGORY_FOOD						"Food"
#define CATEGORY_EMAGGED					"emagged"
#define CATEGORY_OTHER						"other"
#define CATEGORY_AMMO						"Ammo"
#define CATEGORY_EQUIPMENT					"Equipment"
#define CATEGORY_IMPORTED					"Imported"
#define CATEGORY_WEAPONS					"Weapons"
#define CATEGORY_STOCK_PARTS				"Stock Parts"
///! Stock parts sub catagories
#define CATEGORY_TIER_BASIC					"Basic"
#define CATEGORY_TIER_ADVANCED				"Advanced"
#define CATEGORY_TIER_SUPER					"Super"
#define CATEGORY_TIER_BLUESPACE				"Bluespace"
#define CATEGORY_TIER_TELECOMS				CATEGORY_SUBSPACE_TELECOMS
#define CATEGORY_TIER_MATERIALS				"Smelted Materials"

#define CATEGORY_MACHINERY					"Machinery"
#define CATEGORY_MEDICAL					"Medical"
#define CATEGORY_SECURITY					"Security"

#define CATEGORY_COMPUTER_BOARDS			"Computer Boards"
#define CATEGORY_AI_MODULES					"AI Modules"
#define CATEGORY_BLUESPACE_DESIGNS			"Bluespace Designs"
#define CATEGORY_TOOL_DESIGNS				"Tool Designs"
#define CATEGORY_MEDICAL_DESIGNS			"Medical Designs"
#define CATEGORY_MINING_DESIGNS				"Mining Designs"
#define CATEGORY_POWER_DESIGNS				"Power Designs"

#define CATEGORY_COMPUTER_PARTS				"Computer Parts"
#define CATEGORY_ELECTRONICS				"Electronics"
#define CATEGORY_SUBSPACE_TELECOMS			"Subspace Telecoms"
#define CATEGORY_MACHINERY_ENGINEERING		"Engineering Machinery"
#define CATEGORY_MACHINERY_TELEPORTATION	"Teleportation Machinery"
#define CATEGORY_MACHINERY_MEDICAL			"Medical Machinery"
#define CATEGORY_MACHINERY_RESEARCH			"Research Machinery"
#define CATEGORY_MACHINERY_MISC				"Misc. Machinery"
#define CATEGORY_MACHINERY_HYDRO			"Hydroponics Machinery"
#define CATEGORY_FIRING_PINS				"Firing Pins"

#define CATEGORY_EXOSUIT_MODULES			"Exosuit Modules"
#define CATEGORY_EXOSUIT_EQUIPMENT			"Exosuit Equipment"
#define CATEGORY_EXOSUIT_AMMO				"Exosuit Ammunition"
#define CATEGORY_CYBORG						"Cyborg"
#define CATEGORY_CYBORG_MODULES				"Cyborg Upgrade Modules"
#define CATEGORY_MECH_RIPLEY				"Ripley"
#define CATEGORY_MECH_ODYSSEUS				"Odysseus"
#define CATEGORY_MECH_GYGAX					"Gygax"
#define CATEGORY_MECH_DURAND				"Durand"
#define CATEGORY_MECH_HONK					"H.O.N.K"
#define CATEGORY_MECH_PHAZON				"Phazon"
#define CATEGORY_MECH_CLARKE				"Clarke"
#define CATEGORY_CONTROL_INTERFACES			"Control Interfaces"
#define CATEGORY_IMPLANTS					"Implants"
#define CATEGORY_CYBERNETICS				"Cybernetics"

///! Catagories for the bio regenerator
#define CATEGORY_BOTANY_CHEMICALS			"Botany Chemicals"
#define CATEGORY_ORGANIC_MATERIALS			"Organic Materials"

///! Catagories for the limb grower
#define CATEGORY_HUMAN						"human"
#define CATEGORY_LIZARD						"lizard"
#define CATEGORY_MOTH						"moth"
#define CATEGORY_PLASMAMAN					"plasmaman"
#define CATEGORY_ETHEREAL					"ethereal"

///! Catagories for nanites
#define CATEGORY_NANITES_UTILITY			"Utility Nanites"
#define CATEGORY_NANITES_MEDICAL			"Medical Nanites"
#define CATEGORY_NANITES_AUGMENTATION		"Augmentation Nanites"
#define CATEGORY_NANITES_DEFECTIVE			"Defective Nanites"
#define CATEGORY_NANITES_WEAPONIZED			"Weaponized Nanites"
#define CATEGORY_NANITES_SUPPRESSION		"Suppression Nanites"
#define CATEGORY_NANITES_SENSOR				"Sensor Nanites"
#define CATEGORY_NANITES_PROTOCOLS			"Protocols Nanites"

///! Helper to create a category list, just to make it a little cleaner
#define CREATE_CATEGORY_LIST(...) list(__VA_ARGS__)

/// For instances where we don't want a design showing up due to it being for debug/sanity purposes
#define DESIGN_ID_IGNORE "IGNORE_THIS_DESIGN"

#define RESEARCH_MATERIAL_DESTROY_ID "__destroy"

//! Techweb names for new point types. Can be used to define specific point values for specific types of research (science, security, engineering, etc.)
#define TECHWEB_POINT_TYPE_GENERIC "General Research"
#define TECHWEB_POINT_TYPE_NANITES "Nanite Research"

#define TECHWEB_POINT_TYPE_DEFAULT TECHWEB_POINT_TYPE_GENERIC

//! Associative names for techweb point values, see: [all_nodes][code/modules/research/techweb/all_nodes.dm]
#define TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES list(\
	TECHWEB_POINT_TYPE_GENERIC = "General Research",\
	TECHWEB_POINT_TYPE_NANITES = "Nanite Research"\
	)

/// R&D point value for a maxcap bomb. Can be adjusted if need be. Current Value Cap Radius: 100
#define TECHWEB_BOMB_POINTCAP		50000

//! Research point values for slime extracts, see: [xenobio_camera][code/modules/research/xenobiology/xenobio_camera.dm]
#define SLIME_RESEARCH_TIER_0 100
#define SLIME_RESEARCH_TIER_1 500
#define SLIME_RESEARCH_TIER_2 1000
#define SLIME_RESEARCH_TIER_3 1500
#define SLIME_RESEARCH_TIER_4 2000
#define SLIME_RESEARCH_TIER_5 2500
#define SLIME_RESEARCH_TIER_RAINBOW 5000

//! Amount of points gained per second by a single R&D server, see: [research][code/controllers/subsystem/research.dm]
#define TECHWEB_SINGLE_SERVER_INCOME 52.3

//! Swab cell line types
#define CELL_LINE_TABLE_SLUDGE "cell_line_sludge_table"
#define CELL_LINE_TABLE_MOLD "cell_line_mold_table"
#define CELL_LINE_TABLE_MOIST "cell_line_moist_table"
#define CELL_LINE_TABLE_BLOB "cell_line_blob_table"
#define CELL_LINE_TABLE_CLOWN "cell_line_clown_table"

//! Biopsy cell line types
#define CELL_LINE_TABLE_BEAR "cell_line_bear_table"
#define CELL_LINE_TABLE_BLOBBERNAUT "cell_line_blobbernaut_table"
#define CELL_LINE_TABLE_BLOBSPORE "cell_line_blobspore_table"
#define CELL_LINE_TABLE_CARP "cell_line_carp_table"
#define CELL_LINE_TABLE_CAT "cell_line_cat_table"
#define CELL_LINE_TABLE_CHICKEN "cell_line_chicken_table"
#define CELL_LINE_TABLE_COCKROACH "cell_line_cockroach_table"
#define CELL_LINE_TABLE_CORGI "cell_line_corgi_table"
#define CELL_LINE_TABLE_COW "cell_line_cow_table"
#define CELL_LINE_TABLE_GELATINOUS "cell_line_gelatinous_table"
#define CELL_LINE_TABLE_GRAPE "cell_line_grape_table"
#define CELL_LINE_TABLE_MEGACARP "cell_line_megacarp_table"
#define CELL_LINE_TABLE_MOUSE "cell_line_mouse_table"
#define CELL_LINE_TABLE_PINE "cell_line_pine_table"
#define CELL_LINE_TABLE_PUG "cell_line_pug_table"
#define CELL_LINE_TABLE_SLIME "cell_line_slime_table"
#define CELL_LINE_TABLE_SNAKE "cell_line_snake_table"
#define CELL_LINE_TABLE_VATBEAST "cell_line_vatbeast_table"
#define CELL_LINE_TABLE_NETHER "cell_line_nether_table"

//! All cell virus types
#define CELL_VIRUS_TABLE_GENERIC "cell_virus_generic_table"
#define CELL_VIRUS_TABLE_GENERIC_MOB "cell_virus_generic_mob_table"

//! General defines for vatgrowing
/// Past how much growth can the other cell_lines affect a finished cell line negatively
#define VATGROWING_DANGER_MINIMUM 30
