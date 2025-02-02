/datum/martial_art/boxing
	name = "Boxing"
	id = MARTIALART_BOXING

/datum/martial_art/boxing/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, span_warning("Can't disarm while boxing!"))
	return 1

/datum/martial_art/boxing/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, span_warning("Can't grab while boxing!"))
	return 1

/datum/martial_art/boxing/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = 6 + A.dna.species.punchdamage
	if(!damage)
		playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		D.visible_message(span_warning("[A]'s [atk_verb] misses [D]!"), \
			span_userdanger("[A]'s [atk_verb] misses you!"), null, COMBAT_MESSAGE_RANGE)
		log_combat(A, D, "attempted to hit", atk_verb, important = FALSE)
		return 0


	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.get_combat_bodyzone(D)))
	var/armor_block = D.run_armor_check(affecting, MELEE)

	playsound(D.loc, A.dna.species.attack_sound, 25, 1, -1)

	D.visible_message(span_danger("[A] [atk_verb]ed [D]!"), \
			span_userdanger("[A] [atk_verb]ed you!"), null, COMBAT_MESSAGE_RANGE)

	D.apply_damage(damage, STAMINA, affecting, armor_block)
	log_combat(A, D, "punched (boxing) ", name)
	if(D.getStaminaLoss() > 50 && istype(D.mind?.martial_art, /datum/martial_art/boxing))
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)
		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message(span_danger("[A] knocks [D] out with a haymaker!"), \
							span_userdanger("You're knocked unconscious by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
			to_chat(A, span_danger("You knock [D] out with a haymaker!"))
			D.apply_effect(200,EFFECT_KNOCKDOWN,armor_block)
			D.SetSleeping(100)
			D.force_say(A)
			log_combat(A, D, "knocked out (boxing) ", name)
		else if(D.body_position == LYING_DOWN)
			D.force_say(A)
	return TRUE

/obj/item/clothing/gloves/boxing
	var/datum/martial_art/boxing/style = new

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
	return

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(H)
	return
