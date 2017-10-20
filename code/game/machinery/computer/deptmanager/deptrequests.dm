/datum/ntrequest
	var/requestid
	var/requesttype //Demotion, Promotion, Raise pay, Cut pay, bonus and Record.
	var/requesttext
	var/mob/living/carbon/human/fromchar
	var/mob/living/carbon/human/tochar
	var/obj/machinery/computer/department_manager/DeptMan

/datum/ntrequest/New()
	for(var/obj/machinery/computer/department_manager/DM in SSmachines.machinery)
		if(DM && DM.department == "NanoTrasen")
			DeptMan = DM //Assign department manager before-hand.
	requestid = rand(0, 1000) //Basically 1000 requests per time.

/datum/ntrequest/proc/make_request(requesttype,fromchar,tochar,requesttext)
	if(!requesttype)	return 0 //No can do.
	for(var/datum/ntrequest/Request in DeptMan.pendingrequests)
		if(Request.requesttype == requesttype && requesttype == "promotion" || requesttype == "demotion" || requesttype == "bonus")
			return 0 //Skip these, one at a time pls.
		if(Request.requestid == requestid) //Also no duplicate IDs, just to be safe.
			requestid = rand(0, 1000) //So we reset and hope.
			continue
	DeptMan.pendingrequests["[requestid]"] += src // "REQUEST|[requesttype], Sent by [fromchar:job] [fromchar:real_name], Sent to [tochar:job] [tochar:real_name] For [requesttext]"

	DeptMan.save_requests()