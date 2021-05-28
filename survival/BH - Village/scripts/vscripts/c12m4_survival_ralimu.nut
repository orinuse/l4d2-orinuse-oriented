Msg("VSCRIPT: Running c12m4_survival_ralimu SCRIPT; Orin's!\n")

DirectorOptions <-
{
	PreferredMobDirection = SPAWN_LARGE_VOLUME
	PreferredSpecialDirection = SPAWN_NEAR_IT_VICTIM

	ZombieSpawnRange = 1600
	ZombieDiscardRange = 2500
}
local ZombieSpawnRange = DirectorOptions.ZombieSpawnRange
Convars.SetValue("z_large_volume_mob_too_far_xy", ZombieSpawnRange) // Default is 1600
Convars.SetValue("z_large_volume_mob_too_far_z", ZombieSpawnRange / 12.5) // Default is 128; number can be gotten through 1600 / 12.5

// ***********************************
Convars.SetValue("scavenge_item_respawn_delay", RAND_MAX)
