/obj/item/melee
	item_flags = NEEDS_PERMIT | ISWEAPON

/obj/item/melee/proc/check_martial_counter(mob/living/carbon/human/target, mob/living/carbon/human/user)
	if(target.check_block())
		target.visible_message(span_danger("[target.name] blocks [src] and twists [user]'s arm behind [user.p_their()] back!"),
					span_userdanger("You block the attack!"))
		user.Stun(40)
		return TRUE


/obj/item/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	worn_icon_state = "whip"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("flogs", "whips", "lashes", "disciplines")
	attack_verb_simple = list("flog", "whip", "lash", "discipline")
	hitsound = 'sound/weapons/chainhit.ogg'
	custom_materials = list(/datum/material/iron = 1000)

/obj/item/melee/chainofcommand/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/melee/synthetic_arm_blade
	name = "synthetic arm blade"
	desc = "A grotesque blade that on closer inspection seems made of synthetic flesh, it still feels like it would hurt very badly as a weapon."
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	force = 20
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_CUT

/obj/item/melee/synthetic_arm_blade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 60, 80) //very imprecise

/obj/item/melee/sabre
	name = "officer's sabre"
	desc = "An elegant weapon, its monomolecular edge is capable of cutting through flesh and bone with ease."
	icon_state = "sabre"
	item_state = "sabre"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	obj_flags = UNIQUE_RENAME
	force = 15
	block_level = 1
	block_upgrade_walk = TRUE
	block_power = 50
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration = 75
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_CUT
	attack_verb_continuous = list("slashes", "cuts")
	attack_verb_simple = list("slash", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'
	custom_materials = list(/datum/material/iron = 1000)


/obj/item/melee/sabre/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 30, 95, 5) //fast and effective, but as a sword, it might damage the results.

/obj/item/melee/sabre/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/melee/sabre/on_exit_storage(datum/storage/container)
	var/obj/item/storage/belt/sabre/sabre = container.real_location?.resolve()
	if(istype(sabre))
		playsound(sabre, 'sound/items/unsheath.ogg', 25, TRUE)

/obj/item/melee/sabre/on_enter_storage(datum/storage/container)
	var/obj/item/storage/belt/sabre/sabre = container.real_location?.resolve()
	if(istype(sabre))
		playsound(sabre, 'sound/items/sheath.ogg', 25, TRUE)

/obj/item/melee/sabre/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is trying to cut off all [user.p_their()] limbs with [src]! it looks like [user.p_theyre()] trying to commit suicide!"))
	var/i = 0
	ADD_TRAIT(src, TRAIT_NODROP, SABRE_SUICIDE_TRAIT)
	if(iscarbon(user))
		var/mob/living/carbon/Cuser = user
		var/obj/item/bodypart/holding_bodypart = Cuser.get_holding_bodypart_of_item(src)
		var/list/limbs_to_dismember
		var/list/arms = list()
		var/list/legs = list()
		var/obj/item/bodypart/bodypart

		for(bodypart in Cuser.bodyparts)
			if(bodypart == holding_bodypart)
				continue
			if(bodypart.body_part & ARMS)
				arms += bodypart
			else if (bodypart.body_part & LEGS)
				legs += bodypart

		limbs_to_dismember = arms + legs
		if(holding_bodypart)
			limbs_to_dismember += holding_bodypart

		var/speedbase = abs((4 SECONDS) / limbs_to_dismember.len)
		for(bodypart in limbs_to_dismember)
			i++
			addtimer(CALLBACK(src, PROC_REF(suicide_dismember), user, bodypart), speedbase * i)
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), (5 SECONDS) * i)
	return MANUAL_SUICIDE

/obj/item/melee/sabre/proc/suicide_dismember(mob/living/user, obj/item/bodypart/affecting)
	if(!QDELETED(affecting) && affecting.dismemberable && affecting.owner == user && !QDELETED(user))
		playsound(user, hitsound, 25, 1)
		affecting.dismember(BRUTE)
		user.adjustBruteLoss(20)

/obj/item/melee/sabre/proc/manual_suicide(mob/living/user, originally_nodropped)
	if(!QDELETED(user))
		user.adjustBruteLoss(200)
		user.death(FALSE)
	REMOVE_TRAIT(src, TRAIT_NODROP, SABRE_SUICIDE_TRAIT)

/obj/item/melee/sabre/mime
	name = "Bread Blade"
	desc = "An elegant weapon, it has an inscription on it that says:  \"La Gluten Gutter\"."
	force = 18
	icon_state = "rapier"
	item_state = "rapier"
	lefthand_file = null
	righthand_file = null
	block_power = 60
	armor_type = /datum/armor/sabre_mime


