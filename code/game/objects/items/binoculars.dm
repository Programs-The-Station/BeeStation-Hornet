/obj/item/binoculars
	name = "binoculars"
	desc = "Used for long-distance surveillance."
	item_state = "binoculars"
	icon_state = "binoculars"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	var/mob/listeningTo
	var/zoom_out_amt = 6
	var/zoom_amt = 10

/obj/item/binoculars/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, PROC_REF(on_wield))
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, PROC_REF(on_unwield))

/obj/item/binoculars/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed)

/obj/item/binoculars/Destroy()
	listeningTo = null
	return ..()

/obj/item/binoculars/proc/on_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(unwield))
	listeningTo = user
	user.visible_message(span_notice("[user] holds [src] up to [user.p_their()] eyes."), span_notice("You hold [src] up to your eyes."))
	item_state = "binoculars_wielded"
	user.regenerate_icons()
	if(!user?.client)
		return
	var/client/C = user.client
	var/_x = 0
	var/_y = 0
	switch(user.dir)
		if(NORTH)
			_y = zoom_amt
		if(EAST)
			_x = zoom_amt
		if(SOUTH)
			_y = -zoom_amt
		if(WEST)
			_x = -zoom_amt
	C.change_view(get_zoomed_view(world.view, zoom_out_amt))
	C.pixel_x = world.icon_size*_x
	C.pixel_y = world.icon_size*_y

/obj/item/binoculars/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	unwield(user)

/obj/item/binoculars/proc/unwield(mob/user)
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null
	user.visible_message(span_notice("[user] lowers [src]."), span_notice("You lower [src]."))
	item_state = "binoculars"
	user.regenerate_icons()
	if(user && user.client)
		user.regenerate_icons()
		var/client/C = user.client
		C.change_view(CONFIG_GET(string/default_view))
		user.client.pixel_x = 0
		user.client.pixel_y = 0
