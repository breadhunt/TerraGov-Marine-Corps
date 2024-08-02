#define CHARGE_SPEED(charge_component) (min(charge_component.valid_steps_taken, charge_component.max_steps_buildup) * charge_component.speed_per_step)
#define CHARGE_MAX_SPEED (speed_per_step * max_steps_buildup)

#define CHARGE_BULL (1<<0)
#define CHARGE_BULL_HEADBUTT (1<<1)
#define CHARGE_BULL_GORE (1<<2)

#define ONLY_DAMAGE_LIVING (1<<0)
#define CAN_PLOW_SNOW (1<<1)

#define STOP_CRUSHER_ON_DEL (1<<0)

#define CHARGE_TURNING_DISABLED -1

// ***************************************
// *********** Charge - apply to any movable to emulate Crusher/Bull movement.
// ***************************************

/datum/component/charging
	/// Whether charging is currently enabled/disabled; initial value set in Initialize()
	var/charging_enabled = FALSE
	/// Whether text feedback should be provided during charging; set in Initialize()
	var/verbose
	/// The object that's actually charging up and down; set in Initialize()
	var/atom/movable/charger //ANCHOR change this to mob?
	/// Flags to alter charge functionality
	var/charge_flags = CAN_PLOW_SNOW
	///How much momentum is lost on dir change. If CHARGE_TURNING_DISABLED, turning/charging diagonally during a charge ends the charge completely. Can be changed via the update_turning_loss() method
	var/turning_speed_loss = CHARGE_TURNING_DISABLED
	/// Affects how much damage charging into other players does
	var/living_damage = 20
	/// Players on the same team should take less damage from collisions
	var/friendly_damage_mult = 0.2
	/// Affects how much damage charging into objects does
	var/object_damage_mult = 1
	/// What sound should be used during charges
	var/stomp_sound = SFX_ALIEN_FOOTSTEP_LARGE
	/// How loud said sound should be
	var/stomp_loudness = 50
	/// What sound should play when charging into things
	var/crush_sound = SFX_PUNCH

	/// Variables for keeping track of charge states
	var/charge_state = CHARGE_OFF
	var/next_move_limit = 0
	var/turf/lastturf = null
	var/charge_dir = null
	var/valid_steps_taken = 0
	var/speed_per_step = 0.15
	var/steps_for_charge = 7
	var/max_steps_buildup = 14

/datum/component/charging/Initialize(atom/movable/component_charger, verbosity = FALSE)
	. = ..()
	charger = component_charger
	verbose = verbosity

	RegisterSignal(parent, COMSIG_ENABLE_CHARGING_MOVEMENT, PROC_REF(enable_charging))
	RegisterSignal(parent, COMSIG_DISABLE_CHARGING_MOVEMENT, PROC_REF(disable_charging))
	RegisterSignal(parent, COMSIG_CHARGING_UPDATE_TURNING_LOSS, PROC_REF(update_turning_loss))

/datum/component/charging/Destroy(force, silent)
	. = ..()
	if(charging_enabled)
		disable_charging()
	UnregisterSignal(parent, list(COMSIG_ENABLE_CHARGING_MOVEMENT, COMSIG_DISABLE_CHARGING_MOVEMENT, COMSIG_CHARGING_UPDATE_TURNING_LOSS))


/// Toggles charging while moving on
/datum/component/charging/proc/enable_charging(force_non_verbose = FALSE)
	SIGNAL_HANDLER

	charging_enabled = TRUE
	RegisterSignal(charger, COMSIG_MOVABLE_MOVED, PROC_REF(update_charging))
	RegisterSignal(charger, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
	//ANCHOR figuree something out for this please RegisterSignal(charger, UPDATE_ICON_STATE, PROC_REF(update_icon_state))
	RegisterSignal(charger, COMSIG_CHARGING_SNOW_PLOW, PROC_REF(plow_snow))


/// Toggles charging while moving off
/datum/component/charging/proc/disable_charging()
	SIGNAL_HANDLER

	do_stop_momentum() //Reset any ongoing charges
	charging_enabled = FALSE
	UnregisterSignal(charger, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE, COMSIG_CHARGING_SNOW_PLOW))


/// Changes how much momentum is lost when changing directions during a charge
/datum/component/charging/proc/update_turning_loss(datum/source, new_turning_loss)
	SIGNAL_HANDLER
	turning_speed_loss = new_turning_loss


/// Called whenever the charger moves; main momentum calculations are then performed in check_momentum() and handle_momentum()
/datum/component/charging/proc/update_charging(datum/source, atom/oldloc, direction, Forced, old_locs)
	SIGNAL_HANDLER
	if(Forced)
		return

	if(charger.throwing || oldloc == charger.loc)
		return

	if(charge_state == CHARGE_OFF)
		if(charger.dir != direction) //It needs to move twice in the same direction, at least, to begin charging.
			return
		charge_dir = direction
		if(!check_momentum(direction))
			charge_dir = null
			return
		charge_state = CHARGE_BUILDINGUP
		handle_momentum()
		return

	if(!check_momentum(direction))
		do_stop_momentum()
		return

	handle_momentum()


