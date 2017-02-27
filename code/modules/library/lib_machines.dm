/* Library Machines
 *
 * Contains:
 *		Borrowbook datum
 *		Library Public Computer
 *		Cachedbook datum
 *		Library Computer
 *		Library Scanner
 *		Book Binder
 */



/*
 * Library Public Computer
 */
/obj/machinery/computer/libraryconsole
	name = "library visitor console"
	icon_state = "oldcomp"
	icon_screen = "library"
	icon_keyboard = null
	circuit = /obj/item/weapon/circuitboard/computer/libraryconsole
	var/screenstate = 0
	var/title
	var/category = "Any"
	var/author
	var/SQLquery
	clockwork = TRUE //it'd look weird

/obj/machinery/computer/libraryconsole/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/libraryconsole/interact(mob/user)
	user.set_machine(src)
	var/dat = "" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	switch(screenstate)
		if(0)
			dat += "<h2>Search Settings</h2><br>"
			dat += "<A href='?src=\ref[src];settitle=1'>Filter by Title: [title]</A><BR>"
			dat += "<A href='?src=\ref[src];setcategory=1'>Filter by Category: [category]</A><BR>"
			dat += "<A href='?src=\ref[src];setauthor=1'>Filter by Author: [author]</A><BR>"
			dat += "<A href='?src=\ref[src];search=1'>\[Start Search\]</A><BR>"
		if(1)
			if (!dbcon.Connect())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font><BR>"
			else if(!SQLquery)
				dat += "<font color=red><b>ERROR</b>: Malformed search request. Please contact your system administrator for assistance.</font><BR>"
			else
				dat += "<table>"
				dat += "<tr><td>AUTHOR</td><td>TITLE</td><td>CATEGORY</td><td>SS<sup>13</sup>BN</td></tr>"

				var/DBQuery/query = dbcon.NewQuery(SQLquery)
				query.Execute()

				while(query.NextRow())
					var/author = query.item[1]
					var/title = query.item[2]
					var/category = query.item[3]
					var/id = query.item[4]
					dat += "<tr><td>[author]</td><td>[title]</td><td>[category]</td><td>[id]</td></tr>"
				dat += "</table><BR>"
			dat += "<A href='?src=\ref[src];back=1'>\[Go Back\]</A><BR>"
	var/datum/browser/popup = new(user, "publiclibrary", name, 600, 400)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/libraryconsole/Topic(href, href_list)
	. = ..()
	if(..())
		usr << browse(null, "window=publiclibrary")
		onclose(usr, "publiclibrary")
		return

	if(href_list["settitle"])
		var/newtitle = input("Enter a title to search for:") as text|null
		if(newtitle)
			title = sanitize(newtitle)
		else
			title = null
		title = sanitizeSQL(title)
	if(href_list["setcategory"])
		var/newcategory = input("Choose a category to search for:") in list("Any", "Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
		if(newcategory)
			category = sanitize(newcategory)
		else
			category = "Any"
		category = sanitizeSQL(category)
	if(href_list["setauthor"])
		var/newauthor = input("Enter an author to search for:") as text|null
		if(newauthor)
			author = sanitize(newauthor)
		else
			author = null
		author = sanitizeSQL(author)
	if(href_list["search"])
		SQLquery = "SELECT author, title, category, id FROM [format_table_name("library")] WHERE isnull(deleted) AND "
		if(category == "Any")
			SQLquery += "author LIKE '%[author]%' AND title LIKE '%[title]%'"
		else
			SQLquery += "author LIKE '%[author]%' AND title LIKE '%[title]%' AND category='[category]'"
		screenstate = 1

	if(href_list["back"])
		screenstate = 0

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/*
 * Borrowbook datum
 */
/datum/borrowbook // Datum used to keep track of who has borrowed what when and for how long.
	var/bookname
	var/mobname
	var/getdate
	var/duedate

/*
 * Cachedbook datum
 */
/datum/cachedbook // Datum used to cache the SQL DB books locally in order to achieve a performance gain.
	var/id
	var/title
	var/author
	var/category

var/global/list/datum/cachedbook/cachedbooks // List of our cached book datums


/proc/load_library_db_to_cache()
	if(cachedbooks)
		return
	if(!dbcon.Connect())
		return
	cachedbooks = list()
	var/DBQuery/query = dbcon.NewQuery("SELECT id, author, title, category FROM [format_table_name("library")] WHERE isnull(deleted)")
	query.Execute()

	while(query.NextRow())
		var/datum/cachedbook/newbook = new()
		newbook.id = query.item[1]
		newbook.author = query.item[2]
		newbook.title = query.item[3]
		newbook.category = query.item[4]
		cachedbooks += newbook



#define PRINTER_COOLDOWN 60

/*
 * Library Computer
 * After 860 days, it's finally a buildable computer.
 */
// TODO: Make this an actual /obj/machinery/computer that can be crafted from circuit boards and such
// It is August 22nd, 2012... This TODO has already been here for months.. I wonder how long it'll last before someone does something about it.
// It's December 25th, 2014, and this is STILL here, and it's STILL relevant. Kill me
/obj/machinery/computer/libraryconsole/bookmanagement
	name = "book inventory management console"
	var/arcanecheckout = 0
	screenstate = 0 // 0 - Main Menu, 1 - Inventory, 2 - Checked Out, 3 - Check Out a Book
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	var/buffer_book
	var/buffer_mob
	var/upload_category = "Fiction"
	var/list/checkouts = list()
	var/list/inventory = list()
	var/checkoutperiod = 5 // In minutes
	var/obj/machinery/libraryscanner/scanner // Book scanner that will be used when uploading books to the Archive
	var/list/libcomp_menu
	var/page = 1	//current page of the external archives
	var/cooldown = 0

/obj/machinery/computer/libraryconsole/bookmanagement/proc/build_library_menu()
	if(libcomp_menu)
		return
	load_library_db_to_cache()
	if(!cachedbooks)
		return
	libcomp_menu = list("")

	for(var/i in 1 to cachedbooks.len)
		var/datum/cachedbook/C = cachedbooks[i]
		var/page = round(i/250)+1
		if (libcomp_menu.len < page)
			libcomp_menu.len = page
			libcomp_menu[page] = ""
		libcomp_menu[page] += "<tr><td>[C.author]</td><td>[C.title]</td><td>[C.category]</td><td><A href='?src=\ref[src];targetid=[C.id]'>\[Order\]</A></td></tr>\n"

/obj/machinery/computer/libraryconsole/bookmanagement/New()
	..()
	if(circuit)
		circuit.name = "Book Inventory Management Console (Machine Board)"
		circuit.build_path = /obj/machinery/computer/libraryconsole/bookmanagement

/obj/machinery/computer/libraryconsole/bookmanagement/interact(mob/user)
	user.set_machine(src)
	var/dat = "" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	switch(screenstate)
		if(0)
			// Main Menu
			dat += "<A href='?src=\ref[src];switchscreen=1'>1. View General Inventory</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=2'>2. View Checked Out Inventory</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=3'>3. Check out a Book</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=4'>4. Connect to External Archive</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=5'>5. Upload New Title to Archive</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=6'>6. Upload Scanned Title to Newscaster</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=7'>7. Print Corporate Materials</A><BR>"
			if(src.emagged)
				dat += "<A href='?src=\ref[src];switchscreen=8'>8. Access the Forbidden Lore Vault</A><BR>"
			if(src.arcanecheckout)
				print_forbidden_lore(user)
				src.arcanecheckout = 0
		if(1)
			// Inventory
			dat += "<H3>Inventory</H3><BR>"
			for(var/obj/item/weapon/book/b in inventory)
				dat += "[b.name] <A href='?src=\ref[src];delbook=\ref[b]'>(Delete)</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(2)
			// Checked Out
			dat += "<h3>Checked Out Books</h3><BR>"
			for(var/datum/borrowbook/b in checkouts)
				var/timetaken = world.time - b.getdate
				//timetaken *= 10
				timetaken /= 600
				timetaken = round(timetaken)
				var/timedue = b.duedate - world.time
				//timedue *= 10
				timedue /= 600
				if(timedue <= 0)
					timedue = "<font color=red><b>(OVERDUE)</b> [timedue]</font>"
				else
					timedue = round(timedue)
				dat += "\"[b.bookname]\", Checked out to: [b.mobname]<BR>--- Taken: [timetaken] minutes ago, Due: in [timedue] minutes<BR>"
				dat += "<A href='?src=\ref[src];checkin=\ref[b]'>(Check In)</A><BR><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(3)
			// Check Out a Book
			dat += "<h3>Check Out a Book</h3><BR>"
			dat += "Book: [src.buffer_book] "
			dat += "<A href='?src=\ref[src];editbook=1'>\[Edit\]</A><BR>"
			dat += "Recipient: [src.buffer_mob] "
			dat += "<A href='?src=\ref[src];editmob=1'>\[Edit\]</A><BR>"
			dat += "Checkout Date : [world.time/600]<BR>"
			dat += "Due Date: [(world.time + checkoutperiod)/600]<BR>"
			dat += "(Checkout Period: [checkoutperiod] minutes) (<A href='?src=\ref[src];increasetime=1'>+</A>/<A href='?src=\ref[src];decreasetime=1'>-</A>)"
			dat += "<A href='?src=\ref[src];checkout=1'>(Commit Entry)</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(4)
			dat += "<h3>External Archive</h3>"
			build_library_menu()

			if(!cachedbooks)
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font>"
			else
				dat += "<A href='?src=\ref[src];orderbyid=1'>(Order book by SS<sup>13</sup>BN)</A><BR><BR>"
				dat += "<table>"
				dat += "<tr><td>AUTHOR</td><td>TITLE</td><td>CATEGORY</td><td></td></tr>"
				dat += libcomp_menu[Clamp(page,1,libcomp_menu.len)]
				dat += "<tr><td><A href='?src=\ref[src];page=[(max(1,page-1))]'>&lt;&lt;&lt;&lt;</A></td> <td></td> <td></td> <td><span style='text-align:right'><A href='?src=\ref[src];page=[(min(libcomp_menu.len,page+1))]'>&gt;&gt;&gt;&gt;</A></span></td></tr>"
				dat += "</table>"
			dat += "<BR><A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(5)
			dat += "<H3>Upload a New Title</H3>"
			if(!scanner)
				for(var/obj/machinery/libraryscanner/S in range(9))
					scanner = S
					break
			if(!scanner)
				dat += "<FONT color=red>No scanner found within wireless network range.</FONT><BR>"
			else if(!scanner.cache)
				dat += "<FONT color=red>No data found in scanner memory.</FONT><BR>"
			else
				dat += "<TT>Data marked for upload...</TT><BR>"
				dat += "<TT>Title: </TT>[scanner.cache.name]<BR>"
				if(!scanner.cache.author)
					scanner.cache.author = "Anonymous"
				dat += "<TT>Author: </TT><A href='?src=\ref[src];setauthor=1'>[scanner.cache.author]</A><BR>"
				dat += "<TT>Category: </TT><A href='?src=\ref[src];setcategory=1'>[upload_category]</A><BR>"
				dat += "<A href='?src=\ref[src];upload=1'>\[Upload\]</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(6)
			dat += "<h3>Post Title to Newscaster</h3>"
			if(!scanner)
				for(var/obj/machinery/libraryscanner/S in range(9))
					scanner = S
					break
			if(!scanner)
				dat += "<FONT color=red>No scanner found within wireless network range.</FONT><BR>"
			else if(!scanner.cache)
				dat += "<FONT color=red>No data found in scanner memory.</FONT><BR>"
			else
				dat += "<TT>Post [scanner.cache.name] to station newscasters?</TT>"
				dat += "<A href='?src=\ref[src];newspost=1'>\[Post\]</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(7)
			dat += "<h3>NTGanda(tm) Universal Printing Module</h3>"
			dat += "What would you like to print?<BR>"
			dat += "<A href='?src=\ref[src];printbible=1'>\[Bible\]</A><BR>"
			dat += "<A href='?src=\ref[src];printposter=1'>\[Poster\]</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(8)
			dat += "<h3>Accessing Forbidden Lore Vault v 1.3</h3>"
			dat += "Are you absolutely sure you want to proceed? EldritchTomes Inc. takes no responsibilities for loss of sanity resulting from this action.<p>"
			dat += "<A href='?src=\ref[src];arccheckout=1'>Yes.</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=0'>No.</A><BR>"

	var/datum/browser/popup = new(user, "library", name, 600, 400)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/libraryconsole/bookmanagement/proc/print_forbidden_lore(mob/user)
	var/spook = pick("blood", "brass")
	var/turf/T = get_turf(src)
	if(spook == "blood")
		new /obj/item/weapon/tome(T)
	else
		new /obj/item/clockwork/slab(T)

	user << "<span class='warning'>Your sanity barely endures the seconds spent in the vault's browsing window. The only thing to remind you of this when you stop browsing is a [spook == "blood" ? "dusty old tome" : "strange metal tablet"] sitting on the desk. You don't really remember printing it.[spook == "brass" ? " And how did it print something made of metal?" : ""]</span>"
	user.visible_message("[user] stares at the blank screen for a few moments, [user.p_their()] expression frozen in fear. When [user.p_they()] finally awaken[user.p_s()] from it, [user.p_they()] look[user.p_s()] a lot older.", 2)

/obj/machinery/computer/libraryconsole/bookmanagement/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/barcodescanner))
		var/obj/item/weapon/barcodescanner/scanner = W
		scanner.computer = src
		user << "[scanner]'s associated machine has been set to [src]."
		audible_message("[src] lets out a low, short blip.")
	else
		return ..()

