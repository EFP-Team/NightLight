/datum/bounty/item/medical/heart
	name = "Heart"
	description = "Commander Johnson is in critical condition after suffering yet another heart attack. Doctors say he needs a new heart fast. Ship one, pronto! We'll take a better cybernetic one, if need be."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(
		/obj/item/organ/internal/heart = TRUE,
		/obj/item/organ/internal/heart/cybernetic = FALSE,
		/obj/item/organ/internal/heart/cybernetic/tier2 = TRUE,
		/obj/item/organ/internal/heart/cybernetic/tier3 = TRUE,
	)

/datum/bounty/item/medical/lung
	name = "Lungs"
	description = "A recent explosion at Central Command has left multiple staff with punctured lungs. Ship spare lungs to be rewarded. We'll take a better cybernetic one, if need be."
	reward = CARGO_CRATE_VALUE * 10
	required_count = 3
	wanted_types = list(
		/obj/item/organ/internal/lungs = TRUE,
		/obj/item/organ/internal/lungs/cybernetic = FALSE,
		/obj/item/organ/internal/lungs/cybernetic/tier2 = TRUE,
		/obj/item/organ/internal/lungs/cybernetic/tier3 = TRUE,
	)

/datum/bounty/item/medical/appendix
	name = "Appendix"
	description = "Chef Gibb of Central Command wants to prepare a meal using a very special delicacy: an appendix. If you ship one, he'll pay. We'll take a better cybernetic one, if need be."
	reward = CARGO_CRATE_VALUE * 5 //there are no synthetic appendixes
	wanted_types = list(/obj/item/organ/internal/appendix = TRUE)

/datum/bounty/item/medical/ears
	name = "Ears"
	description = "Multiple staff at Station 12 have been left deaf due to unauthorized clowning. Ship them new ears. We'll take better cybernetic ones, if need be."
	reward = CARGO_CRATE_VALUE * 10
	required_count = 3
	wanted_types = list(
		/obj/item/organ/internal/ears = TRUE,
		/obj/item/organ/internal/ears/cybernetic = FALSE,
		/obj/item/organ/internal/ears/cybernetic/upgraded = TRUE,
	)

/datum/bounty/item/medical/liver
	name = "Livers"
	description = "Multiple high-ranking CentCom diplomats have been hospitalized with liver failure after a recent meeting with Third Soviet Union ambassadors. Help us out, will you? We'll take better cybernetic ones, if need be."
	reward = CARGO_CRATE_VALUE * 10
	required_count = 3
	wanted_types = list(
		/obj/item/organ/internal/liver = TRUE,
		/obj/item/organ/internal/liver/cybernetic = FALSE,
		/obj/item/organ/internal/liver/cybernetic/tier2 = TRUE,
		/obj/item/organ/internal/liver/cybernetic/tier3 = TRUE,
	)

/datum/bounty/item/medical/eye
	name = "Organic Eyes"
	description = "Station 5's Research Director Willem is requesting a few pairs of non-robotic eyes. Don't ask questions, just ship them."
	reward = CARGO_CRATE_VALUE * 10
	required_count = 3
	wanted_types = list(
		/obj/item/organ/internal/eyes = TRUE,
		/obj/item/organ/internal/eyes/robotic = FALSE,
	)

/datum/bounty/item/medical/tongue
	name = "Tongues"
	description = "A recent attack by Mime extremists has left staff at Station 23 speechless. Ship some spare tongues."
	reward = CARGO_CRATE_VALUE * 10
	required_count = 3
	wanted_types = list(/obj/item/organ/internal/tongue = TRUE)

/datum/bounty/item/medical/lizard_tail
	name = "Lizard Tail"
	description = "The Wizard Federation has made off with Nanotrasen's supply of lizard tails. While CentCom is dealing with the wizards, can the station spare a tail of their own?"
	reward = CARGO_CRATE_VALUE * 6
	wanted_types = list(/obj/item/organ/external/tail/lizard = TRUE)

/datum/bounty/item/medical/cat_tail
	name = "Cat Tail"
	description = "Central Command has run out of heavy duty pipe cleaners. Can you ship over a cat tail to help us out?"
	reward = CARGO_CRATE_VALUE * 6
	wanted_types = list(/obj/item/organ/external/tail/cat = TRUE)

/datum/bounty/item/medical/chainsaw
	name = "Chainsaw"
	description = "A CMO at CentCom is having trouble operating on golems. She requests one chainsaw, please."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/item/chainsaw = TRUE)

/datum/bounty/item/medical/tail_whip //Like the cat tail bounties, with more processing.
	name = "Nine Tails whip"
	description = "Commander Jackson is looking for a fine addition to her exotic weapons collection. She will reward you handsomely for either a Cat or Liz o' Nine Tails."
	reward = CARGO_CRATE_VALUE * 8
	wanted_types = list(/obj/item/melee/chainofcommand/tailwhip = TRUE)

/datum/bounty/item/medical/surgerycomp
	name = "Surgery Computer"
	description = "After another freak bombing incident at our annual cheesefest at centcom, we have a massive stack of injured crew on our end. Please send us a fresh surgery computer, if at all possible."
	reward = CARGO_CRATE_VALUE * 12
	wanted_types = list(/obj/machinery/computer/operating = TRUE)

/datum/bounty/item/medical/surgerytable
	name = "Operating Table"
	description = "After a recent influx of infected crew members recently, we've seen that masks just aren't cutting it alone. Silver Operating tables might just do the trick though, send us one to use."
	reward = CARGO_CRATE_VALUE * 6
	wanted_types = list(/obj/structure/table/optable = TRUE)