/// Called whenever the charger changes direction. The momentum lost while turning is determined by the 'turning_speed_loss' variable.
/datum/component/charging/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(charge_state == CHARGE_OFF)
		return
	if(!old_dir || !new_dir || old_dir == new_dir) //Check for null direction from help shuffle signals
		return
	if(turning_speed_loss != CHARGE_TURNING_DISABLED)
		speed_down(turning_speed_loss)
		return
	do_stop_momentum()


/// Called when our charger gets enough momentum to begin fully charging; registers collision signals for charging and updates variables/icons.
/datum/component/charging/proc/do_start_crushing()
	RegisterSignals(charger, list(COMSIG_MOVABLE_PREBUMP_TURF, COMSIG_MOVABLE_PREBUMP_MOVABLE, COMSIG_MOVABLE_PREBUMP_EXIT_MOVABLE), PROC_REF(do_crush))
	charge_state = CHARGE_ON
	charger.update_icon()
	if(ismob(charger))
		var/mob/mob_charger = charger
		mob_charger.update_icons()


/// Stops the ongoing charge state. Unregisters collision signals for charigng and resets variables/icons.
/datum/component/charging/proc/do_stop_crushing()
	UnregisterSignal(charger, list(COMSIG_MOVABLE_PREBUMP_TURF, COMSIG_MOVABLE_PREBUMP_MOVABLE, COMSIG_MOVABLE_PREBUMP_EXIT_MOVABLE))
	if(valid_steps_taken > 0) //If this is false, then do_stop_momentum() should have it handled already.
		charge_state = CHARGE_BUILDINGUP
		charger.update_icon()
		if(ismob(charger))
			var/mob/mob_charger = charger
			mob_charger.update_icons()


/// Stops charger momentum entirely. Use this to stop an ongoing charge, like for if the charger smashes into a wall.
/datum/component/charging/proc/do_stop_momentum(message = TRUE)
	if(message && verbose && valid_steps_taken >= steps_for_charge)
		charger.visible_message(span_danger("[charger] skids to a halt!"),
		span_warning("We skid to a halt."), null, 5)
	valid_steps_taken = 0
	next_move_limit = 0
	lastturf = null
	charge_dir = null
	if(charge_state >= CHARGE_ON)
		do_stop_crushing()
	charge_state = CHARGE_OFF
	charger.update_icon()
	if(ismob(charger))
		var/mob/mob_charger = charger
		mob_charger.update_icons()


/// Checks whether we are allowed to update momentum status yet or not. If this returns FALSE, momentum cannot be built up.
/datum/component/charging/proc/check_momentum(newdir)
	if((newdir && ISDIAGONALDIR(newdir) || charge_dir != newdir) && turning_speed_loss == CHARGE_TURNING_DISABLED) //Check for null direction from help shuffle signals
		return FALSE

	if(next_move_limit && world.time > next_move_limit)
		return FALSE

	if(charge_dir != charger.dir && turning_speed_loss == CHARGE_TURNING_DISABLED)
		return FALSE

	if(charger.pulledby)
		return FALSE

	if(lastturf && (!isturf(lastturf) || isspaceturf(lastturf) || (charger.loc == lastturf))) //Check that we haven't moved from our last turf, aka stopped
		return FALSE

	return TRUE


/// Handles main momentum calculations, updating crushing states according to our new momentum.
/datum/component/charging/proc/handle_momentum()
	next_move_limit = world.time + 0.5 SECONDS

	if(++valid_steps_taken <= max_steps_buildup)
		if(valid_steps_taken == steps_for_charge)
			do_start_crushing()
		else if(valid_steps_taken == max_steps_buildup)
			charge_state = CHARGE_MAX
			if(isliving(charger))
				addtimer(CALLBACK(charger, TYPE_PROC_REF(/mob/living, emote), "roar"), 0.05 SECONDS)
		if(ismob(charger))
			var/mob/mob_charger = charger
			mob_charger.add_movespeed_modifier(MOVESPEED_ID_CHARGING, TRUE, 100, NONE, TRUE, -CHARGE_SPEED(src))

	if(valid_steps_taken > steps_for_charge)
		handle_special_momentum_effects()

	lastturf = charger.loc


/// Handles special effects for every time momentum increases (i.e for every step of an ongoing charge).
/datum/component/charging/proc/handle_special_momentum_effects()
	return


/// Slows down charger momentum by 'amount' tiles
/datum/component/charging/proc/speed_down(amt)
	if(valid_steps_taken == 0)
		return
	valid_steps_taken -= amt
	if(valid_steps_taken <= 0)
		valid_steps_taken = 0
		do_stop_momentum()
	else if(valid_steps_taken < steps_for_charge)
		do_stop_crushing()

// ***************************************
// *********** Pre-Crush
// ***************************************

#define PRECRUSH_STOPPED -1
#define PRECRUSH_PLOWED -2
#define PRECRUSH_ENTANGLED -3