/datum/armor/sabre_mime
	fire = 100
	acid = 100

/obj/item/melee/sabre/mime/on_exit_storage(datum/storage/container)
	var/obj/item/storage/belt/sabre/mime/sabre = container.real_location?.resolve()
	if(istype(sabre))
		playsound(sabre, 'sound/items/unsheath.ogg', 25, TRUE)

/obj/item/melee/sabre/on_enter_storage(datum/storage/container)
	var/obj/item/storage/belt/sabre/mime/sabre = container.real_location?.resolve()
	if(istype(sabre))
		playsound(sabre, 'sound/items/sheath.ogg', 25, TRUE)

/obj/item/melee/classic_baton
	name = "classic baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	worn_icon_state = "classic_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 12 //9 hit crit
	w_class = WEIGHT_CLASS_NORMAL

	var/cooldown_check = 0 // Used interally, you don't want to modify

	var/cooldown = 20 // Default wait time until can stun again.
	var/stun_time_silicon = (5 SECONDS) // If enabled, how long do we stun silicons.
	var/stamina_damage = 55 // Do we deal stamina damage.
	var/affect_silicon = FALSE // Does it stun silicons.
	var/on_sound // "On" sound, played when switching between able to stun or not.
	var/on_stun_sound = 'sound/effects/woodhit.ogg' // Default path to sound for when we stun.
	var/stun_animation = FALSE // Do we animate the "hit" when stunning.
	var/on = TRUE // Are we on or off

	var/on_icon_state // What is our sprite when turned on
	var/off_icon_state // What is our sprite when turned off
	var/on_item_state // What is our in-hand sprite when turned on
	var/force_on // Damage when on - not stunning
	var/force_off // Damage when off - not stunning
	var/weight_class_on // What is the new size class when turned on

/obj/item/melee/classic_baton/Initialize(mapload)
	. = ..()
	// Adding an extra break for the sake of presentation
	if(stamina_damage != 0)
		offensive_notes = "It takes [span_warning("[CEILING(100 / stamina_damage, 1)] stunning hit\s")] to stun an enemy."

// Description for trying to stun when still on cooldown.
/obj/item/melee/classic_baton/proc/get_wait_description()
	return

// Description for when turning their baton "on"
/obj/item/melee/classic_baton/proc/get_on_description()
	. = list()

	.["local_on"] = span_warning("You extend the baton.")
	.["local_off"] = span_notice("You collapse the baton.")

	return .

// Default message for stunning mob.
/obj/item/melee/classic_baton/proc/get_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visibletrip"] =  span_danger("[user] has knocked [target]'s legs out from under them with [src]!")
	.["localtrip"] = span_danger("[user] has knocked your legs out from under you with [src]!")
	.["visibleknockout"] =  span_danger("[user] has violently knocked out [target] with [src]!")
	.["localknockout"] = span_danger("[user] has beat you with such force on the head with [src] you fall unconscious...")
	.["visibledisarm"] =  span_danger("[user] has disarmed [target] with [src]!")
	.["localdisarm"] = span_danger("[user] whacks your arm with [src], causing a coursing pain!")
	.["visiblestun"] =  span_danger("[user] beat [target] with [src]!")
	.["localstun"] = span_danger("[user] has beat you with [src]!")
	.["visibleshead"] =  span_danger("[user] beat [target] on the head with [src]!")
	.["localhead"] = span_danger("[user] has beat your head with [src]!")
	.["visiblearm"] =  span_danger("[user] beat [target]'s arm with [src]!")
	.["localarm"] = span_danger("[user] has beat your arm with [src]!")
	.["visibleleg"] =  span_danger("[user] beat [target]'s leg with [src]!")
	.["localleg"] = span_danger("[user] has beat you in the leg with [src]!")

	return .

// Default message for stunning a silicon.
/obj/item/melee/classic_baton/proc/get_silicon_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = span_danger("[user] pulses [target]'s sensors with the baton!")
	.["local"] = span_danger("You pulse [target]'s sensors with the baton!")

	return .

// Are we applying any special effects when we stun to carbon
/obj/item/melee/classic_baton/proc/additional_effects_carbon(mob/living/target, mob/living/user)
	return

// Are we applying any special effects when we stun to silicon
/obj/item/melee/classic_baton/proc/additional_effects_silicon(mob/living/target, mob/living/user)
	return

//Police Baton
/obj/item/melee/classic_baton/police
	name = "police baton"
	stun_animation = TRUE

