/**
 * # For Each Component
 *
 * Sends a signal for each item in a list
 */
/obj/item/circuit_component/foreach
	display_name = "For Each"
	desc = "A component that loops through each element in a list."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// The list type
	DEFINE_OPTION_PORT(list_options)

	/// The list to iterate over
	DEFINE_INPUT_PORT(list_to_iterate)

	/// The current element from the list
	DEFINE_OUTPUT_PORT(element)
	/// The current index from the list
	DEFINE_OUTPUT_PORT(current_index)
	/// A signal that is sent when the list has moved onto the next index.
	DEFINE_OUTPUT_PORT(on_next_index)
	/// A signal that is sent when the list has finished iterating
	DEFINE_OUTPUT_PORT(on_finished)

	/// The limit of iterations before it breaks. Used to prevent from someone iterating a massive list constantly
	var/limit = 100

/obj/item/circuit_component/foreach/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/foreach/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		list_to_iterate.set_datatype(PORT_TYPE_LIST(new_datatype))
		element.set_datatype(new_datatype)

/obj/item/circuit_component/foreach/populate_ports()
	list_to_iterate = add_input_port("List Input", PORT_TYPE_LIST(PORT_TYPE_ANY))

	element = add_output_port("Element", PORT_TYPE_ANY)
	current_index = add_output_port("Index", PORT_TYPE_NUMBER)
	on_next_index = add_output_port("Next Index", PORT_TYPE_SIGNAL)
	on_finished = add_output_port("On Finished", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/foreach/input_received(datum/port/input/port)
	var/index = 1
	for(var/element_in_list in list_to_iterate.value)
		if(index > limit)
			break
		element.set_output(element_in_list)
		current_index.set_output(index)
		on_next_index.set_output(COMPONENT_SIGNAL)
		index += 1
	on_finished.set_output(COMPONENT_SIGNAL)
