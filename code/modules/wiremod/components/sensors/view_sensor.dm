/**
 * # View Sensor
 *
 * Returns all movable objects in view.
 */

#define VIEW_SENSOR_RANGE 5
#define VIEW_SENSOR_COOLDOWN 1 SECONDS

/obj/item/circuit_component/view_sensor
	display_name = "View Sensor"
	desc = "Outputs a list with all movable objects in it's view. Requires a shell."
	category = "Sensor"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	power_usage_per_input = 10 //Normal components have 1

	/// The result from the output
	var/datum/port/output/result
	var/datum/port/output/cooldown

	COOLDOWN_DECLARE(use_cooldown)

	var/see_invisible = SEE_INVISIBLE_LIVING

/obj/item/circuit_component/view_sensor/populate_ports()
	result = add_output_port("Result", PORT_TYPE_LIST(PORT_TYPE_ATOM))
	cooldown = add_output_port("Scan On Cooldown", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/view_sensor/input_received(datum/port/input/port)
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		result.set_output(null)
		cooldown.set_output(COMPONENT_SIGNAL)
		return

	if(!parent || !parent.shell)
		result.set_output(null)
		return

	if(!isturf(parent.shell.loc))
		if(isliving(parent.shell.loc))
			var/mob/living/owner = parent.shell.loc
			if(parent.shell != owner.get_active_held_item() && parent.shell != owner.get_inactive_held_item())
				result.set_output(null)
				return
		else
			result.set_output(null)
			return

	var/object_list = list()

	for(var/atom/movable/target in view(5, get_turf(parent.shell)))
		if(target.invisibility > see_invisible)
			continue

		object_list += target

	result.set_output(object_list)
	COOLDOWN_START(src, use_cooldown, VIEW_SENSOR_COOLDOWN)

#undef VIEW_SENSOR_RANGE
#undef VIEW_SENSOR_COOLDOWN