/proc/precrush2signal(precrush)
	switch(precrush)
		if(PRECRUSH_STOPPED)
			return COMPONENT_MOVABLE_PREBUMP_STOPPED
		if(PRECRUSH_PLOWED)
			return COMPONENT_MOVABLE_PREBUMP_PLOWED
		if(PRECRUSH_ENTANGLED)
			return COMPONENT_MOVABLE_PREBUMP_ENTANGLED
		else
			return NONE

// Charge is divided into two acts: before and after the crushed thing taking damage, as that can cause it to be deleted.
/datum/component/charging/proc/do_crush(datum/source, atom/crushed)
	SIGNAL_HANDLER
	if(isliving(charger))
		var/mob/living/living_charger = charger
		if(living_charger.incapacitated() || living_charger.now_pushing)
			return NONE

	if((charge_flags & ONLY_DAMAGE_LIVING) && !isliving(crushed))
		do_stop_momentum()
		return COMPONENT_MOVABLE_PREBUMP_STOPPED

	var/precrush = crushed.pre_crush_act(charger, src) //Negative values are codes. Positive ones are damage to deal.
	switch(precrush)
		if(null)
			CRASH("[crushed] returned null from do_crush()")
		if(PRECRUSH_STOPPED)
			return COMPONENT_MOVABLE_PREBUMP_STOPPED //Already handled, no need to continue.
		if(PRECRUSH_PLOWED)
			return COMPONENT_MOVABLE_PREBUMP_PLOWED
		if(PRECRUSH_ENTANGLED)
			. = COMPONENT_MOVABLE_PREBUMP_ENTANGLED

	var/preserved_name = crushed.name

	if(isliving(crushed))
		var/mob/living/crushed_living = crushed
		playsound(crushed_living.loc, crush_sound, 25, 1)
		if(crushed_living.buckled)
			crushed_living.buckled.unbuckle_mob(crushed_living)
		animation_flash_color(crushed_living)

		if(precrush > 0)
			log_combat(charger, crushed_living, "charged")

			if(isliving(charger))
				var/mob/living/living_charger = charger
				if(crushed_living.job?.faction == living_charger.job?.faction)
					precrush *= friendly_damage_mult

			//There is a chance to do enough damage here to gib certain mobs. Better update immediately.
			crushed_living.apply_damage(precrush * living_damage, BRUTE, BODY_ZONE_CHEST, MELEE, updating_health = TRUE) //ANCHOR to add: friendly_damage_mult
			if(QDELETED(crushed_living) && verbose)
				charger.visible_message(span_danger("[charger] annihilates [preserved_name]!"),
				span_warning("We annihilate [preserved_name]!"))
				return COMPONENT_MOVABLE_PREBUMP_PLOWED

		return precrush2signal(crushed_living.post_crush_act(charger, src))

	if(isobj(crushed))
		var/obj/crushed_obj = crushed
		if(istype(crushed_obj, /obj/structure/xeno/silo) || istype(crushed_obj, /obj/structure/xeno/xeno_turret))
			return precrush2signal(crushed_obj.post_crush_act(charger, src))
		playsound(crushed_obj.loc, SFX_PUNCH, 25, 1)
		var/crushed_behavior = crushed_obj.crushed_special_behavior()
		var/obj_damage_mult = object_damage_mult
		if(isarmoredvehicle(crushed) || ishitbox(crushed))
			obj_damage_mult *= 5
		crushed_obj.take_damage(precrush * obj_damage_mult, BRUTE, MELEE)
		if(QDELETED(crushed_obj) && verbose)
			charger.visible_message(span_danger("[charger] crushes [preserved_name]!"),
			span_warning("We crush [preserved_name]!"))
			if(crushed_behavior & STOP_CRUSHER_ON_DEL)
				return COMPONENT_MOVABLE_PREBUMP_STOPPED
			else
				return COMPONENT_MOVABLE_PREBUMP_PLOWED

		return precrush2signal(crushed_obj.post_crush_act(charger, src))

	if(isturf(crushed))
		var/turf/crushed_turf = crushed
		switch(precrush)
			if(1 to 3)
				crushed_turf.ex_act(precrush)

		if(verbose)
			if(QDELETED(crushed_turf))
				charger.visible_message(span_danger("[charger] plows straight through [preserved_name]!"),
				span_warning("We plow straight through [preserved_name]!"))
				return COMPONENT_MOVABLE_PREBUMP_PLOWED

			charger.visible_message(span_danger("[charger] rams into [crushed_turf] and skids to a halt!"),
			span_warning("We ram into [crushed_turf] and skid to a halt!"))
		do_stop_momentum(FALSE)
		return COMPONENT_MOVABLE_PREBUMP_STOPPED


//Anything called here will have failed CanPass(), so it's likely dense.
/atom/proc/pre_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	return //If this happens it will error.


