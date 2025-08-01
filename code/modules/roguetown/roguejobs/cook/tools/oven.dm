
/obj/machinery/light/rogue/oven
	icon = 'icons/roguetown/misc/lighting.dmi'
	name = "oven"
	icon_state = "oven1"
	base_state = "oven"
	density = FALSE
	on = FALSE
	/// The name of the underlay that is displayed under the oven.
	var/underlay_name = "oven_under"
	var/list/food = list()
	var/maxfood = 5
	var/donefoods = FALSE
	var/lastsmoke = 0
	var/need_underlay_update = TRUE
	var/mob/living/carbon/human/lastuser

/obj/machinery/light/rogue/oven/OnCrafted(dirin)
	dirin = turn(dirin, 180)
	. = ..(dirin)
	update_icon()

/obj/machinery/light/rogue/oven/attackby(obj/item/W, mob/living/user, params)
	lastuser = user
	var/_y = text2num(params2list(params)["icon-y"])
	var/clicked_top
	if(_y > 14)
		clicked_top = TRUE

	if(clicked_top)
		if((W.item_flags & ABSTRACT) || HAS_TRAIT(W, TRAIT_NODROP))
			return ..()
		if(W.wlength > WLENGTH_NORMAL)
			return ..()
		if(food.len < maxfood)
			donefoods = FALSE
			W.forceMove(src)
			food += W
			playsound(get_turf(src.loc), 'sound/items/wood_sharpen.ogg', 50) // neu cooking
			user.visible_message(span_warning("[user] puts something in the oven."))
			need_underlay_update = TRUE
			update_icon()
			return
	return ..()

/obj/machinery/light/rogue/oven/process()
	..()
	var/datum/skill/craft/cooking/cs = lastuser?.mind?.get_skill_level(/datum/skill/craft/cooking)
	var/cooktime_divisor = get_cooktime_divisor(cs)
	if(on)
		for(var/obj/item/I in food)
			var/obj/item/C = I.cooking(10 * cooktime_divisor, 10, src)
			if(C)
				donefoods = TRUE
				food -= I
				qdel(I)
				food += C
				visible_message(span_notice("Something smells good!"))
				need_underlay_update = TRUE
		update_icon()


/obj/machinery/light/rogue/oven/Crossed(atom/movable/AM, oldLoc)
	return

/obj/machinery/light/rogue/oven/north
	dir = NORTH
	pixel_y = -32

/obj/machinery/light/rogue/oven/south
	dir = SOUTH
	pixel_y = 32 //so we see it in mapper

/obj/machinery/light/rogue/oven/west
	dir = WEST
	pixel_x = 32

/obj/machinery/light/rogue/oven/east
	dir = EAST
	pixel_x = -32

/obj/machinery/light/rogue/oven/center

/obj/machinery/light/rogue/oven/Initialize()
	. = ..()
	update_icon()

/obj/machinery/light/rogue/oven/update_icon()
	pixel_x = 0
	pixel_y = 0
	switch(dir)
		if(SOUTH)
			pixel_y = 32
		if(NORTH)
			pixel_y = -32
		if(WEST)
			pixel_x = 32
		if(EAST)
			pixel_x = -32
	icon_state = "[base_state][on]"

	if(on)
		var/burning
		for(var/obj/item/reagent_containers/food/snacks/S in food)
			if(S.burning >= S.burntime)
				burning = TRUE
		if(burning)
			if(world.time > lastsmoke + 10 SECONDS)
				lastsmoke = world.time
				var/datum/effect_system/smoke_spread/smoke = new
				smoke.set_up(0, src)
				smoke.start()

	if(need_underlay_update)
		need_underlay_update = FALSE
		underlays.Cut()
		for(var/obj/item/I in food)
			I.pixel_x = 0
			I.pixel_y = 0
			var/mutable_appearance/M = new /mutable_appearance(I)
			M.transform *= 0.5
			M.pixel_y = rand(-2,4) // WHY WOULD YOU WANT TO HIDE THE ENTIRE SPRITE?? Fixed now
			M.layer = 4.24
			underlays += M
		var/mutable_appearance/M = mutable_appearance(icon, underlay_name)
		M.layer = 4.23
		underlays += M

/obj/machinery/light/rogue/oven/attack_hand(mob/user, params)
	lastuser = user
	var/_y = text2num(params2list(params)["icon-y"])
	var/clicked_top
	if(_y > 14)
		clicked_top = TRUE
	if(clicked_top)
		if(food.len)
			var/obj/item/I = food[food.len]
			I.forceMove(get_turf(user))
			food -= I
			user.put_in_active_hand(I)
			donefoods = FALSE
			need_underlay_update = TRUE
			update_icon()
	else
		return ..()


/obj/machinery/light/rogue/oven/tree
	name = "livingwood oven"
	icon_state = "oven_tree1"
	base_state = "oven_tree"
	underlay_name = "oven_under_tree"

/obj/machinery/light/rogue/oven/tree/north
	dir = NORTH
	pixel_y = -32

/obj/machinery/light/rogue/oven/tree/south
	dir = SOUTH
	pixel_y = 32 //so we see it in mapper

/obj/machinery/light/rogue/oven/tree/west
	dir = WEST
	pixel_x = 32

/obj/machinery/light/rogue/oven/tree/east
	dir = EAST
	pixel_x = -32

/obj/machinery/light/rogue/oven/tree/center
