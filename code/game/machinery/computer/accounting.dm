/obj/machinery/computer/accounting
	name = "account lookup console"
	desc = "Used to view crew member accounts and purchases."
	icon_screen = "accounts"
	icon_keyboard = "id_key"
	circuit = /obj/item/circuitboard/computer/accounting
	light_color = LIGHT_COLOR_GREEN

/obj/machinery/computer/accounting/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "AccountingConsole", name)
		ui.open()

/obj/machinery/computer/accounting/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	var/list/player_accounts = list()
	var/list/audit_list = SSeconomy.audit_log

	for(var/current_account as anything in SSeconomy.bank_accounts_by_id)
		var/datum/bank_account/current_bank_account = SSeconomy.bank_accounts_by_id[current_account]
		var/job_title = current_bank_account.account_job?.title
		player_accounts += list(list(
			"name" = current_bank_account.account_holder,
			"job" = job_title ? job_title : "No Job",
			"balance" = round(current_bank_account.account_balance),
			"modifier" = round((current_bank_account.payday_modifier * 0.9), 0.1),
		))
	data["PlayerAccounts"] = player_accounts
	data["AuditLog"] = audit_list
	data["Crashing"] = HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING)
	return data

