/datum/outfit/job/zombie/assistant
	name = "Assistant BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/black
	ears = /obj/item/radio/survivor
	mask = /obj/item/clothing/mask/gas/tactical/coif
	head = /obj/item/clothing/head/welding/flipped
	belt = /obj/item/storage/belt/utility/full
	l_pocket = /obj/item/flashlight/combat

/datum/outfit/job/zombie/scientist
	name = "Scientist BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/rank/scientist
	wear_suit = /obj/item/clothing/suit/storage/labcoat/researcher
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/toxins
	ears = /obj/item/radio/survivor
	l_pocket = /obj/item/storage/pouch/surgery
	r_pocket = /obj/item/flashlight/combat

	backpack_contents = list(
		/obj/item/roller = 1,
		/obj/item/defibrillator = 1,
		//obj/item/reagent_containers/hypospray/autoinjector/polyhexanide = 1,
		//obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin = 1,
		//obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 1,
		//obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)


/datum/outfit/job/zombie/doctor
	name = "Doctor's Assistant BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/rank/medical/blue
	wear_suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/med
	gloves = /obj/item/clothing/gloves/latex
	glasses = /obj/item/clothing/glasses/hud/health
	r_pocket = /obj/item/storage/pouch/surgery
	belt = /obj/item/storage/belt/rig
	mask = /obj/item/clothing/mask/surgical
	ears = /obj/item/radio/survivor

	backpack_contents = list(
		/obj/item/flashlight = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

	belt_contents = list(
		/obj/item/roller = 1,
		/obj/item/defibrillator = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack = 2,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack = 2,
		/obj/item/stack/medical/splint = 2,
		/obj/item/storage/pill_bottle/packet/bicaridine = 1,
		/obj/item/storage/pill_bottle/packet/kelotane = 1,
		/obj/item/storage/pill_bottle/packet/tramadol = 1,
		/obj/item/storage/pill_bottle/packet/tricordrazine = 1,
		/obj/item/storage/pill_bottle/packet/dylovene = 1,
		/obj/item/storage/pill_bottle/packet/isotonic = 1,
		/obj/item/storage/pill_bottle/inaprovaline = 1,
	)

/datum/outfit/job/zombie/liaison
	name = "Liaison BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/liaison_suit
	shoes = /obj/item/clothing/shoes/black
	ears = /obj/item/radio/survivor
	belt = /obj/item/storage/holster/belt/pistol/m4a3/vp78
	l_pocket = /obj/item/tool/crowbar

/datum/outfit/job/zombie/civilian
	name = "Civilian BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm
	ears = /obj/item/radio/survivor

	backpack_contents = list(
		/obj/item/tool/crowbar = 1,
		/obj/item/flashlight = 1,
		/obj/item/weapon/combat_knife/upp = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)


/datum/outfit/job/zombie/chef
	name = "Chef BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/rank/chef
	wear_suit = /obj/item/clothing/suit/storage/chef
	head = /obj/item/clothing/head/chefhat
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack
	ears = /obj/item/radio/survivor

	backpack_contents = list(
		/obj/item/flashlight = 1,
		/obj/item/tool/kitchen/knife/butcher = 1,
		/obj/item/reagent_containers/food/snacks/burger/crazy = 1,
		/obj/item/reagent_containers/food/snacks/soup/mysterysoup = 1,
		/obj/item/reagent_containers/food/snacks/packaged_hdogs = 1,
		/obj/item/reagent_containers/food/snacks/organ = 1,
		/obj/item/reagent_containers/food/snacks/chocolateegg = 1,
		/obj/item/reagent_containers/food/snacks/meat/xeno = 1,
		/obj/item/reagent_containers/food/snacks/pastries/xemeatpie = 1,
		/obj/item/reagent_containers/food/snacks/donut/meat = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)


/datum/outfit/job/zombie/botanist
	name = "Botanist BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/rank/hydroponics
	wear_suit = /obj/item/clothing/suit/storage/apron/overalls
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/hydroponics
	ears = /obj/item/radio/survivor
	suit_store = /obj/item/weapon/combat_knife
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/tool/crowbar
	belt = /obj/item/weapon/gun/shotgun/double

	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris = 2,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiadeus = 2,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

/datum/outfit/job/zombie/atmos
	name = "Atmospherics Technician BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/rank/atmospheric_technician
	wear_suit = /obj/item/clothing/suit/storage/hazardvest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/som
	gloves = /obj/item/clothing/gloves/insulated
	belt = /obj/item/storage/belt
	glasses = /obj/item/clothing/glasses/welding
	r_pocket = /obj/item/storage/pouch/electronics/full
	l_pocket = /obj/item/storage/pouch/construction
	ears = /obj/item/radio/survivor

	backpack_contents = list(
		/obj/item/lightreplacer = 1,
		/obj/item/deployable_floodlight = 1,
		/obj/item/explosive/grenade/chem_grenade/metalfoam = 2,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

	belt_contents = list(
		/obj/item/tool/screwdriver = 1,
		/obj/item/tool/wrench = 1,
		/obj/item/tool/wirecutters = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/weldingtool = 1,
		/obj/item/tool/multitool = 1,
		/obj/item/stack/cable_coil = 1,
	)


/datum/outfit/job/zombie/chaplain
	name = "Chaplain BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/rank/chaplain
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm
	ears = /obj/item/radio/survivor

	backpack_contents = list(
		/obj/item/storage/fancy/candle_box = 1,
		/obj/item/tool/candle = 3,
		/obj/item/tool/lighter = 1,
		/obj/item/storage/bible = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 1,
	)

/datum/outfit/job/zombie/miner
	name = "Miner BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/rank/miner
	head = /obj/item/clothing/head/helmet/space/rig/mining
	shoes = /obj/item/clothing/shoes/black
	gloves = /obj/item/clothing/gloves/ruggedgloves
	back = /obj/item/storage/backpack/satchel/som
	r_pocket = /obj/item/reagent_containers/cup/glass/flask
	wear_suit = /obj/item/clothing/suit/space/rig/mining
	ears = /obj/item/radio/survivor

	backpack_contents = list(
		/obj/item/storage/fancy/cigarettes = 1,
		/obj/item/tool/lighter = 1,
		/obj/item/reagent_containers/food/drinks/bottle/whiskey = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)


/datum/outfit/job/zombie/salesman
	name = "Salesman BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/lawyer/purpsuit
	wear_suit = /obj/item/clothing/suit/storage/lawyer/purpjacket
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel
	mask = /obj/item/clothing/mask/cigarette/pipe/bonepipe
	glasses = /obj/item/clothing/glasses/sunglasses/aviator
	ears = /obj/item/radio/survivor

	backpack_contents = list(
		/obj/item/weapon/gun/pistol/holdout = 1,
		/obj/item/ammo_magazine/pistol/holdout = 3,
		/obj/item/tool/lighter/zippo = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

/datum/outfit/job/zombie/bartender
	name = "Bartender BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/rank/bartender
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/ammo_magazine/shotgun/buckshot
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/collectable/tophat
	ears = /obj/item/radio/survivor
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/tool/crowbar
	suit_store = /obj/item/weapon/gun/shotgun/double/sawn

	backpack_contents = list(
		/obj/item/reagent_containers/food/drinks/bottle/whiskey = 1,
		/obj/item/reagent_containers/food/drinks/bottle/vodka = 1,
		/obj/item/reagent_containers/food/drinks/cans/beer = 2,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

/datum/outfit/job/zombie/rambo
	name = "Overpowered BRAINS"
	jobtype = /datum/job/zombie
	w_uniform = /obj/item/clothing/under/marine/striped
	wear_suit = /obj/item/clothing/suit/armor/patrol
	shoes = /obj/item/clothing/shoes/marine/clf/full
	back = /obj/item/storage/holster/blade/machete/full
	gloves = /obj/item/clothing/gloves/ruggedgloves
	suit_store = /obj/item/weapon/gun/rifle/alf_machinecarbine/assault
	belt = /obj/item/storage/belt/marine/alf_machinecarbine
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	r_pocket = /obj/item/flashlight/combat
	head = /obj/item/clothing/head/headband
	ears = /obj/item/radio/survivor

//Bio protection
/datum/outfit/job/zombie/chemist
	name = "Pharmacy Technician BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/rank/chemist
	wear_suit = /obj/item/clothing/suit/storage/labcoat/virologist
	mask = /obj/item/clothing/mask/surgical
	back = /obj/item/storage/backpack/satchel/chem
	belt = /obj/item/storage/belt/hypospraybelt
	gloves = /obj/item/clothing/gloves/latex
	shoes = /obj/item/clothing/shoes/white
	ears = /obj/item/radio/survivor
	glasses = /obj/item/clothing/glasses/science
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/tool/crowbar
	suit_store = /obj/item/healthanalyzer

	backpack_contents = list(
		/obj/item/reagent_containers/dropper = 1,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack = 1,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack = 1,
		/obj/item/stack/medical/splint = 2,
		/obj/item/defibrillator = 1,
		/obj/item/clothing/glasses/hud/health = 1,
	)

	belt_contents = list(
		/obj/item/reagent_containers/glass/bottle/bicaridine = 1,
		/obj/item/reagent_containers/glass/bottle/kelotane = 1,
		/obj/item/reagent_containers/glass/bottle/tramadol = 1,
		/obj/item/reagent_containers/glass/bottle/tricordrazine = 1,
		/obj/item/reagent_containers/glass/bottle/lemoline/doctor = 1,
		/obj/item/reagent_containers/glass/beaker/large = 2,
		/obj/item/reagent_containers/hypospray/advanced/bicaridine = 1,
		/obj/item/reagent_containers/hypospray/advanced/kelotane = 1,
		/obj/item/reagent_containers/hypospray/advanced/tramadol = 1,
		/obj/item/reagent_containers/hypospray/advanced/tricordrazine = 1,
		/obj/item/reagent_containers/hypospray/advanced/dylovene = 1,
		/obj/item/reagent_containers/hypospray/advanced/inaprovaline = 1,
		/obj/item/reagent_containers/hypospray/advanced/hypervene = 1,
		/obj/item/reagent_containers/hypospray/advanced/imialky = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 1,
		/obj/item/reagent_containers/hypospray/advanced/big = 2,
		/obj/item/storage/syringe_case/empty = 2,
	)

//Fire protection
/datum/outfit/job/zombie/fireman
	name = "Fireman BRAINS"
	jobtype = /datum/job/zombie
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/survivor
	wear_suit = /obj/item/clothing/suit/fire
	head = /obj/item/clothing/head/hardhat/red
	mask = /obj/item/clothing/mask/gas

//Resists bullets
/datum/outfit/job/zombie/security
	name = "Security Guard BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/colonist
	wear_suit = /obj/item/clothing/suit/armor/bulletproof/zombie
	head = /obj/item/clothing/head/securitycap/zombie
	shoes = /obj/item/clothing/shoes/marine/full
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security
	gloves = /obj/item/clothing/gloves/black
	suit_store = /obj/item/weapon/gun/pistol/g22
	ears = /obj/item/radio/survivor

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/pistol/g22 = 2,
		/obj/item/flashlight/combat = 1,
		/obj/item/weapon/telebaton = 1,
	)

//Resists energy
/datum/outfit/job/zombie/marshal
	name = "Colonial Marshal BRAINS"
	jobtype = /datum/job/zombie

	w_uniform = /obj/item/clothing/under/CM_uniform
	wear_suit = /obj/item/clothing/suit/armor/det_suit/zombie
	shoes = /obj/item/clothing/shoes/jackboots
	suit_store = /obj/item/storage/holster/belt/m44/full
	belt = /obj/item/storage/belt/sparepouch
	gloves = /obj/item/clothing/gloves/ruggedgloves
	l_pocket = /obj/item/flashlight/combat
	ears = /obj/item/radio/survivor
	head = /obj/item/clothing/head/tgmcberet/red

	belt_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

//Has energy module
/datum/outfit/job/zombie/marine
	name = "Marine BRAINS"
	jobtype = /datum/job/zombie
	w_uniform = /obj/item/clothing/under/marine/jaeger
	wear_suit = /obj/item/clothing/suit/modular/jaeger/light/zombie
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/marine
	head = /obj/item/clothing/head/slouch