/obj/item/melee/classic_baton/police/attack(mob/living/target, mob/living/user)
	if(!on)
		return ..()
	var/def_check = target.getarmor(type = MELEE, penetration = armour_penetration)

	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, span_danger("You hit yourself over the head."))
		user.adjustStaminaLoss(stamina_damage)

		additional_effects_carbon(user) // user is the target here
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		// We don't stun if we're on harm.
		if (!user.combat_mode)
			if (affect_silicon)
				var/list/desc = get_silicon_stun_description(target, user)

				target.flash_act(affect_silicon = TRUE)
				target.Paralyze(stun_time_silicon)
				additional_effects_silicon(target, user)

				user.visible_message(desc["visible"], desc["local"])
				playsound(get_turf(src), on_stun_sound, 100, TRUE, -1)

				if (stun_animation)
					user.do_attack_animation(target)
			else
				..()
		else
			..()
		return
	if(!isliving(target))
		return
	if (user.combat_mode)
		if(!..())
			return
		if(!iscyborg(target))
			return
	else
		if(cooldown_check <= world.time)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if (H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
					return
				if(check_martial_counter(H, user))
					log_combat(user, target, "attempted to attack", src, "(blocked by martial arts)")
					return

			var/list/desc = get_stun_description(target, user)

			if (stun_animation)
				user.do_attack_animation(target)
			playsound(get_turf(src), on_stun_sound, 75, 1, -1)
			additional_effects_carbon(target, user)
			if((user.is_zone_selected(BODY_ZONE_HEAD)) || (user.is_zone_selected(BODY_ZONE_CHEST)))
				target.apply_damage(stamina_damage, STAMINA, BODY_ZONE_CHEST, def_check)
				log_combat(user, target, "stunned", src)
				target.visible_message(desc["visiblestun"], desc["localstun"])
			if((user.is_zone_selected(BODY_ZONE_R_LEG)) || (user.is_zone_selected(BODY_ZONE_L_LEG)))
				target.Knockdown(30)
				log_combat(user, target, "tripped", src)
				target.visible_message(desc["visibletrip"], desc["localtrip"])
			var/combat_zone = user.get_combat_bodyzone(target)
			if(combat_zone == BODY_ZONE_L_ARM)
				target.apply_damage(50, STAMINA, BODY_ZONE_L_ARM, def_check)
				log_combat(user, target, "disarmed", src)
				target.visible_message(desc["visibledisarm"], desc["localdisarm"])
			if(combat_zone == BODY_ZONE_R_ARM)
				target.apply_damage(50, STAMINA, BODY_ZONE_R_ARM, def_check)
				log_combat(user, target, "disarmed", src)
				target.visible_message(desc["visibledisarm"], desc["localdisarm"])

			add_fingerprint(user)

			cooldown_check = world.time + cooldown
		else
			var/wait_desc = get_wait_description()
			if (wait_desc)
				to_chat(user, wait_desc)

/obj/item/melee/classic_baton/police/deputy
	name = "deputy baton"
	force = 12
	cooldown = 10
	stamina_damage = 20
	stun_animation = TRUE

//Telescopic Baton
/obj/item/melee/classic_baton/police/telescopic
	name = "telescopic baton"
	desc = "A compact and harmless personal defense weapon. Sturdy enough to knock the feet out from under attackers and robust enough to disarm with a quick strike to the hand"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "telebaton_0"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	stamina_damage = 0
	stun_animation = FALSE
	item_state = null
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON
	force = 0
	on = FALSE
	on_sound = 'sound/weapons/batonextend.ogg'

	on_icon_state = "telebaton_1"
	off_icon_state = "telebaton_0"
	on_item_state = "nullrod"
	force_on = 0
	force_off = 0
	weight_class_on = WEIGHT_CLASS_BULKY

/obj/item/melee/classic_baton/telescopic/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(on)
		return ..()
	return 0

/obj/item/melee/classic_baton/telescopic/suicide_act(mob/living/user)
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/brain/B = H.get_organ_by_type(/obj/item/organ/brain)

	user.visible_message(span_suicide("[user] stuffs [src] up [user.p_their()] nose and presses the 'extend' button! It looks like [user.p_theyre()] trying to clear [user.p_their()] mind."))
	if(!on)
		src.attack_self(user)
	else
		playsound(src, on_sound, 50, 1)
		add_fingerprint(user)
	sleep(3)
	if (!QDELETED(H))
		if(!QDELETED(B))
			H.internal_organs -= B
			qdel(B)
		new /obj/effect/gibspawner/generic(H.drop_location(), H)
		return BRUTELOSS

/obj/item/melee/classic_baton/police/telescopic/attack_self(mob/user)
	on = !on
	var/list/desc = get_on_description()

	if(on)
		to_chat(user, desc["local_on"])
		icon_state = on_icon_state
		item_state = on_item_state
		w_class = weight_class_on
		force = force_on
		attack_verb_continuous = list("smacks", "strikes", "cracks", "beats")
		attack_verb_simple = list("smack", "strike", "crack", "beat")
	else
		to_chat(user, desc["local_off"])
		icon_state = off_icon_state
		item_state = null //no sprite for concealment even when in hand
		slot_flags = ITEM_SLOT_BELT
		w_class = WEIGHT_CLASS_SMALL
		force = force_off
		attack_verb_continuous = list("hits", "pokes")
		attack_verb_simple = list("hit", "poke")

	playsound(src.loc, on_sound, 50, 1)
	add_fingerprint(user)

//Contractor Baton
/obj/item/melee/classic_baton/retractible_stun
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "contractor_baton_0"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	item_state = null
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON
	force = 5
	on = FALSE
	var/knockdown_time_carbon = (1.5 SECONDS) // Knockdown length for carbons.
	var/stamina_damage_non_target = 55
	var/stamina_damage_target = 85
	var/target_confusion = 4 SECONDS

	stamina_damage = 85
	affect_silicon = TRUE
	on_sound = 'sound/weapons/contractorbatonextend.ogg'
	on_stun_sound = 'sound/effects/contractorbatonhit.ogg'
	stun_animation = TRUE

	on_icon_state = "contractor_baton_1"
	off_icon_state = "contractor_baton_0"
	on_item_state = "contractor_baton"
	force_on = 10
	force_off = 5
	weight_class_on = WEIGHT_CLASS_NORMAL

/obj/item/melee/classic_baton/retractible_stun/get_wait_description()
	return span_danger("The baton is still charging!")

/obj/item/melee/classic_baton/retractible_stun/additional_effects_carbon(mob/living/target, mob/living/user)
	target.Jitter(2 SECONDS)
	target.stuttering += 2 SECONDS

/obj/item/melee/classic_baton/retractible_stun/attack_self(mob/user)
	on = !on
	var/list/desc = get_on_description()

	if(on)
		to_chat(user, desc["local_on"])
		icon_state = on_icon_state
		item_state = on_item_state
		w_class = weight_class_on
		force = force_on
		attack_verb_continuous = list("smacks", "strikes", "cracks", "beats")
		attack_verb_simple = list("smack", "strike", "crack", "beat")
	else
		to_chat(user, desc["local_off"])
		icon_state = off_icon_state
		item_state = null //no sprite for concealment even when in hand
		slot_flags = ITEM_SLOT_BELT
		w_class = WEIGHT_CLASS_SMALL
		force = force_off
		attack_verb_continuous = list("hits", "pokes")
		attack_verb_simple = list("hit", "poke")

	playsound(src.loc, on_sound, 50, TRUE)
	add_fingerprint(user)

/obj/item/melee/classic_baton/retractible_stun/proc/is_target(mob/living/target, mob/living/user)
	return TRUE

/obj/item/melee/classic_baton/retractible_stun/proc/check_disabled(mob/living/target, mob/living/user)
	return FALSE

/obj/item/melee/classic_baton/retractible_stun/attack(mob/living/target, mob/living/user)
	if(!on)
		return ..()

	if(check_disabled(target, user))
		return ..()

	var/is_target = is_target(target, user)

	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, span_danger("You hit yourself over the head."))

		user.Paralyze(knockdown_time_carbon * force)
		user.adjustStaminaLoss(stamina_damage)

		additional_effects_carbon(user) // user is the target here
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		// We don't stun if we're on harm.
		if (!user.combat_mode)
			if (affect_silicon)
				var/list/desc = get_silicon_stun_description(target, user)

				target.flash_act(affect_silicon = TRUE)
				target.Paralyze(stun_time_silicon)
				additional_effects_silicon(target, user)

				user.visible_message(desc["visible"], desc["local"])
				playsound(get_turf(src), on_stun_sound, 100, TRUE, -1)

				if (stun_animation)
					user.do_attack_animation(target)
			else
				..()
		else
			..()
		return
	if(!isliving(target))
		return
	if (user.combat_mode)
		if(!..())
			return
		if(!iscyborg(target))
			return
	else
		if(cooldown_check <= world.time)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if (H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
					return
				if(check_martial_counter(H, user))
					log_combat(user, target, "attempted to attack", src, "(blocked by martial arts)")
					return

			var/list/desc = get_stun_description(target, user)

			if (stun_animation)
				user.do_attack_animation(target)

			playsound(get_turf(src), on_stun_sound, 75, TRUE, -1)
			if(is_target)
				target.Knockdown(knockdown_time_carbon)
				target.drop_all_held_items()
				target.adjustStaminaLoss(stamina_damage)
				if(target_confusion > 0 && target.confused < 6 SECONDS)
					target.confused = min(target.confused + target_confusion, 6 SECONDS)
			else
				target.Knockdown(knockdown_time_carbon)
				target.adjustStaminaLoss(stamina_damage_non_target)
			additional_effects_carbon(target, user)

			log_combat(user, target, "stunned", src)
			add_fingerprint(user)

			target.visible_message(desc["visible"], desc["local"])

			cooldown_check = world.time + cooldown
		else
			var/wait_desc = get_wait_description()
			if (wait_desc)
				to_chat(user, wait_desc)

/obj/item/melee/classic_baton/retractible_stun/contractor_baton
	name = "contractor baton"
	desc = "A compact, specialised baton assigned to Syndicate contractors. Applies light electric shocks that can resonate with a specific target's brain frequency causing significant stunning effects."
	var/datum/antagonist/traitor/owner_data = null

/obj/item/melee/classic_baton/retractible_stun/contractor_baton/check_disabled(mob/living/target, mob/living/user)
	return !owner_data || owner_data?.owner?.current != user

/obj/item/melee/classic_baton/retractible_stun/contractor_baton/is_target(mob/living/target, mob/living/user)
	return owner_data.contractor_hub?.current_contract?.contract?.target == target.mind

/obj/item/melee/classic_baton/retractible_stun/contractor_baton/pickup(mob/user)
	..()
	if(!owner_data)
		var/datum/antagonist/traitor/traitor_data = user.mind?.has_antag_datum(/datum/antagonist/traitor)
		if(traitor_data)
			owner_data = traitor_data
			to_chat(user, span_notice("[src] scans your genetic data as you pick it up, creating an uplink with the syndicate database. Attacking your current target will stun them, however the baton is weak against non-targets."))

/obj/item/melee/classic_baton/retractible_stun/bounty
	name = "bounty hunter baton"
	desc = "A compact, specialised retractible stun baton assigned to bounty hunters."
	knockdown_time_carbon = (2 SECONDS)
	stamina_damage_non_target = 60
	stamina_damage_target = 60
	stamina_damage = 60
	target_confusion = 0

// Supermatter Sword
/obj/item/melee/supermatter_sword
	name = "supermatter sword"
	desc = "In a station full of bad ideas, this might just be the worst."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "supermatter_sword"
	item_state = "supermatter_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = null
	w_class = WEIGHT_CLASS_BULKY
	force = 0.001
	armour_penetration = 1000
	var/obj/machinery/power/supermatter_crystal/shard
	var/balanced = 1
	block_level = 1
	block_upgrade_walk = TRUE
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_PROJECTILE
	force_string = "INFINITE"

/obj/item/melee/supermatter_sword/on_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, damage, attack_type)
	qdel(hitby)
	owner.visible_message(span_danger("[hitby] evaporates in midair!"))
	return TRUE

