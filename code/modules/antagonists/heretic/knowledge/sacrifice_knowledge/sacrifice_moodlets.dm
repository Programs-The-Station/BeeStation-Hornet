// Some moodlets involved in the sacrifice process.
/datum/mood_event/shadow_realm
	description = span_hypnophrase("Where am I?!")
	mood_change = -15
	timeout = 3 MINUTES

/datum/mood_event/shadow_realm_live
	description = span_greentext("I'm alive... I'm alive!!")
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/shadow_realm_live_sad
	description = span_boldwarning("The hands! The horrible, horrific hands! I see them when I close my eyes!")
	mood_change = -6
	timeout = 10 MINUTES