/obj/pre_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	if((resistance_flags & (INDESTRUCTIBLE|CRUSHER_IMMUNE)) || charge_component.charge_state < CHARGE_ON)
		charge_component.do_stop_momentum()
		return PRECRUSH_STOPPED
	if(anchored)
		if(atom_flags & ON_BORDER)
			if(dir == REVERSE_DIR(charger.dir))
				. = (CHARGE_SPEED(charge_component) * 80) //Damage to inflict.
				charge_component.speed_down(3)
				return
			else
				. = (CHARGE_SPEED(charge_component) * 160)
				charge_component.speed_down(1)
				return
		else
			. = (CHARGE_SPEED(charge_component) * 240)
			charge_component.speed_down(2)
			return

	for(var/m in buckled_mobs)
		unbuckle_mob(m)
	return (CHARGE_SPEED(charge_component) * 20) //Damage to inflict.

/obj/vehicle/unmanned/pre_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	return (CHARGE_SPEED(charge_component) * 10)

/obj/vehicle/sealed/mecha/pre_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	return (CHARGE_SPEED(charge_component) * 375)

/obj/hitbox/pre_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	return (CHARGE_SPEED(charge_component) * 20)

/obj/structure/razorwire/pre_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE) || charge_component.charge_state < CHARGE_ON)
		charge_component.do_stop_momentum()
		return PRECRUSH_STOPPED
	if(anchored)
		var/charge_damage = (CHARGE_SPEED(charge_component) * 45)  // 2.1 * 45 = 94.5 max damage to inflict.
		. = charge_damage
		charge_component.speed_down(3)
		if(isxeno(charger))
			var/mob/living/carbon/xenomorph/xenomorph_charger = charger
			xenomorph_charger.adjust_sunder(10)
		return
	return (CHARGE_SPEED(charge_component) * 20) //Damage to inflict.

/obj/structure/bed/pre_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	. = ..()
	if(!.)
		return
	if(buckled_bodybag)
		unbuckle_bodybag()


/mob/living/pre_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	return (stat == DEAD ? 0 : CHARGE_SPEED(charge_component))


//Special override case. May not call the parent.
/mob/living/carbon/xenomorph/pre_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	if(!issamexenohive(charger))
		return ..()

	var/mob/living/carbon/xenomorph/xenomorph_charger = charger
	if(anchored || (mob_size > xenomorph_charger.mob_size && charge_component.charge_state <= CHARGE_MAX))
		if(charge_component.verbose)
			xenomorph_charger.visible_message(span_danger("[xenomorph_charger] rams into [src] and skids to a halt!"),
			span_warning("We ram into [src] and skid to a halt!"))
		charge_component.do_stop_momentum(FALSE)
		if(!anchored)
			step(src, xenomorph_charger.dir)
		return PRECRUSH_STOPPED

	throw_at(get_step(loc, (xenomorph_charger.dir & (NORTH|SOUTH) ? pick(EAST, WEST) : pick(NORTH, SOUTH))), 1, 1, xenomorph_charger, (mob_size < xenomorph_charger.mob_size))

	charge_component.speed_down(1) //Lose one turf worth of speed.
	return PRECRUSH_PLOWED


/turf/pre_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	if(charge_component.valid_steps_taken >= charge_component.max_steps_buildup)
		return 2 //Should dismantle, or at least heavily damage it.
	return 3 //Lighter damage.


// ***************************************
// *********** Post-Crush
// ***************************************

/atom/proc/post_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	return PRECRUSH_STOPPED //By default, if this happens then movement stops. But not necessarily.


/obj/post_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	if(anchored) //Did it manage to stop it?
		if(charge_component.verbose)
			charger.visible_message(span_danger("[charger] rams into [src] and skids to a halt!"),
			span_warning("We ram into [src] and skid to a halt!"))
		if(charge_component.charge_state > CHARGE_OFF)
			charge_component.do_stop_momentum(FALSE)
		return PRECRUSH_STOPPED
	var/fling_dir = pick(GLOB.cardinals - ((charger.dir & (NORTH|SOUTH)) ? list(NORTH, SOUTH) : list(EAST, WEST))) //Fling them somewhere not behind nor ahead of the charger.
	var/fling_dist = min(round(CHARGE_SPEED(charge_component)) + 1, 3)
	if(!step(src, fling_dir) && density)
		charge_component.do_stop_momentum(FALSE) //Failed to be tossed away and returned, more powerful than ever, to block the charger's path.
		if(charge_component.verbose)
			charger.visible_message(span_danger("[charger] rams into [src] and skids to a halt!"),
				span_warning("We ram into [src] and skid to a halt!"))
		return PRECRUSH_STOPPED
	if(--fling_dist)
		for(var/i in 1 to fling_dist)
			if(!step(src, fling_dir))
				break
	if(charge_component.verbose)
		charger.visible_message("[span_warning("[charger] knocks [src] aside.")]!",
		span_warning("We knock [src] aside.")) //Canisters, crates etc. go flying.
	charge_component.speed_down(2) //Lose two turfs worth of speed.
	return PRECRUSH_PLOWED


