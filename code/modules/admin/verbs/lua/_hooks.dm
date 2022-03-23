/datum
	var/__auxtools_weakref_id //used by auxtools for weak references

/**
 * Sets a global proc to call in place of just outright setting a datum's var to a given value
 *
 * The proc will be called with the arguments (datum/datum_to_modify, var_name, value)
 *
 * required wrapper text the name of the proc to use as the wrapper
 */
/proc/__lua_set_set_var_wrapper(wrapper)
	CRASH("auxlua not loaded")

/**
 * Sets a global proc to call in place of just outright calling a given proc on a datum
 *
 * The proc will be called with the arguments (datum/thing_to_call, proc_to_call, list/arguments)
 *
 * required wrapper text the name of the proc to use as the wrapper
 */
/proc/__lua_set_datum_proc_call_wrapper(wrapper)
	CRASH("auxlua not loaded")

/**
 * Sets a global proc to call in place of just outright calling a given global proc
 *
 * The proc will be called with the arguments (proc_to_call, list/arguments)
 *
 * required wrapper text the name of the proc to use as the wrapper
 */
/proc/__lua_set_global_proc_call_wrapper(wrapper)
	CRASH("auxlua not loaded")

/**
 * Sets a global proc to call in place of require
 *
 * The proc will be called with the name of the package to load as its only argument
 * The proc should return lua source code.
 * If the proc runtimes or returns something other than text, auxlua will fall back
 * on the original require function, whose built-in searchers will search through
 * the current working directory of the Dream Daemon process.
 *
 * required wrapper text the name of the proc to use as the wrapper
 */
/proc/__lua_set_require_wrapper(wrapper)
	CRASH("auxlua not loaded")

/**
 * Sets the maximum amount of time a lua chunk or function can execute without sleeping or yielding.
 * Chunks/functions that exceed this duration will produce an error.
 *
 * required limit number the execution limit, in milliseconds
 */
/proc/__lua_set_execution_limit(limit)
	CRASH("auxlua not loaded")

/**
 * Creates a new lua context.
 *
 * return text a pointer to the created context.
 */
/proc/__lua_new_context()
	CRASH("auxlua not loaded")

/**
 * Loads a chunk of lua source code and executes it
 *
 * required context text a pointer to the context
 * in which to execute the code
 * required script text the lua source code to execute
 * optional name text a name to give to the chunk
 *
 * return list|text a list of lua return information
 * or an error message if the context was corrupted
 *
 * Lua return information is formatted as followed:
 * - ["status"]: How the chunk or function stopped code execution
 *     - "sleeping": The chunk or function called dm.sleep,
 *       placing it in the sleep queue. Items in the sleep
 *       queue can be resumed using /proc/__lua_awaken
 *     - "yielded": The chunk or function called coroutine.yield,
 *       placing it in the yield table. Items in the yield
 *       table can can be resumed by passing their index
 *       to /proc/__lua_resume
 *     - "finished": The chunk or function finished
 *     - "errored": The chunk or function produced an error
 *     - "bad return": The chunk or function yielded or finished,
 *       but its return value could not be converted to DM values
 * - ["param"]: Depends on status.
 *     - "sleeping": null
 *     - "yielded" or "finished": The return/yield value(s)
 *     - "errored" or "bad return": The error message
 * - ["yield_index"]: The index in the yield table where the
 *   chunk or function is located, for calls to __lua_resume
 * - ["name"]: The name of the chunk or function, for logging
 */
/proc/__lua_load(context, script, name)
	CRASH("auxlua not loaded")

/**
 * Calls a lua function
 *
 * required context text a pointer to the context
 * in which to call the function
 * required function text the name of the function to call
 * optional arguments list arguments to pass to the function
 *
 * return list|text a list of lua return information
 * or an error message if the context was corrupted
 *
 * Lua return information is formatted as followed:
 * - ["status"]: How the chunk or function stopped code execution
 *     - "sleeping": The chunk or function called dm.sleep,
 *       placing it in the sleep queue. Items in the sleep
 *       queue can be resumed using /proc/__lua_awaken
 *     - "yielded": The chunk or function called coroutine.yield,
 *       placing it in the yield table. Items in the yield
 *       table can can be resumed by passing their index
 *       to /proc/__lua_resume
 *     - "finished": The chunk or function finished
 *     - "errored": The chunk or function produced an error
 *     - "bad return": The chunk or function yielded or finished,
 *       but its return value could not be converted to DM values
 * - ["param"]: Depends on status.
 *     - "sleeping": null
 *     - "yielded" or "finished": The return/yield value(s)
 *     - "errored" or "bad return": The error message
 * - ["yield_index"]: The index in the yield table where the
 *   chunk or function is located, for calls to __lua_resume
 * - ["name"]: The name of the chunk or function, for logging
 */
