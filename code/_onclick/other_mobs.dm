/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/UnarmedAttack(atom/A, proximity, params)

	if(!has_active_hand()) //can't attack without a hand.
		to_chat(src, span_warning("I lack working hands."))
		return

	if(!has_hand_for_held_index(used_hand)) //can't attack without a hand.
		to_chat(src, span_warning("I can't move this hand."))
		return

	if(check_arm_grabbed(used_hand))
		to_chat(src, span_warning("Someone is grabbing my arm!"))
		return

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines
	if(proximity && istype(G) && G.Touch(A,1))
		return
	//This signal is needed to prevent gloves of the north star + hulk.
	if(SEND_SIGNAL(src, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, A, proximity) & COMPONENT_NO_ATTACK_HAND)
		return
	SEND_SIGNAL(src, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, A, proximity)
	if(isliving(A))
		var/mob/living/L = A
		if(!used_intent.noaa)
			playsound(get_turf(src), pick(GLOB.unarmed_swingmiss), 100, FALSE)
//			src.emote("attackgrunt")
		if(L.checkmiss(src))
			return
		if(!L.checkdefense(used_intent, src))
			L.attack_hand(src, params)
		return
	else
		var/item_skip = FALSE
		if(isitem(A))
			var/obj/item/I = A
			if(I.w_class < WEIGHT_CLASS_GIGANTIC)
				item_skip = TRUE
		if(!item_skip)
			if(used_intent.type == INTENT_GRAB)
				var/obj/AM = A
				if(istype(AM) && !AM.anchored)
					start_pulling(A) //add params to grab bodyparts based on loc
					return
			if(used_intent.type == INTENT_DISARM)
				var/obj/AM = A
				if(istype(AM) && !AM.anchored)
					var/jadded = max(100-(STASTR*10),5)
					if(rogfat_add(jadded))
						visible_message(span_info("[src] pushes [AM]."))
						PushAM(AM, MOVE_FORCE_STRONG)
					else
						visible_message(span_warning("[src] pushes [AM]."))
					changeNext_move(CLICK_CD_MELEE)
					return
		A.attack_hand(src, params)

/mob/living/rmb_on(atom/A, params)
	if(stat)
		return

	if(!has_active_hand()) //can't attack without a hand.
		to_chat(src, span_warning("I lack working hands."))
		return

	if(!has_hand_for_held_index(used_hand)) //can't attack without a hand.
		to_chat(src, span_warning("I can't move this hand."))
		return

	if(check_arm_grabbed(used_hand))
		to_chat(src, span_warning("[pulledby] is restraining my arm!"))
		return

	A.attack_right(src, params)

/mob/living/attack_right(mob/user, params)
	. = ..()
//	if(!user.Adjacent(src)) //alreadyu checked in rmb_on
//		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.face_atom(src)
	if(user.cmode)
		if(user.rmb_intent)
			user.rmb_intent.special_attack(user, src)
	else
		ongive(user, params)

/turf/attack_right(mob/user, params)
	. = ..()
	user.changeNext_move(CLICK_CD_MELEE)
	user.face_atom(src)
	if(user.cmode)
		if(user.rmb_intent)
			user.rmb_intent.special_attack(user, src)

/atom/proc/ongive(mob/user, params)
	return

/obj/item/ongive(mob/user, params) //take an item if hand is empty
	if(user.get_active_held_item())
		return
	src.attack_hand(user, params)

/mob
	var/mob/givingto
	var/lastgibto

/mob/living/ongive(mob/user, params)
	if(!ishuman(user) || src == user)
		return
	var/mob/living/carbon/human/H = user
	if(givingto == H && !H.get_active_held_item()) //take item being offered
		if(world.time > lastgibto + 300) //time out give after a while
			givingto = null
			return
		var/obj/item/I = get_active_held_item()
		if(I)
			transferItemToLoc(I, newloc = H, force = FALSE, silent = TRUE)
			H.put_in_active_hand(I)
			visible_message(span_notice("[src.name] gives [I] to [H.name]."))
			return
		else
			givingto = null
	else if(!H.givingto && H.get_active_held_item()) //offer item
		if(get_empty_held_indexes())
			var/obj/item/I = H.get_active_held_item()
			H.givingto = src
			H.lastgibto = world.time
			to_chat(src, span_notice("[H.name] offers [I] to me."))
			to_chat(H, span_notice("I offer [I] to [src.name]."))
		else
			to_chat(H, span_warning("[src.name]'s hands are full."))