/obj/structure/razorwire/post_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	if(!anchored)
		return ..()

	if(!isliving(charger))
		return ..()

	var/mob/living/living_charger = charger
	razorwire_tangle(charger, RAZORWIRE_ENTANGLE_DELAY * 0.10) //entangled for only 10% as long or 0.5 seconds
	if(charge_component.verbose)
		living_charger.visible_message(span_danger("The barbed wire slices into [living_charger]!"),
		span_danger("The barbed wire slices into you!"), null, 5)
	living_charger.Paralyze(0.5 SECONDS)
	living_charger.apply_damage(RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MIN_DAMAGE_MULT_MED, BRUTE, sharp = TRUE, updating_health = TRUE) //Armor is being ignored here.
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	update_icon()
	return PRECRUSH_ENTANGLED //Let's return this so that the charger may enter the turf in where it's entangled, if it survived the wounds without gibbing.


/obj/structure/door/post_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	if(!anchored || !density)
		return ..()

	if(!ismob(charger))
		return ..()

	attempt_to_open(charger, TRUE, TRUE, angle2dir(Get_Angle(src, charger)), TRUE)
	//ANCHOR WTF???if(CHECK_BITFIELD(door_flags, DOOR_OPEN))
		//return PRECRUSH_PLOWED
	return PRECRUSH_STOPPED


/obj/machinery/vending/post_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	if(!anchored)
		return ..()
	tip_over()
	if(density)
		return PRECRUSH_STOPPED
	if(charge_component.verbose)
		charger.visible_message(span_danger("[charger] slams [src] into the ground!"),
		span_warning("We slam [src] into the ground!"))
	return PRECRUSH_PLOWED

/obj/vehicle/post_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	if(isxeno(charger))
		var/mob/living/carbon/xenomorph/xenomorph_charger = charger
		take_damage(xenomorph_charger.xeno_caste.melee_damage * xenomorph_charger.xeno_melee_damage_modifier, BRUTE, MELEE)
	else
		take_damage(15 * charge_component.object_damage_mult, BRUTE, MELEE)

	if(density && charger.move_force <= move_resist)
		if(charge_component.verbose)
			charger.visible_message(span_danger("[charger] rams into [src] and skids to a halt!"),
			span_warning("We ram into [src] and skid to a halt!"))
		charge_component.do_stop_momentum(FALSE)
		return PRECRUSH_STOPPED
	charge_component.speed_down(2) //Lose two turfs worth of speed.
	return NONE

/mob/living/post_crush_act(atom/movable/charger, datum/component/charging/charge_component)
	if(!ismob(charger))
		return
	var/mob/mob_charger = charger

	if(density && ((mob_size == mob_charger.mob_size && charge_component.charge_state <= CHARGE_MAX) || mob_size > mob_charger.mob_size)) //ANCHOR add handling for non-xenos here (since charger?.mob_size will return false)
		if(charge_component.verbose)
			charger.visible_message(span_danger("[charger] rams into [src] and skids to a halt!"),
			span_warning("We ram into [src] and skid to a halt!"))
		charge_component.do_stop_momentum(FALSE)
		step(src, charger.dir)
		return PRECRUSH_STOPPED

	charge_component.pre_crush_living(src)

	if(anchored)
		charge_component.do_stop_momentum(FALSE)
		if(charge_component.verbose)
			charger.visible_message(span_danger("[charger] rams into [src] and skids to a halt!"),
				span_warning("We ram into [src] and skid to a halt!"))
		return PRECRUSH_STOPPED

	charge_component.post_crush_living(src)
	charge_component.do_stop_momentum(FALSE)
	return PRECRUSH_STOPPED

// ***************************************
// *********** Charging Component Crush Procs
// ***************************************

/datum/component/charging/proc/pre_crush_living(mob/living/target)
	return

/datum/component/charging/proc/post_crush_living(mob/living/target)
	return

// ***************************************
// *********** Misc procs; special interactions go here
// ***************************************

/// Updates icon state to match charging. Not used by xenomorphs (blame snowflake code)
/datum/component/charging/proc/update_icon_state()
	SIGNAL_HANDLER
	return TRUE


/// Checks whether to update special state of xenomorph chargers
/datum/component/charging/xenomorph/proc/update_charger_icon()
	SIGNAL_HANDLER

	if(charge_state < CHARGE_ON)
		return FALSE
	return TRUE


/// Called whenever snow is entered
/datum/component/charging/proc/plow_snow(datum/source, turf/open/floor/plating/ground/snow/to_plow)
	SIGNAL_HANDLER
	if(!(charge_flags & CAN_PLOW_SNOW) || charge_state < CHARGE_ON)
		return

	to_plow.slayer = 0
	to_plow.update_appearance()
	to_plow.update_sides()


/// Gore emote for bull
/mob/living/proc/emote_gored()
	return

/mob/living/carbon/human/emote_gored()
	if(species.species_flags & NO_PAIN)
		return
	emote("gored")

/mob/living/carbon/xenomorph/emote_gored()
	emote(prob(70) ? "hiss" : "roar")