/proc/__lua_call(context, function, arguments)
	CRASH("auxlua not loaded")

/**
 * Dequeues the task at the front of the sleep queue and resumes it
 *
 * required context text a pointer to the context in which
 * to resume a task
 *
 * return list|text|null a list of lua return information,
 * an error message if the context is corrupted,
 * or null if the sleep queue is empty
 *
 * Lua return information is formatted as followed:
 * - ["status"]: How the chunk or function stopped code execution
 *     - "sleeping": The chunk or function called dm.sleep,
 *       placing it in the sleep queue. Items in the sleep
 *       queue can be resumed using /proc/__lua_awaken
 *     - "yielded": The chunk or function called coroutine.yield,
 *       placing it in the yield table. Items in the yield
 *       table can can be resumed by passing their index
 *       to /proc/__lua_resume
 *     - "finished": The chunk or function finished
 *     - "errored": The chunk or function produced an error
 *     - "bad return": The chunk or function yielded or finished,
 *       but its return value could not be converted to DM values
 * - ["param"]: Depends on status.
 *     - "sleeping": null
 *     - "yielded" or "finished": The return/yield value(s)
 *     - "errored" or "bad return": The error message
 * - ["yield_index"]: The index in the yield table where the
 *   chunk or function is located, for calls to __lua_resume
 * - ["name"]: The name of the chunk or function, for logging
 */
/proc/__lua_awaken(context)
	CRASH("auxlua not loaded")

/**
 * Removes the task at the specified index from the yield table
 * and resumes it
 *
 * required context text a pointer to the context in which to
 * resume a task
 * required index number the index in the yield table of the
 * task to resume
 * optional arguments list the arguments to resume the task with
 *
 * return list|text|null a list of lua return information,
 * an error message if the context is corrupted,
 * or null if there is no task at the specified index
 *
 * Lua return information is formatted as followed:
 * - ["status"]: How the chunk or function stopped code execution
 *     - "sleeping": The chunk or function called dm.sleep,
 *       placing it in the sleep queue. Items in the sleep
 *       queue can be resumed using /proc/__lua_awaken
 *     - "yielded": The chunk or function called coroutine.yield,
 *       placing it in the yield table. Items in the yield
 *       table can can be resumed by passing their index
 *       to /proc/__lua_resume
 *     - "finished": The chunk or function finished
 *     - "errored": The chunk or function produced an error
 *     - "bad return": The chunk or function yielded or finished,
 *       but its return value could not be converted to DM values
 * - ["param"]: Depends on status.
 *     - "sleeping": null
 *     - "yielded" or "finished": The return/yield value(s)
 *     - "errored" or "bad return": The error message
 * - ["yield_index"]: The index in the yield table where the
 *   chunk or function is located, for calls to __lua_resume
 * - ["name"]: The name of the chunk or function, for logging
 */
/proc/__lua_resume(context, index, arguments)
	CRASH("auxlua not loaded")

/**
 * Get the variables within a context's environment.
 * Values not convertible to DM values are substituted
 * for their types as text
 *
 * required context text a pointer to the context
 * to get the variables from
 *
 * return list the variables of the context's environment
 */
/proc/__lua_get_globals(context)
	CRASH("auxlua not loaded")

/**
 * Get a list of all tasks currently in progress within a context
 *
 * required context text a pointer to the context
 * to get the tasks from
 *
 * return list a list of the context's tasks, formatted as follows:
 * - name: The name of the task
 * - status: Whether the task is sleeping or yielding
 * - index: The index of the task in the sleep queue
 *   or yield table, whichever is applicable
 */
/proc/__lua_get_tasks(context)
	CRASH("auxlua not loaded")

/**
 * Kills a task in progress
 *
 * required context text a pointer to the context
 * in which to kill a task
 * required info list the task info
 */
/proc/__lua_kill_task(context, info)
	CRASH("auxlua not loaded")
