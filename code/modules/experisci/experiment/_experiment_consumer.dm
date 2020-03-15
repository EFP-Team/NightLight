/**
  * # Experiment Consumer
  *
  * This is the base component for getting experiments for consumption from a connected techweb.
  */
/datum/component/experiment_consumer
	/// Holds the currently linked techweb to get experiments from
	var/datum/techweb/linked_web
	/// Holds the currently selected experiment
	var/datum/experiment/selected_experiment

/datum/component/experiment_consumer/proc/select_experiment(mob/user, var/list/experiment_types = null, strict_types = FALSE)
	if (!linked_web)
		to_chat(user, "<span class='notice'>There is no linked research server to get experiments from.</span>")
		return

	var/list/experiments = list()
	for (var/datum/experiment/e in linked_web.active_experiments)
		if (parent.type in e.allowed_experimentors)
			var/matched_type = null
			for (var/i in experiment_types)
				if (istype(e, i))
					matched_type = i
					break
			if (matched_type)
				experiments[e.name] = e
	if (experiments.len == 0)
		to_chat(user, "<span class='notice'>There are no active experiments on this research server that are compatible with this device.</span>")
		return

	var/selected = input(user, "Select an experiment", "Experiments") as null|anything in experiments
	var/datum/experiment/new_experiment = selected ? experiments[selected] : null
	if (new_experiment && new_experiment != selected_experiment)
		selected_experiment = new_experiment
		to_chat(user, "<span class='notice'>You selected [new_experiment.name].</span>")
	else
		to_chat(user, "<span class='notice'>You decide not to change the selected experiment.</span>")

/datum/component/experiment_consumer/proc/link_techweb(datum/techweb/new_web)
	if (new_web == linked_web)
		return
	selected_experiment = null
	linked_web = new_web

/datum/component/experiment_consumer/proc/unlink_techweb()
	selected_experiment = null
	linked_web = null

/datum/component/experiment_consumer/proc/select_techweb(mob/user)
	var/list/servers = get_available_servers()
	if (servers.len == 0)
		to_chat(user, "No research servers detected in your vicinity.")
		return
	var/snames = list()
	for (var/obj/s in servers)
		snames[s.name] = s
	var/selected = input(user, "Select a research server", "Research Servers") as null|anything in snames
	var/obj/machinery/rnd/server/new_server = selected ? snames[selected] : null
	if (new_server && new_server.stored_research != linked_web)
		link_techweb(new_server.stored_research)
		to_chat(user, "<span class='notice'>Linked to [new_server.name].</span>")
	else
		to_chat(user, "<span class='notice'>You decide not to change the linked research server.</span>")

/datum/component/experiment_consumer/proc/get_available_servers(var/turf/pos = null)
	if (!pos)
		pos = get_turf(parent)
	var/list/local_servers = list()
	for (var/obj/machinery/rnd/server/s in SSresearch.servers)
		var/turf/s_pos = get_turf(s)
		if (pos && s_pos && s_pos.z == pos.z)
			local_servers += s
	return local_servers
