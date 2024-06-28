/// Datum tracker for storage UI
/datum/storage_interface
	/// UI elements for this theme
	var/atom/movable/screen/close/closer
	var/atom/movable/screen/storage/cells
	var/atom/movable/screen/storage/corner/corner_top_left
	var/atom/movable/screen/storage/corner/top_right/corner_top_right
	var/atom/movable/screen/storage/corner/bottom_left/corner_bottom_left
	var/atom/movable/screen/storage/corner/bottom_right/corner_bottom_right
	var/atom/movable/screen/storage/rowjoin/rowjoin_left
	var/atom/movable/screen/storage/rowjoin/right/rowjoin_right

	/// Storage that owns us
	var/datum/storage/parent_storage

/datum/storage_interface/New(ui_style, parent_storage)
	..()
	src.parent_storage = parent_storage
	closer = new(null, null, parent_storage)
	cells = new(null, null, parent_storage)
	corner_top_left = new(null, null, parent_storage)
	corner_top_right = new(null, null, parent_storage)
	corner_bottom_left = new(null, null, parent_storage)
	corner_bottom_right = new(null, null, parent_storage)
	rowjoin_left = new(null, null, parent_storage)
	rowjoin_right = new(null, null, parent_storage)
	for (var/atom/movable/screen/ui_elem as anything in list_ui_elements())
		ui_elem.icon = ui_style

/// Returns all UI elements under this theme
/datum/storage_interface/proc/list_ui_elements()
	return list(cells, corner_top_left, corner_top_right, corner_bottom_left, corner_bottom_right, rowjoin_left, rowjoin_right, closer)

/datum/storage_interface/Destroy(force)
	QDEL_NULL(cells)
	QDEL_NULL(corner_top_left)
	QDEL_NULL(corner_top_right)
	QDEL_NULL(corner_bottom_left)
	QDEL_NULL(corner_bottom_right)
	QDEL_NULL(rowjoin_left)
	QDEL_NULL(rowjoin_right)
	parent_storage = null
	return ..()

/// Updates position of all UI elements
/datum/storage_interface/proc/update_position(screen_start_x, screen_pixel_x, screen_start_y, screen_pixel_y, columns, rows)
	var/start_pixel_x = screen_start_x * 32 + screen_pixel_x
	var/start_pixel_y = screen_start_y * 32 + screen_pixel_y
	var/end_pixel_x = start_pixel_x + (columns - 1) * 32
	var/end_pixel_y = start_pixel_y + (rows - 1) * 32

	cells.screen_loc = spanning_screen_loc(start_pixel_x, start_pixel_y, end_pixel_x, end_pixel_y)
	var/left_edge_loc = spanning_screen_loc(start_pixel_x + 32, start_pixel_y, end_pixel_x, end_pixel_y)
	var/right_edge_loc = spanning_screen_loc(start_pixel_x, start_pixel_y, end_pixel_x + max(0, (columns - 2)) * 32, end_pixel_y)
	corner_top_left.screen_loc = left_edge_loc
	corner_top_right.screen_loc = right_edge_loc
	corner_bottom_left.screen_loc = left_edge_loc
	corner_bottom_right.screen_loc = right_edge_loc

	var/row_loc = spanning_screen_loc(start_pixel_x, start_pixel_y + 27, end_pixel_x, end_pixel_y + 27 + max(0, rows - 2) * 32)
	rowjoin_left.screen_loc = row_loc
	rowjoin_left.alpha = (rows > 1) * 255

	rowjoin_right.screen_loc = row_loc
	rowjoin_right.alpha = (rows > 1) * 255

	closer.screen_loc = "[screen_start_x + columns]:[screen_pixel_x - 5],[screen_start_y]:[screen_pixel_y]"

/proc/spanning_screen_loc(start_px, start_py, end_px, end_py)
	var/starting_tile_x = round(start_px / 32)
	start_px -= starting_tile_x * 32
	var/starting_tile_y = round(start_py/ 32)
	start_py -= starting_tile_y * 32
	var/ending_tile_x = round(end_px / 32)
	end_px -= ending_tile_x * 32
	var/ending_tile_y = round(end_py / 32)
	end_py -= ending_tile_y * 32
	return "[starting_tile_x]:[start_px],[starting_tile_y]:[start_py] to [ending_tile_x]:[end_px],[ending_tile_y]:[end_py]"
