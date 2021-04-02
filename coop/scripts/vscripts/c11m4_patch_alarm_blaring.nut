Msg("VSCRIPT: Running c11m4_patch_alarm_blaring.nut\n");

const ALARM_DURATION = 10

DirectorOptions <-
{
	LockTempo = true
	PanicForever = true

	MobMinSize = 5
	MobMaxSize = 7
	MobSpawnMinTime = 1
	MobSpawnMaxTime = 1
	MobMaxPending = 30

	SpawnSetPosition = Vector(2700.272217, 3429.643555, 152.031250)
	SpawnSetRadius = 800
	SpawnSetRule = SPAWN_POSITIONAL

	PreferredMobDirection = SPAWN_POSITIONAL
	PreferredSpecialDirection = SPAWN_SPECIALS_ANYWHERE

	MinimumStageTime = ALARM_DURATION // for director_debug, doesn't reliably turn shit off for me
}
Director.ResetMobTimer()

local spawn_zombie_alarm2 = null
while( spawn_zombie_alarm2 = Entities.FindByName(spawn_zombie_alarm2, "spawn_zombie_alarm2") )
{
//	EntFire("!self", "AddOutput", "OnSpawnNormal !self:RunScriptCode:RushVictim(null, 8000):0.1:-1", 0, spawn_zombie_alarm2)
	EntityOutputs.AddOutput(spawn_zombie_alarm2, "OnSpawnNormal", "!self", "RunScriptCode", "RushVictim(null, 8000)", 0.1, -1)
	EntFire("!self", "SpawnZombie", null, (RandomFloat(0.1, 0.3)), spawn_zombie_alarm2)
}

EntFire("@director", "RunScriptCode", "StartAssault()", 0.1)
EntFire("@director", "EndCustomScriptedStage", null, ALARM_DURATION)
EntFire("alarm_off_relay", "Trigger", null, ALARM_DURATION)