/atom/proc/onkick(mob/user)
	return

/obj/item/onkick(mob/user)
	if(!ontable())
		if(w_class < WEIGHT_CLASS_HUGE)
			throw_at(get_ranged_target_turf(src, get_dir(user,src), 2), 2, 2, user, FALSE)

/atom/proc/onbite(mob/user)
	return

/mob/living/onbite(mob/living/carbon/human/user)
	return

///Initial bite on target
/mob/living/carbon/onbite(mob/living/carbon/human/user)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("I don't want to harm [src]!"))
		return FALSE
	if(!user.can_bite())
		to_chat(user, span_warning("My mouth has something in it."))
		return FALSE

	var/datum/intent/bite/bitten = new()
	if(checkdefense(bitten, user))
		return FALSE

	if(user.pulling != src)
		if(!lying_attack_check(user))
			return FALSE

	var/def_zone = check_zone(user.zone_selected)
	var/obj/item/bodypart/affecting = get_bodypart(def_zone)
	if(!affecting)
		to_chat(user, span_warning("Nothing to bite."))
		return

	next_attack_msg.Cut()

	var/nodmg = FALSE
	var/dam2do = 10*(user.STASTR/20)
	if(HAS_TRAIT(user, TRAIT_STRONGBITE))
		dam2do *= 2
	if(!HAS_TRAIT(user, TRAIT_STRONGBITE))
		if(!affecting.has_wound(/datum/wound/bite))
			nodmg = TRUE
	if(!nodmg)
		var/armor_block = run_armor_check(user.zone_selected, "stab",blade_dulling=BCLASS_BITE)
		if(!apply_damage(dam2do, BRUTE, def_zone, armor_block, user))
			nodmg = TRUE
			next_attack_msg += span_warning("Armor stops the damage.")

	var/datum/wound/caused_wound
	if(!nodmg)
		caused_wound = affecting.bodypart_attacked_by(BCLASS_BITE, dam2do, user, user.zone_selected, crit_message = TRUE)
	visible_message(span_danger("[user] bites [src]'s [parse_zone(user.zone_selected)]![next_attack_msg.Join()]"), \
					span_userdanger("[user] bites my [parse_zone(user.zone_selected)]![next_attack_msg.Join()]"))

	next_attack_msg.Cut()

//nodmg if they don't have an open wound
//nodmg if we don't have strongbite
//nodmg if our teeth can't break through their armour

	if(!nodmg)
		playsound(src, "smallslash", 100, TRUE, -1)
		if(ishuman(src) && user.mind)
			var/mob/living/carbon/human/bite_victim = src
			/*
				WEREWOLF INFECTION VIA BITE
			*/
			if(istype(user.dna.species, /datum/species/werewolf))
				if(HAS_TRAIT(src, TRAIT_SILVER_BLESSED))
					to_chat(user, span_warning("BLEH! [bite_victim] tastes of SILVER! My gift cannot take hold."))
				else
					caused_wound?.werewolf_infect_attempt()
					if(prob(30))
						user.werewolf_feed(bite_victim, 10)
			
			/*
				ZOMBIE INFECTION VIA BITE
			*/
			var/datum/antagonist/zombie/zombie_antag = user.mind.has_antag_datum(/datum/antagonist/zombie)
			if(zombie_antag && zombie_antag.has_turned)
				zombie_antag.last_bite = world.time
				if(bite_victim.zombie_infect_attempt())   // infect_attempt on bite
					to_chat(user, span_danger("You feel your gift trickling from your mouth into [bite_victim]'s wound..."))
				
	var/obj/item/grabbing/bite/B = new()
	user.equip_to_slot_or_del(B, SLOT_MOUTH)
	if(user.mouth == B)
		var/used_limb = src.find_used_grab_limb(user)
		B.name = "[src]'s [parse_zone(used_limb)]"
		var/obj/item/bodypart/BP = get_bodypart(check_zone(used_limb))
		BP.grabbedby += B
		B.grabbed = src
		B.grabbee = user
		B.limb_grabbed = BP
		B.sublimb_grabbed = used_limb

		lastattacker = user.real_name
		lastattackerckey = user.ckey
		if(mind)
			mind.attackedme[user.real_name] = world.time
		log_combat(user, src, "bit")
	return TRUE

