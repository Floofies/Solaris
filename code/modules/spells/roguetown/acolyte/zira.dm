// Zira Spells
/obj/effect/proc_holder/spell/invoked/blindness
	name = "Blindness"
	desc = "Direct a mote of living darkness to temporarily blind another."
	overlay_state = "blindness"
	clothes_req = FALSE
	releasedrain = 30
	chargedrain = 5
	chargetime = 5
	range = 7
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'sound/magic/churn.ogg'
	spell_tier = 2 // Combat spell
	invocation = "Obcaeco!"
	invocation_type = "whisper"
	associated_skill = /datum/skill/magic/arcane
	antimagic_allowed = TRUE
	recharge_time = 15 SECONDS
	cost = 1
	xp_gain = TRUE

/obj/effect/proc_holder/spell/invoked/blindness/miracle
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	chargedrain = 0
	chargetime = 0
	invocation = "Zira blinds thee of thy sins!"
	invocation_type = "shout" //can be none, whisper, emote and shout
	associated_skill = /datum/skill/magic/holy
	devotion_cost = 15
	miracle = TRUE

/obj/effect/proc_holder/spell/invoked/blindness/cast(list/targets, mob/user = usr)
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(target.anti_magic_check(TRUE, TRUE))
			return FALSE
		target.visible_message(span_warning("[user] points at [target]'s eyes!"),span_warning("My eyes are covered in darkness!"))
		target.blind_eyes(4)
		return TRUE
	revert_cast()
	return FALSE

/obj/effect/proc_holder/spell/invoked/invisibility
	name = "Invisibility"
	overlay_state = "invisibility"
	desc = "Make another (or yourself) invisible for fifteen seconds."
	releasedrain = 30
	chargedrain = 5
	chargetime = 5
	clothes_req = FALSE
	recharge_time = 30 SECONDS
	range = 3
	warnie = "sydwarning"
	movement_interrupt = FALSE
	spell_tier = 2
	invocation_type = "none" // No emote feedback intentionally.
	sound = 'sound/misc/area.ogg' //This sound doesnt play for some reason. Fix me.
	associated_skill = /datum/skill/magic/arcane
	antimagic_allowed = TRUE
	hide_charge_effect = TRUE
	cost = 2
	xp_gain = TRUE

/obj/effect/proc_holder/spell/invoked/invisibility/miracle
	miracle = TRUE
	devotion_cost = 25
	chargetime = 0
	chargedrain = 0
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	associated_skill = /datum/skill/magic/holy

/obj/effect/proc_holder/spell/invoked/invisibility/cast(list/targets, mob/living/user)
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(target.anti_magic_check(TRUE, TRUE))
			return FALSE

		target.visible_message(span_warning("[target] starts to fade into thin air!"), span_notice("You start to become invisible!"))
		animate(target, alpha = 0, time = 1 SECONDS, easing = EASE_IN)

		target.invis_broken_early = FALSE
		target.mob_timers[MT_INVISIBILITY] = world.time + 15 SECONDS

		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, update_sneak_invis), TRUE), 15 SECONDS)
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, invisibility_fadeback_check)), 15 SECONDS)

		return TRUE

	revert_cast()
	return FALSE
	
/mob/living/proc/invisibility_fadeback_check()
	if(invis_broken_early)
		invis_broken_early = FALSE
		return
	visible_message(span_warning("[src] fades back into view."), span_notice("You become visible again."))