/obj/machinery/computer/libraryconsole/bookmanagement/emag_act(mob/user)
	if(density && !emagged)
		emagged = 1

/obj/machinery/computer/libraryconsole/bookmanagement/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=library")
		onclose(usr, "library")
		return
	if(href_list["page"] && screenstate == 4)
		page = text2num(href_list["page"])
	if(href_list["switchscreen"])
		switch(href_list["switchscreen"])
			if("0")
				screenstate = 0
			if("1")
				screenstate = 1
			if("2")
				screenstate = 2
			if("3")
				screenstate = 3
			if("4")
				screenstate = 4
			if("5")
				screenstate = 5
			if("6")
				screenstate = 6
			if("7")
				screenstate = 7
			if("8")
				screenstate = 8
	if(href_list["arccheckout"])
		if(src.emagged)
			src.arcanecheckout = 1
		src.screenstate = 0
	if(href_list["increasetime"])
		checkoutperiod += 1
	if(href_list["decreasetime"])
		checkoutperiod -= 1
		if(checkoutperiod < 1)
			checkoutperiod = 1
	if(href_list["editbook"])
		buffer_book = copytext(sanitize(input("Enter the book's title:") as text|null),1,MAX_MESSAGE_LEN)
	if(href_list["editmob"])
		buffer_mob = copytext(sanitize(input("Enter the recipient's name:") as text|null),1,MAX_NAME_LEN)
	if(href_list["checkout"])
		var/datum/borrowbook/b = new /datum/borrowbook
		b.bookname = sanitize(buffer_book)
		b.mobname = sanitize(buffer_mob)
		b.getdate = world.time
		b.duedate = world.time + (checkoutperiod * 600)
		checkouts.Add(b)
	if(href_list["checkin"])
		var/datum/borrowbook/b = locate(href_list["checkin"]) in checkouts
		if(b && istype(b))
			checkouts.Remove(b)
	if(href_list["delbook"])
		var/obj/item/weapon/book/b = locate(href_list["delbook"]) in inventory
		if(b && istype(b))
			inventory.Remove(b)
	if(href_list["setauthor"])
		var/newauthor = copytext(sanitize(input("Enter the author's name: ") as text|null),1,MAX_MESSAGE_LEN)
		if(newauthor)
			scanner.cache.author = newauthor
	if(href_list["setcategory"])
		var/newcategory = input("Choose a category: ") in list("Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
		if(newcategory)
			upload_category = newcategory
	if(href_list["upload"])
		if(scanner)
			if(scanner.cache)
				var/choice = input("Are you certain you wish to upload this title to the Archive?") in list("Confirm", "Abort")
				if(choice == "Confirm")
					if (!dbcon.Connect())
						alert("Connection to Archive has been severed. Aborting.")
					else

						var/sqltitle = sanitizeSQL(scanner.cache.name)
						var/sqlauthor = sanitizeSQL(scanner.cache.author)
						var/sqlcontent = sanitizeSQL(scanner.cache.dat)
						var/sqlcategory = sanitizeSQL(upload_category)
						var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("library")] (author, title, content, category, ckey, datetime) VALUES ('[sqlauthor]', '[sqltitle]', '[sqlcontent]', '[sqlcategory]', '[usr.ckey]', Now())")
						if(!query.Execute())
							usr << query.ErrorMsg()
						else
							log_game("[usr.name]/[usr.key] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] signs")
							alert("Upload Complete. Uploaded title will be unavailable for printing for a short period")
	if(href_list["newspost"])
		if(!news_network)
			alert("No news network found on station. Aborting.")
		var/channelexists = 0
		for(var/datum/newscaster/feed_channel/FC in news_network.network_channels)
			if(FC.channel_name == "Nanotrasen Book Club")
				channelexists = 1
				break
		if(!channelexists)
			news_network.CreateFeedChannel("Nanotrasen Book Club", "Library", null)
		news_network.SubmitArticle(scanner.cache.dat, "[scanner.cache.name]", "Nanotrasen Book Club", null)
		alert("Upload complete. Your uploaded title is now available on station newscasters.")
	if(href_list["orderbyid"])
		if(cooldown > world.time)
			say("Printer unavailable. Please allow a short time before attempting to print.")
		else
			var/orderid = input("Enter your order:") as num|null
			if(orderid)
				if(isnum(orderid) && IsInteger(orderid))
					href_list["targetid"] = num2text(orderid)

	if(href_list["targetid"])
		var/sqlid = sanitizeSQL(href_list["targetid"])
		if (!dbcon.Connect())
			alert("Connection to Archive has been severed. Aborting.")
		if(cooldown > world.time)
			say("Printer unavailable. Please allow a short time before attempting to print.")
		else
			cooldown = world.time + PRINTER_COOLDOWN
			var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("library")] WHERE id=[sqlid] AND isnull(deleted)")
			query.Execute()

			while(query.NextRow())
				var/author = query.item[2]
				var/title = query.item[3]
				var/content = query.item[4]
				var/obj/item/weapon/book/B = new(get_turf(src))
				B.name = "Book: [title]"
				B.title = title
				B.author = author
				B.dat = content
				B.icon_state = "book[rand(1,8)]"
				visible_message("[src]'s printer hums as it produces a completely bound book. How did it do that?")
				break
	if(href_list["printbible"])
		if(cooldown < world.time)
			var/obj/item/weapon/storage/book/bible/B = new /obj/item/weapon/storage/book/bible(src.loc)
			if(SSreligion.Bible_icon_state && SSreligion.Bible_item_state)
				B.icon_state = SSreligion.Bible_icon_state
				B.item_state = SSreligion.Bible_item_state
				B.name = SSreligion.Bible_name
				B.deity_name = SSreligion.Bible_deity_name
			cooldown = world.time + PRINTER_COOLDOWN
		else
			say("Printer currently unavailable, please wait a moment.")
	if(href_list["printposter"])
		if(cooldown < world.time)
			new /obj/item/weapon/poster/legit(src.loc)
			cooldown = world.time + PRINTER_COOLDOWN
		else
			say("Printer currently unavailable, please wait a moment.")
	add_fingerprint(usr)
	updateUsrDialog()

