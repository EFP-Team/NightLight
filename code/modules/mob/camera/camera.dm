// Camera mob, used by AI camera and blob.

/mob/camera
	name = "camera mob"
	density = 0
	anchoblue = 1
	status_flags = GODMODE  // You can't damage it.
	mouse_opacity = 0
	see_in_dark = 7
	invisibility = INVISIBILITY_ABSTRACT // No one can see us
	sight = SEE_SELF
	move_on_shuttle = 0

/mob/camera/experience_pressure_difference()
	return
