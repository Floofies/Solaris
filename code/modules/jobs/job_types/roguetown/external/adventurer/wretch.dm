/datum/job/roguetown/wretch
	title = "Wretch"
	flag = WRETCH
	department_flag = PEASANTS
	selection_color = JCOLOR_PEASANT
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	allowed_races = RACES_ALL_KINDS
	tutorial = "You live on the fringes of society. By concequence, coincidence or damnation you live with a bounty on your head and wanted by the town."
	outfit = null
	outfit_female = null
	display_order = JDO_WRETCH
	show_in_credits = FALSE
	min_pq = 20
	max_pq = null

	advclass_cat_rolls = list(CTAG_WRETCH = 20)
	PQ_boost_divider = 10
	round_contrib_points = 2

	announce_latejoin = FALSE
	wanderer_examine = TRUE
	advjob_examine = TRUE
	always_show_on_latechoices = TRUE
	job_reopens_slots_on_death = TRUE
	same_job_respawn_delay = 1 MINUTES

/datum/job/roguetown/wretch/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L)
		var/mob/living/carbon/human/H = L
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")

		if(GLOB.adventurer_hugbox_duration)
			addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, adv_hugboxing_start)), 1)

/datum/advclass/wretch/deserter
	name = "Deserter"
	tutorial = "You were once a venerated and revered knight - now, a traitor who abandoned your liege. You live the life of an outlaw, shunned and looked down upon by society."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/deserter
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_OUTLANDER, TRAIT_HEAVYARMOR, TRAIT_OUTLAW)

/datum/outfit/job/roguetown/wretch/deserter/pre_equip(mob/living/carbon/human/H)
	H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/axes, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	var/weapons = list("Estoc","Mace + Shield","Flail + Shield","Lucerne","Battle Axe")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Estoc")
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
			r_hand = /obj/item/rogueweapon/estoc
			backr = /obj/item/gwstrap
		if("Mace + Shield")
			H.mind.adjust_skillrank(/datum/skill/combat/maces, 1, TRUE)
			beltr = /obj/item/rogueweapon/mace/steel
			backr = /obj/item/rogueweapon/shield/tower/metal
		if("Flail + Shield")
			H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 1, TRUE)
			beltr = /obj/item/rogueweapon/flail/sflail
			backr = /obj/item/rogueweapon/shield/tower/metal
		if("Lucerne")
			H.mind.adjust_skillrank(/datum/skill/combat/polearms, 1, TRUE)
			r_hand = /obj/item/rogueweapon/eaglebeak/lucerne
			backr = /obj/item/gwstrap
		if("Battle Axe")
			H.mind.adjust_skillrank(/datum/skill/combat/axes, 1, TRUE)
			backr = /obj/item/rogueweapon/stoneaxe/battle
	H.change_stat("strength", 2)
	H.change_stat("constitution", 2)
	H.change_stat("endurance", 1)
	head = /obj/item/clothing/head/roguetown/helmet/sallet/visored
	gloves = /obj/item/clothing/gloves/roguetown/chain
	pants = /obj/item/clothing/under/roguetown/chainlegs
	neck = /obj/item/clothing/neck/roguetown/bevor
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	armor = /obj/item/clothing/suit/roguetown/armor/brigandine/coatplates
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	backl = /obj/item/storage/backpack/rogue/satchel //gwstraps landing on backr asyncs with backpack_contents
	backpack_contents = list(/obj/item/rogueweapon/huntingknife = 1, /obj/item/flashlight/flare/torch/lantern/prelit = 1)
	GLOB.outlawed_players += H.real_name
	var/my_crime = input(H, "What is your crime?", "Crime") as text|null
	if (!my_crime)
		my_crime = "crimes against the Crown"
	var/bounty_total
	bounty_total = rand(151, 250)
	add_bounty(H.real_name, bounty_total, FALSE, my_crime, "The Justiciary of Rasura")


/datum/advclass/wretch/outlaw
	name = "Outlaw"
	tutorial = "You're a seasoned criminal known for your heinous acts, your face plastered on wanted posters across the region. A life of theft, robbery, and ill-gotten-gains comes naturally to you."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/outlaw
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_OUTLANDER, TRAIT_MEDIUMARMOR, TRAIT_DODGEEXPERT, TRAIT_OUTLAW)


