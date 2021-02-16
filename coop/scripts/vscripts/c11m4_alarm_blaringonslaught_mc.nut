Msg("VSCRIPT: c11m4_alarm_blaringonslaught_mc.nut\n");

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

	MinimumStageTime = ALARM_DURATION // for info_director
}
Director.ResetMobTimer()

local spawn_zombie_alarm2 = null
while( spawn_zombie_alarm2 = Entities.FindByName(spawn_zombie_alarm2, "spawn_zombie_alarm2") )
{
	EntFire("!self", "SpawnZombie", null, (RandomFloat(0, 0.2)), spawn_zombie_alarm2)
	EntFire("!self", "RunScriptCode", "RushVictim(null, 8000)", 0.3, spawn_zombie_alarm2)
}
StartAssault()
EntFire("securityalarmsparksidle1_modded", "StopSpark")
EntFire("@director", "EndCustomScriptedStage", null, ALARM_DURATION)
EntFire("alarm_off_relay", "Trigger", null, ALARM_DURATION)