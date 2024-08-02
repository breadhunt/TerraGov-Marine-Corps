
// ***************************************
// *********** Charge
// ***************************************

/datum/action/ability/xeno_action/ready_charge
	name = "Toggle Charging"
	action_icon_state = "ready_charge"
	action_icon = 'icons/Xeno/actions/crusher.dmi'
	desc = "Toggles the movement-based charge on and off."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOGGLE_CHARGE,
	)
	action_type = ACTION_TOGGLE
	use_state_flags = ABILITY_USE_LYING
	///The subtype of charging component to use. Determines the behaviour of the charge.
	var/charge_component = /datum/component/charging/xenomorph/crusher
	var/charge_ability_on = FALSE
	/// Whether charging should be activated when the ability is given.
	var/should_start_on = TRUE

/datum/action/ability/xeno_action/ready_charge/give_action(mob/living/L)
	. = ..()
	AddComponent(charge_component, owner, TRUE)
	if(should_start_on)
		charge_on()

/datum/action/ability/xeno_action/ready_charge/Destroy()
	if(charge_ability_on)
		charge_off()
	return ..()


/datum/action/ability/xeno_action/ready_charge/remove_action(mob/living/L)
	if(charge_ability_on)
		charge_off()
	return ..()


/datum/action/ability/xeno_action/ready_charge/action_activate()
	if(charge_ability_on)
		charge_off()
		return
	charge_on()


/// Toggles the charge on
/datum/action/ability/xeno_action/ready_charge/proc/charge_on()
	charge_ability_on = TRUE
	set_toggle(TRUE)
	SEND_SIGNAL(src, COMSIG_ENABLE_CHARGING_MOVEMENT)


/// Toggles the charge off
/datum/action/ability/xeno_action/ready_charge/proc/charge_off()
	charge_ability_on = FALSE
	set_toggle(FALSE)
	SEND_SIGNAL(src, COMSIG_DISABLE_CHARGING_MOVEMENT)



/datum/action/ability/xeno_action/ready_charge/bull_charge
	action_icon_state = "bull_ready_charge"
	action_icon = 'icons/Xeno/actions/bull.dmi'
	charge_component = /datum/component/charging/xenomorph/bull

/datum/action/ability/xeno_action/ready_charge/bull_charge/on_xeno_upgrade()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.upgrade < XENO_UPGRADE_PRIMO)
		SEND_SIGNAL(src, COMSIG_CHARGING_UPDATE_TURNING_LOSS, CHARGE_TURNING_DISABLED)
	SEND_SIGNAL(src, COMSIG_CHARGING_UPDATE_TURNING_LOSS, 8)



/datum/action/ability/xeno_action/ready_charge/queen_charge
	action_icon_state = "queen_ready_charge"
	action_icon = 'icons/Xeno/actions/queen.dmi'
	charge_component = /datum/component/charging/xenomorph/crusher/queen