/datum/outfit/job/roguetown/wretch/outlaw/pre_equip(mob/living/carbon/human/H)
	head = /obj/item/clothing/head/roguetown/helmet/kettle
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	cloak = /obj/item/clothing/cloak/raincloak/mortus
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	neck = /obj/item/clothing/neck/roguetown/gorget
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	mask = /obj/item/clothing/mask/rogue/ragmask/black
	beltr = /obj/item/quiver/bolts
	backpack_contents = list(/obj/item/storage/belt/rogue/pouch/coins/poor = 1, /obj/item/lockpickring/mundane = 1, /obj/item/flashlight/flare/torch/lantern/prelit = 1)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 6, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/stealing, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/lockpicking, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/traps, 5, TRUE)
	H.cmode_music = 'sound/music/combat_vaquero.ogg'
	var/weapons = list("Rapier","Dagger", "Whip")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Rapier")
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
			beltl = /obj/item/rogueweapon/sword/rapier
		if("Dagger")
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
			beltl = /obj/item/rogueweapon/huntingknife/idagger/silver/elvish
		if ("Whip")
			H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 1, TRUE)
			beltl = /obj/item/rogueweapon/whip
	H.change_stat("strength", -1)
	H.change_stat("constitution", 1)
	H.change_stat("endurance", 2)
	H.change_stat("speed", 3)
	GLOB.outlawed_players += H.real_name
	var/my_crime = input(H, "What is your crime?", "Crime") as text|null
	if (!my_crime)
		my_crime = "crimes against the Crown"
	var/bounty_total
	bounty_total = rand(151, 250)
	add_bounty(H.real_name, bounty_total, FALSE, my_crime, "The Justiciary of Rasura")

/datum/advclass/wretch/poacher
	name = "Poacher"
	tutorial = "You have rejected society and its laws, choosing life in the wilderness instead. Simple thieving highwayman or freedom fighter, you take from those who have and give to the have-nots. Fancy, how the latter includes yourself!"
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/poacher
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_OUTLANDER, TRAIT_DODGEEXPERT, TRAIT_OUTLAW, TRAIT_WOODSMAN, TRAIT_OUTDOORSMAN)


/datum/outfit/job/roguetown/wretch/poacher/pre_equip(mob/living/carbon/human/H)
	head = /obj/item/clothing/head/roguetown/roguehood/darkgreen
	mask = /obj/item/clothing/mask/rogue/wildguard
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/darkgreen
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	beltl = /obj/item/quiver/arrows
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	backpack_contents = list(/obj/item/bait = 1, /obj/item/rogueweapon/huntingknife = 1, /obj/item/storage/belt/rogue/pouch/coins/poor = 1, /obj/item/flashlight/flare/torch/lantern/prelit = 1)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/bows, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/axes, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/stealing, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/traps, 4, TRUE)
	//these people live in the forest so let's give them some peasant skills
	H.mind.adjust_skillrank(/datum/skill/craft/crafting, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/tanning, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/labor/butchering, 1, TRUE)
	H.cmode_music = 'sound/music/combat_poacher.ogg'
	var/weapons = list("Dagger","Axe", "Cudgel", "My Bow Is Enough")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Dagger")
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
			beltr = /obj/item/rogueweapon/huntingknife/idagger/steel
		if("Axe")
			H.mind.adjust_skillrank(/datum/skill/combat/axes, 2, TRUE)
			beltr = /obj/item/rogueweapon/stoneaxe/woodcut
		if ("Cudgel")
			H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
			beltr = /obj/item/rogueweapon/mace/cudgel
		if ("My Bow Is Enough")
			H.mind.adjust_skillrank(/datum/skill/combat/bows, 1, TRUE)
			head = /obj/item/clothing/head/roguetown/duelhat
	H.change_stat("endurance", 1)
	H.change_stat("perception", 2)
	H.change_stat("speed", 2)
	GLOB.outlawed_players += H.real_name
	var/my_crime = input(H, "What is your crime?", "Crime") as text|null
	if (!my_crime)
		my_crime = "crimes against the Crown"
	var/bounty_total
	bounty_total = rand(151, 250)
	add_bounty(H.real_name, bounty_total, FALSE, my_crime, "The Justiciary of Rasura")

