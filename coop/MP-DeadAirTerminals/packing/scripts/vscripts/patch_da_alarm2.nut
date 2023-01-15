// This script might be a little messy; I maintained this the least and made this the earliest
Msg("VSCRIPT [Orin]: Running 'patch_da_alarm2' \n");

const ALARM_DURATION = 10
DirectorOptions <-
{
	MobMinSize = 5
	MobMaxSize = 7
	MobSpawnMinTime = 1
	MobSpawnMaxTime = 1
	MobMaxPending = 30

	PreferredMobPosition = Vector(2700.272, 3429.644, 152.031) // Behind pile of luggage in hallway
	PreferredMobPositionRange = 800 // Range of navmeshes for mob spawning a survivor must be close enough to, otherwise defaults to ANYWHERE
	PreferredMobDirection = SPAWN_NEAR_POSITION

	//PreferredMobDirection = SPAWN_FAR_AWAY_FROM_SURVIVORS
	PreferredSpecialDirection = SPAWN_SPECIALS_ANYWHERE

	MinimumStageTime = ALARM_DURATION // for director_debug, doesn't reliably turn shit off for me in a ScriptedPanicEvent
}
Director.ResetMobTimer()

for ( local ent=null; ent = Entities.FindByName( ent, "spawn_zombie_alarm2" ); )
{
	EntityOutputs.AddOutput( ent, "OnSpawnNormal", "!self", "RunScriptCode", "RushVictim(null, 8000)", 0.1, -1 )
	DoEntFire( "!self", "SpawnZombie", "", RandomFloat(0.1, 0.3), null, ent )
}
EntFire("@director", "RunScriptCode", "StartAssault()", 0.1)
EntFire("@director", "EndScript", null, ALARM_DURATION)
EntFire("alarm_off_relay", "Trigger", null, ALARM_DURATION)
