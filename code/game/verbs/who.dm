
/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "<b>Current Players:</b>\n"

	var/list/Lines = list()

	if(check_rights(R_INVESTIGATE, 0))
		for(var/client/C in GLOB.clients)
			var/entry
			if(check_rights(R_ADMIN, 0, C))
				entry = "\t<span class='admin'>[create_text_tag("admin", "Admin: ", usr.client)] [C.key]</span>"
			else if(check_rights(R_MOD, 0, C))
				entry = "\t<span class='moderator'>[create_text_tag("mod", "Moderator: ", usr.client)] [C.key]</span>"
			else if(C.donator)
				entry = "\t<span class='donator[C.donator]'>[create_text_tag("don", "Donator: ", usr.client)] [C.key]</span>"
			else if(C.ap_veteran)
				entry = "\t<span class='apveteran'>[create_text_tag("veteran", "Veteran: ", usr.client)] [C.key]</span>"
			else
				entry = "\t[create_text_tag("player", "Player: ", usr.client)] [C.key]"
			if(!C.mob) //If mob is null, print error and skip rest of info for client.
				entry += " - <font color='red'><i>HAS NO MOB</i></font>"
				Lines += entry
				continue

			entry += " - Playing as [C.mob.real_name]"
			switch(C.mob.stat)
				if(UNCONSCIOUS)
					entry += " - <font color='darkgray'><b>Unconscious</b></font>"
				if(DEAD)
					if(isghost(C.mob))
						var/mob/observer/ghost/O = C.mob
						if(O.started_as_observer)
							entry += " - <font color='gray'>Observing</font>"
						else
							entry += " - <font color='black'><b>DEAD</b></font>"
					else
						entry += " - <font color='black'><b>DEAD</b></font>"

			var/age
			if(isnum(C.player_age))
				age = C.player_age
			else
				age = 0

			if(age <= 1)
				age = "<font color='#ff0000'><b>[age]</b></font>"
			else if(age < 10)
				age = "<font color='#ff8c00'><b>[age]</b></font>"

			entry += " - [age]"

			if(is_special_character(C.mob))
				entry += " - <b><font color='red'>Antagonist</font></b>"
			if(C.is_afk())
				entry += " (AFK - [C.inactivity2text()])"
			for(var/N in ODB.userwatchlist)
				if(findtext(N, C.key)) //Found this man in the watch list?
					entry += " <b><font color='red'>(WATCH)</font></b>"
			entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"
			Lines += entry
	else
		for(var/client/C in GLOB.clients)
			if(!C.is_stealthed())
				if(check_rights(R_ADMIN, 0, C))
					Lines += "\t<span class='admin'>[create_text_tag("admin", "Admin: ", usr.client)] [C.key]</span>"
				else if(check_rights(R_MOD, 0, C))
					Lines += "\t<span class='moderator'>[create_text_tag("mod", "Moderator: ", usr.client)] [C.key]</span>"
				else if(C.donator)
					Lines += "\t<span class='donator[C.donator]'>[create_text_tag("don", "Donator: ", usr.client)] [C.key]</span>"
				else if(C.ap_veteran)
					Lines += "\t<span clas='apveteran'>[create_text_tag("veteran", "Veteran: ", usr.client)] [C.key]</span>"
				else
					Lines += "\t[create_text_tag("player", "Player: ", usr.client)] [C.key]"

	for(var/line in sortList(Lines))
		msg += "[line]\n"

	msg += "<b>Total Players: [length(Lines)]</b>"
	to_chat(src, msg)

/client/verb/staffwho()
	set category = "Admin"
	set name = "Staffwho"

	var/list/msg = list()
	var/active_staff = 0
	var/total_staff = 0
	var/can_investigate = check_rights(R_INVESTIGATE, 0)

	for(var/client/C in GLOB.admins)
		var/line = list()
		if(!can_investigate && C.is_stealthed())
			continue
		total_staff++
		if(check_rights(R_ADMIN,0,C))
			line += "\t[C] is \an <b>["\improper[C.holder.rank]"]</b>"
		else
			line += "\t[C] is \an ["\improper[C.holder.rank]"]"
		if(!C.is_afk())
			active_staff++
		if(can_investigate)
			if(C.is_afk())
				line += " (AFK - [C.inactivity2text()])"
			if(isghost(C.mob))
				line += " - Observing"
			else if(isnewplayer(C.mob))
				line += " - Lobby"
			else
				line += " - Playing"
			if(C.is_stealthed())
				line += " (Stealthed)"
		line = jointext(line,null)
		if(check_rights(R_ADMIN,0,C))
			msg.Insert(1, line)
		else
			msg += line

	if(config.admin_irc)
		to_chat(src, "<span class='info'>Adminhelps are also sent to IRC. If no admins are available in game try anyway and an admin on IRC may see it and respond.</span>")
	to_chat(src, "<b>Current Staff ([active_staff]/[total_staff]):</b>")
	to_chat(src, jointext(msg,"\n"))
