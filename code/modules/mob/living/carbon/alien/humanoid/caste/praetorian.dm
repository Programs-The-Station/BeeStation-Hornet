/mob/living/carbon/alien/humanoid/royal/praetorian
	name = "alien praetorian"
	caste = "p"
	maxHealth = 250
	health = 250
	icon_state = "alienp"

/mob/living/carbon/alien/humanoid/royal/praetorian/Initialize(mapload)
	real_name = name
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/repulse/xeno(src))
	AddAbility(new /obj/effect/proc_holder/alien/royal/praetorian/evolve())
	. = ..()

/mob/living/carbon/alien/humanoid/royal/praetorian/create_internal_organs()
	internal_organs += new /obj/item/organ/alien/plasmavessel/large
	internal_organs += new /obj/item/organ/alien/resinspinner
	internal_organs += new /obj/item/organ/alien/acid
	internal_organs += new /obj/item/organ/alien/neurotoxin
	return ..()

/obj/effect/proc_holder/alien/royal/praetorian/evolve
	name = "Evolve"
	desc = "Produce an internal egg sac capable of spawning children. Only one queen can exist at a time. Costs 500 Plasma."
	plasma_cost = 500
	action_icon_state = "alien_evolve_praetorian"

/obj/effect/proc_holder/alien/royal/praetorian/evolve/fire(mob/living/carbon/alien/humanoid/user)
	var/obj/item/organ/alien/hivenode/node = user.getorgan(/obj/item/organ/alien/hivenode)
	if(!node) //Just in case this particular Praetorian gets violated and kept by the RD as a replacement for Lamarr.
		to_chat(user, span_danger("Without the hivemind, you would be unfit to rule as queen!"))
		return FALSE
	if(node.recent_queen_death)
		to_chat(user, span_danger("You are still too burdened with guilt to evolve into a queen."))
		return FALSE
	if(!get_alien_type_in_hive(/mob/living/carbon/alien/humanoid/royal/queen))
		var/mob/living/carbon/alien/humanoid/royal/queen/new_xeno = new(user.loc)
		user.alien_evolve(new_xeno)
		return TRUE
	else
		to_chat(user, span_notice("We already have an alive queen."))
		return FALSE