/datum/advclass/wretch/necromancer
	name = "Necromancer"
	tutorial = "You have been ostracized and hunted by society for your dark magics and perversion of life."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/necromancer
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_OUTLANDER, TRAIT_ZOMBIE_IMMUNE, TRAIT_MAGEARMOR, TRAIT_GRAVEROBBER, TRAIT_OUTLAW, TRAIT_ARCANE_T3, TRAIT_MAGIC_TUTOR)

/datum/outfit/job/roguetown/wretch/necromancer/pre_equip(mob/living/carbon/human/H)
	H.mind.current.faction += "[H.mind.name]_[H.ckey]_faction"
	head = /obj/item/clothing/head/roguetown/roguehood/black
	shoes = /obj/item/clothing/shoes/roguetown/boots
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/black
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/reagent_containers/glass/bottle/rogue/manapot
	neck = /obj/item/clothing/neck/roguetown/gorget
	beltl = /obj/item/rogueweapon/huntingknife
	backl = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff/ruby
	backpack_contents = list(/obj/item/spellbook_unfinished/pre_arcane = 1, /obj/item/roguegem/amethyst = 1, /obj/item/roguekey/underking = 1, /obj/item/storage/belt/rogue/pouch/coins/poor = 1, /obj/item/flashlight/flare/torch/lantern/prelit = 1)
	H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/alchemy, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/magic/arcane, 4, TRUE)
	H.cmode_music = 'sound/music/combat_cult.ogg'
	if(H.age == AGE_OLD)
		H.mind.adjust_skillrank(/datum/skill/magic/arcane, 1, TRUE)
	H.change_stat("intelligence", 4)
	H.change_stat("endurance", 1)
	H.change_stat("speed", 1)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/prestidigitation)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/eyebite)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/bonechill)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/minion_order)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/raise_lesser_undead/necromancer)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/gravemark)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/nondetection)
	H.mind.adjust_spellpoints(18)
	GLOB.excommunicated_players += H.real_name
	var/my_crime = input(H, "What is your crime?", "Crime") as text|null
	if (!my_crime)
		my_crime = "crimes against the Crown"
	var/bounty_total
	bounty_total = rand(151, 250)
	add_bounty(H.real_name, bounty_total, FALSE, my_crime, "The Chapel Of Lights")


/datum/advclass/wretch/berserker
	name = "Berserker"
	tutorial = "You are a warrior feared for your brutality, dedicated to using your might for your own gain. Might equals right, and you are the reminder of such a saying."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/berserker
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_OUTLANDER, TRAIT_STRONGBITE, TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN, TRAIT_OUTLAW)


/datum/outfit/job/roguetown/wretch/berserker/pre_equip(mob/living/carbon/human/H)
	head = /obj/item/clothing/head/roguetown/helmet/kettle
	mask = /obj/item/clothing/mask/rogue/wildguard
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	gloves = /obj/item/clothing/gloves/roguetown/plate
	backr = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather
	neck = /obj/item/clothing/neck/roguetown/leather
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	backpack_contents = list(/obj/item/rogueweapon/huntingknife = 1, /obj/item/flashlight/flare/torch/lantern/prelit = 1, /obj/item/storage/belt/rogue/pouch/coins/poor = 1)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/axes, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/tanning, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/labor/butchering, 1, TRUE)
	H.cmode_music = 'sound/music/combat_berserker.ogg'
	var/weapons = list("Katar","Steel Knuckles","MY BARE HANDS!!!","Battle Axe","Mace","Sword")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if ("Katar")
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			beltr = /obj/item/rogueweapon/katar
		if ("Steel Knuckles")
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			beltr = /obj/item/rogueweapon/knuckles
		if ("MY BARE HANDS!!!")
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			ADD_TRAIT(H, TRAIT_CIVILIZEDBARBARIAN, TRAIT_GENERIC)
		if ("Battle Axe")
			H.mind.adjust_skillrank(/datum/skill/combat/axes, 1, TRUE)
			beltr = /obj/item/rogueweapon/stoneaxe/battle
		if ("Mace")
			H.mind.adjust_skillrank(/datum/skill/combat/maces, 1, TRUE)
			beltr = /obj/item/rogueweapon/mace/goden/steel
		if ("Sword")
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
			beltr = /obj/item/rogueweapon/sword/falx
	H.change_stat("strength", 3)
	H.change_stat("endurance", 1)
	H.change_stat("constitution", 2)
	H.change_stat("intelligence", -3)
	H.change_stat("perception", -1)
	H.change_stat("speed", 1)
	GLOB.outlawed_players += H.real_name
	var/my_crime = input(H, "What is your crime?", "Crime") as text|null
	if (!my_crime)
		my_crime = "crimes against the Crown"
	var/bounty_total
	bounty_total = rand(151, 250)
	add_bounty(H.real_name, bounty_total, FALSE, my_crime, "The Justiciary of Rasura")