/obj/item/melee/supermatter_sword/Initialize(mapload)
	. = ..()
	shard = new /obj/machinery/power/supermatter_crystal(src)
	qdel(shard.countdown)
	shard.countdown = null
	START_PROCESSING(SSobj, src)
	visible_message(span_warning("[src] appears, balanced ever so perfectly on its hilt. This isn't ominous at all."))

/obj/item/melee/supermatter_sword/process()
	if(balanced || throwing || ismob(src.loc) || isnull(src.loc))
		return
	if(!isturf(src.loc))
		var/atom/target = src.loc
		forceMove(target.loc)
		consume_everything(target)
	else
		var/turf/T = get_turf(src)
		if(!isspaceturf(T))
			consume_turf(T)

/obj/item/melee/supermatter_sword/afterattack(target, mob/user, proximity_flag)
	. = ..()
	if(user && target == user)
		user.dropItemToGround(src)
	if(proximity_flag)
		consume_everything(target)

/obj/item/melee/supermatter_sword/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(ismob(hit_atom))
		var/mob/M = hit_atom
		if(src.loc == M)
			M.dropItemToGround(src)
	consume_everything(hit_atom)

/obj/item/melee/supermatter_sword/pickup(user)
	..()
	balanced = 0

/obj/item/melee/supermatter_sword/ex_act(severity, target)
	visible_message(span_danger("The blast wave smacks into [src] and rapidly flashes to ash."),\
	span_italics("You hear a loud crack as you are washed with a wave of heat."))
	consume_everything()