/mob/living/proc/get_jump_range()
	if(!check_armor_skill() || get_item_by_slot(SLOT_LEGCUFFED))
		return 1
	if(m_intent == MOVE_INTENT_RUN)
		return 3
	return 2

/// Returns the stamina cost to jump. Will never use more than 100 stam.
/mob/living/proc/get_jump_stam_cost()
	. = 10
	if(m_intent == MOVE_INTENT_RUN)
		. = 15
	var/mob/living/carbon/human/H = src
	if(istype(H))
		. += H.get_complex_pain()/50
	if(!check_armor_skill() || get_item_by_slot(SLOT_LEGCUFFED))
		. += 50
	return clamp(., 0, 100)

/mob/living/proc/get_jump_offbalance_time()
	if(m_intent == MOVE_INTENT_RUN)
		return 3 SECONDS
	return 2 SECONDS

/// Performs a jump. Used by the jump MMB intent. Returns TRUE if a jump was performed.
/mob/living/proc/can_jump(atom/A)
	var/turf/our_turf = get_turf(src)
	if(istype(our_turf, /turf/open/water))
		to_chat(src, span_warning("I'm floating in [our_turf]."))
		return FALSE
	if(!A || QDELETED(A) || !A.loc)
		return FALSE
	if(A == src || A == src.loc)
		return FALSE
	if(get_num_legs() < 2)
		return FALSE
	if(pulledby && pulledby != src)
		to_chat(src, span_warning("I'm being grabbed."))
		return FALSE
	if(IsOffBalanced())
		to_chat(src, span_warning("I haven't regained my balance yet."))
		return FALSE
	if(!(mobility_flags & MOBILITY_STAND) && !HAS_TRAIT(src, TRAIT_LEAPER))// The Jester cares not for such social convention.
		to_chat(src, span_warning("I should stand up first."))
		return FALSE
	if(A.z != z && !HAS_TRAIT(src, TRAIT_ZJUMP))
		return FALSE
	return TRUE

/mob/living/proc/can_kick(atom/A, do_message = TRUE)
	if(get_num_legs() < 2)
		return FALSE
	if(!A.Adjacent(src))
		return FALSE
	if(A == src)
		return FALSE
	if(isliving(A) && !(mobility_flags & MOBILITY_STAND) && pulledby)
		return FALSE
	if(IsOffBalanced())
		if(do_message)
			to_chat(src, span_warning("I haven't regained my balance yet."))
		return FALSE
	if(QDELETED(src) || QDELETED(A))
		return FALSE
	return TRUE

/// Performs a kick. Used by the kick MMB intent. Returns TRUE if a kick was performed.
/mob/living/proc/try_kick(atom/A)
	if(!can_kick(A))
		return FALSE
	changeNext_move(mmb_intent.clickcd)
	face_atom(A)

	playsound(src, pick(PUNCHWOOSH), 100, FALSE, -1)
	// play the attack animation even when kicking non-mobs
	if(mmb_intent) // why this would be null and not INTENT_KICK i have no clue, but the check already existed
		do_attack_animation(A, visual_effect_icon = mmb_intent.animname)
	// but the rest of the logic is pretty much mob-only
	if(ismob(A) && mmb_intent)
		var/mob/living/M = A
		sleep(mmb_intent.swingdelay)
		if(QDELETED(src) || QDELETED(M))
			return FALSE
		if(!M.Adjacent(src))
			return FALSE
		if(src.incapacitated())
			return FALSE
		if(M.checkmiss(src))
			return FALSE
		if(M.checkdefense(mmb_intent, src))
			return FALSE
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.dna.species.kicked(src, H)
		else
			M.onkick(src)
	else
		A.onkick(src)
	OffBalance(3 SECONDS)
	return TRUE