/datum/advclass/wretch/charlatan
	name = "Charlatan"
	tutorial = "Once court jester or wandering bard now you are nothing but a prancing dancing wretch. It takes a truly horrible deed to damn a jester.."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/charlatan
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_DODGEEXPERT, TRAIT_OUTLAW, TRAIT_ZJUMP, TRAIT_LEAPER, TRAIT_NUTCRACKER)


/datum/outfit/job/roguetown/wretch/charlatan/pre_equip(mob/living/carbon/human/H)
	shoes = /obj/item/clothing/shoes/roguetown/jester
	pants = /obj/item/clothing/under/roguetown/tights
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt/bog
	beltr = /obj/item/rogueweapon/huntingknife/throwingknife
	belt = /obj/item/storage/belt/rogue/leather/rope
	beltl = /obj/item/storage/belt/rogue/pouch
	head = /obj/item/clothing/head/roguetown/jester
	neck = /obj/item/clothing/neck/roguetown/coif
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/stealing, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/music, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/lockpicking, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/traps, 2, TRUE)
	H.cmode_music = 'sound/music/combat_jester.ogg'
	H.verbs |= /mob/living/carbon/human/proc/ventriloquate
	H.verbs |= /mob/living/carbon/human/proc/ear_trick
	if(!istype(H.getorganslot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/wild_tongue))
		H.internal_organs_slot[ORGAN_SLOT_TONGUE] = new /obj/item/organ/tongue/wild_tongue
	var/weapons = list("Flute", "Hurdy Gurdy", "Accordian", "Harp", "Viola", "Guitar", "Vocals", "Drum")
	var/weapon_choice = input("What will we play today?", "Make your choice!") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if ("Flute")
			r_hand = /obj/item/rogue/instrument/flute
		if ("Hurdy Gurdy")
			r_hand = /obj/item/rogue/instrument/hurdygurdy
		if ("Accordian")
			r_hand = /obj/item/rogue/instrument/accord
		if ("Harp")
			r_hand = /obj/item/rogue/instrument/harp
		if ("Viola")
			r_hand = /obj/item/rogue/instrument/viola
		if ("Guitar")
			r_hand = /obj/item/rogue/instrument/guitar
		if ("Vocals")
			r_hand = /obj/item/rogue/instrument/vocals
		if ("Drum")
			r_hand = /obj/item/rogue/instrument/drum
	H.change_stat("intelligence", 1)
	H.change_stat("speed", 2)
	H.STALUC = rand(4, 16)

	GLOB.outlawed_players += H.real_name
	var/my_crime = input(H, "What is your crime?", "Crime") as text|null
	if (!my_crime)
		my_crime = "crimes against the Crown"
	var/bounty_total
	bounty_total = rand(1, 250)
	add_bounty(H.real_name, bounty_total, FALSE, my_crime, "The Justiciary of Rasura")

/datum/advclass/wretch/charnaldok
	name = "Charnal Doktor"
	tutorial = "The peasants are weary of surgeons for good reason. The skills that can give life can just as easily take it. After years of dedication and hard work why wouldn't you want something for yourself? It's a shame you lost your reputation for it..."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/charnaldok
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_EMPATH, TRAIT_NOSTINK, TRAIT_OUTLAW)

	// A wretch version of an old townie doc. They have good medical and alchemical stats making them a tempting offer if they wish to help the town, or dangerous if they hinder.