/obj/item/melee/supermatter_sword/acid_act()
	visible_message(span_danger("The acid smacks into [src] and rapidly flashes to ash."),\
	span_italics("You hear a loud crack as you are washed with a wave of heat."))
	consume_everything()

/obj/item/melee/supermatter_sword/bullet_act(obj/projectile/P)
	visible_message(span_danger("[P] smacks into [src] and rapidly flashes to ash."),\
	span_italics("You hear a loud crack as you are washed with a wave of heat."))
	consume_everything(P)
	return BULLET_ACT_HIT

/obj/item/melee/supermatter_sword/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] touches [src]'s blade. It looks like [user.p_theyre()] tired of waiting for the radiation to kill [user.p_them()]!"))
	user.dropItemToGround(src, TRUE)
	shard.Bumped(user)

/obj/item/melee/supermatter_sword/proc/consume_everything(target)
	if(isnull(target))
		shard.Consume()
	else if(!isturf(target))
		shard.Bumped(target)
	else
		consume_turf(target)

/obj/item/melee/supermatter_sword/proc/consume_turf(turf/T)
	var/oldtype = T.type
	var/turf/newT = T.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	if(newT.type == oldtype)
		return
	playsound(T, 'sound/effects/supermatter.ogg', 50, 1)
	T.visible_message(span_danger("[T] smacks into [src] and rapidly flashes to ash."),\
	span_italics("You hear a loud crack as you are washed with a wave of heat."))
	shard.Consume()
	CALCULATE_ADJACENT_TURFS(T, MAKE_ACTIVE)

