/obj/effect/landmark/cargo_supply
	icon_state = "requisitionop"

/obj/effect/landmark/cargo_supply/Initialize(mapload)
	GLOB.supply_vendor_turfs += loc
	..()
	return INITIALIZE_HINT_QDEL