/datum/outfit/job/roguetown/wretch/charnaldok/pre_equip(mob/living/carbon/human/H)

	head = /obj/item/clothing/head/roguetown/roguehood/shalal/heavyhood
	cloak = /obj/item/clothing/cloak/raincloak/mortus
	mask = /obj/item/clothing/mask/rogue/deacon
	neck = 	/obj/item/storage/belt/rogue/pouch/coins/poor
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/black
	gloves = /obj/item/clothing/gloves/roguetown/leather
	pants = /obj/item/clothing/under/roguetown/trou/leather/mourning
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/black
	beltl = /obj/item/storage/belt/rogue/surgery_bag/full/deacon
	beltr = /obj/item/rogueweapon/huntingknife/idagger/silver
	id = /obj/item/scomstone/bad
	r_hand = /obj/item/rogueweapon/woodstaff
	backl = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,	/obj/item/natural/worms/leech/cheele = 1,
	/obj/item/reagent_containers/glass/bottle/waterskin = 1, /obj/item/storage/belt/rogue/pouch/coins/mid = 1)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/alchemy, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sewing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/medicine, 5, TRUE)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/diagnose/secular)
	H.cmode_music = 'sound/music/combat_physician.ogg'
	H.change_stat("strength", -1)
	H.change_stat("constitution", -1)
	H.change_stat("intelligence", 2)
	H.change_stat("fortune", 1)

	GLOB.outlawed_players += H.real_name
	var/my_crime = input(H, "What is your crime?", "Crime") as text|null
	if (!my_crime)
		my_crime = "crimes against the Crown"
	var/bounty_total
	bounty_total = rand(151, 250)
	add_bounty(H.real_name, bounty_total, FALSE, my_crime, "The Mage's University")



/datum/advclass/wretch/leper
	name = "Leper"
	tutorial = "Your terrible affliction cost your rank and your family. The last man to see your face screamed in terror. Now you hide what you are and only through devotion will you be saved."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/leper
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_MEDIUMARMOR, TRAIT_LEPROSY, TRAIT_LEECHIMMUNE, TRAIT_MISSING_NOSE, TRAIT_UNSEEMLY, TRAIT_OUTLAW)


/datum/outfit/job/roguetown/wretch/leper/pre_equip(mob/living/carbon/human/H)
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan
	mask = /obj/item/clothing/mask/rogue/ragmask
	cloak = /obj/item/clothing/cloak/raincloak/mortus
	gloves = /obj/item/clothing/gloves/roguetown/chain
	pants = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /datum/supply_pack/rogue/armor/gambeson
	armor = /obj/item/clothing/suit/roguetown/armor/brigandine/coatplates
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather
	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/rogueweapon/huntingknife = 1, /obj/item/flashlight/flare/torch/lantern/prelit = 1)
	H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/axes, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/shields, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.cmode_music = 'sound/music/combat_leper.ogg'
	var/weapons = list("Heavy is the Blade","A Bloodletter's Flail","I deserve no weapon.")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Heavy is the Blade")
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
			r_hand = /obj/item/rogueweapon/greatsword/grenz
			backr = /obj/item/gwstrap
		if("A Bloodletter's Flail")
			H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 1, TRUE)
			beltr = /obj/item/rogueweapon/flail/sflail
		if("I deserve no weapon")
			r_hand = /obj/item/reagent_containers/glass/bottle/waterskin
	H.change_stat("strength", 2)
	H.change_stat("constitution", -1)
	H.change_stat("endurance", -1)
	H.change_stat("speed", -2)
	switch(H.patron?.type)
		if(/datum/patron/lording_three/aeternus)
			neck = /obj/item/clothing/neck/roguetown/psicross/aeternus
		if(/datum/patron/lording_three/zira)
			neck = /obj/item/clothing/neck/roguetown/psicross/zira
		if(/datum/patron/peoples_pantheon/cinella)
			neck = /obj/item/clothing/neck/roguetown/psicross/cinella
		if(/datum/patron/three_sisters/tamari)
			neck = /obj/item/clothing/neck/roguetown/psicross/tamari
		if(/datum/patron/lording_three/tsoridys)
			neck = /obj/item/clothing/neck/roguetown/psicross/tsoridys
		if(/datum/patron/peoples_pantheon/carthus)
			neck = /obj/item/clothing/neck/roguetown/psicross/carthus
		if(/datum/patron/three_sisters/nunos)
			neck = /obj/item/clothing/neck/roguetown/psicross/nunos
		if(/datum/patron/peoples_pantheon/varielle)
			neck = /obj/item/clothing/neck/roguetown/psicross/varielle
		if(/datum/patron/three_sisters/kasmidian)
			var/list/psicross_options = list(
			/obj/item/clothing/neck/roguetown/psicross,
			/obj/item/clothing/neck/roguetown/psicross/aeternus,
			/obj/item/clothing/neck/roguetown/psicross/zira,
			/obj/item/clothing/neck/roguetown/psicross/cinella,
			/obj/item/clothing/neck/roguetown/psicross/tamari,
			/obj/item/clothing/neck/roguetown/psicross/tsoridys,
			/obj/item/clothing/neck/roguetown/psicross/carthus,
			/obj/item/clothing/neck/roguetown/psicross/nunos,
			/obj/item/clothing/neck/roguetown/psicross/varielle
			)
			neck = pick(psicross_options)
	GLOB.outlawed_players += H.real_name
	var/my_crime = input(H, "What is your crime?", "Crime") as text|null
	if (!my_crime)
		my_crime = "spreading foul disease"
	var/bounty_total
	bounty_total = rand(151, 250)
	add_bounty(H.real_name, bounty_total, FALSE, my_crime, "The Chapel Of Lights")

