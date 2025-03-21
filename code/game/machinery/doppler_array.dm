#define PRINTER_TIMEOUT 40

/obj/machinery/doppler_array
	name = "tachyon-doppler array"
	desc = "A highly precise directional sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array.\n"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = TRUE
	verb_say = "states coldly"
	var/cooldown = 10
	var/next_announce = 0
	var/max_dist = 150
	/// Number which will be part of the name of the next record, increased by one for each already created record
	var/record_number = 1
	/// Cooldown for the print function
	var/printer_ready = 0
	/// List of all explosion records in the form of /datum/data/tachyon_record
	var/list/records = list()

/obj/machinery/doppler_array/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, PROC_REF(sense_explosion))
	RegisterSignal(src, COMSIG_MOVABLE_SET_ANCHORED, PROC_REF(power_change))
	printer_ready = world.time + PRINTER_TIMEOUT
	// Alt clicking when unwrenched does not rotate. (likely from UI not returning the mouse click)
	// Also there is no sprite change for rotation dir, this shouldn't even have a rotate component tbh
	AddComponent(/datum/component/simple_rotation, AfterRotation = CALLBACK(src, PROC_REF(RotationMessage)))

/datum/tachyon_record
	var/name = "Log Recording"
	var/timestamp
	var/coordinates = ""
	var/displacement = 0
	var/factual_radius = list()
	var/theory_radius = list()


/obj/machinery/doppler_array/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/doppler_array/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TachyonArray")
		ui.open()

/obj/machinery/doppler_array/ui_data(mob/user)
	var/list/data = list()
	data["records"] = list()
	for(var/datum/tachyon_record/record in records)
		var/list/record_data = list(
			name = record.name,
			timestamp = record.timestamp,
			coordinates = record.coordinates,
			displacement = record.displacement,
			factual_epicenter_radius = record.factual_radius["epicenter_radius"],
			factual_outer_radius = record.factual_radius["outer_radius"],
			factual_shockwave_radius = record.factual_radius["shockwave_radius"],
			theory_epicenter_radius = record.theory_radius["epicenter_radius"],
			theory_outer_radius = record.theory_radius["outer_radius"],
			theory_shockwave_radius = record.theory_radius["shockwave_radius"],
			ref = REF(record)
		)
		data["records"] += list(record_data)
	return data

/obj/machinery/doppler_array/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("delete_record")
			var/datum/tachyon_record/record = locate(params["ref"]) in records
			if(!records || !(record in records))
				return
			records -= record
			. = TRUE
		if("print_record")
			var/datum/tachyon_record/record  = locate(params["ref"]) in records
			if(!records || !(record in records))
				return
			print(usr, record)
			. = TRUE

/obj/machinery/doppler_array/proc/print(mob/user, datum/tachyon_record/record)
	if(!record)
		return
	if(printer_ready < world.time)
		printer_ready = world.time + PRINTER_TIMEOUT
		new /obj/item/paper/record_printout(loc, record)
	else if(user)
		to_chat(user, span_warning("[src] is busy right now."))

/obj/item/paper/record_printout
	name = "paper - Log Recording"

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/paper/record_printout)

