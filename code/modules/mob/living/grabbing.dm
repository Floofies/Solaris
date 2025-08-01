///////////OFFHAND///////////////
/obj/item/grabbing
	name = "pulling"
	icon_state = "pulling"
	icon = 'icons/mob/roguehudgrabs.dmi'
	w_class = WEIGHT_CLASS_HUGE
	possible_item_intents = list(/datum/intent/grab/upgrade)
	item_flags = ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	grab_state = 0 //this is an atom/movable var i guess
	no_effect = TRUE
	force = 0
	experimental_inhand = FALSE
	var/grabbed				//ref to what atom we are grabbing
	var/obj/item/bodypart/limb_grabbed		//ref to actual bodypart being grabbed if we're grabbing a carbo
	var/sublimb_grabbed		//ref to what precise (sublimb) we are grabbing (if any) (text)
	var/mob/living/carbon/grabbee
	var/list/dependents = list()
	var/handaction
	var/bleed_suppressing = 0.5 //multiplier for how much we suppress bleeding, can accumulate so two grabs means 25% bleeding

/atom/movable //reference to all obj/item/grabbing
	var/list/grabbedby = list()

/turf
	var/list/grabbedby = list()

/obj/item/grabbing/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/item/grabbing/process()
	valid_check()

/obj/item/grabbing/proc/valid_check()
	// We require adjacency to count the grab as valid
	if(grabbee.Adjacent(grabbed))
		return TRUE
	grabbee.stop_pulling(FALSE)
	qdel(src)
	return FALSE

/obj/item/grabbing/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C != grabbee)
			qdel(src)
			return 1
		if(modifiers["right"])
			qdel(src)
			return 1
	return ..()

/obj/item/grabbing/proc/update_hands(mob/user)
	if(!user)
		return
	if(!iscarbon(user))
		return
	var/mob/living/carbon/C = user
	for(var/i in 1 to C.held_items.len)
		var/obj/item/I = C.get_item_for_held_index(i)
		if(I == src)
			if(i == 1)
				C.r_grab = src
			else
				C.l_grab = src

/datum/proc/grabdropped(obj/item/grabbing/G)
	if(G)
		for(var/datum/D in G.dependents)
			if(D == src)
				G.dependents -= D

/obj/item/grabbing/proc/relay_cancel_action()
	if(handaction)
		for(var/datum/D in dependents) //stop fapping
			if(handaction == D)
				D.grabdropped(src)
		handaction = null

/obj/item/grabbing/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(isobj(grabbed))
		var/obj/I = grabbed
		I.grabbedby -= src
	if(ismob(grabbed))
		var/mob/M = grabbed
		M.grabbedby -= src
	if(isturf(grabbed))
		var/turf/T = grabbed
		T.grabbedby -= src
	if(grabbee)
		if(grabbee.r_grab == src)
			grabbee.r_grab = null
		if(grabbee.l_grab == src)
			grabbee.l_grab = null
		if(grabbee.mouth == src)
			grabbee.mouth = null
	for(var/datum/D in dependents)
		D.grabdropped(src)
	return ..()

/obj/item/grabbing/dropped(mob/living/user, show_message = TRUE)
	SHOULD_CALL_PARENT(FALSE)
	// Dont stop the pull if another hand grabs the person
	if(user.r_grab == src)
		if(user.l_grab && user.l_grab.grabbed == user.r_grab.grabbed)
			qdel(src)
			return
	if(user.l_grab == src)
		if(user.r_grab && user.r_grab.grabbed == user.l_grab.grabbed)
			qdel(src)
			return
	if(grabbed == user.pulling)
		user.stop_pulling(FALSE)
	if(!user.pulling)
		user.stop_pulling(FALSE)
	for(var/mob/M in user.buckled_mobs)
		if(M == grabbed)
			user.unbuckle_mob(M, force = TRUE)
	if(QDELETED(src))
		return
	qdel(src)

/mob/living/carbon/human
	var/mob/living/carbon/human/hostagetaker //Stores the person that took us hostage in a var, allows us to force them to attack the mob and such
	var/mob/living/carbon/human/hostage //What hostage we have

