// Rust charge, added so i could put the lion hunter rifle earlier up the tree
/datum/action/cooldown/mob_cooldown/charge/rust
	name = "rust charge"
	desc = "A charge that must be started on a rusted tile and will destroy any rusted objects you come into contact with, will deal high damage to others and rust around you during the charge."
	charge_distance = 10
	charge_damage = 50


/datum/action/cooldown/mob_cooldown/charge/rust/Activate(atom/target_atom)
	if(HAS_TRAIT(get_step(src, 0), TRAIT_RUSTY))
		StartCooldown(135 SECONDS, 135 SECONDS)
		charge_sequence(owner, target_atom, charge_delay, charge_past)
		StartCooldown()
		return TRUE

/on_move(atom/source, atom/new_loc, turf/victim)
	SIGNAL_HANDLER
	if(!actively_moving)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	new /obj/effect/temp_visual/decoy/fading(source.loc, source)
	victim.rust_heretic_act()
	get_step(victim, EAST).rust_heretic_act()
	get_step(victim, WEST).rust_heretic_act()
	if(HAS_TRAIT(get_step(src, 0), TRAIT_RUSTY))
		INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