/mob/living/MiddleClickOn(atom/A, params)
	..()
	if(!mmb_intent)
		if(!A.Adjacent(src))
			return
		A.MiddleClick(src, params)
	else
		switch(mmb_intent.type)
//			if(INTENT_GIVE)
//				if(!A.Adjacent(src))
//					return
//				changeNext_move(mmb_intent.clickcd)
//				face_atom(A)
//				A.ongive(src, params)
			if(INTENT_KICK)
				try_kick(A)
				return
			if(INTENT_JUMP)
				jump_action(A)
			if(INTENT_BITE)
				if(!A.Adjacent(src))
					return
				if(A == src)
					return
				if(src.incapacitated())
					return
				if(!get_location_accessible(src, BODY_ZONE_PRECISE_MOUTH, grabs="other"))
					to_chat(src, span_warning("My mouth is blocked."))
					return
				if(HAS_TRAIT(src, TRAIT_NO_BITE))
					to_chat(src, span_warning("I can't bite."))
					return
				changeNext_move(mmb_intent.clickcd)
				face_atom(A)
				A.onbite(src)
				return
			if(INTENT_STEAL)
				if(!A.Adjacent(src))
					return
				if(ishuman(A))
					var/mob/living/carbon/human/U = src
					var/mob/living/carbon/human/V = A
					var/thiefskill = src.mind.get_skill_level(/datum/skill/misc/stealing)
					var/stealroll = roll("[thiefskill]d6")
					var/targetperception = (V.STAPER)
					var/list/stealablezones = list("chest", "neck", "groin", "r_hand", "l_hand")
					var/list/stealpos = list()
					var/list/mobsbehind = list()
					var/exp_to_gain = STAINT
					to_chat(src, span_notice("I try to steal from [V]..."))	
					if(do_after(src, 5, target = V, progress = 0))
						if(stealroll > targetperception)
						//TODO add exp here
							// RATWOOD MODULAR START
							if(V.cmode)
								to_chat(src, "<span class='warning'>[V] is alert. I can't pickpocket them like this.</span>")
								return
							// RATWOOD MODULAR END
							if(U.get_active_held_item())
								to_chat(src, span_warning("I can't pickpocket while my hand is full!"))
								return
							if(!(zone_selected in stealablezones))
								to_chat(src, span_warning("What am I going to steal from there?"))
								return
							mobsbehind |= cone(V, list(turn(V.dir, 180)), list(src))
							if(mobsbehind.Find(src) || V.IsUnconscious() || V.eyesclosed || V.eye_blind || V.eye_blurry || !(V.mobility_flags & MOBILITY_STAND))
								switch(U.zone_selected)
									if("chest")
										if (V.get_item_by_slot(SLOT_BACK_L))
											stealpos.Add(V.get_item_by_slot(SLOT_BACK_L))
										if (V.get_item_by_slot(SLOT_BACK_R))
											stealpos.Add(V.get_item_by_slot(SLOT_BACK_R))
									if("neck")
										if (V.get_item_by_slot(SLOT_NECK))
											stealpos.Add(V.get_item_by_slot(SLOT_NECK))
									if("groin")
										if (V.get_item_by_slot(SLOT_BELT_R))
											stealpos.Add(V.get_item_by_slot(SLOT_BELT_R))
										if (V.get_item_by_slot(SLOT_BELT_L))
											stealpos.Add(V.get_item_by_slot(SLOT_BELT_L))
									if("r_hand", "l_hand")
										if (V.get_item_by_slot(SLOT_RING))
											stealpos.Add(V.get_item_by_slot(SLOT_RING))
								if (length(stealpos) > 0)
									var/obj/item/picked = pick(stealpos)
									V.dropItemToGround(picked)
									put_in_active_hand(picked)
									to_chat(src, span_green("I stole [picked]!"))
									V.log_message("has had \the [picked] stolen by [key_name(U)]", LOG_ATTACK, color="white")
									U.log_message("has stolen \the [picked] from [key_name(V)]", LOG_ATTACK, color="white")
								else
									exp_to_gain /= 2 // these can be removed or changed on reviewer's discretion
									to_chat(src, span_warning("I didn't find anything there. Perhaps I should look elsewhere."))
							else
								to_chat(src, "<span class='warning'>They can see me!")
						if(stealroll <= 5)
							V.log_message("has had an attempted pickpocket by [key_name(U)]", LOG_ATTACK, color="white")
							U.log_message("has attempted to pickpocket [key_name(V)]", LOG_ATTACK, color="white")
							U.visible_message(span_danger("[U] failed to pickpocket [V]!"))
							to_chat(V, span_danger("[U] tried pickpocketing me!"))
						if(stealroll < targetperception)
							V.log_message("has had an attempted pickpocket by [key_name(U)]", LOG_ATTACK, color="white")
							U.log_message("has attempted to pickpocket [key_name(V)]", LOG_ATTACK, color="white")
							to_chat(src, span_danger("I failed to pick the pocket!"))
							to_chat(V, span_danger("Someone tried pickpocketing me!"))
							exp_to_gain /= 5 // these can be removed or changed on reviewer's discretion
						// If we're pickpocketing someone else, and that person is conscious, grant XP
						if(src != V && V.stat == CONSCIOUS)
							mind.add_sleep_experience(/datum/skill/misc/stealing, exp_to_gain, FALSE)
						changeNext_move(mmb_intent.clickcd)
				return
			if(INTENT_SPELL)
				if(ranged_ability?.InterceptClickOn(src, params, A))
					changeNext_move(mmb_intent.clickcd)
					if(mmb_intent.releasedrain)
						rogfat_add(mmb_intent.releasedrain)
				return

