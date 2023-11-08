(define (domain trip-domain)
(:requirements :typing :equality :adl :fluents)
(:types city hotel)

(:predicates
	(inCity ?h - hotel ?c - city)
	(flight ?s - city ?d - city)
	(visited ?c - city)
	(selectedFlight ?s - city ?d - city)
	(sleepIn ?h - hotel)
	(last-city ?c - city)
	(incomplete)
)

(:functions
	(visited-cities) - number
	(total-days) - number
	(total-price) - number
	(total-interest) - number
	(stay ?c -city) - number
	(minDaysCity ?c - city) - number
	(maxDaysCity ?c - city) - number
	(cityInterest ?c - city) - number
	(flightPrice ?s - city ?d - city) - number
	(hotelPrice ?h - hotel) - number
	(minPriceTrip) - number
	(maxPriceTrip) - number
)

; ********** ACTIONS **********  

(:action select-first-city
	:parameters (?c - city ?h - hotel)
	
	:precondition (and 
		(= (visited-cities) 0) 
		(inCity ?h ?c))
		
	:effect (and
		(visited ?c)
		(increase (visited-cities) 1)
		(increase (total-days) 1)
		(increase (stay ?c) 1)
		(increase (total-interest) (cityInterest ?c))
		(increase (total-price) (hotelPrice ?h))
		(sleepIn ?h)
		(last-city ?c)
		(when (< (stay ?c) (minDaysCity ?c))
			(incomplete)))
)

(:action stay-one-more-day
	:parameters (?lc - city ?h - hotel)
	
	:precondition (and
		(last-city ?lc)
		(inCity ?h ?lc)
		(< (stay ?lc) (maxDaysCity ?lc)))
	
	:effect (and
		(increase (total-days) 1)
		(increase (stay ?lc) 1)
		(increase (total-price) (hotelPrice ?h))
		(when (= (stay ?lc) (minDaysCity ?lc))
			(not (incomplete))))
)

(:action select-next-city
	:parameters (?lc - city ?c - city ?h - hotel)
	
	:precondition (and 
		(> (visited-cities) 0)
		
		(last-city ?lc)
		(> (stay ?lc) (minDaysCity ?lc))
		
		(flight ?lc ?c)
		(not (visited ?c))
		(inCity ?h ?c))
		
	:effect (and
		(selectedFlight ?lc ?c)
		(visited ?c)
		(increase (visited-cities) 1)
		(increase (total-days) 1)
		(increase (stay ?c) 1)
		(sleepIn ?h)
		(increase (total-price) (hotelPrice ?h))
		(increase (total-price) (flightPrice ?lc ?c))
		(increase (total-interest) (cityInterest ?c))
		(not (last-city ?lc))
		(last-city ?c)
		(when (< (stay ?c) (minDaysCity ?c))
			(incomplete)))
)

)
