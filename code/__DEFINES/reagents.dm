#define SOLID 			1
#define LIQUID			2
#define GAS				3

/// Moles per reagent unit. Used to convert between reagent units and gases.
#define REAGENT_MOLE_DENSITY	10

/// The boiling point of water.
#define BP_WATER			(T0C + 100)
/// The boiling point of nitrogen. Should remain above 300 while the chem dispenser exists.
#define BP_NITROGEN			(310)
/// The boiling point of oxygen. Should remain above 300 while the chem dispenser exists.
#define BP_OXYGEN			(310)
/// The boiling point of CO2.
#define BP_CARBON_DIOXIDE	(195)
/// The boiling point of nitrous oxide.
#define BP_NITROUS_OXIDE	(185)
/// The boiling point of tritium. Actually just used for condensation.
#define BP_TRITIUM			(25)
/// The boiling point of hydrogen. Actually just used for condensation since hydrogen gas is supposed to be rare
#define BP_HYDROGEN			(23)
/// The boiling point of liquid plasma.
#define BP_PLASMA			(T0C + 50)

#define INJECTABLE		(1<<0)	// Makes it possible to add reagents through droppers and syringes.
#define DRAWABLE		(1<<1)	// Makes it possible to remove reagents through syringes.

#define REFILLABLE		(1<<2)	// Makes it possible to add reagents through any reagent container.
#define DRAINABLE		(1<<3)	// Makes it possible to remove reagents through any reagent container.
#define DUNKABLE		(1<<4)	// Allows items to be dunked into this container for transfering reagents. Used in conjunction with the dunkable component.

#define TRANSPARENT		(1<<5)	// Used on containers which you want to be able to see the reagents off.
#define AMOUNT_VISIBLE	(1<<6)	// For non-transparent containers that still have the general amount of reagents in them visible.
#define NO_REACT		(1<<7)	// Applied to a reagent holder, the contents will not react with each other.

// Is an open container for all intents and purposes.
#define OPENCONTAINER 	(REFILLABLE | DRAINABLE | TRANSPARENT)

// Reagent exposure methods.
/// Used for splashing.
#define TOUCH			(1<<0)
/// Used for ingesting the reagents. Food, drinks, inhaling smoke.
#define INGEST			(1<<1)
/// Used by foams, sprays, and blob attacks.
#define VAPOR			(1<<2)
/// Used by medical patches and gels.
#define PATCH			(1<<3)
/// Used for direct injection of reagents.
#define INJECT			(1<<4)

#define MIMEDRINK_SILENCE_DURATION 30  //ends up being 60 seconds given 1 tick every 2 seconds
///Health threshold for synthflesh and rezadone to unhusk someone
#define UNHUSK_DAMAGE_THRESHOLD 50
///Amount of synthflesh required to unhusk someone
#define SYNTHFLESH_UNHUSK_AMOUNT 100

//used by chem masters and pill presses
#define PILL_STYLE_COUNT 22 //Update this if you add more pill icons or you die
#define RANDOM_PILL_STYLE 22 //Dont change this one though

//used by chem master
#define CONDIMASTER_STYLE_AUTO "auto"
#define CONDIMASTER_STYLE_FALLBACK "_"

#define ALLERGIC_REMOVAL_SKIP "Allergy"
