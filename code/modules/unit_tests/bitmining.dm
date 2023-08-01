#define TEST_MAP "test_only"
#define TEST_MAP_EXPENSIVE "test_only_expensive"
#define TEST_MAP_MOBS "test_only_mobs"

/// The qserver and qconsole should find each other on init
/datum/unit_test/qserver_find_console/Run()
	var/obj/machinery/computer/quantum_console/console = allocate(/obj/machinery/computer/quantum_console)
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	TEST_ASSERT_NOTNULL(console.server_ref, "Quantum console did not set server_ref")
	TEST_ASSERT_NOTNULL(server.console_ref, "Quantum server did not set console_ref")

	var/obj/machinery/computer/quantum_console/connected_console = server.console_ref.resolve()
	var/obj/machinery/quantum_server/connected_server = console.server_ref.resolve()
	TEST_ASSERT_EQUAL(connected_console, console, "Quantum console did not set server_ref correctly")
	TEST_ASSERT_EQUAL(connected_server, server, "Quantum server did not set console_ref correctly")

/// Initializing map templates
/datum/unit_test/qserver_initialize_domain/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)

	var/datum/map_template/virtual_domain/domain = server.initialize_domain(TEST_MAP)
	TEST_ASSERT_EQUAL(domain.id, TEST_MAP, "Did not load test map correctly")

/// Initializing virtual domain
/datum/unit_test/qserver_initialize_vdom/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)

	server.initialize_virtual_domain()
	TEST_ASSERT_NOTNULL(server.vdom_ref, "Did not initialize vdom")
	TEST_ASSERT_EQUAL(length(server.map_load_turf), 1, "There should only ever be ONE turf, the bottom left, in the map_load_turf list")
	TEST_ASSERT_EQUAL(length(server.safehouse_load_turf), 1, "There should only ever be ONE turf, the bottom left, in the safehouse_load_turf list")

/// Loading maps onto the vdom
/datum/unit_test/qserver_load_domain/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)

	server.initialize_virtual_domain()
	TEST_ASSERT_NOTNULL(server.vdom_ref, "Sanity: Did not initialize vdom_ref")

	var/datum/map_template/virtual_domain/domain = server.initialize_domain(map_id = TEST_MAP)
	TEST_ASSERT_EQUAL(domain.id, TEST_MAP, "Sanity: Did not load test map correctly")

	server.load_domain(domain)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Did not load the correct domain")
	TEST_ASSERT_NOTNULL(server.generated_safehouse, "Did not load generated_safehouse correctly")
	TEST_ASSERT_NOTNULL(server.generated_domain, "Did not load generated_domain correctly")
	TEST_ASSERT_EQUAL(length(server.exit_turfs), 3, "Did not load the correct number of exit turfs")

/// Handles cases with stopping domains. The server should cool down & prevent stoppage with active mobs
/datum/unit_test/qserver_stop_domain/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)

	server.cold_boot_map(labrat, TEST_MAP)
	TEST_ASSERT_NOTNULL(server.vdom_ref, "Sanity: Did not initialize vdom_ref")
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Sanity: Did not load test map correctly")

	server.stop_domain()
	TEST_ASSERT_NOTNULL(server.vdom_ref, "Should not erase vdom_ref on stop_domain()")
	TEST_ASSERT_NULL(server.generated_domain, "Did not stop domain")
	TEST_ASSERT_NULL(server.generated_safehouse, "Did not stop safehouse")
	TEST_ASSERT_EQUAL(server.get_ready_status(), FALSE, "Should cool down, but did not set ready status to FALSE")

	server.cold_boot_map(labrat, TEST_MAP)
	TEST_ASSERT_NULL(server.generated_domain, "Should prevent loading a new domain while cooling down")

	server.cool_off()
	server.cold_boot_map(labrat, TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Should load a new domain after cooldown")

	var/datum/weakref/fake_mind_ref = WEAKREF(labrat)
	server.occupant_mind_refs += fake_mind_ref
	server.stop_domain()
	TEST_ASSERT_NULL(server.generated_domain, "Should force stop a domain even with occupants")

/// Handles the linking process to boot a domain from scratch
/datum/unit_test/qserver_cold_boot_map/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	labrat.mind_initialize()
	labrat.mock_client = new()

	server.cold_boot_map(labrat, map_id = TEST_MAP)
	TEST_ASSERT_NOTNULL(server.generated_domain, "Did not cold boot generated_domain correctly")

	server.cold_boot_map(labrat, map_id = TEST_MAP_EXPENSIVE)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Should prevent loading multiple domains")

	server.stop_domain()
	server.cool_off()
	var/datum/weakref/fake_mind_ref = WEAKREF(labrat)
	server.occupant_mind_refs += fake_mind_ref
	server.cold_boot_map(labrat, map_id = TEST_MAP)
	TEST_ASSERT_NULL(server.generated_domain, "Should prevent setting domains with occupants")

	server.stop_domain()
	server.cool_off()
	server.occupant_mind_refs -= fake_mind_ref
	server.points = 3
	server.cold_boot_map(labrat, map_id = TEST_MAP_EXPENSIVE)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP_EXPENSIVE, "Sanity: Should've loaded expensive test map")
	TEST_ASSERT_EQUAL(server.points, 0, "Should've spent 3 points on loading a 3 point domain")

