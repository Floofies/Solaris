/obj/item/flashlight
	name = "flashlight"
	desc = ""
	custom_price = 10
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = null
	light_system = MOVABLE_LIGHT
	light_outer_range = 4
	light_power = 1
	slot_flags = ITEM_SLOT_BELT
	var/weather_resistant = FALSE
	possible_item_intents = list(INTENT_GENERIC)
	var/on = FALSE

/obj/item/flashlight/Initialize()
	. = ..()
	if(icon_state == "[initial(icon_state)]-on")
		on = TRUE
	update_brightness()

/obj/item/flashlight/proc/update_brightness(mob/user = null)
	if(on)
		icon_state = "[initial(icon_state)]-on"
	else
		icon_state = initial(icon_state)
	set_light_on(on)

/obj/item/flashlight/attack_self(mob/user)
	on = !on
	update_brightness(user)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
	return 1

/obj/item/flashlight/suicide_act(mob/living/carbon/human/user)
	if (user.eye_blind)
		user.visible_message("<span class='suicide'>[user] is putting [src] close to [user.p_their()] eyes and turning it on... but [user.p_theyre()] blind!</span>")
		return SHAME
	user.visible_message("<span class='suicide'>[user] is putting [src] close to [user.p_their()] eyes and turning it on! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (FIRELOSS)

/obj/item/flashlight/attack(mob/living/carbon/M, mob/living/carbon/human/user)
	add_fingerprint(user)
	return ..()

// FLARES

/obj/item/flashlight/flare
	name = "flare"
	desc = ""
	w_class = WEIGHT_CLASS_SMALL
	light_outer_range = 7 // Pretty bright.
	icon_state = "flare"
	item_state = "flare"
	actions_types = list()
	heat = 1000
	light_color = LIGHT_COLOR_FLARE
	grind_results = list(/datum/reagent/sulfur = 15)

	var/fuel = 12000
	var/on_damage = 7
	var/produce_heat = 1500
	var/times_used = 0

/obj/item/flashlight/flare/process()
	open_flame(heat)
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()
		if(!fuel)
			icon_state = "[initial(icon_state)]-empty"
		STOP_PROCESSING(SSobj, src)

/obj/item/flashlight/flare/ignition_effect(atom/A, mob/user)
	if(fuel && on)
		. = "<span class='notice'>[user] lights [A] with [src] like a real \
			badass.</span>"
	else
		. = ""

/obj/item/flashlight/flare/proc/turn_off()
	on = FALSE
	force = initial(src.force)
	damtype = initial(src.damtype)
	if(ismob(loc))
		var/mob/U = loc
		update_brightness(U)
	else
		update_brightness(null)

/obj/item/flashlight/flare/update_brightness(mob/user = null)
	..()
	if(on)
		item_state = "[initial(item_state)]-on"
	else
		item_state = "[initial(item_state)]"

/obj/item/flashlight/flare/attack_self(mob/user)

	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='warning'>[src] is out of fuel!</span>")
		return
	if(on)
		to_chat(user, "<span class='warning'>[src] is already on!</span>")
		return

	. = ..()
	// All good, turn it on.
	if(.)
		user.visible_message("<span class='notice'>[user] lights \the [src].</span>", "<span class='notice'>I light \the [src]!</span>")
		force = on_damage
//		damtype = "fire"
		START_PROCESSING(SSobj, src)

/obj/item/flashlight/flare/get_temperature()
	return on * heat

/obj/item/flashlight/flare/torch
	name = "torch"
	desc = ""
	w_class = WEIGHT_CLASS_NORMAL
	light_outer_range = 5
	force = 1
	icon = 'icons/roguetown/items/lighting.dmi'
	icon_state = "torch"
	item_state = "torch"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	light_color = "#f5a885"
	on_damage = 2
	flags_1 = null
	possible_item_intents = list(/datum/intent/use, /datum/intent/hit)
	slot_flags = ITEM_SLOT_HIP
	var/datum/looping_sound/torchloop/soundloop = null         //remove the = null to re-add the torch crackle sounds.
	var/should_self_destruct = TRUE //added for torch burnout
	max_integrity = 40
	fuel = 30 MINUTES
	light_depth = 0
	light_height = 0

	grid_width = 32
	grid_height = 32

/obj/item/flashlight/flare/torch/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.7,"sx" = -8,"sy" = 4,"nx" = 10,"ny" = 4,"wx" = -7,"wy" = 3,"ex" = 2,"ey" = 6,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 2,"sturn" = 2,"wturn" = -2,"eturn" = -2,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/flashlight/flare/torch/Initialize()
	GLOB.weather_act_upon_list += src
	. = ..()
	if(soundloop)
		soundloop = new(src, FALSE)

/obj/item/flashlight/flare/torch/Destroy()
	GLOB.weather_act_upon_list -= src
	. = ..()

/obj/item/flashlight/flare/torch/process()
	open_flame(heat)
	if(!fuel || !on)
		turn_off()
		STOP_PROCESSING(SSobj, src)
		if(!fuel)
			icon_state = "torch-empty"
		return
	if(!istype(loc,/obj/machinery/light/rogue/torchholder))
		if(!ismob(loc))
			if(prob(23))
				turn_off()
				STOP_PROCESSING(SSobj, src)
				return
		else
			var/mob/M = loc
			if(!(src in M.held_items))
				if(prob(23))
					turn_off()
					STOP_PROCESSING(SSobj, src)
					return
		fuel = max(fuel - 10, 0)

/obj/item/flashlight/flare/torch/attack_self(mob/user)

	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='warning'>[src] doesn't have any pitch left!</span>")
		return
	if(on)
		turn_off()

/obj/item/flashlight/flare/torch/extinguish()
	if(on)
		turn_off()

/obj/item/flashlight/flare/torch/weather_act_on(weather_trait, severity)
	if(weather_trait != PARTICLEWEATHER_RAIN)
		return
	if(weather_resistant)
		return
	extinguish()

/obj/item/flashlight/flare/torch/turn_off()
	playsound(src.loc, 'sound/items/firesnuff.ogg', 100)
	if(soundloop)
		soundloop.stop()
	STOP_PROCESSING(SSobj, src)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()
		M.update_inv_belt()
	damtype = BRUTE

/obj/item/flashlight/flare/torch/fire_act(added, maxstacks)
	if(fuel)
		if(!on)
			playsound(src.loc, 'sound/items/firelight.ogg', 100)
			on = TRUE
			damtype = BURN
			update_brightness()
			force = on_damage
			if(soundloop)
				soundloop.start()
			if(ismob(loc))
				var/mob/M = loc
				M.update_inv_hands()
			START_PROCESSING(SSobj, src)
	..()

/obj/item/flashlight/flare/torch/afterattack(atom/movable/A, mob/user, proximity)
	. = ..()
	if (!proximity)
		return
	if (on && (prob(50) || (user.used_intent.type == /datum/intent/use)))
		if (ismob(A))
			A.spark_act()
		else
			A.fire_act(3,3)

		if (should_self_destruct)  // check if self-destruct
			times_used += 1
			if (times_used >= 8) //amount used before burning out
				user.visible_message("<span class='warning'>[src] has burnt out and falls apart!</span>")
				qdel(src)

/obj/item/flashlight/flare/torch/spark_act()
	fire_act()

/obj/item/flashlight/flare/torch/get_temperature()
	if(on)
		return FIRE_MINIMUM_TEMPERATURE_TO_SPREAD
	return ..()

/obj/item/flashlight/flare/torch/prelit/Initialize() //Prelit version, testing to see if it causes less issues with pre_equip dropping stuff in your hands
	. = ..()
	spark_act()

/obj/item/flashlight/flare/torch/metal
	name = "torch"
	force = 1
	icon_state = "mtorch"
	light_outer_range = 6
	fuel = 120 MINUTES
	should_self_destruct = TRUE

/obj/item/flashlight/flare/torch/metal/afterattack(atom/movable/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(on && (prob(50) || (user.used_intent.type == /datum/intent/use)))
		if(ismob(A))
			A.spark_act()
		else
			A.fire_act(3,3)

		if (should_self_destruct)  // check if self-destruct
			times_used += 1
			if (times_used >= 13) //amount used before burning out
				user.visible_message("<span class='warning'>[src] has burnt out and falls apart!</span>")
				qdel(src)

/obj/item/flashlight/flare/torch/lantern
	name = "iron lamptern"
	icon_state = "lamp"
	desc = "A light to guide the way."
	light_outer_range = 7
	on = FALSE
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_HIP
	force = 1
	on_damage = 5
	fuel = 120 MINUTES
	should_self_destruct = FALSE
	grid_width = 32
	grid_height = 64

/obj/item/flashlight/flare/torch/lantern/afterattack(atom/movable/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(on && (prob(50) || (user.used_intent.type == /datum/intent/use)))
		if(ismob(A))
			A.spark_act()
		else
			A.fire_act(3,3)

/obj/item/flashlight/flare/torch/lantern/process()
	open_flame(heat)
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()
		STOP_PROCESSING(SSobj, src)

/obj/item/flashlight/flare/torch/lantern/extinguish()
	return

/obj/item/flashlight/flare/torch/lantern/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = -2,"sy" = -4,"nx" = 9,"ny" = -4,"wx" = -3,"wy" = -4,"ex" = 2,"ey" = -4,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/flashlight/flare/torch/lantern/prelit/Initialize() //Prelit version
	. = ..()
	spark_act()

/obj/item/flashlight/flare/torch/lantern/bronzelamptern
	name = "bronze lamptern"
	icon_state = "bronzelamp"
	item_state = "bronzelamp"
	desc = "A marvel of engineering that emits a pale green glow."
	light_outer_range = 8
	light_color ="#bdf4d4"
	on = FALSE

/obj/item/flashlight/flare/torch/lantern/copper
	name = "copper lamptern"
	icon_state = "clamp"
	desc = "A simple and cheap lamptern."
	light_outer_range = 7
	on = FALSE
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_HIP
	force = 1
	on_damage = 5
	fuel = 120 MINUTES
	should_self_destruct = FALSE

/obj/item/flashlight/flare/torch/lantern/copper/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = -2,"sy" = -4,"nx" = 9,"ny" = -4,"wx" = -3,"wy" = -4,"ex" = 2,"ey" = -4,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

//Wisp Lantern
/obj/item/wisp_lantern
	name = "magic lantern"
	desc = "A magical lantern with a dancing spirit."
	icon = 'icons/roguetown/items/lighting.dmi'
	icon_state = "lamp"
	item_state = "lantern"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	slot_flags = ITEM_SLOT_HIP
	var/obj/effect/wisp/wisp

/obj/item/wisp_lantern/attack_self(mob/user)
	if(!wisp)
		to_chat(user, span_warning("The spirit has gone missing!"))
		icon_state = "lantern_wisp-on"
		return

	if(wisp.loc == src)
		to_chat(user, span_notice("I release the spirit. It dances around me and guides my path."))
		icon_state = "lantern_wisp-on"
		wisp.orbit(user, 20)
		SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Freed")

	else
		to_chat(user, span_notice("I return the spirit to it's cage."))
		icon_state = "lantern_wisp"
		wisp.forceMove(src)
		SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Returned")

/obj/item/wisp_lantern/Initialize()
	. = ..()
	wisp = new(src)

/obj/item/wisp_lantern/Destroy()
	if(wisp)
		if(wisp.loc == src)
			qdel(wisp)
		else
			wisp.visible_message(span_notice("[wisp] weeps for a time, then it passes."))
	return ..()

/obj/effect/wisp
	name = "wisp"
	desc = "These seelie spirits often appear in magical forests.."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "spark"
	color = GLOW_COLOR_ICE
	light_system = MOVABLE_LIGHT
	light_outer_range = 7
	pixel_x = 20
	light_flags = LIGHT_ATTACHED
	layer = ABOVE_ALL_MOB_LAYER
	var/sight_flags = SEE_MOBS
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/effect/wisp/orbit(atom/thing)
	. = ..()
	if(ismob(thing))
		RegisterSignal(thing, COMSIG_MOB_UPDATE_SIGHT, PROC_REF(update_user_sight))
		var/mob/being = thing
		being.update_sight()
		to_chat(thing, span_notice("The wisp enhances my vision."))

/obj/effect/wisp/stop_orbit(datum/component/orbiter/orbits)
	. = ..()
	if(ismob(orbits.parent))
		UnregisterSignal(orbits.parent, COMSIG_MOB_UPDATE_SIGHT)
		to_chat(orbits.parent, span_notice("Darkness consumes me once more."))

/obj/effect/wisp/proc/update_user_sight(mob/user)
	user.sight |= sight_flags
	if(!isnull(lighting_alpha))
		user.lighting_alpha = min(user.lighting_alpha, lighting_alpha)
