/**
 * create_file
 *
 * Creates a new file and immediately stores it on the modular computer. Internally
 * just creates the file datum and calls `store_file`. Returns the new file if it was successful.
 */
/datum/modular_computer_host/proc/create_file(filetype)
	if(!ispath(filetype, /datum/computer_file))
		CRASH("Attempted to create non-computer file type [filetype]")

	var/datum/computer_file/new_file = new filetype

	if(!can_store_file(new_file))
		qdel(new_file)
		return null

	store_file(new_file)
	return new_file

/**
 * store_file
 *
 * Adds an already initialized file to the computer, checking if one already exists.
 * Returns TRUE if successfully stored, FALSE otherwise.
 */
/datum/modular_computer_host/proc/store_file(datum/computer_file/file_storing)
	if(!file_storing || !istype(file_storing))
		return FALSE
	if(!can_store_file(file_storing))
		return FALSE

	// This file is already stored. Don't store it again.
	if(file_storing in stored_files)
		return FALSE

	SEND_SIGNAL(file_storing, COMSIG_MODULAR_COMPUTER_FILE_ADDING)
	file_storing.computer = src
	file_storing.physical = physical
	stored_files.Add(file_storing)
	used_capacity += file_storing.size
	SEND_SIGNAL(file_storing, COMSIG_MODULAR_COMPUTER_FILE_ADDED)
	return TRUE

/**
 * remove_file
 *
 * Removes a given file from the computer, if possible.
 * Properly checking if the file even exists and is in the computer.
 * Returns TRUE if successfully completed, FALSE otherwise
 */
/datum/modular_computer_host/proc/remove_file(datum/computer_file/file_removing)
	if(!file_removing || !istype(file_removing))
		return FALSE
	if(!(file_removing in stored_files))
		return FALSE
	if(istype(file_removing, /datum/computer_file/program))
		var/datum/computer_file/program/program_file = file_removing
		if(program_file.program_state != PROGRAM_STATE_KILLED)
			program_file.kill_program(TRUE)
		if(program_file.program_state == PROGRAM_STATE_ACTIVE)
			active_program = null

	SEND_SIGNAL(file_removing, COMSIG_MODULAR_COMPUTER_FILE_DELETING)
	stored_files.Remove(file_removing)
	used_capacity -= file_removing.size
	file_removing.computer = null
	file_removing.physical = null
	SEND_SIGNAL(file_removing, COMSIG_MODULAR_COMPUTER_FILE_DELETED)
	return TRUE

/**
 * can_store_file
 *
 * Checks if a computer can store a file, as computers can only store unique files.
 * returns TRUE if possible, FALSE otherwise.
 */
/datum/modular_computer_host/proc/can_store_file(datum/computer_file/file)
	if(!file || !istype(file))
		return FALSE
	if(file in stored_files)
		return FALSE
	if(find_file_by_name(file.filename))
		return FALSE
	// In the unlikely event someone manages to create that many files.
	// BYOND is acting weird with numbers above 999 in loops (infinite loop prevention)
	if(stored_files.len >= 999)
		return FALSE
	if((used_capacity + file.size) > max_capacity)
		return FALSE

	return TRUE

/**
 * find_file_by_name
 *
 * Will check all applications in a tablet for files and, if they have \
 * the same filename (disregarding extension), will return it.
 * If a computer disk is passed instead, it will check the disk over the computer.
 */
/datum/modular_computer_host/proc/find_file_by_name(filename, obj/item/computer_disk/target_disk)
	if(!filename)
		return null
	if(target_disk)
		for(var/datum/computer_file/file as anything in target_disk.stored_files)
			if(file.filename == filename)
				return file
	else
		for(var/datum/computer_file/file as anything in stored_files)
			if(file.filename == filename)
				return file
	return null
