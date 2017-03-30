/proc/priority_announce(text, title = "", sound = 'sound/AI/attention.ogg', type)
	if(!text)
		return

	text = russian_html2text(sanitize_russian(text))

	var/announcement

	if(type == "Priority")
		announcement += "<h1 class='alert'>Priority Announcement</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[rhtml_encode(title)]</h2>"
	else if(type == "Captain")
		announcement += "<h1 class='alert'>Captain Announces</h1>"
		news_network.SubmitArticle(russian_text2html(text), "Captain's Announcement", "Station Announcements", null)

	else
		announcement += "<h1 class='alert'>[command_name()] Update</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[rhtml_encode(title)]</h2>"
		if(title == "")
			news_network.SubmitArticle(russian_text2html(text), "Central Command Update", "Station Announcements", null)
		else
			news_network.SubmitArticle(russian_text2html(title) + "<br><br>" + russian_text2html(text), "Central Command", "Station Announcements", null)

	announcement += "<br><span class='alert'>[rhtml_encode(text)]</span><br>"
	announcement += "<br>"

	for(var/mob/M in player_list)
		if(!isnewplayer(M) && !M.ear_deaf)
			to_chat(M, announcement)
			if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
				M << sound(sound)

/proc/print_command_report(text = "", title = null, announce=TRUE)
	if(!title)
		title = "Classified [command_name()] Update"

	if(announce)
		priority_announce("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message", 'sound/AI/commandreport.ogg')

	for(var/obj/machinery/computer/communications/C in machines)
		if(!(C.stat & (BROKEN|NOPOWER)) && C.z == ZLEVEL_STATION)
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(C.loc)
			P.name = "paper - '[title]'"
			P.info = russian_text2html(sanitize_russian(text,1))
			C.messagetitle.Add("[title]")
			C.messagetext.Add(russian_text2html(sanitize_russian(text,1)))
			P.update_icon()

/proc/minor_announce(message, title = "Attention:", alert)
	if(!message)
		return

	for(var/mob/M in player_list)
		if(!isnewplayer(M) && !M.ear_deaf)
			to_chat(M, "<b><font size = 3><font color = red>[title]</font color><BR>[russian_html2text(message)]</font size></b><BR>")
			if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
				if(alert)
					M << sound('sound/misc/notice1.ogg')
				else
					M << sound('sound/misc/notice2.ogg')