//Return TRUE to cancel other attack hand effects that respect it.
/atom/proc/attack_hand(mob/user, params)
	. = FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND))
		add_fingerprint(user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_NO_ATTACK_HAND)
		. = TRUE
	if(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND)
		. = _try_interact(user)

/atom/proc/attack_right(mob/user)
	. = FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND))
		add_fingerprint(user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_NO_ATTACK_HAND)
		. = TRUE
	if(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND)
		. = _try_interact(user)

//Return a non FALSE value to cancel whatever called this from propagating, if it respects it.
/atom/proc/_try_interact(mob/user)
	if(IsAdminGhost(user))		//admin abuse
		return interact(user)
	if(can_interact(user))
		return interact(user)
	return FALSE

/atom/proc/can_interact(mob/user)
	if(!user.can_interact_with(src))
		return FALSE
	if((interaction_flags_atom & INTERACT_ATOM_REQUIRES_DEXTERITY) && !user.IsAdvancedToolUser())
		to_chat(user, span_warning("I don't have the dexterity to do this!"))
		return FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_IGNORE_INCAPACITATED) && user.incapacitated((interaction_flags_atom & INTERACT_ATOM_IGNORE_RESTRAINED), !(interaction_flags_atom & INTERACT_ATOM_CHECK_GRAB)))
		return FALSE
	return TRUE

/atom/ui_status(mob/user)
	. = ..()
	if(!can_interact(user))
		. = min(., UI_UPDATE)

/atom/movable/can_interact(mob/user)
	. = ..()
	if(!.)
		return
	if(!anchored && (interaction_flags_atom & INTERACT_ATOM_REQUIRES_ANCHORED))
		return FALSE

/atom/proc/interact(mob/user)
	if(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_INTERACT)
		add_hiddenprint(user)
	else
		add_fingerprint(user)
	if(interaction_flags_atom & INTERACT_ATOM_UI_INTERACT)
		return ui_interact(user)
	return FALSE

/*
/mob/living/carbon/human/RestrainedClickOn(atom/A) ---carbons will handle this
	return
*/

/mob/living/carbon/RestrainedClickOn(atom/A)
	return 0

/mob/living/carbon/human/RangedAttack(atom/A, mouseparams)
	. = ..()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		if(istype(G) && G.Touch(A,0)) // for magic gloves
			return
	if(!used_intent.noaa && ismob(A))
//		playsound(src, pick(GLOB.unarmed_swingmiss), 100, FALSE)
		do_attack_animation(A, visual_effect_icon = used_intent.animname)
		changeNext_move(used_intent.clickcd)