/// Special behaviours for objects
/obj/proc/crushed_special_behavior()
	return NONE

/obj/structure/window/framed/crushed_special_behavior()
	if(window_frame)
		return STOP_CRUSHER_ON_DEL
	else ..()

// ***************************************
// *********** Xenomorphs
// ***************************************

/datum/component/charging/xenomorph
	/// Multiplier for how much plasma each charged tile should use up
	var/plasma_use_multiplier = 1


/datum/component/charging/xenomorph/Initialize(start_enabled, verbosity)
	. = ..()
	RegisterSignal(charger, COMSIG_UPDATE_CHARGER_ICON, PROC_REF(update_charger_icon))
	RegisterSignal(charger, COMSIG_UPDATE_CHARGER_WOUNDED_ICON, PROC_REF(update_charger_wounded_icon))
	RegisterSignal(charger, COMSIG_CHARGING_CHECK_CANNOT_ADJUST_STAGGER, PROC_REF(check_cannot_adjust_stagger))
	RegisterSignal(charger, COMSIG_CHARGING_CHECK_CANNOT_ADD_SLOWDOWN, PROC_REF(check_cannot_add_slowdown))

/datum/component/charging/xenomorph/Destroy(force, silent)
	UnregisterSignal(charger, list(COMSIG_UPDATE_CHARGER_ICON, COMSIG_UPDATE_CHARGER_WOUNDED_ICON, COMSIG_CHARGING_CHECK_CANNOT_ADJUST_STAGGER, COMSIG_CHARGING_CHECK_CANNOT_ADD_SLOWDOWN))
	return ..()


/datum/component/charging/xenomorph/do_stop_momentum(message = TRUE)
	. = ..()
	var/mob/living/carbon/xenomorph/xeno_charger = charger
	xeno_charger.remove_movespeed_modifier(MOVESPEED_ID_CHARGING)


/datum/component/charging/xenomorph/check_momentum(newdir)
	. = ..()
	if(!isxeno(charger))
		return FALSE

	var/mob/living/carbon/xenomorph/xeno_charger = charger

	if(xeno_charger.pulling)
		return FALSE

	if(xeno_charger.incapacitated())
		return FALSE

	if(xeno_charger.plasma_stored < round(CHARGE_SPEED(src)*plasma_use_multiplier))
		return FALSE


/datum/component/charging/xenomorph/handle_momentum()
	var/mob/living/carbon/xenomorph/xeno_charger = charger
	if(xeno_charger.pulling && valid_steps_taken)
		xeno_charger.stop_pulling()

	. = ..()


/datum/component/charging/xenomorph/handle_special_momentum_effects()
	var/mob/living/carbon/xenomorph/xeno_charger = charger
	xeno_charger.use_plasma(round(CHARGE_SPEED(src) * plasma_use_multiplier))

/datum/component/charging/xenomorph/update_charger_icon(datum/source)
	if(!..() || !isxeno(source))
		return FALSE
	var/mob/living/carbon/xenomorph/xenomorph_charger = source
	xenomorph_charger.icon_state = "[xenomorph_charger.xeno_caste.caste_name][(xenomorph_charger.xeno_flags & XENO_ROUNY) ? " rouny" : ""] Charging"
	return TRUE


/datum/component/charging/xenomorph/post_crush_living(mob/living/target)
	var/fling_dir = pick((charger.dir & (NORTH|SOUTH)) ? list(WEST, EAST, charger.dir|WEST, charger.dir|EAST) : list(NORTH, SOUTH, charger.dir|NORTH, charger.dir|SOUTH)) //Fling them somewhere not behind nor ahead of the charger.
	var/fling_dist = min(round(CHARGE_SPEED(src)) + 1, 3)
	var/turf/destination = target.loc
	var/turf/temp

	for(var/i in 1 to fling_dist)
		temp = get_step(destination, fling_dir)
		if(!temp)
			break
		destination = temp
	if(destination != target.loc)
		target.throw_at(destination, fling_dist, 1, charger, TRUE)

	if(verbose)
		charger.visible_message(span_danger("[charger] rams [target]!"),
		span_warning("We ram [target]!"))
	speed_down(1) //Lose one turf worth of speed.
	GLOB.round_statistics.bull_crush_hit++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "bull_crush_hit")
	return PRECRUSH_PLOWED


/datum/component/charging/xenomorph/proc/update_charger_wounded_icon(datum/source)
	SIGNAL_HANDLER
	if(charge_state < CHARGE_ON)
		return FALSE
	return TRUE


/datum/component/charging/xenomorph/proc/check_cannot_adjust_stagger()
	SIGNAL_HANDLER
	if(charge_state < CHARGE_ON)
		return TRUE
	return FALSE


/datum/component/charging/xenomorph/proc/check_cannot_add_slowdown()
	SIGNAL_HANDLER
	if(charge_state < CHARGE_ON)
		return TRUE
	return FALSE

// ***************************************
// *********** Crusher
// ***************************************

/datum/component/charging/xenomorph/crusher