/obj/item/melee/supermatter_sword/add_blood_DNA(list/blood_dna)
	return FALSE

/obj/item/melee/curator_whip
	name = "curator's whip"
	desc = "Somewhat eccentric and outdated, it still stings like hell to be hit by."
	icon_state = "whip"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	worn_icon_state = "whip"
	slot_flags = ITEM_SLOT_BELT
	force = 0.001 //"Some attack noises shit"
	reach = 3
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("flogs", "whips", "lashes", "disciplines")
	attack_verb_simple = list("flog", "whip", "lash", "discipline")
	hitsound = 'sound/weapons/whip.ogg'

/obj/item/melee/curator_whip/attack(mob/living/target, mob/living/user)
	. = ..()
	if(!ishuman(target))
		return

	switch(user.get_combat_bodyzone(target))
		if(BODY_ZONE_L_ARM)
			whip_disarm(user, target, "left")
		if(BODY_ZONE_R_ARM)
			whip_disarm(user, target, "right")
		if(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
			whip_trip(user, target)
		else
			whip_lash(user, target)

/obj/item/melee/curator_whip/proc/whip_disarm(mob/living/carbon/user, mob/living/target, side)
	var/obj/item/I = target.get_held_items_for_side(side)
	if(I)
		if(target.dropItemToGround(I))
			target.visible_message(span_danger("[I] is yanked out of [target]'s hands by [src]!"),span_userdanger("[user] grabs [I] out of your hands with [src]!"))
			to_chat(user, span_notice("You yank [I] towards yourself."))
			log_combat(user, target, "disarmed", src)
			if(!user.get_inactive_held_item())
				user.throw_mode_on(THROW_MODE_TOGGLE)
				user.swap_hand()
				I.throw_at(user, 10, 2)

/obj/item/melee/curator_whip/proc/whip_trip(mob/living/user, mob/living/target) //this is bad and ugly but not as bad and ugly as the original code
	if(get_dist(user, target) < 2)
		to_chat(user, span_warning("[target] is too close to trip with the whip!"))
		return
	target.Knockdown(3 SECONDS)
	log_combat(user, target, "tripped", src)
	target.visible_message(span_danger("[user] knocks [target] off [target.p_their()] feet!"), span_userdanger("[user] yanks your legs out from under you!"))

/obj/item/melee/curator_whip/proc/whip_lash(mob/living/user, mob/living/target)
	if(target.getarmor(type = MELEE, penetration = armour_penetration) < 16)
		target.emote("scream")
		target.visible_message(span_danger("[user] whips [target]!"), span_userdanger("[user] whips you! It stings!"))

/obj/item/melee/roastingstick
	name = "advanced roasting stick"
	desc = "A telescopic roasting stick with a miniature shield generator designed to ensure entry into various high-tech shielded cooking ovens and firepits."
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "roastingstick_0"
	item_state = null
	worn_icon_state = "tele_baton"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON
	force = 0
	attack_verb_continuous = list("hits", "pokes")
	attack_verb_simple = list("hit", "poke")
	/// The sausage attatched to our stick.
	var/obj/item/food/sausage/held_sausage
	/// Static list of things our roasting stick can interact with.
	var/static/list/ovens
	/// The beam that links to the oven we use
	var/datum/beam/beam

/obj/item/melee/roastingstick/Initialize(mapload)
	. = ..()
	if(!ovens)
		ovens = typecacheof(list(/obj/anomaly, /obj/machinery/power/supermatter_crystal, /obj/structure/bonfire))
	AddComponent( \
		/datum/component/transforming, \
		hitsound_on = hitsound, \
		clumsy_check = FALSE, \
		inhand_icon_change = FALSE, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_PRE_TRANSFORM, PROC_REF(attempt_transform))
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_PRE_TRANSFORM].
 *
 * If there is a sausage attached, returns COMPONENT_BLOCK_TRANSFORM.
 */