//		src.emote("attackgrunt")
		playsound(get_turf(src), used_intent.miss_sound, 100, FALSE)
		if(used_intent.miss_text)
			visible_message(span_warning("[src] [used_intent.miss_text]!"), \
							span_warning("I [used_intent.miss_text]!"))
		aftermiss()

//	if(isturf(A) && get_dist(src,A) <= 1) //move this to grab inhand item being used on an empty tile
//		src.Move_Pulled(A)
//		return

/mob/living/proc/jump_action(atom/A)
	if(istype(get_turf(src), /turf/open/water))
		to_chat(src, span_warning("I can't jump while floating."))
		return

	if(!A || QDELETED(A) || !A.loc)
		return

	if(A == src || A == loc)
		return

	if(src.get_num_legs() < 2)
		return

	if(pulledby && pulledby != src)
		to_chat(src, span_warning("I'm being grabbed."))
		resist_grab()
		return

	if(IsOffBalanced())
		to_chat(src, span_warning("I haven't regained my balance yet."))
		return

	if(!(mobility_flags & MOBILITY_STAND))
		if(!HAS_TRAIT(src, TRAIT_LEAPER))// The Jester cares not for such social convention.
			to_chat(src, span_warning("I should stand up first."))
			return

	if(!isatom(A))
		return

	if(A.z != z)
		if(!HAS_TRAIT(src, TRAIT_ZJUMP))
			to_chat(src, span_warning("That's too high for me..."))
			return

	changeNext_move(mmb_intent.clickcd)

	face_atom(A)

	var/jadded
	var/jrange
	var/jextra = FALSE

	if(m_intent == MOVE_INTENT_RUN)
		emote("leap", forced = TRUE)
		OffBalance(30)
		jadded = 45
		jrange = 3

		if(!HAS_TRAIT(src, TRAIT_LEAPER))// The Jester lands where the Jester wants.
			jextra = TRUE
	else
		emote("jump", forced = TRUE)
		OffBalance(20)
		jadded = 20
		jrange = 2

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		jadded += H.get_complex_pain()/50
		if(!H.check_armor_skill() || H.legcuffed)
			jadded += 50
			jrange = 1

	jump_action_resolve(A, jadded, jrange, jextra)

#define FLIP_DIRECTION_CLOCKWISE 1
#define FLIP_DIRECTION_ANTICLOCKWISE 0

/mob/living/proc/jump_action_resolve(atom/A, jadded, jrange, jextra)
	var/do_a_flip
	var/flip_direction = FLIP_DIRECTION_CLOCKWISE
	var/prev_pixel_z = pixel_z
	var/prev_transform = transform
	if(mind && mind.get_skill_level(/datum/skill/misc/athletics) > 4)
		do_a_flip = TRUE
		if((dir & SOUTH) || (dir & WEST))
			flip_direction = FLIP_DIRECTION_ANTICLOCKWISE

	if(rogfat_add(min(jadded,100)))
		if(do_a_flip)
			var/flip_angle = flip_direction ? 120 : -120
			animate(src, pixel_z = pixel_z + 6, transform = turn(transform, flip_angle), time = 1)
			animate(transform = turn(transform, flip_angle), time=1)
			animate(pixel_z = prev_pixel_z, transform = turn(transform, flip_angle), time=1)
			animate(transform = prev_transform, time = 0)
		else
			animate(src, pixel_z = pixel_z + 6, time = 1)
			animate(pixel_z = prev_pixel_z, transform = turn(transform, pick(-12, 0, 12)), time=2)
			animate(transform = prev_transform, time = 0)

		if(jextra)
			throw_at(A, jrange, 1, src, spin = FALSE)
			while(src.throwing)
				sleep(1)
			throw_at(get_step(src, src.dir), 1, 1, src, spin = FALSE)
		else
			throw_at(A, jrange, 1, src, spin = FALSE)
			while(src.throwing)
				sleep(1)
		if(!HAS_TRAIT(src, TRAIT_ZJUMP) && (m_intent == MOVE_INTENT_RUN))	//Jesters and werewolves don't get immobilized at all
			Immobilize((HAS_TRAIT(src, TRAIT_LEAPER) ? 5 : 10))	//Acrobatics get half the time
		if(isopenturf(src.loc))
			var/turf/open/T = src.loc
			if(T.landsound)
				playsound(T, T.landsound, 100, FALSE)
			T.Entered(src)
	else
		animate(src, pixel_z = pixel_z + 6, time = 1)
		animate(pixel_z = prev_pixel_z, transform = turn(transform, pick(-12, 0, 12)), time=2)
		animate(transform = prev_transform, time = 0)
		throw_at(A, 1, 1, src, spin = FALSE)