/datum/component/charging/xenomorph/crusher/Initialize(start_enabled, verbosity)
	. = ..()
	RegisterSignal(charger, COMSIG_XENOABILITY_CRUSHER_ADVANCE, PROC_REF(do_advance))

/datum/component/charging/xenomorph/crusher/handle_special_momentum_effects()
	. = ..()
	if(MODULUS(valid_steps_taken, 4) == 0)
		playsound(charger, SFX_ALIEN_CHARGE, 50)
	var/shake_dist = min(round(CHARGE_SPEED(src) * 5), 8)
	for(var/mob/living/carbon/victim in range(shake_dist, charger))
		if(isxeno(victim))
			continue
		if(victim.stat == DEAD)
			continue
		if(victim.client)
			shake_camera(victim, 1, 1)
		if(victim.loc != charger.loc || !victim.lying_angle || isnestedhost(victim))
			continue
		if(verbose)
			charger.visible_message(span_danger("[charger] runs [victim] over!"),
				span_danger("We run [victim] over!"), null, 5)
		victim.take_overall_damage(CHARGE_SPEED(src) * 10, BRUTE,MELEE, max_limbs = 3)
		animation_flash_color(victim)

/datum/component/charging/xenomorph/crusher/pre_crush_living(mob/living/target)
	target.Paralyze(CHARGE_SPEED(src) * 2 SECONDS)

/// Crusher's primordial ability; initiates charging if it's not already, then moves the crusher forward to simulate charging.
/datum/component/charging/xenomorph/crusher/proc/do_advance(datum/source, atom/target, advance_range)
	SIGNAL_HANDLER
	if(!isxeno(charger) || !target)
		return

	var/aimdir = get_dir(charger, target)

	var/charge_previously_disabled = FALSE
	if(!charging_enabled)
		charge_previously_disabled = TRUE
		enable_charging(TRUE)

	do_stop_momentum(FALSE) //Reset charge so next_move_limit check_momentum() does not cuck us and 0 out steps_taken
	do_start_crushing()
	valid_steps_taken = max_steps_buildup - 1
	charge_dir = aimdir //Set dir so check_momentum() does not cuck us
	turning_speed_loss = 0 //So charging diagonally does not cuck us

	for(var/i=0 to max(get_dist(charger, target), advance_range))
		if(i % 2)
			playsound(charger, SFX_ALIEN_CHARGE, 50)
			new /obj/effect/temp_visual/after_image(get_turf(charger), charger)
		charger.Move(get_step(charger, aimdir), aimdir)
		aimdir = get_dir(charger, target)

	if(charge_previously_disabled)
		disable_charging(FALSE)

	turning_speed_loss = initial(turning_speed_loss)

// ***************************************
// *********** Bull
// ***************************************

/datum/component/charging/xenomorph/bull
	/// Determines what type of bull charge to use
	var/charge_type = CHARGE_BULL
	/// Little var to keep track on special attack timers.
	var/next_special_attack = 0
	charge_flags = ONLY_DAMAGE_LIVING || CAN_PLOW_SNOW
	speed_per_step = 0.15
	steps_for_charge = 5
	max_steps_buildup = 10
	living_damage = 37
	plasma_use_multiplier = 2


/datum/component/charging/xenomorph/bull/Initialize(start_enabled, verbosity)
	. = ..()
	RegisterSignal(charger, COMSIG_XENOACTION_TOGGLECHARGETYPE, PROC_REF(toggle_charge_type))


/datum/component/charging/xenomorph/bull/Destroy(force, silent)
	. = ..()
	UnregisterSignal(charger, COMSIG_XENOACTION_TOGGLECHARGETYPE)


/datum/component/charging/xenomorph/bull/handle_special_momentum_effects()
	if(MODULUS(valid_steps_taken, 4) == 0)
		playsound(charger, SFX_ALIEN_FOOTSTEP_LARGE, 50)


/datum/component/charging/xenomorph/bull/pre_crush_living(mob/living/target)
	switch(charge_type)
		if(CHARGE_BULL)
			target.Paralyze(0.2 SECONDS)
		if(CHARGE_BULL_HEADBUTT)
			target.Paralyze(CHARGE_SPEED(src) * 1.5 SECONDS)
		if(CHARGE_BULL_GORE)
			target.adjust_stagger(CHARGE_SPEED(src) * 1 SECONDS)
			target.adjust_slowdown(CHARGE_SPEED(src) * 1)
			target.reagents.add_reagent(/datum/reagent/toxin/xeno_ozelomelyn, 10)
			playsound(target,'sound/effects/spray3.ogg', 15, TRUE)