/obj/item/melee/roastingstick/proc/attempt_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(held_sausage)
		to_chat(user, span_warning("You can't retract [src] while [held_sausage] is attached!"))
		return COMPONENT_BLOCK_TRANSFORM

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Gives feedback on stick extension.
 */
/obj/item/melee/roastingstick/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	icon_state = active ? "roastingstick_1" : "roastingstick_0"
	item_state = active ? "nullrod" : null
	if(user)
		balloon_alert(user, "[active ? "extended" : "collapsed"] [src]")
	playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/melee/roastingstick/attackby(atom/target, mob/user)
	..()
	if (istype(target, /obj/item/food/meat) || istype(target, /obj/item/food/sausage))
		var/obj/item/food/target_sausage = target
		if ( !( target_sausage.foodtypes & RAW ) &&  !( target_sausage.foodtypes & FRIED ) ) // ONLY COOKED MEATS, NO RAW, NO FRIED.
			if (!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
				to_chat(user, span_warning("You must extend [src] to attach anything to it!"))
				return
			if (held_sausage)
				to_chat(user, span_warning("[held_sausage] is already attached to [src]!"))
				return
			if (user.transferItemToLoc(target, src))
				held_sausage = target
			else
				to_chat(user, span_warning("[target] doesn't seem to want to get on [src]!"))
		else
			to_chat(user, span_warning("[target] can't be roasted using [src]! Pre-cook the meat!"))
	else
		to_chat(user, span_warning("[target] can't be roasted using [src]!"))
	update_appearance()

/obj/item/melee/roastingstick/attack_hand(mob/user, list/modifiers)
	..()
	if (held_sausage)
		user.put_in_hands(held_sausage)

/obj/item/melee/roastingstick/update_overlays()
	. = ..()
	if(held_sausage)
		. += mutable_appearance(icon, "roastingstick_sausage")

/obj/item/melee/roastingstick/Exited(atom/movable/gone, direction)
	. = ..()
	if (gone == held_sausage)
		held_sausage = null
		update_appearance()

/obj/item/melee/roastingstick/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if (!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return
	if (!is_type_in_typecache(target, ovens))
		return
	if (istype(target, /obj/anomaly) && get_dist(user, target) < 10)
		to_chat(user, span_notice("You send [held_sausage] towards [target]."))
		playsound(src, 'sound/items/rped.ogg', 50, TRUE)
		beam = user.Beam(target, icon_state = "rped_upgrade", time = 10 SECONDS)
	else if (user.Adjacent(target))
		to_chat(user, span_notice("You extend [src] towards [target]."))
		playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, TRUE)
	else
		return
	finish_roasting(user, target)

/obj/item/melee/roastingstick/proc/finish_roasting(user, atom/target)
	if(do_after(user, 100, target = user))
		to_chat(user, span_notice("You finish roasting [held_sausage]."))
		playsound(src, 'sound/items/welder2.ogg', 50, TRUE)
		held_sausage.add_atom_colour(rgb(103, 63, 24), FIXED_COLOUR_PRIORITY)
		held_sausage.name = "[target.name]-roasted [held_sausage.name]"
		held_sausage.desc = "[held_sausage.desc] It has been cooked to perfection on \a [target]."
		update_appearance()
	else
		QDEL_NULL(beam)
		playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)
		to_chat(user, span_notice("You put [src] away."))