#undef FLIP_DIRECTION_CLOCKWISE
#undef FLIP_DIRECTION_ANTICLOCKWISE

/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(atom/A)
	if(!isliving(A))
		if(used_intent.type == INTENT_GRAB)
			var/obj/structure/AM = A
			if(istype(AM) && !AM.anchored)
				start_pulling(A) //add params to grab bodyparts based on loc
				return
		if(used_intent.type == INTENT_DISARM)
			var/obj/structure/AM = A
			if(istype(AM) && !AM.anchored)
				var/jadded = max(100-(STASTR*10),5)
				if(rogfat_add(jadded))
					visible_message(span_info("[src] pushes [AM]."))
					PushAM(AM, MOVE_FORCE_STRONG)
				else
					visible_message(span_warning("[src] pushes [AM]."))
				return
	A.attack_animal(src)

/atom/proc/attack_animal(mob/user)
	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ANIMAL, user)

/mob/living/RestrainedClickOn(atom/A)
	return

/*
	Monkeys
*/
/mob/living/carbon/monkey/UnarmedAttack(atom/A)
	A.attack_paw(src)

/atom/proc/attack_paw(mob/user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_PAW, user) & COMPONENT_NO_ATTACK_HAND)
		return TRUE
	return FALSE

/*
	Monkey RestrainedClickOn() was apparently the
	one and only use of all of the restrained click code
	(except to stop you from doing things while handcuffed);
	moving it here instead of various hand_p's has simplified
	things considerably
*/
/mob/living/carbon/monkey/RestrainedClickOn(atom/A)
	if(..())
		return
	if(used_intent.type != INTENT_HARM || !ismob(A))
		return
	if(is_muzzled())
		return
	var/mob/living/carbon/ML = A
	if(istype(ML))
		var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/obj/item/bodypart/affecting = null
		if(ishuman(ML))
			var/mob/living/carbon/human/H = ML
			affecting = H.get_bodypart(ran_zone(dam_zone))
		var/armor = ML.run_armor_check(affecting, "stab")
		if(prob(75))
			ML.apply_damage(rand(1,3), BRUTE, affecting, armor)
			ML.visible_message(span_danger("[name] bites [ML]!"), \
							span_danger("[name] bites you!"), span_hear("I hear a chomp!"), COMBAT_MESSAGE_RANGE, name)
			to_chat(name, span_danger("I bite [ML]!"))
			if(armor >= 2)
				return
		else
			ML.visible_message(span_danger("[src]'s bite misses [ML]!"), \
							span_danger("I avoid [src]'s bite!"), span_hear("I hear jaws snapping shut!"), COMBAT_MESSAGE_RANGE, src)
			to_chat(src, span_danger("My bite misses [ML]!"))

/*
	True Devil
*/

/mob/living/carbon/true_devil/UnarmedAttack(atom/A, proximity)
	A.attack_hand(src)

/*
	Brain
*/

/mob/living/brain/UnarmedAttack(atom/A)//Stops runtimes due to attack_animal being the default
	return

/*
	Simple animals
*/

/mob/living/simple_animal/UnarmedAttack(atom/A, proximity)
	if(!dextrous)
		return ..()
	if(!ismob(A))
		A.attack_hand(src)
		update_inv_hands()


/*
	Hostile animals
*/

/mob/living/simple_animal/hostile/UnarmedAttack(atom/A)
	target = A
	if(dextrous && !ismob(A))
		..()
	else
		AttackingTarget(A)



/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/dead/new_player/ClickOn()
	return