/datum/component/charging/xenomorph/bull/post_crush_living(mob/living/target)
	switch(charge_type)
		if(CHARGE_BULL)
			return ..()

		if(CHARGE_BULL_HEADBUTT)
			var/fling_dist = min(round(CHARGE_SPEED(src)) + 2, 3)
			var/fling_dir = charger.dir
			if(ismob(charger))
				var/mob/mob_charger = charger
				if(mob_charger.a_intent != INTENT_HARM)
					fling_dir = REVERSE_DIR(charger.dir)

			var/turf/destination = target.loc
			var/turf/temp

			for(var/i in 1 to fling_dist)
				temp = get_step(destination, fling_dir)
				if(!temp)
					break
				destination = temp
			if(destination != target.loc)
				target.throw_at(destination, fling_dist, 1, charger, TRUE)

			if(verbose)
				charger.visible_message(span_danger("[charger] rams into [target] and flings [target.p_them()] away!"),
					span_warning("We ram into [target] and skid to a halt!")) //ANCHRO this should not be 'src'. Go through all instances of visible_message and sort them tf out, add verbosity, make them fit, etc
			GLOB.round_statistics.bull_headbutt_hit++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "bull_headbutt_hit")

		if(CHARGE_BULL_GORE)
			if(world.time > next_special_attack)
				next_special_attack = world.time + 2 SECONDS
				var/turf/destination = get_step(target.loc, charger.dir)
				if(destination)
					target.throw_at(destination, 1, 1, charger, FALSE)
				if(verbose)
					charger.visible_message(span_danger("[charger] gores [target]!"),
						span_warning("We gore [target] and skid to a halt!"))
				GLOB.round_statistics.bull_gore_hit++
				SSblackbox.record_feedback("tally", "round_statistics", 1, "bull_gore_hit")


/// Swaps the type of charge to use when charging
/datum/component/charging/xenomorph/bull/proc/toggle_charge_type(datum/source, new_charge_type = CHARGE_BULL)
	SIGNAL_HANDLER

	if(charge_type == new_charge_type)
		return

	if(charge_state >= CHARGE_ON)
		do_stop_momentum()

	switch(new_charge_type)
		if(CHARGE_BULL)
			charge_type = CHARGE_BULL
			crush_sound = initial(crush_sound)
			to_chat(charger, span_notice("Now charging normally."))
		if(CHARGE_BULL_HEADBUTT)
			charge_type = CHARGE_BULL_HEADBUTT
			to_chat(charger, span_notice("Now headbutting on impact."))
		if(CHARGE_BULL_GORE)
			charge_type = CHARGE_BULL_GORE
			crush_sound = SFX_ALIEN_TAIL_ATTACK
			to_chat(charger, span_notice("Now goring on impact."))

// ***************************************
// *********** Behemoth
// ***************************************

/datum/component/charging/xenomorph/behemoth
	charge_flags = ONLY_DAMAGE_LIVING || CAN_PLOW_SNOW
	speed_per_step = 0.35
	steps_for_charge = 4
	max_steps_buildup = 4
	living_damage = 0
	plasma_use_multiplier = 0
	turning_speed_loss = 8


/datum/component/charging/xenomorph/behemoth/enable_charging(verbose = TRUE)
	. = ..()
	var/mob/living/carbon/xenomorph/xeno_charger = charger
	ADD_TRAIT(xeno_charger, TRAIT_SILENT_FOOTSTEPS, XENO_TRAIT)
	for(var/mob/living/rider AS in xeno_charger.buckled_mobs)
		xeno_charger.unbuckle_mob(rider)


/datum/component/charging/xenomorph/behemoth/disable_charging(verbose = TRUE)
	. = ..()
	var/mob/living/carbon/xenomorph/xeno_charger = charger
	REMOVE_TRAIT(xeno_charger, TRAIT_SILENT_FOOTSTEPS, XENO_TRAIT)


/datum/component/charging/xenomorph/behemoth/handle_special_momentum_effects()
	if(MODULUS(valid_steps_taken, 2) == 0)
		playsound(charger, SFX_BEHEMOTH_ROLLING, 30)


/datum/component/charging/xenomorph/behemoth/update_charger_icon(datum/source)
	if(!charging_enabled)
		return FALSE

	var/mob/living/carbon/xenomorph/xenomorph_charger = source
	if(valid_steps_taken == max_steps_buildup)
		xenomorph_charger.icon_state = "Behemoth[(xenomorph_charger.xeno_flags & XENO_ROUNY) ? " rouny" : ""] Charging"
	else
		xenomorph_charger.icon_state = "Behemoth Rolling"
	return TRUE


/datum/component/charging/xenomorph/behemoth/update_charger_wounded_icon(datum/source)
	if(charging_enabled)
		return TRUE
	. = ..()

// ***************************************
// *********** Queen
// ***************************************

/datum/component/charging/xenomorph/crusher/queen


/datum/component/charging/xenomorph/crusher/queen/update_charger_icon(datum/source)
	if(!..())
		return FALSE
	var/mob/living/carbon/xenomorph/xenomorph_charger = source
	xenomorph_charger.icon_state = "Queen Charging"
	return TRUE







#undef CHARGE_SPEED
#undef CHARGE_MAX_SPEED

#undef STOP_CRUSHER_ON_DEL

#undef PRECRUSH_STOPPED
#undef PRECRUSH_PLOWED
#undef PRECRUSH_ENTANGLED