/obj/item/melee/knockback_stick
	name = "Knockback Stick"
	desc = "An portable anti-gravity generator which knocks people back upon contact."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "telebaton_1"
	item_state = "nullrod"
	worn_icon_state = "tele_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("repells")
	attack_verb_simple = list("repell")
	var/cooldown = 0
	var/knockbackpower = 6

/obj/item/melee/knockback_stick/attack(mob/living/target, mob/living/user)
	add_fingerprint(user)

	if(cooldown <= world.time)
		playsound(get_turf(src), 'sound/effects/woodhit.ogg', 75, 1, -1)
		log_combat(user, target, "knockedbacked", src)
		target.visible_message(span_danger("[user] has knocked back [target] with [src]!"), \
			span_userdanger("[user] has knocked you back [target] with [src]!"))

		var/throw_dir = get_dir(user,target)
		var/turf/throw_at = get_ranged_target_turf(target, throw_dir, knockbackpower)
		target.throw_at(throw_at, throw_range, 3)

		cooldown = world.time + 15

//Former Wooden Baton
/obj/item/melee/tonfa
	name = "Police Tonfa"
	desc = "A traditional police baton for gaining the submission of an uncooperative target without the use of lethal-force. \
		As with all traditional weapons, the target will find themselves bruised, but alive. It has proven to be effective in preventing \
		repeat offenses and has brought employment to lawyers for decades."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "beater"
	item_state = "beater"
	worn_icon_state = "classic_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	force = 12
	throwforce = 7
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_LARGE
	hitsound = 'sound/effects/woodhit.ogg'
	/// Damage dealt while on help intent
	var/non_harm_force = 3
	/// Stamina damage dealt
	var/stamina_force = 25

// #11200 Review - TEMP: Hacky code to deal with force string for this item.
/obj/item/melee/tonfa/openTip(location, control, params, mob/living/user)
	if (user != null && !user.combat_mode)
		force = non_harm_force
	else
		force = initial(force)
	return ..()

/obj/item/melee/tonfa/attack(mob/living/target, mob/living/user)
	var/target_zone = user.get_combat_bodyzone(target)
	var/armour_level = target.getarmor(target_zone, STAMINA, penetration = armour_penetration - 15)

	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, span_danger("You hit yourself over the head."))
		user.adjustStaminaLoss(stamina_force)

		// Deal full damage
		force = initial(force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(!isliving(target))
		return ..()
	if(iscyborg(target))
		if (!user.combat_mode)
			playsound(get_turf(src), hitsound, 75, 1, -1)
			user.do_attack_animation(target) // The attacker cuddles the Cyborg, awww. No damage here.
			return
	if (!user.combat_mode)
		force = non_harm_force
	else
		force = initial(force)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if (H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
			return
		if(check_martial_counter(H, user))
			log_combat(user, target, "attempted to attack", src, "(blocked by martial arts)")
			return

		target.visible_message("[user] strikes [target] in the [parse_zone(target_zone)].", "You strike [target] in the [parse_zone(target_zone)].")
		log_combat(user, target, "attacked", src)

		// If the target has a lot of stamina loss, knock them down
		if ((user.is_zone_selected(BODY_ZONE_L_LEG) || user.is_zone_selected(BODY_ZONE_R_LEG)) && target.getStaminaLoss() > 22)
			var/effectiveness = CLAMP01((target.getStaminaLoss() - 22) / 50)
			log_combat(user, target, "knocked-down", src, "(additional effect)")
			// Move the target back upon knockdown, to give them some time to recover
			var/shove_dir = get_dir(user.loc, target.loc)
			var/turf/target_shove_turf = get_step(target.loc, shove_dir)
			var/mob/living/carbon/human/target_collateral_human = locate(/mob/living/carbon) in target_shove_turf.contents
			if (target_collateral_human && target_shove_turf != get_turf(user))
				target.Knockdown(max(0.5 SECONDS, effectiveness * 4 SECONDS * (100-armour_level)/100))
				target_collateral_human.Knockdown(0.5 SECONDS)
			else
				target.Knockdown(effectiveness * 4 SECONDS * (100-armour_level)/100)
			target.Move(target_shove_turf, shove_dir)
		if (user.is_zone_selected(BODY_ZONE_L_LEG) || user.is_zone_selected(BODY_ZONE_R_LEG) || user.is_zone_selected(BODY_ZONE_L_ARM) || user.is_zone_selected(BODY_ZONE_R_ARM))
			// 4-5 hits on an unarmoured target
			target.apply_damage(stamina_force*0.6, STAMINA, target_zone, armour_level)
		else
			// 4-5 hits on an unarmoured target
			target.apply_damage(stamina_force, STAMINA, target_zone, armour_level)

	return ..()
