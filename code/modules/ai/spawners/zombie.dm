/obj/effect/ai_node/spawner/zombie
	name = "tunnel"
	desc = "It reeks of rotten flesh and has stains of old blood and scratches."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "hole"
	invisibility = 0
	resistance_flags = UNACIDABLE|PLASMACUTTER_IMMUNE|PROJECTILE_IMMUNE
	spawntypes = list(
		/obj/effect/spawn_group_with_animation/zombie_spawn/random,
	)
	spawnamount = 2
	spawndelay = 25 SECONDS
	maxamount = 50
	///Currently is considered under threat
	var/threat_warning = FALSE
	///proxy sensor holder
	var/datum/proximity_monitor/proximity_monitor
	COOLDOWN_DECLARE(proxy_alert_cooldown)
	COOLDOWN_DECLARE(defender_spawn_cooldown)

/obj/effect/ai_node/spawner/zombie/Initialize(mapload)
	. = ..()
	GLOB.zombie_spawners += src
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips_large.dmi', null, "zombie_spawner_clear"))
	proximity_monitor = new(src, ZOMBIE_STRUCTURE_DETECTION_RANGE)

/obj/effect/ai_node/spawner/zombie/Destroy()
	. = ..()
	GLOB.zombie_spawners -= src
	SSminimaps.remove_marker(src)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ZOMBIE_TUNNEL_DESTROYED)
	QDEL_NULL(proximity_monitor)

/obj/effect/ai_node/spawner/zombie/plastique_act()
	spawn_defenders()
	playsound(loc, 'sound/effects/meteorimpact.ogg', 35, 1)
	playsound(loc, pick('sound/hallucinations/far_noise.ogg', 'sound/hallucinations/veryfar_noise.ogg'), 50, 1)
	qdel(src)

/obj/effect/ai_node/spawner/zombie/examine(mob/user)
	. = ..()
	. += span_notice("It seems like you could collapse it with a plastique explosive.")

///Called by a proximity alert, spawns defenders when a threat is detected
/obj/effect/ai_node/spawner/zombie/proc/spawn_defenders()
	var/spawn_animation = pickweight(spawntypes)
	new spawn_animation(loc, ZOMBIE_DEFENDER_AMOUNT)

/obj/effect/ai_node/spawner/zombie/HasProximity(atom/movable/hostile)
	if(iszombie(hostile))
		return

	if(!iscarbon(hostile) && !isvehicle(hostile))
		return

	if(iscarbon(hostile))
		var/mob/living/carbon/carbon_triggerer = hostile
		if(carbon_triggerer.stat == DEAD)
			return

	if(COOLDOWN_FINISHED(src, proxy_alert_cooldown))
		if(SSspawning.spawnerdata[src].max_allowed_mobs != ZOMBIE_THREATENED_CAP)
			maxamount = SSspawning.spawnerdata[src].max_allowed_mobs
		SSspawning.spawnerdata[src].max_allowed_mobs = ZOMBIE_THREATENED_CAP
		threat_warning = TRUE
		addtimer(CALLBACK(src, PROC_REF(clear_warning)), ZOMBIE_STRUCTURE_DETECTION_COOLDOWN)
		update_minimap_icon()

	if(COOLDOWN_FINISHED(src, defender_spawn_cooldown))
		spawn_defenders()
		COOLDOWN_START(src, defender_spawn_cooldown, ZOMBIE_STRUCTURE_DEFENDER_COOLDOWN)

///Clears any threat warnings
/obj/effect/ai_node/spawner/zombie/proc/clear_warning()
	threat_warning = FALSE
	update_minimap_icon()
	SSspawning.spawnerdata[src].max_allowed_mobs = maxamount

///Updates minimap icon when a threat is detected
/obj/effect/ai_node/spawner/zombie/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips_large.dmi', null, "zombie_spawner[threat_warning ? "_warn" : "_clear"]"))



/obj/effect/spawn_group_with_animation/zombie_spawn
	/// Particle holders
	var/obj/effect/abstract/particle_holder/spawning_dirt_kickup
	var/obj/effect/abstract/particle_holder/spawning_debris
	var/obj/effect/abstract/particle_holder/spawning_debris_base

/obj/effect/spawn_group_with_animation/zombie_spawn/do_spawning_effect()
	spawning_dirt_kickup = new(get_turf(src), /particles/dirt_kickup/spawning)
	spawning_debris = new(get_turf(src), /particles/falling_debris/small/spawning)
	spawning_debris_base = new(get_turf(src), /particles/falling_debris/small/spawning/base)
	playsound(loc, 'sound/zombies/tunnel_dig.ogg', 100)

/obj/effect/spawn_group_with_animation/zombie_spawn/cleanup_self()
	QDEL_NULL(spawning_dirt_kickup)
	QDEL_NULL(spawning_debris)
	QDEL_NULL(spawning_debris_base)
	return ..()

/obj/effect/spawn_group_with_animation/zombie_spawn/random
	var/spawntypes = list(list(/mob/living/carbon/human/species/zombie/ai/patrol = 85,
							/mob/living/carbon/human/species/zombie/ai/fast/patrol = 15,
							) = 95, list(/mob/living/carbon/human/species/zombie/ai/tank/patrol = 2,
							/mob/living/carbon/human/species/zombie/ai/smoker/patrol = 1,
							/mob/living/carbon/human/species/zombie/ai/hunter/patrol = 1,
							/mob/living/carbon/human/species/zombie/ai/boomer/patrol = 1,
							/mob/living/carbon/human/species/zombie/ai/elite/patrol = 1,
							) = 5,
						)

/obj/effect/spawn_group_with_animation/zombie_spawn/random/spawn_group(spawn_amount)
	var/spawntype
	for(var/i in 1 to spawn_amount)
		spawntype = pickweight(spawntypes)
		if(islist(spawntype)) //for nested spawn options
			spawntype = pickweight(spawntype)
		new spawntype(get_turf(src))

// Spawns a pack of zombies, plus a leader
/obj/effect/spawn_group_with_animation/zombie_spawn/zombie_pack
	///Leader zombie typepath
	var/leader_type = /mob/living/carbon/human/species/zombie/ai/patrol
	///Minion zombie typepath
	var/minion_type = /mob/living/carbon/human/species/zombie/ai/patrol
	///Default number of minion zombies
	var/minion_number = 6

/obj/effect/spawn_group_with_animation/zombie_spawn/zombie_pack/spawn_group(spawn_amount = 0)
	if(!spawn_amount)
		spawn_amount = minion_number

	var/leader = new leader_type(loc)
	for(var/i in 1 to spawn_amount)
		new minion_type(loc, leader)

/obj/effect/spawn_group_with_animation/zombie_spawn/zombie_pack/tank
	leader_type = /mob/living/carbon/human/species/zombie/ai/tank/patrol

/obj/effect/spawn_group_with_animation/zombie_spawn/zombie_pack/smoker
	leader_type = /mob/living/carbon/human/species/zombie/ai/smoker/patrol

/obj/effect/spawn_group_with_animation/zombie_spawn/zombie_pack/hunter
	leader_type = /mob/living/carbon/human/species/zombie/ai/hunter/patrol

/obj/effect/spawn_group_with_animation/zombie_spawn/zombie_pack/boomer
	leader_type = /mob/living/carbon/human/species/zombie/ai/boomer/patrol

/obj/effect/spawn_group_with_animation/zombie_spawn/zombie_pack/fast_pack
	leader_type = /mob/living/carbon/human/species/zombie/ai/fast/patrol
	minion_type = /mob/living/carbon/human/species/zombie/ai/fast/patrol