/*
 * Library Scanner
 */
/obj/machinery/libraryscanner
	name = "scanner control interface"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	var/obj/item/weapon/book/cache		// Last scanned book

/obj/machinery/libraryscanner/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/weapon/book))
		if(!user.drop_item())
			return
		O.loc = src
	else
		return ..()

/obj/machinery/libraryscanner/attack_hand(mob/user)
	usr.set_machine(src)
	var/dat = "" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	if(cache)
		dat += "<FONT color=#005500>Data stored in memory.</FONT><BR>"
	else
		dat += "No data stored in memory.<BR>"
	dat += "<A href='?src=\ref[src];scan=1'>\[Scan\]</A>"
	if(cache)
		dat += "       <A href='?src=\ref[src];clear=1'>\[Clear Memory\]</A><BR><BR><A href='?src=\ref[src];eject=1'>\[Remove Book\]</A>"
	else
		dat += "<BR>"
	var/datum/browser/popup = new(user, "scanner", name, 600, 400)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/libraryscanner/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=scanner")
		onclose(usr, "scanner")
		return

	if(href_list["scan"])
		for(var/obj/item/weapon/book/B in contents)
			cache = B
			break
	if(href_list["clear"])
		cache = null
	if(href_list["eject"])
		for(var/obj/item/weapon/book/B in contents)
			B.loc = src.loc
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "book binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	anchored = 1
	density = 1
	var/busy = 0

/obj/machinery/bookbinder/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/weapon/paper))
		bind_book(user, O)
	else if(default_unfasten_wrench(user, O))
		return 1
	else
		return ..()

/obj/machinery/bookbinder/proc/bind_book(mob/user, obj/item/weapon/paper/P)
	if(stat)
		return
	if(busy)
		user << "<span class='warning'>The book binder is busy. Please wait for completion of previous operation.</span>"
		return
	if(!user.drop_item())
		return
	P.loc = src
	user.visible_message("[user] loads some paper into [src].", "You load some paper into [src].")
	audible_message("[src] begins to hum as it warms up its printing drums.")
	busy = 1
	sleep(rand(200,400))
	busy = 0
	if(P)
		if(!stat)
			visible_message("[src] whirs as it prints and binds a new book.")
			var/obj/item/weapon/book/B = new(src.loc)
			B.dat = P.info
			B.name = "Print Job #" + "[rand(100, 999)]"
			B.icon_state = "book[rand(1,7)]"
			qdel(P)
		else
			P.loc = loc
