/datum/element/lazystorage

/datum/element/lazystorage/Attach(datum/target)
	. = ..()
	if(!istype(target, /obj/item/storage))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_CONTAINS_STORAGE, .proc/on_check)
	RegisterSignal(target, COMSIG_IS_STORAGE_LOCKED, .proc/check_locked)
	RegisterSignal(target, COMSIG_TRY_STORAGE_SHOW, .proc/signal_show_attempt)
	RegisterSignal(target, COMSIG_TRY_STORAGE_INSERT, .proc/signal_insertion_attempt)
	RegisterSignal(target, COMSIG_TRY_STORAGE_CAN_INSERT, .proc/signal_can_insert)
	RegisterSignal(target, COMSIG_TRY_STORAGE_TAKE_TYPE, .proc/signal_take_type)
	RegisterSignal(target, COMSIG_TRY_STORAGE_FILL_TYPE, .proc/signal_fill_type)
	RegisterSignal(target, COMSIG_TRY_STORAGE_SET_LOCKSTATE, .proc/set_locked)
	RegisterSignal(target, COMSIG_TRY_STORAGE_TAKE, .proc/signal_take_obj)
	RegisterSignal(target, COMSIG_TRY_STORAGE_QUICK_EMPTY, .proc/signal_quick_empty)
	RegisterSignal(target, COMSIG_TRY_STORAGE_RETURN_INVENTORY, .proc/signal_return_inv)
	RegisterSignal(target, COMSIG_CLICK_ALT, .proc/on_alt_click)
	RegisterSignal(target, COMSIG_MOUSEDROP_ONTO, .proc/mousedrop_onto)
	RegisterSignal(target, COMSIG_MOUSEDROPPED_ONTO, .proc/mousedrop_receive)
	RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, .proc/attack_self)

/datum/element/lazystorage/Detach(obj/item/storage/source, force)
	. = ..()
	UnregisterSignal(source, list(
		COMSIG_CONTAINS_STORAGE,
		COMSIG_IS_STORAGE_LOCKED,
		COMSIG_TRY_STORAGE_SHOW,
		COMSIG_TRY_STORAGE_INSERT,
		COMSIG_TRY_STORAGE_CAN_INSERT,
		COMSIG_TRY_STORAGE_TAKE_TYPE,
		COMSIG_TRY_STORAGE_FILL_TYPE,
		COMSIG_TRY_STORAGE_SET_LOCKSTATE,
		COMSIG_TRY_STORAGE_TAKE,
		COMSIG_TRY_STORAGE_QUICK_EMPTY,
		COMSIG_TRY_STORAGE_RETURN_INVENTORY,
		COMSIG_CLICK_ALT,
		COMSIG_MOUSEDROP_ONTO,
		COMSIG_MOUSEDROPPED_ONTO,
		COMSIG_ITEM_ATTACK_SELF,
	))


/// ( ͡° ͜ʖ ͡°)
#define LAZYSTORAGE_PASSTHROUGH_PROC(name, signal) \
/datum/element/lazystorage/proc/##name(obj/item/storage/source, ...) {\
	var/datum/component/storage/real_storage = source.AddComponent(source.component_type);\
	Detach(source);\
	source.item_flags &= ~ITEM_LAZY_STORAGE;\
	source.PopulateContents();\
	source.StorageInitialize(real_storage);\
	if (real_storage.signal_procs[source] && real_storage.signal_procs[source][signal]) {\
		return call(real_storage, real_storage.signal_procs[source][signal])(arglist(args));\
	};\
}

LAZYSTORAGE_PASSTHROUGH_PROC(on_check, COMSIG_CONTAINS_STORAGE)
LAZYSTORAGE_PASSTHROUGH_PROC(check_locked, COMSIG_IS_STORAGE_LOCKED)
LAZYSTORAGE_PASSTHROUGH_PROC(signal_show_attempt, COMSIG_TRY_STORAGE_SHOW)
LAZYSTORAGE_PASSTHROUGH_PROC(signal_insertion_attempt, COMSIG_TRY_STORAGE_INSERT)
LAZYSTORAGE_PASSTHROUGH_PROC(signal_can_insert, COMSIG_TRY_STORAGE_CAN_INSERT)
LAZYSTORAGE_PASSTHROUGH_PROC(signal_take_type, COMSIG_TRY_STORAGE_TAKE_TYPE)
LAZYSTORAGE_PASSTHROUGH_PROC(signal_fill_type, COMSIG_TRY_STORAGE_FILL_TYPE)
LAZYSTORAGE_PASSTHROUGH_PROC(set_locked, COMSIG_TRY_STORAGE_SET_LOCKSTATE)
LAZYSTORAGE_PASSTHROUGH_PROC(signal_take_obj, COMSIG_TRY_STORAGE_TAKE)
LAZYSTORAGE_PASSTHROUGH_PROC(signal_quick_empty, COMSIG_TRY_STORAGE_QUICK_EMPTY)
LAZYSTORAGE_PASSTHROUGH_PROC(signal_return_inv, COMSIG_TRY_STORAGE_RETURN_INVENTORY)
LAZYSTORAGE_PASSTHROUGH_PROC(on_alt_click, COMSIG_CLICK_ALT)
LAZYSTORAGE_PASSTHROUGH_PROC(mousedrop_onto, COMSIG_MOUSEDROP_ONTO)
LAZYSTORAGE_PASSTHROUGH_PROC(mousedrop_receive, COMSIG_MOUSEDROPPED_ONTO)
LAZYSTORAGE_PASSTHROUGH_PROC(attack_self, COMSIG_ITEM_ATTACK_SELF)