/datum/advclass/wretch/swashbuckler
	name = "Swashbuckler"
	tutorial = "You've known for a long time that the seas are full of plunder. Coastal towns like this are rich for the pickings, full of fatcats and merchants an unscrupulous sea traveller like yourself can certainly take advantage of..."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/swashbuckler
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_DODGEEXPERT, TRAIT_CINELLA_SWIM, TRAIT_OUTLAW)

/datum/outfit/job/roguetown/wretch/swashbuckler/pre_equip(mob/living/carbon/human/H)
	..()
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel = 1, /obj/item/storage/belt/rogue/pouch/coins/poor = 1)
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/rogueweapon/mace/cudgel
	pants = /obj/item/clothing/under/roguetown/trou/leather
	armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
	shoes = /obj/item/clothing/shoes/roguetown/boots
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	r_hand = /obj/item/rogueweapon/sword/falx
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/carpentry, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/stealing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/labor/butchering, 1, TRUE)
	H.change_stat("speed", 1)
	H.change_stat("fortune", 1)
	H.change_stat("perception", 1)
	H.cmode_music = 'sound/music/combat_buccaneer.ogg'

	GLOB.outlawed_players += H.real_name
	var/my_crime = input(H, "What is your crime?", "Crime") as text|null
	if (!my_crime)
		my_crime = "crimes against the Crown"
	var/bounty_total
	bounty_total = rand(151, 250)
	add_bounty(H.real_name, bounty_total, FALSE, my_crime, "The Port Authority")


/datum/advclass/wretch/smuggler
	name = "Smuggler"
	tutorial = "Smuggling is a trade like any other. Supply creates demand. You know how to get things, sometimes through less than legal means, and while you are no sellsword you are more than capable of defending yourself for your work."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/smuggler
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_SEEPRICES_SHITTY, TRAIT_OUTLAW)

// effectively an outlaw merchant
/datum/outfit/job/roguetown/wretch/smuggler/pre_equip(mob/living/carbon/human/H)
	..()
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel = 1, /obj/item/flashlight/flare/torch/lantern/prelit = 1, /obj/item/lockpickring/mundane = 1,)
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	cloak = /obj/item/clothing/cloak/raincloak
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/rogueweapon/mace/cudgel
	beltr = /obj/item/quiver/bolts
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	shoes = /obj/item/clothing/shoes/roguetown/boots
	r_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/lockpicking, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/traps, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/stealing, 3, TRUE)
	H.change_stat("intelligence", 1)
	H.change_stat("perception", 2)
	H.change_stat("fortune", 1)
	H.change_stat("speed", 1)
	H.cmode_music = 'sound/music/combat_buccaneer.ogg'
	GLOB.outlawed_players += H.real_name
	var/my_crime = input(H, "What is your crime?", "Crime") as text|null
	if (!my_crime)
		my_crime = "crimes against the Crown"
	var/bounty_total
	bounty_total = rand(151, 250)
	add_bounty(H.real_name, bounty_total, FALSE, my_crime, "The Justiciary of Rasura")