/// Tests the netpod's ability to buckle in and set refs
/datum/unit_test/netpod_close/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/obj/machinery/netpod/pod = allocate(/obj/machinery/netpod, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	labrat.mind_initialize()
	labrat.mock_client = new()

	pod.find_server() // enter_matrix calls this but I want to set it separately
	TEST_ASSERT_NOTNULL(pod.server_ref, "Sanity: Did not set server_ref")

	var/obj/machinery/quantum_server/connected_server = pod.server_ref.resolve()
	TEST_ASSERT_EQUAL(connected_server, server, "Did not set server_ref correctly")

	server.cold_boot_map(labrat, map_id = TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Sanity: Did not load test map correctly")

	labrat.forceMove(pod.loc)
	pod.close_machine(labrat)
	TEST_ASSERT_NOTNULL(pod.occupant, "Did not set occupant_ref")
	UNTIL(!isnull(pod.occupant_mind_ref))
	TEST_ASSERT_EQUAL(server.occupant_mind_refs[1], pod.occupant_mind_ref, "Did not add mind to server occupant_mind_refs")

/// Tests the netpod's ability to disconnect
/datum/unit_test/netpod_disconnect/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/obj/machinery/netpod/pod = allocate(/obj/machinery/netpod, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/datum/weakref/server_ref = WEAKREF(server)

	labrat.mind_initialize()
	labrat.mock_client = new()
	labrat.mind.key = "fake_mind"
	labrat.key = "fake_mind" // Original body gets a fake mind
	var/datum/mind/real_mind = WEAKREF(labrat.mind)

	pod.find_server()
	TEST_ASSERT_NOTNULL(pod.server_ref, "Sanity: netpod did not set server_ref")

	pod.server_ref = null // We can use this to see if the disconnect was successful
	pod.set_occupant(labrat)
	pod.disconnect_occupant(labrat.mind)
	TEST_ASSERT_NULL(pod.server_ref, "Should've prevented disconnect with no occupant")

	var/datum/mind/wrong_mind = new("wrong_mind") // 'another player'
	pod.occupant_mind_ref = real_mind
	pod.set_occupant(labrat)
	pod.disconnect_occupant(wrong_mind)
	TEST_ASSERT_NULL(pod.server_ref, "Should've prevented disconnect with wrong mind destination")

	pod.server_ref = null
	pod.set_occupant(labrat)
	pod.disconnect_occupant(labrat.mind)
	var/mob/living/mob_occupant = pod.occupant
	TEST_ASSERT_EQUAL(pod.server_ref, server_ref, "Should have correct server_ref")
	TEST_ASSERT_EQUAL(mob_occupant.get_organ_loss(ORGAN_SLOT_BRAIN), 0, "Should not have taken brain damage on disconnect")
	TEST_ASSERT_NOTNULL(mob_occupant, "Should NOT clear occupant_ref, unbuckle only")
	TEST_ASSERT_NULL(pod.occupant_mind_ref, "Should've cleared occupant_mind_ref")

	/// Testing force disconn
	pod.server_ref = null
	pod.occupant_mind_ref = real_mind
	pod.set_occupant(labrat)
	pod.disconnect_occupant(labrat.mind , forced = TRUE)
	mob_occupant = pod.occupant
	TEST_ASSERT_NOTNULL(pod.server_ref, "Sanity: pod didn't set server")
	TEST_ASSERT_EQUAL(mob_occupant.get_organ_loss(ORGAN_SLOT_BRAIN), 60, "Should've taken brain damage on force disconn")

/// Tests cases where the netpod is destroyed or the occupant unbuckled
/datum/unit_test/netpod_break/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/obj/machinery/netpod/pod = allocate(/obj/machinery/netpod, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	labrat.mind_initialize()
	labrat.mock_client = new()
	labrat.mind.key = "fake_mind"
	var/datum/weakref/real_mind = WEAKREF(labrat.mind)

	server.cold_boot_map(labrat, map_id = TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Sanity: Did not load test map correctly")

	labrat.forceMove(pod.loc)
	pod.set_occupant(labrat)
	pod.close_machine(labrat)
	TEST_ASSERT_EQUAL(pod.occupant, labrat, "Sanity: Pod didn't set occupant")
	TEST_ASSERT_NOTNULL(pod.server_ref, "Sanity: Pod didn't set server")
	TEST_ASSERT_NOTNULL(pod.occupant_mind_ref, "Sanity: Pod didn't set mind")
	TEST_ASSERT_EQUAL(pod.occupant_mind_ref, real_mind, "Sanity: Pod didn't set mind")

	pod.open_machine()
	TEST_ASSERT_NULL(pod.occupant, "Should've cleared occupant")
	TEST_ASSERT_EQUAL(labrat.get_organ_loss(ORGAN_SLOT_BRAIN), 60, "Should have taken brain damage on unbuckle")

	labrat.fully_heal()
	pod.set_occupant(labrat)
	pod.close_machine(labrat)
	TEST_ASSERT_NOTNULL(pod.occupant_mind_ref, "Sanity: Pod didn't set mind")
	TEST_ASSERT_EQUAL(pod.occupant_mind_ref, real_mind, "Sanity: Pod didn't set mind")

	qdel(pod)
	TEST_ASSERT_EQUAL(labrat.get_organ_loss(ORGAN_SLOT_BRAIN), 60, "Should have taken brain damage on pod deletion")

/// Tests the connection between avatar and pilot
/datum/unit_test/avatar_connection/Run()
	var/obj/machinery/netpod/pod = allocate(/obj/machinery/netpod)
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human/consistent)

	labrat.mind_initialize()
	labrat.mock_client = new()
	labrat.mind.key = "test_key"

	var/datum/weakref/initial_mind = labrat.mind
	var/datum/weakref/labrat_mind_ref = WEAKREF(labrat.mind)
	pod.occupant_mind_ref = labrat_mind_ref
	pod.occupant = labrat

	labrat.mind.initial_avatar_connection(avatar = target, hosting_netpod = pod, server = server)
	TEST_ASSERT_NOTNULL(target.mind, "Couldn't transfer mind to target")
	TEST_ASSERT_EQUAL(target.mind, initial_mind, "New mind is different from original")
	TEST_ASSERT_NOTNULL(target.mind.pilot_ref, "Could not set avatar_ref")
	TEST_ASSERT_NOTNULL(target.mind.netpod_ref, "Could not set netpod_ref")

	var/mob/living/carbon/human/labrat_resolved = target.mind.pilot_ref.resolve()
	TEST_ASSERT_EQUAL(labrat, labrat_resolved, "Wrong pilot ref")

	var/obj/machinery/netpod/connected_pod = target.mind.netpod_ref.resolve()
	TEST_ASSERT_EQUAL(connected_pod, pod, "Wrong netpod ref")

	target.apply_damage(10, damagetype = BURN, def_zone = BODY_ZONE_HEAD, blocked = 0, forced = TRUE)
	TEST_ASSERT_EQUAL(labrat.getFireLoss(), 10, "Damage was not transferred to pilot")
	TEST_ASSERT_NOTNULL(locate(/obj/item/bodypart/head) in labrat.get_damaged_bodyparts(burn = TRUE), "Pilot did not get damaged bodypart")

	target.apply_damage(999, forced = TRUE, spread_damage = TRUE)
	TEST_ASSERT_EQUAL(target.stat, DEAD, "Target should have died on lethal damage")
	TEST_ASSERT_EQUAL(labrat.stat, DEAD, "Pilot should have died on lethal damage")
	TEST_ASSERT_EQUAL(initial_mind, labrat.mind, "Pilot should have been transferred back to initial mind")

	var/mob/living/carbon/human/to_gib = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/pincushion = allocate(/mob/living/carbon/human/consistent)
	pincushion.mind_initialize()
	pincushion.mock_client = new()
	pincushion.mind.key = "gibbed_key"
	var/datum/mind/pincushion_mind = pincushion.mind
	pod.occupant_mind_ref = WEAKREF(pincushion.mind)
	pod.occupant = pincushion

	pincushion.mind.initial_avatar_connection(avatar = to_gib, hosting_netpod = pod, server = server)
	TEST_ASSERT_EQUAL(to_gib.mind, pincushion_mind, "Pincushion mind should have been transferred to the gib target")

	to_gib.gib()
	TEST_ASSERT_EQUAL(pincushion_mind, pincushion.mind, "Pilot should have been transferred back on avatar gib")
	TEST_ASSERT_EQUAL(pincushion.get_organ_loss(ORGAN_SLOT_BRAIN), 60, "Pilot should have taken brain dmg on gib disconnect")

/// Tests the signals sent when the server is destroyed, mobs step on a loaded tile, etc
/datum/unit_test/bitmining_signals
	var/client_connect_received = FALSE
	var/client_disconnect_received = FALSE
	var/crowbar_alert_received = FALSE
	var/domain_complete_received = FALSE
	var/integrity_alert_received = FALSE
	var/sever_avatar_received = FALSE
	var/shutdown_alert_received = FALSE

/datum/unit_test/bitmining_signals/proc/on_client_connected(datum/source)
	SIGNAL_HANDLER
	client_connect_received = TRUE

/datum/unit_test/bitmining_signals/proc/on_client_disconnected(datum/source)
	SIGNAL_HANDLER
	client_disconnect_received = TRUE

/datum/unit_test/bitmining_signals/proc/on_crowbar_alert(datum/source)
	SIGNAL_HANDLER
	crowbar_alert_received = TRUE

/datum/unit_test/bitmining_signals/proc/on_domain_complete(datum/source)
	SIGNAL_HANDLER
	domain_complete_received = TRUE

/datum/unit_test/bitmining_signals/proc/on_shutdown_alert(datum/source)
	SIGNAL_HANDLER
	shutdown_alert_received = TRUE

/datum/unit_test/bitmining_signals/proc/on_netpod_broken(datum/source)
	SIGNAL_HANDLER
	sever_avatar_received = TRUE

/datum/unit_test/bitmining_signals/proc/on_netpod_integrity(datum/source)
	SIGNAL_HANDLER
	integrity_alert_received = TRUE

/datum/unit_test/bitmining_signals/proc/on_server_crash(datum/source)
	SIGNAL_HANDLER
	sever_avatar_received = TRUE

/datum/unit_test/bitmining_signals/Run()
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/obj/machinery/netpod/netpod = allocate(/obj/machinery/netpod, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/obj/structure/closet/crate/secure/bitminer_loot/encrypted/crate = allocate(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)

	labrat.mind_initialize()
	labrat.mock_client = new()
	labrat.mind.key = "fake_mind"
	var/datum/weakref/labrat_mind_ref = WEAKREF(labrat.mind)

	var/obj/item/crowbar/prybar = allocate(/obj/item/crowbar)
	var/mob/living/carbon/human/perp = allocate(/mob/living/carbon/human/consistent)

	RegisterSignal(server, COMSIG_BITMINING_CLIENT_CONNECTED, PROC_REF(on_client_connected))
	RegisterSignal(server, COMSIG_BITMINING_CLIENT_DISCONNECTED, PROC_REF(on_client_disconnected))
	RegisterSignal(server, COMSIG_BITMINING_DOMAIN_COMPLETE, PROC_REF(on_domain_complete))
	RegisterSignal(server, COMSIG_BITMINING_SHUTDOWN_ALERT, PROC_REF(on_shutdown_alert))
	RegisterSignal(server, COMSIG_BITMINING_SEVER_AVATAR, PROC_REF(on_server_crash))
	RegisterSignal(netpod, COMSIG_BITMINING_CROWBAR_ALERT, PROC_REF(on_crowbar_alert))
	RegisterSignal(netpod, COMSIG_BITMINING_SEVER_AVATAR, PROC_REF(on_netpod_broken))
	RegisterSignal(netpod, COMSIG_BITMINING_NETPOD_INTEGRITY, PROC_REF(on_netpod_integrity))

	server.cold_boot_map(labrat, map_id = TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Sanity: Did not load test map correctly")

	labrat.forceMove(get_turf(netpod))
	netpod.set_occupant(labrat)
	netpod.close_machine(labrat)
	TEST_ASSERT_EQUAL(netpod.occupant, labrat, "Sanity: Did not set occupant")
	TEST_ASSERT_NOTNULL(netpod.server_ref, "Sanity: Did not set server")
	TEST_ASSERT_EQUAL(netpod.occupant_mind_ref, labrat_mind_ref, "Sanity: Did not set mind")
	TEST_ASSERT_EQUAL(client_connect_received, TRUE, "Did not send COMSIG_BITMINING_CLIENT_CONNECTED")

	// Will get back to this later
	// netpod.take_damage(netpod.max_integrity - 50)
	// TEST_ASSERT_EQUAL(integrity_alert_received, TRUE, "Did not send COMSIG_BITMINING_NETPOD_INTEGRITY")

	perp.put_in_active_hand(prybar)
	netpod.default_pry_open(prybar, perp)
	TEST_ASSERT_EQUAL(crowbar_alert_received, TRUE, "Did not send COMSIG_BITMINING_CROWBAR_ALERT")
	TEST_ASSERT_EQUAL(sever_avatar_received, TRUE, "Did not send COMSIG_BITMINING_SEVER_AVATAR")
	TEST_ASSERT_EQUAL(client_disconnect_received, TRUE, "Did not send COMSIG_BITMINING_CLIENT_DISCONNECTED")

	sever_avatar_received = FALSE
	server.occupant_mind_refs += labrat_mind_ref
	server.begin_shutdown(perp)
	TEST_ASSERT_EQUAL(shutdown_alert_received, TRUE, "Did not send COMSIG_BITMINING_SHUTDOWN_ALERT")
	TEST_ASSERT_EQUAL(sever_avatar_received, TRUE, "Did not send COMSIG_BITMINING_SERVER_CRASH")

	server.cool_off()
	server.occupant_mind_refs.Cut()
	server.cold_boot_map(labrat, map_id = TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Sanity: Did not load test map correctly")
	TEST_ASSERT_NOTEQUAL(length(server.send_turfs), 0, "Sanity: Did not find a send turf")

	crate.forceMove(pick(server.send_turfs))
	TEST_ASSERT_EQUAL(domain_complete_received, TRUE, "Did not send COMSIG_BITMINING_DOMAIN_COMPLETE")

/// Tests the server's ability to generate a loot crate
/datum/unit_test/qserver_generate_rewards/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	labrat.mind_initialize()
	labrat.mock_client = new()

	var/turf/tiles = get_adjacent_open_turfs(server)
	TEST_ASSERT_NOTEQUAL(length(tiles), 0, "Sanity: Did not find an open turf")

	server.cold_boot_map(labrat, map_id = TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Sanity: Did not load test map correctly")

	server.receive_turfs = tiles
	TEST_ASSERT_EQUAL(server.generate_loot(), TRUE, "Should generate loot with a receive turf")

	// This is a pretty shallow test. I keep getting null crates with locate(), so I'm not sure how to test this
	// var/obj/structure/closet/crate/secure/bitminer_loot/decrypted/crate = locate(/obj/structure/closet/crate/secure/bitminer_loot/decrypted) in tiles
	// TEST_ASSERT_NOTNULL(crate, "Should generate a loot crate")

/// Server side randomization of domains
/datum/unit_test/qserver_get_random_domain_id/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)

	var/id = server.get_random_domain_id()
	TEST_ASSERT_NULL(id, "Shouldn't return a random domain with no points")

	server.points = 3
	id = server.get_random_domain_id()
	TEST_ASSERT_NOTNULL(id, "Should return a random domain with points")

	/// Can't truly test the randomization past this

/// Tests getting list of domain generated mobs for antag targets
/datum/unit_test/qserver_get_valid_domain_mobs/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)

	server.cold_boot_map(labrat, map_id = TEST_MAP_MOBS)
	TEST_ASSERT_NOTNULL(server.generated_domain, "Sanity: Did not load test map correctly")

	var/list/mobs = server.get_valid_domain_targets()
	TEST_ASSERT_EQUAL(length(mobs), 0, "Shouldn't get a list without players")

	server.occupant_mind_refs += WEAKREF(labrat.mind)
	mobs = server.get_valid_domain_targets()
	TEST_ASSERT_EQUAL(length(mobs), 1, "Should return a list of mobs")

	var/mob/living/basic/pet/dog/corgi/pupper = locate(/mob/living/basic/pet/dog/corgi) in mobs
	TEST_ASSERT_NOTNULL(pupper, "Should be a corgi on test map")

	mobs.Cut()
	pupper.mind_initialize()
	mobs = server.get_valid_domain_targets()
	TEST_ASSERT_EQUAL(length(mobs), 0, "Should not return mobs with minds")

/// Tests the ability to create hololadders and effectively, retries
/datum/unit_test/qserver_generate_hololadder/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)

	server.generate_hololadder()
	TEST_ASSERT_EQUAL(length(server.exit_turfs), 0, "Sanity: Shouldn't exist any exit turfs until boot")
	TEST_ASSERT_EQUAL(server.retries_spent, 0, "Shouldn't create a hololadder without exit turfs")

	server.cold_boot_map(labrat, map_id = TEST_MAP_MOBS)
	TEST_ASSERT_NOTNULL(server.generated_domain, "Sanity: Did not load test map correctly")
	TEST_ASSERT_EQUAL(length(server.exit_turfs), 3, "Should create 3 exit turfs")

	server.generate_hololadder()
	TEST_ASSERT_EQUAL(server.retries_spent, 1, "Should've spent a retry")

	server.generate_hololadder()
	server.generate_hololadder()
	TEST_ASSERT_EQUAL(server.retries_spent, 3, "Should've spent 3 retries")

	server.generate_hololadder()
	TEST_ASSERT_EQUAL(server.retries_spent, 3, "Shouldn't spend more than 3 retries")

	server.stop_domain()
	TEST_ASSERT_EQUAL(server.retries_spent, 0, "Should reset retries on stop_domain()")

/// Tests the calculate rewards function
/datum/unit_test/qserver_calculate_rewards/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	var/datum/weakref/labrat_mind_ref = WEAKREF(labrat.mind)

	server.cold_boot_map(labrat, map_id = TEST_MAP)
	TEST_ASSERT_NOTNULL(server.generated_domain, "Sanity: Did not load test map correctly")

	var/rewards = server.calculate_rewards()
	TEST_ASSERT_EQUAL(rewards, 1, "Should return base rewards with unmodded")

	server.domain_randomized = TRUE
	rewards = server.calculate_rewards()
	TEST_ASSERT_EQUAL(rewards, 1.2, "Should increase rewards wehen randomized")

	server.domain_randomized = FALSE
	server.occupant_mind_refs += labrat_mind_ref
	server.occupant_mind_refs += labrat_mind_ref
	server.occupant_mind_refs += labrat_mind_ref
	rewards = server.calculate_rewards()
	var/totalA = ROUND_UP(rewards)
	var/totalB = ROUND_UP(1 + server.multiplayer_bonus * 2)
	TEST_ASSERT_EQUAL(totalA, totalB, "Should increase rewards with occupants")

	for(var/datum/stock_part/servo/servo in server.component_parts)
		server.component_parts -= servo
		server.component_parts += new /datum/stock_part/servo/tier4

	server.occupant_mind_refs.Cut()
	rewards = server.calculate_rewards()
	TEST_ASSERT_EQUAL(rewards, 1.6, "Should increase rewards with modded servos")

#undef TEST_MAP
#undef TEST_MAP_EXPENSIVE
#undef TEST_MAP_MOBS