/mob/living/carbon/human/proc/attackhostage()
	if(!istype(hostagetaker.get_active_held_item(), /obj/item/rogueweapon))
		return
	var/obj/item/rogueweapon/WP = hostagetaker.get_active_held_item()
	WP.attack(src, hostagetaker)
	hostagetaker.visible_message("<span class='danger'>\The [hostagetaker] attacks \the [src] reflexively!</span>")
	hostagetaker.hostage = null
	hostagetaker = null

/obj/item/grabbing/attack(mob/living/M, mob/living/user)
	if(M != grabbed)
		return FALSE
	if(!valid_check())
		return FALSE
	user.changeNext_move(CLICK_CD_MELEE * 2 - user.STASPD) // 24 - the user's speed
	var/skill_diff = 0
	var/combat_modifier = 1
	if(user.mind)
		skill_diff += (user.mind.get_skill_level(/datum/skill/combat/wrestling))
	if(M.mind)
		skill_diff -= (M.mind.get_skill_level(/datum/skill/combat/wrestling))

	if(M.surrendering)
		combat_modifier = 2

	if(M.restrained())
		combat_modifier += 0.25

	if(!(M.mobility_flags & MOBILITY_STAND) && user.mobility_flags & MOBILITY_STAND)
		combat_modifier += 0.05

	if(user.cmode && !M.cmode)
		combat_modifier += 0.3
	else if(!user.cmode && M.cmode)
		combat_modifier -= 0.3

	switch(user.used_intent.type)
		if(/datum/intent/grab/upgrade)
			if(!(M.status_flags & CANPUSH) || HAS_TRAIT(M, TRAIT_PUSHIMMUNE))
				to_chat(user, span_warning("Can't get a grip!"))
				return FALSE
			user.rogfat_add(rand(7,15))
			M.grippedby(user)
		if(/datum/intent/grab/choke)
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(iscarbon(M) && M != user)
					user.rogfat_add(rand(1,3))
					var/mob/living/carbon/C = M
					if(get_location_accessible(C, BODY_ZONE_PRECISE_NECK))
						if(prob(25))
							C.emote("choke")
						C.adjustOxyLoss(user.STASTR)
					C.visible_message(span_danger("[user] [pick("chokes", "strangles")] [C]!"), \
									span_userdanger("[user] [pick("chokes", "strangles")] me!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE, user)
					to_chat(user, span_danger("I [pick("choke", "strangle")] [C]!"))
		if(/datum/intent/grab/twist)
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(iscarbon(M))
					user.rogfat_add(rand(3,8))
					twistlimb(user)
		if(/datum/intent/grab/twistitem)
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(ismob(M))
					user.rogfat_add(rand(3,8))
					twistitemlimb(user)
		if(/datum/intent/grab/remove)
			user.rogfat_add(rand(3,13))
			if(isitem(sublimb_grabbed))
				removeembeddeditem(user)
			else
				user.stop_pulling()
		if(/datum/intent/grab/shove)
			if(!(user.mobility_flags & MOBILITY_STAND))
				to_chat(user, span_warning("I must stand.."))
				return
			if(!(M.mobility_flags & MOBILITY_STAND))
				if(user.loc != M.loc)
					to_chat(user, span_warning("I must be above them."))
					return
				var/stun_dur = max(((65 + (skill_diff * 10) + (user.STASTR * 5) - (M.STASTR * 5)) * combat_modifier), 20)
				var/pincount = 0
				user.rogfat_add(rand(1,3))
				while(M == grabbed && !(M.mobility_flags & MOBILITY_STAND))
					if(M.IsStun())
						if(!do_after(user, stun_dur + 1, needhand = 0, target = M))
							pincount = 0
							break
						M.Stun(stun_dur - pincount * 2)	
						M.Immobilize(stun_dur)	//Made immobile for the whole do_after duration, though
						user.rogfat_add(rand(1,3) + abs(skill_diff) + stun_dur / 1.5)
						M.visible_message(span_danger("[user] keeps [M] pinned to the ground!"))
						pincount += 2
					else
						M.Stun(stun_dur - 10)
						M.Immobilize(stun_dur)
						user.rogfat_add(rand(1,3) + abs(skill_diff) + stun_dur / 1.5)
						pincount += 2
						M.visible_message(span_danger("[user] pins [M] to the ground!"), \
							span_userdanger("[user] pins me to the ground!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE)
			else
				user.rogfat_add(rand(5,15))
				if(prob(clamp((((4 + (((user.STASTR - M.STASTR)/2) + skill_diff)) * 10 + rand(-5, 5)) * combat_modifier), 5, 95)))
					M.visible_message(span_danger("[user] shoves [M] to the ground!"), \
									span_userdanger("[user] shoves me to the ground!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE)
					M.Knockdown(max(10 + (skill_diff * 2), 1))
				else
					M.visible_message(span_warning("[user] tries to shove [M]!"), \
									span_danger("[user] tries to shove me!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE)

/obj/item/grabbing/proc/twistlimb(mob/living/user) //implies limb_grabbed and sublimb are things
	var/mob/living/carbon/C = grabbed
	var/armor_block = C.run_armor_check(limb_grabbed, "slash")
	var/damage = user.get_punch_dmg()
	playsound(C.loc, "genblunt", 100, FALSE, -1)
	C.next_attack_msg.Cut()
	C.apply_damage(damage, BRUTE, limb_grabbed, armor_block)
	limb_grabbed.bodypart_attacked_by(BCLASS_TWIST, damage, user, sublimb_grabbed, crit_message = TRUE)
	C.visible_message(span_danger("[user] twists [C]'s [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]"), \
					span_userdanger("[user] twists my [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_warning("I twist [C]'s [parse_zone(sublimb_grabbed)].[C.next_attack_msg.Join()]"))
	C.next_attack_msg.Cut()
	log_combat(user, C, "limbtwisted [sublimb_grabbed] ")
	if(limb_grabbed.status == BODYPART_ROBOTIC && armor_block == 0) //Twisting off prosthetics.
		C.visible_message(span_danger("[C]'s prosthetic [parse_zone(sublimb_grabbed)] twists off![C.next_attack_msg.Join()]"), \
					span_userdanger("My prosthetic [parse_zone(sublimb_grabbed)] was twisted off of me![C.next_attack_msg.Join()]"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("I twisted [C]'s prosthetic [parse_zone(sublimb_grabbed)] off.[C.next_attack_msg.Join()]"))
		limb_grabbed.drop_limb(TRUE)

/obj/item/grabbing/proc/twistitemlimb(mob/living/user) //implies limb_grabbed and sublimb are things
	var/mob/living/M = grabbed
	var/damage = rand(5,10)
	var/obj/item/I = sublimb_grabbed
	playsound(M.loc, "genblunt", 100, FALSE, -1)
	M.apply_damage(damage, BRUTE, limb_grabbed)
	M.visible_message(span_danger("[user] twists [I] in [M]'s wound!"), \
					span_userdanger("[user] twists [I] in my wound!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE)
	log_combat(user, M, "itemtwisted [sublimb_grabbed] ")

/obj/item/grabbing/proc/removeembeddeditem(mob/living/user) //implies limb_grabbed and sublimb are things
	var/mob/living/M = grabbed
	var/obj/item/bodypart/L = limb_grabbed
	playsound(M.loc, "genblunt", 100, FALSE, -1)
	log_combat(user, M, "itemremovedgrab [sublimb_grabbed] ")
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/obj/item/I = locate(sublimb_grabbed) in L.embedded_objects
		if(QDELETED(I) || QDELETED(L) || !L.remove_embedded_object(I))
			return FALSE
		L.receive_damage(I.embedding.embedded_unsafe_removal_pain_multiplier*I.w_class) //It hurts to rip it out, get surgery you dingus.
		user.dropItemToGround(src) // this will unset vars like limb_grabbed
		user.put_in_hands(I)
		C.emote("paincrit", TRUE)
		playsound(C, 'sound/foley/flesh_rem.ogg', 100, TRUE, -2)
		if(usr == src)
			user.visible_message(span_notice("[user] rips [I] out of [user.p_their()] [L.name]!"), span_notice("I rip [I] from my [L.name]."))
		else
			user.visible_message(span_notice("[user] rips [I] out of [C]'s [L.name]!"), span_notice("I rip [I] from [C]'s [L.name]."))
	else if(HAS_TRAIT(M, TRAIT_SIMPLE_WOUNDS))
		var/obj/item/I = locate(sublimb_grabbed) in M.simple_embedded_objects
		if(QDELETED(I) || !M.simple_remove_embedded_object(I))
			return FALSE
		M.apply_damage(I.embedding.embedded_unsafe_removal_pain_multiplier*I.w_class, BRUTE) //It hurts to rip it out, get surgery you dingus.
		user.dropItemToGround(src) // this will unset vars like limb_grabbed
		user.put_in_hands(I)
		M.emote("paincrit", TRUE)
		playsound(M, 'sound/foley/flesh_rem.ogg', 100, TRUE, -2)
		if(user == M)
			user.visible_message(span_notice("[user] rips [I] out of [user.p_them()]self!"), span_notice("I remove [I] from myself."))
		else
			user.visible_message(span_notice("[user] rips [I] out of [M]!"), span_notice("I rip [I] from [src]."))
	user.update_grab_intents(grabbed)
	return TRUE

/obj/item/grabbing/attack_turf(turf/T, mob/living/user)
	if(!valid_check())
		return
	user.changeNext_move(CLICK_CD_MELEE)
	switch(user.used_intent.type)
		if(/datum/intent/grab/move)
			if(isturf(T))
				user.Move_Pulled(T)
		if(/datum/intent/grab/smash)
			if(!(user.mobility_flags & MOBILITY_STAND))
				to_chat(user, span_warning("I must stand.."))
				return
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(isopenturf(T))
					if(iscarbon(grabbed))
						var/mob/living/carbon/C = grabbed
						if(!C.Adjacent(T))
							return FALSE
						if(C.mobility_flags & MOBILITY_STAND)
							return
						playsound(C.loc, T.attacked_sound, 100, FALSE, -1)
						smashlimb(T, user)
				else if(isclosedturf(T))
					if(iscarbon(grabbed))
						var/mob/living/carbon/C = grabbed
						if(!C.Adjacent(T))
							return FALSE
						if(!(C.mobility_flags & MOBILITY_STAND))
							return
						playsound(C.loc, T.attacked_sound, 100, FALSE, -1)
						smashlimb(T, user)

/obj/item/grabbing/attack_obj(obj/O, mob/living/user)
	if(!valid_check())
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(user.used_intent.type == /datum/intent/grab/smash)
		if(isstructure(O) && O.blade_dulling != DULLING_CUT)
			if(!(user.mobility_flags & MOBILITY_STAND))
				to_chat(user, span_warning("I must stand.."))
				return
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(iscarbon(grabbed))
					var/mob/living/carbon/C = grabbed
					if(!C.Adjacent(O))
						return FALSE
					playsound(C.loc, O.attacked_sound, 100, FALSE, -1)
					smashlimb(O, user)


/obj/item/grabbing/proc/smashlimb(atom/A, mob/living/user) //implies limb_grabbed and sublimb are things
	var/mob/living/carbon/C = grabbed
	var/armor_block = C.run_armor_check(limb_grabbed, d_type)
	var/damage = user.get_punch_dmg()
	C.next_attack_msg.Cut()
	if(C.apply_damage(damage, BRUTE, limb_grabbed, armor_block))
		limb_grabbed.bodypart_attacked_by(BCLASS_BLUNT, damage, user, sublimb_grabbed, crit_message = TRUE)
		playsound(C.loc, "smashlimb", 100, FALSE, -1)
	else
		C.next_attack_msg += " <span class='warning'>Armor stops the damage.</span>"
	C.visible_message(span_danger("[user] smashes [C]'s [limb_grabbed] into [A]![C.next_attack_msg.Join()]"), \
					span_userdanger("[user] smashes my [limb_grabbed] into [A]![C.next_attack_msg.Join()]"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_warning("I smash [C]'s [limb_grabbed] against [A].[C.next_attack_msg.Join()]"))
	C.next_attack_msg.Cut()
	log_combat(user, C, "limbsmashed [limb_grabbed] ")

/datum/intent/grab
	unarmed = TRUE
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	canparry = FALSE
	no_attack = TRUE
	misscost = 2
	releasedrain = 2

/datum/intent/grab/move
	name = "grab move"
	desc = ""
	icon_state = "inmove"

/datum/intent/grab/upgrade
	name = "upgrade grab"
	desc = ""
	icon_state = "ingrab"

/datum/intent/grab/smash
	name = "smash"
	desc = ""
	icon_state = "insmash"

/datum/intent/grab/twist
	name = "twist"
	desc = ""
	icon_state = "intwist"

/datum/intent/grab/choke
	name = "choke"
	desc = ""
	icon_state = "inchoke"

/datum/intent/grab/shove
	name = "shove"
	desc = ""
	icon_state = "intackle"

/datum/intent/grab/twistitem
	name = "twist in wound"
	desc = ""
	icon_state = "intwist"

/datum/intent/grab/remove
	name = "remove"
	desc = ""
	icon_state = "intake"


/obj/item/grabbing/bite
	name = "bite"
	icon_state = "bite"
	slot_flags = ITEM_SLOT_MOUTH
	bleed_suppressing = 1
	var/last_drink
	var/last_stealth_bite

/obj/item/grabbing/bite/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(!valid_check())
		return
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C != grabbee || C.incapacitated() || C.stat == DEAD)
			qdel(src)
			return 1
		if(modifiers["right"])
			qdel(src)
			return 1
		var/_y = text2num(params2list(params)["icon-y"])
		if(_y>=17)
			bitelimb(C)
		else
			drinklimb(C)
	return 1

///Chewing after bite
/obj/item/grabbing/bite/proc/bitelimb(mob/living/carbon/human/user) //implies limb_grabbed and sublimb are things
	if(!user.Adjacent(grabbed))
		qdel(src)
		return
	if(world.time <= user.next_move)
		return
	/*if(!user.can_bite()) // If this is enabled, check can_bite or else won't be able to chew after biting
		to_chat(user, span_warning("My mouth has something in it."))
		return FALSE*/

	user.changeNext_move(CLICK_CD_MELEE)
	var/mob/living/carbon/C = grabbed
	var/armor_block = C.run_armor_check(sublimb_grabbed, d_type)
	var/damage = user.get_punch_dmg()
	if(HAS_TRAIT(user, TRAIT_STRONGBITE))
		damage = damage*2
	C.next_attack_msg.Cut()
	//leaving out silent biting, but if we wanted, it would be here
	if(C.apply_damage(damage, BRUTE, limb_grabbed, armor_block))
		playsound(C.loc, "smallslash", 100, FALSE, -1)
		var/datum/wound/caused_wound = limb_grabbed.bodypart_attacked_by(BCLASS_BITE, damage, user, sublimb_grabbed, crit_message = TRUE)
		if(user.mind && caused_wound)
			/*
				WEREWOLF CHEW.
			*/
			if(istype(user.dna.species, /datum/species/werewolf))
				caused_wound?.werewolf_infect_attempt()
				if(prob(30))
					user.werewolf_feed(C)

			/*
				ZOMBIE CHEW. ZOMBIFICATION
			*/
			var/datum/antagonist/zombie/zombie_antag = user.mind.has_antag_datum(/datum/antagonist/zombie)
			if(zombie_antag && zombie_antag.has_turned)
				var/datum/antagonist/zombie/existing_zombie = C.mind?.has_antag_datum(/datum/antagonist/zombie) //If the bite target is a zombie
				if(!existing_zombie && caused_wound?.zombie_infect_attempt())   // infect_attempt on wound
					to_chat(user, span_danger("You feel your gift trickling into [C]'s wound...")) //message to the zombie they infected the target
/*
	Code below is for a zombie smashing the brains of unit. The code expects the brain to be part of the head which is not the case with AP. Kept for posterity in case it's used in an overhaul.
*/
/*			if(user.mind.has_antag_datum(/datum/antagonist/zombie))
				var/mob/living/carbon/human/H = C
				if(istype(H))
					INVOKE_ASYNC(H, TYPE_PROC_REF(/mob/living/carbon/human, zombie_infect_attempt))
				if(C.stat)
					if(istype(limb_grabbed, /obj/item/bodypart/head))
						var/obj/item/bodypart/head/HE = limb_grabbed
						if(HE.brain)
							QDEL_NULL(HE.brain)
							C.visible_message("<span class='danger'>[user] consumes [C]'s brain!</span>", \
								"<span class='userdanger'>[user] consumes my brain!</span>", "<span class='hear'>I hear a sickening sound of chewing!</span>", COMBAT_MESSAGE_RANGE, user)
							to_chat(user, "<span class='boldnotice'>Braaaaaains!</span>")
							if(!user.mob_timers["zombie_tri"])
								user.mob_timers["zombie_tri"] = world.time
							playsound(C.loc, 'sound/combat/fracture/headcrush (2).ogg', 100, FALSE, -1)
							return*/
	else
		C.next_attack_msg += " <span class='warning'>Armor stops the damage.</span>"
	C.visible_message(span_danger("[user] bites [C]'s [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]"), \
					span_userdanger("[user] bites my [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]"), span_hear("I hear a sickening sound of chewing!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("I bite [C]'s [parse_zone(sublimb_grabbed)].[C.next_attack_msg.Join()]"))
	C.next_attack_msg.Cut()
	log_combat(user, C, "limb chewed [sublimb_grabbed] ")

//this is for carbon mobs being drink only
/obj/item/grabbing/bite/proc/drinklimb(mob/living/user) //implies limb_grabbed and sublimb are things
	if(!user.Adjacent(grabbed))
		qdel(src)
		return
	if(world.time <= user.next_move)
		return
	if(world.time < last_drink + 2 SECONDS)
		return
	if(!limb_grabbed.get_bleed_rate())
		to_chat(user, span_warning("Sigh. It's not bleeding."))
		return
	var/mob/living/carbon/C = grabbed
	if(C.dna?.species && (NOBLOOD in C.dna.species.species_traits))
		to_chat(user, span_warning("Sigh. No blood."))
		return
	if(C.blood_volume <= 0)
		to_chat(user, span_warning("Sigh. No blood."))
		return
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(istype(H.wear_neck, /obj/item/clothing/neck/roguetown/psicross/silver) || HAS_TRAIT(H, TRAIT_SILVER_BLESSED))
			to_chat(user, span_userdanger("SILVER! HISSS!!!"))
			return
	last_drink = world.time
	user.changeNext_move(CLICK_CD_MELEE)

	if(user.mind && C.mind)
		var/datum/antagonist/vampirelord/VDrinker = user.mind.has_antag_datum(/datum/antagonist/vampirelord)
		var/datum/antagonist/vampirelord/VVictim = C.mind.has_antag_datum(/datum/antagonist/vampirelord)
		
		var/zomwerewolf = C.mind.has_antag_datum(/datum/antagonist/werewolf)
		if(!zomwerewolf)
			if(C.stat != DEAD)
				zomwerewolf = C.mind.has_antag_datum(/datum/antagonist/zombie)
		if(VDrinker)
			if(zomwerewolf|| HAS_TRAIT(VVictim,TRAIT_VAMPIRISM))
				to_chat(user, span_danger("I'm going to puke..."))
				addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living/carbon, vomit), 0, TRUE), rand(8 SECONDS, 15 SECONDS))
			else
				if(VVictim)
					to_chat(user, span_warning("It's vitae, just like mine."))
				else if (C.vitae_pool > 500)
					C.blood_volume = max(C.blood_volume-45, 0)
					C.vitae_pool -= 500
					if(ishuman(C))
						var/mob/living/carbon/human/H = C
						if(H.virginity)
							to_chat(user, "<span class='love'>Virgin blood, delicious!</span>")
							if(VDrinker.isspawn)
								VDrinker.handle_vitae(750, 750)
							else
								VDrinker.handle_vitae(750)
					if(VDrinker.isspawn)
						VDrinker.handle_vitae(500, 500)
					else
						VDrinker.handle_vitae(500)
				else
					to_chat(user, span_warning("No more vitae from this blood..."))
		else
/*			if(VVictim)
				to_chat(user, "<span class='notice'>A strange, sweet taste tickles my throat.</span>")
				addtimer(CALLBACK(user, .mob/living/carbon/human/proc/vampire_infect), 1 MINUTES) // I'll use this for succession later.
			else */
			
			if(HAS_TRAIT(user,TRAIT_VAMPIRISM))

			else
				to_chat(user, "<span class='warning'>I'm going to puke...</span>")
				addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living/carbon, vomit), 0, TRUE), rand(8 SECONDS, 15 SECONDS))
	else
		if(user.mind)
			if(user.mind.has_antag_datum(/datum/antagonist/vampirelord))
				var/datum/antagonist/vampirelord/VDrinker = user.mind.has_antag_datum(/datum/antagonist/vampirelord)
				C.blood_volume = max(C.blood_volume-45, 0)
				if(VDrinker.isspawn)
					VDrinker.handle_vitae(300, 300)
				else
					VDrinker.handle_vitae(300)
	if(ishuman(C) && ishuman(user))
		var/mob/living/carbon/human/BSDrinker = user
		var/mob/living/carbon/human/BSVictim = C
		var/zomwerewolf = C.mind?.has_antag_datum(/datum/antagonist/werewolf)
		if(HAS_TRAIT(BSDrinker,TRAIT_VAMPIRISM))
			if(zomwerewolf)
				to_chat(BSDrinker, span_danger("I'm going to puke..."))
				addtimer(CALLBACK(BSDrinker, TYPE_PROC_REF(/mob/living/carbon, vomit), 0, TRUE), rand(8 SECONDS, 15 SECONDS))
			else
				if(HAS_TRAIT(BSVictim,TRAIT_VAMPIRISM))
					//you can transfer vitae, but not grow in power
					to_chat(BSDrinker, span_warning("It's vitae, just like mine."))
					BSVictim.vitae -= 200
					BSDrinker.vitae += 200
				if ((BSVictim.vitae_pool > 200) && (!HAS_TRAIT(BSVictim,TRAIT_VAMPIRISM)))
					BSVictim.blood_volume = max(BSVictim.blood_volume-45, 0)
					BSVictim.vitae_pool -= 200
					if(ishuman(BSVictim))
						if(BSVictim.virginity && (HAS_TRAIT(BSDrinker,TRAIT_EFFICIENT_DRINKER)))
							to_chat(BSDrinker, "<span class='love'>Virgin blood, delicious!</span>")
							to_chat(BSDrinker, span_warning("I feel my power grow greatly"))
							BSDrinker.vitae += 600
							BSDrinker.bs_vitae_total += 600
							BSDrinker.mind.add_sleep_experience(/datum/skill/magic/vampirism, 12)
							BSDrinker.mind.add_sleep_experience(/datum/skill/magic/blood, 7)
						else if(HAS_TRAIT(BSDrinker,TRAIT_EFFICIENT_DRINKER)) //Extra for an efficient drinker
							to_chat(BSDrinker, span_warning("I feel my power grow greatly"))
							BSDrinker.vitae += 400
							BSDrinker.bs_vitae_total += 400
							BSDrinker.mind.add_sleep_experience(/datum/skill/magic/vampirism, 10)
							BSDrinker.mind.add_sleep_experience(/datum/skill/magic/blood, 5)
						else if(BSVictim.virginity)
							to_chat(BSDrinker, "<span class='love'>Virgin blood, delicious!</span>")
							to_chat(BSDrinker, span_warning("I feel my power grow greatly"))
							BSDrinker.vitae += 350
							BSDrinker.bs_vitae_total += 350
							BSDrinker.mind.add_sleep_experience(/datum/skill/magic/vampirism, 7)
							BSDrinker.mind.add_sleep_experience(/datum/skill/magic/blood, 3)
						else
							to_chat(BSDrinker, span_warning("I feel my power grow"))
							BSDrinker.vitae += 200
							BSDrinker.bs_vitae_total += 200
							BSDrinker.mind.add_sleep_experience(/datum/skill/magic/vampirism, 5)
							BSDrinker.mind.add_sleep_experience(/datum/skill/magic/blood, 2)
					else
						to_chat(BSDrinker, span_warning("I feel my power grow"))
						BSDrinker.vitae += 200
						BSDrinker.bs_vitae_total += 200
						BSDrinker.mind.add_sleep_experience(/datum/skill/magic/vampirism, 5)
						BSDrinker.mind.add_sleep_experience(/datum/skill/magic/blood, 2)

				else
					//you gain vitae but not to level up
					to_chat(BSDrinker, span_warning("I no longer gain power from this blood..."))
					BSVictim.blood_volume = max(C.blood_volume-45, 0)
					BSDrinker.vitae += 200

	C.blood_volume = max(C.blood_volume-15, 0)
	C.handle_blood()

	playsound(user.loc, 'sound/misc/drink_blood.ogg', 100, FALSE, -4)

	C.visible_message(span_danger("[user] drinks from [C]'s [parse_zone(sublimb_grabbed)]!"), \
					span_userdanger("[user] drinks from my [parse_zone(sublimb_grabbed)]!"), span_hear("..."), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_warning("I drink from [C]'s [parse_zone(sublimb_grabbed)]."))
	log_combat(user, C, "drank blood from ")

	if(ishuman(C) && C.mind && (!HAS_TRAIT(user,TRAIT_VAMPIRISM)))
		var/datum/antagonist/vampirelord/VDrinker = user.mind.has_antag_datum(/datum/antagonist/vampirelord)
		if(!VDrinker.isspawn || !HAS_TRAIT(C,TRAIT_VAMPIRISM))
			switch(alert("Would you like to sire a new spawn?",,"Yes","No"))
				if("Yes")
					user.visible_message("[user] begins to infuse dark magic into [C]")
					if(do_after(user, 30))
						C.visible_message("[C] rises as a new spawn!")
						var/datum/antagonist/vampirelord/lesser/new_antag = new /datum/antagonist/vampirelord/lesser()
						new_antag.sired = TRUE
						C.mind.add_antag_datum(new_antag)
						sleep(20)
						C.fully_heal()
				if("No")
					to_chat(user, span_warning("I decide [C] is unworthy."))
	if(ishuman(C) && C.mind && (HAS_TRAIT(user,TRAIT_VAMPIRISM)))
		var/mob/living/carbon/human/BSDrinker = user
		var/mob/living/carbon/human/BSVictim = C	
		if(BSVictim.blood_volume <= BLOOD_VOLUME_SURVIVE)				
			if (!HAS_TRAIT(BSVictim,TRAIT_VAMPIRISM) && HAS_TRAIT(BSVictim,TRAIT_BLOOD_THRALL) )
				switch(alert("Would you like to sire a bloodsucker?",,"Yes","No"))
					if("Yes")
						BSDrinker.visible_message("[BSDrinker] begins to infuse dark magic into [BSVictim]")
						if(do_after(BSDrinker, 30))
							BSVictim.visible_message("[BSVictim] rises as a new spawn!")
							var/datum/antagonist/bloodsucker/lesser/new_antag = new /datum/antagonist/bloodsucker/lesser()
							new_antag.sired = TRUE
							BSVictim.mind.add_antag_datum(new_antag)
							sleep(20)
							BSVictim.fully_heal()
					if("No")
						to_chat(BSDrinker, span_warning("I decide [BSVictim] is unworthy."))
