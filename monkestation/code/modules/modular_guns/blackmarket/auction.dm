#define AUCTION_TIME 5 MINUTES

/datum/market/blackmarket/auction
	name = "Black Market Auction"
	market_flags = MARKET_AUCTION
	categories = list("Auction")
	///list of all items and when they start in world time
	var/list/queued_items = list()
	///how many items we have in a queue at once
	var/queue_length = 3
	///our current auction
	var/datum/market_item/auction/current_auction
	///how much time is left of our auction checked with COOLDOWN_TIME_LEFT
	COOLDOWN_DECLARE(current_auction_time)

/datum/market/blackmarket/auction/add_item(datum/market_item/item)
	if(!prob(initial(item.availability_prob)))
		return FALSE

	if(ispath(item))
		item = new item()

	if(!length(available_items))
		available_items = list()
		categories |= "Auction"

	available_items += item
	return TRUE

/datum/market/blackmarket/auction/try_process()
	if(!length(queued_items))
		var/datum/market_item/auction/first_item = pick(available_items)
		var/datum/market_item/auction/created_item = new first_item.type
		queued_items += created_item
		queued_items[created_item] = world.time + rand(3 MINUTES, 5.5 MINUTES) + AUCTION_TIME

	if(length(queued_items) < queue_length) // we are missing a new auction
		var/datum/market_item/auction/listed_item = pick(available_items)
		var/datum/market_item/auction/new_item = new listed_item.type
		var/initial_time = queued_items[queued_items[length(queued_items)]]
		queued_items += new_item
		queued_items[new_item] = initial_time + rand(3 MINUTES, 5.5 MINUTES) + AUCTION_TIME

	if(COOLDOWN_FINISHED(src, current_auction_time) && current_auction)
		grab_purchase_info(current_auction, current_auction.category, SHIPPING_METHOD_TELEPORT)
		current_auction = null

	if(world.time >= queued_items[queued_items[1]])
		current_auction = queued_items[1]
		queued_items[queued_items[1]] = 0
		queued_items -= current_auction
		COOLDOWN_START(src, current_auction_time, AUCTION_TIME)


/datum/market/blackmarket/auction/pre_purchase(item, category, method, obj/item/market_uplink/uplink, user, bid_amount)
	if(item != current_auction.type)
		return FALSE

	if(current_auction.user == user)
		to_chat(user, span_warning("You are currently the top bidder on [current_auction] already!"))
		return FALSE

	var/price = current_auction.price

	if(price >= bid_amount)
		to_chat(user, span_warning("You need to bid more than the current bid amount!"))
		return FALSE

	if(!uplink.current_user)///There is no ID card on the user, or the ID card has no account
		to_chat(user, span_warning("The uplink sparks, as it can't identify an ID card with a bank account on you."))
		return FALSE
	var/balance = uplink?.current_user.account_balance

	// I can't get the price of the item and shipping in a clean way to the UI, so I have to do this.
	if(balance < bid_amount)
		to_chat(user, span_warning("You don't have enough credits in [uplink] to bid on [current_auction]."))
		return FALSE

	if(current_auction.user)
		current_auction.bidders += list(list(
			"name" = "Test Name",
			"amount" = current_auction.current_price,
		))

	current_auction.uplink = uplink
	current_auction.user = user
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		current_auction.top_bidder = "Anonymous [human.dna.species.name]"
	else
		current_auction.top_bidder = "Anonymous Creature"
	current_auction.current_price = bid_amount
	current_auction.price = bid_amount


/datum/market/blackmarket/auction/proc/grab_purchase_info(datum/market_item/auction/item, category, method)
	purchase(item.type, category, method, item.uplink, item.user)


/datum/market/blackmarket/auction/guns
	name = "Back Alley Guns"

/datum/market_item/auction
	markets = list(/datum/market/blackmarket/auction)
	///the user whos currently bid on it
	var/mob/user
	///the current price we have
	var/current_price = 0
	///the highest bidding uplink
	var/obj/item/market_uplink/uplink
	///list of mob names with prices used to show previous prices
	var/list/bidders = list()
	///the name of our top bidder as a string
	var/top_bidder
