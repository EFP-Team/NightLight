/*
	USAGE:

		var/datum/callback/C = new(object|null, /proc/type/path|"procstring", arg1, arg2, ... argn)
		var/timerid = addtimer(C, time, timertype)
		OR
		var/timerid = addtimer(CALLBACK(object|null, /proc/type/path|procstring, arg1, arg2, ... argn), time, timertype)

		Note: proc strings can only be given for datum proc calls, global procs must be proc paths
		Also proc strings are strongly advised against because they don't compile error if the proc stops existing
		See the note on proc typepath shortcuts

	INVOKING THE CALLBACK:
		var/result = C.Invoke(args, to, add) //additional args are added after the ones given when the callback was created
		OR
		var/result = C.InvokeAsync(args, to, add) //Sleeps will not block, returns . on the first sleep (then continues on in the "background" after the sleep/block ends), otherwise operates normally.

		Optionally do INVOKE(<CALLBACK args>) to immediately create and call InvokeAsync

	PROC TYPEPATH SHORTCUTS (these operate on paths, not types, so to these shortcuts, datum is NOT a parent of atom, etc...)

		global proc while in another global proc:
			.procname
			Example:
				CALLBACK(GLOBAL_PROC, .some_proc_here)

		proc defined on current(src) object (when in a /proc/ and not an override) OR overridden at src or any of it's parents:
			.procname
			Example:
				CALLBACK(src, .some_proc_here)


		when the above doesn't apply:
			.proc/procname
			Example:
				CALLBACK(src, .proc/some_proc_here)

		proc defined on a parent of a some type:
			/some/type/.proc/some_proc_here



		Other wise you will have to do the full typepath of the proc (/type/of/thing/proc/procname)

*/

/datum/callback
	var/datum/object = GLOBAL_PROC
	var/delegate
	var/list/arguments

/datum/callback/New(thingtocall, proctocall, ...)
	if (thingtocall)
		object = thingtocall
	delegate = proctocall
	if (length(args) > 2)
		arguments = args.Copy(3)


/datum/callback/immediate/New(thingtocall, proctocall, ...)
	set waitfor = FALSE

	//copypasta of above
	if (thingtocall)
		object = thingtocall
	delegate = proctocall
	if (length(args) > 2)
		arguments = args.Copy(3)

#include "callback_invoke.dm"

/datum/callback/proc/Invoke(...)
#include "callback_invoke.dm"

//copy and pasted because fuck proc overhead
/datum/callback/proc/InvokeAsync(...)
	set waitfor = FALSE
#include "callback_invoke.dm"
