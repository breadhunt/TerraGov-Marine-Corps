/obj/effect/ai_node/spawner
	name = "AI spawner node"
	invisibility = INVISIBILITY_OBSERVER
	/**
	 * Possible spawn typepaths
	 * Can support a single typepath, a list of typepaths, or a list of lists
	 * Uses pickweight for selection
	 */
	var/list/spawntypes
	///Amount of types to spawn for each squad created
	var/spawnamount
	///Delay between squad spawns, dont set this to below SSspawning wait
	var/spawndelay = 4 SECONDS
	///Max amount of
	var/maxamount = 5
	///Whether we want to use the postspawn proc on the mobs created by the Spawner
	var/use_postspawn = FALSE

//Example implementation;
/obj/effect/ai_node/spawner/Initialize(mapload)
	if(!spawntypes || !spawnamount)
		stack_trace("Invalid spawn parameters on AI spawn node, deleting")
		return INITIALIZE_HINT_QDEL
	if(spawndelay < SSspawning.wait)
		stack_trace("Spawndelay  too low, deleting AI spawner node")
		return INITIALIZE_HINT_QDEL
	. = ..()
	SSspawning.registerspawner(src, spawndelay, spawntypes, maxamount, spawnamount, use_postspawn ? CALLBACK(src, PROC_REF(postspawn)) : null)

///This proc runs on the created mobs if use_postspawn   is enabled, use this to equip humans and such
/obj/effect/ai_node/spawner/proc/postspawn(list/squad)
	return

/// Spawn objects/datums/whatever with a fancy spawning animation
/obj/effect/spawn_group_with_animation
	/// How long should we wait to run spawning logic?
	var/spawn_effect_time = 2.5 SECONDS

/obj/effect/spawn_group_with_animation/Initialize(mapload, spawn_amount)
	. = ..()
	do_spawning_effect()
	addtimer(CALLBACK(src, PROC_REF(spawn_group), spawn_amount), spawn_effect_time)
	addtimer(CALLBACK(src, PROC_REF(cleanup_self)), spawn_effect_time + 1 SECONDS) //wait a second for spawning to finish

/// Spawning animation logic here, length of animation until spawning is defined by spawn_effect_time
/obj/effect/spawn_group_with_animation/proc/do_spawning_effect()

/// Spawning logic; override and spawn whatever you want.
/obj/effect/spawn_group_with_animation/proc/spawn_group(spawn_amount)

/// Clean up after ourselves once the spawning is complete
/obj/effect/spawn_group_with_animation/proc/cleanup_self()
	qdel(src)
