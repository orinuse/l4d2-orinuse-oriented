Msg("VSCRIPT: Running c12m4_survival_ralimu.nut; Orin's!\n")

DirectorOptions <-
{
	PreferredMobDirection = SPAWN_LARGE_VOLUME
	PreferredSpecialDirection = SPAWN_LARGE_VOLUME

	ZombieSpawnRange = 2500
	ZombieDiscardRange = 3000
}

function OnGameEvent_create_panic_event(params)
{
	local spawn_zombie_run = null
	while( spawn_zombie_run = Entities.FindByName(spawn_zombie_run, "spawn_zombie_run") )
	{
		if( RandomInt(0,2) == 2 )
			EntFire("!self", "SpawnZombie", "", 0, spawn_zombie_run)
	}
}