/obj/item/paper/record_printout/Initialize(mapload, datum/tachyon_record/record)
	. = ..()

	if(record)
		name = "paper - [record.name]"

		default_raw_text += {"<h2>[record.name]</h2>
		<ul><li>Timestamp: [record.timestamp]</li>
		<li>Coordinates: [record.coordinates]</li>
		<li>Displacement: [record.displacement] seconds</li>
		<li>Epicenter Radius: [record.factual_radius["epicenter_radius"]]</li>
		<li>Outer Radius: [record.factual_radius["outer_radius"]]</li>
		<li>Shockwave Radius: [record.factual_radius["shockwave_radius"]]</li></ul>"}

		if(length(record.theory_radius))
			default_raw_text += {"<ul><li>Theoretical Epicenter Radius: [record.theory_radius["epicenter_radius"]]</li>
			<li>Theoretical Outer Radius: [record.theory_radius["outer_radius"]]</li>
			<li>Theoretical Shockwave Radius: [record.theory_radius["shockwave_radius"]]</li></ul>"}

		update_icon()

/obj/machinery/doppler_array/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		if(!anchored && !isinspace())
			set_anchored(TRUE)
			to_chat(user, span_notice("You fasten [src]."))
		else if(anchored)
			set_anchored(FALSE)
			to_chat(user, span_notice("You unfasten [src]."))
		I.play_tool_sound(src)
		return
	return ..()

/obj/machinery/doppler_array/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/machinery/doppler_array/proc/RotationMessage(mob/user)
	to_chat(user, span_notice("You adjust [src]'s dish to face to the [dir2text(dir)]."))
	playsound(src, 'sound/items/screwdriver2.ogg', 50, 1)

/obj/machinery/doppler_array/proc/sense_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range, explosion_index)
	SIGNAL_HANDLER

	if(machine_stat & NOPOWER)
		return FALSE
	var/turf/zone = get_turf(src)
	if(zone.get_virtual_z_level() != epicenter.get_virtual_z_level())
		return FALSE

	if(next_announce > world.time)
		return FALSE
	next_announce = world.time + cooldown

	var/distance = get_dist(epicenter, zone)
	var/direct = get_dir(zone, epicenter)

	if(distance > max_dist)
		return FALSE
	if(!(direct & dir))
		return FALSE

	var/datum/tachyon_record/new_record = new /datum/tachyon_record()
	new_record.name = "Log Recording #[record_number]"
	new_record.timestamp = station_time_timestamp()
	new_record.coordinates = "[epicenter.x], [epicenter.y]"
	new_record.displacement = took
	new_record.factual_radius["epicenter_radius"] = devastation_range
	new_record.factual_radius["outer_radius"] = heavy_impact_range
	new_record.factual_radius["shockwave_radius"] = light_impact_range

	var/list/messages = list("Explosive disturbance detected.",
							"Epicenter at: grid ([epicenter.x], [epicenter.y]). Temporal displacement of tachyons: [took] seconds.",
							"Factual: Epicenter radius: [devastation_range]. Outer radius: [heavy_impact_range]. Shockwave radius: [light_impact_range].")

	// If the bomb was capped, say its theoretical size.
	if(devastation_range < orig_dev_range || heavy_impact_range < orig_heavy_range || light_impact_range < orig_light_range)
		messages += "Theoretical: Epicenter radius: [orig_dev_range]. Outer radius: [orig_heavy_range]. Shockwave radius: [orig_light_range]."
		new_record.theory_radius["epicenter_radius"] = orig_dev_range
		new_record.theory_radius["outer_radius"] = orig_heavy_range
		new_record.theory_radius["shockwave_radius"] = orig_light_range

	for(var/message in messages)
		say(message)

	record_number++
	records += new_record
	//Update to viewers
	ui_update()

	for(var/mob/living/carbon/human/H in oviewers(src))
		if(H.client)
			INVOKE_ASYNC(H.client, TYPE_PROC_REF(/client, increase_score), /datum/award/score/bomb_score, H, orig_light_range)

	return TRUE

/obj/machinery/doppler_array/powered()
	if(!anchored)
		return FALSE
	return ..()

/obj/machinery/doppler_array/update_icon()
	if(machine_stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/doppler_array/research
	name = "tachyon-doppler research array"
	desc = "A specialized tachyon-doppler bomb detection array that uses the results of the highest yield of explosions for research."
	var/datum/techweb/linked_techweb

//Portable version, built into EOD equipment. It simply provides an explosion's three damage levels.
/obj/machinery/doppler_array/integrated
	name = "integrated tachyon-doppler module"
	max_dist = 21
	use_power = NO_POWER_USE
	var/obj/item/clothing/head/helmet/space/hardsuit/suit

/obj/machinery/doppler_array/integrated/New(hardsuit)
	. = ..()
	suit = hardsuit

/obj/machinery/doppler_array/integrated/sense_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range, explosion_index)
	var/turf/zone = suit.loc
	if(!zone || zone?.get_virtual_z_level() != epicenter.get_virtual_z_level())
		return FALSE

	if(next_announce > world.time)
		return FALSE
	next_announce = world.time + cooldown

	var/distance = get_dist(epicenter, zone)
	if(distance > max_dist)
		return FALSE

	var/list/messages = list("Explosive disturbance detected.",
							"Epicenter at: grid ([epicenter.x], [epicenter.y]). Temporal displacement of tachyons: [took] seconds.",
							"Factual: Epicenter radius: [devastation_range]. Outer radius: [heavy_impact_range]. Shockwave radius: [light_impact_range].")
	for(var/message in messages)
		say(message)

//probably needs a way to ignore admin explosives later on
/obj/machinery/doppler_array/research/sense_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	. = ..()
	if(!.)
		return
	if(!istype(linked_techweb))
		say("Warning: No linked research system!")
		return

	var/general_point_gain = 0
	var/discovery_point_gain = 0

	/*****The Point Calculator*****/

	if(orig_light_range < 10)
		say("Explosion not large enough for research calculations.")
		return
	else if(orig_light_range < 4500)
		general_point_gain = (83300 * orig_light_range) / (orig_light_range + 3000)
	else
		general_point_gain = TECHWEB_BOMB_POINTCAP

	/*****The Point Capper*****/
	if(general_point_gain > linked_techweb.largest_bomb_value)
		if(general_point_gain <= TECHWEB_BOMB_POINTCAP || linked_techweb.largest_bomb_value < TECHWEB_BOMB_POINTCAP)
			var/old_tech_largest_bomb_value = linked_techweb.largest_bomb_value //held so we can pull old before we do math
			linked_techweb.largest_bomb_value = general_point_gain
			general_point_gain -= old_tech_largest_bomb_value
			general_point_gain = min(general_point_gain,TECHWEB_BOMB_POINTCAP)
		else
			linked_techweb.largest_bomb_value = TECHWEB_BOMB_POINTCAP
			general_point_gain = 1000
		var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_SCI_ID)
		if(D)
			D.adjust_money(general_point_gain)
			discovery_point_gain = general_point_gain * 0.5
			linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, general_point_gain)
			linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, discovery_point_gain)

			say("Explosion details and mixture analyzed and sold to the highest bidder for $[general_point_gain], with a reward of [general_point_gain] General Research points and [discovery_point_gain] Discovery Research points.")

	else //you've made smaller bombs
		say("Data already captured. Aborting.")
		return

/obj/machinery/doppler_array/research/science/Initialize(mapload)
	. = ..()
	linked_techweb = SSresearch.science_tech

#undef PRINTER_TIMEOUT
