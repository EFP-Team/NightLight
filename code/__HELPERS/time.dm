//Returns the world time in english
/proc/worldtime2text()
	return gameTimestamp("hh:mm:ss", world.time)

/proc/time_stamp(format = "hh:mm:ss", show_ds)
	var/time_string = time2text(world.timeofday, format)
	return show_ds ? "[time_string]:[world.timeofday % 10]" : time_string

/proc/gameTimestamp(format = "hh:mm:ss", wtime=null)
	if(!wtime)
		wtime = world.time
	return time2text(wtime - GLOB.timezoneOffset + SSticker.gametime_offset - SSticker.round_start_time, format)

/* Returns 1 if it is the selected month and day */
/proc/isDay(month, day)
	if(isnum(month) && isnum(day))
		var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
		var/DD = text2num(time2text(world.timeofday, "DD")) // get the current day
		if(month == MM && day == DD)
			return 1

		// Uncomment this out when debugging!
		//else
			//return 1

//returns timestamp in a sql and ISO 8601 friendly format
/proc/SQLtime(timevar)
	if(!timevar)
		timevar = world.realtime
	return time2text(timevar, "YYYY-MM-DD hh:mm:ss")


GLOBAL_VAR_INIT(midnight_rollovers, 0)
GLOBAL_VAR_INIT(rollovercheck_last_timeofday, 0)
/proc/update_midnight_rollover()
	if (world.timeofday < GLOB.rollovercheck_last_timeofday) //TIME IS GOING BACKWARDS!
		return GLOB.midnight_rollovers++
	return GLOB.midnight_rollovers

/proc/weekdayofthemonth()
	var/DD = text2num(time2text(world.timeofday, "DD")) 	// get the current day
	switch(DD)
		if(8 to 13)
			return 2
		if(14 to 20)
			return 3
		if(21 to 27)
			return 4
		if(28 to INFINITY)
			return 5
		else
			return 1

//Takes a value of time in deciseconds.
//Returns a text value of that number in hours, minutes, or seconds.
/proc/DisplayTimeText(time_value)
	var/second = time_value*0.1
	var/minute = null
	var/hour = null
	var/day = null

	if(!second)
		return "0 seconds"
	if(second >= 60)
		minute = round_down(second/60)
		second = round(second - (minute*60), 0.1)
	if(second != 1 && second != 0)
		if(day || hour || minute)
			second = " and [second] seconds"
		else
			second = "[second] seconds"
	else if(second == 1)
		if(day || hour || minute)
			second = " and 1 second"
		else
			second = "1 second"
	else
		second = null

	if(!minute)
		return "[second]"
	if(minute >= 60)
		hour = round_down(minute/60,1)
		minute = round(minute - (hour*60))
	if(minute != 1 && minute != 0)
		if((day || hour) && second)
			minute = ", [minute] minutes"
		else if((day || hour) && !second)
			minute = " and [minute] minutes"
		else
			minute = "[minute] minutes"
	else if(minute == 1)
		if((day || hour) && second)
			minute = ", 1 minute"
		else if((day || hour) && !second)
			minute = " and 1 minute"
		else
			minute = "1 minute"
	else
		minute = null

	if(!hour)
		return "[minute][second]"
	if(hour >= 24)
		day = round_down(hour/24,1)
		hour = round(hour - (day*24))
	if(hour != 1 && hour != 0)
		if(day && (minute || second))
			hour = ", [hour] hours"
		else if(day && (!minute || !second))
			hour = " and [hour] hours"
		else
			hour = "[hour] hours"
	else if(hour == 1)
		if(day && (minute || second))
			hour = ", 1 hour"
		else if(day && (!minute || !second))
			hour = " and 1 hour"
		else
			hour = "1 hour"
	else
		hour = null

	if(!day)
		return "[hour][minute][second]"
	if(day > 1)
		day = "[day] days"
	else
		day = "1 day"

	return "[day][hour][minute][second]"
