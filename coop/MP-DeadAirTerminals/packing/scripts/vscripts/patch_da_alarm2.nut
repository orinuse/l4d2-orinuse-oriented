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

	// Defaults to ANYWHERE if the preferred position is considered ineffective by the Director
	PreferredMobPosition = Vector(2973.925, 2174.885, 152.031) // First set of blue chairs the survivors see
	PreferredMobPositionRange = 500
	PreferredMobDirection = SPAWN_NEAR_POSITION
	PreferredSpecialDirection = SPAWN_SPECIALS_ANYWHERE

	MinimumStageTime = ALARM_DURATION // for director_debug, doesn't reliably turn shit off for me in a ScriptedPanicEvent
}
Director.ResetMobTimer()

for ( local ent=null; ent = Entities.FindByName( ent, "spawn_zombie_alarm2" ); )
{
	EntityOutputs.AddOutput( ent, "OnSpawnNormal", "!self", "RunScriptCode", "RushVictim(null, 8000)", 0.1, -1 )
	EntFire( "!activator", "SpawnZombie", null, RandomFloat(0.1, 0.3), ent )
}
EntFire("@director", "RunScriptCode", "StartAssault()", 0.1)
EntFire("@director", "EndScript", null, ALARM_DURATION)
EntFire("alarm_off_relay", "Trigger", null, ALARM_DURATION)
