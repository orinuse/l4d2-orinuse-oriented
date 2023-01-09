// Dead Air - Terminals DLC Patches, of Orin's
// Copyright ©️ 2021 Orinuse (http://steamcommunity.com/profiles/76561198294712284)
//// For full details on the license, see the addon / repository's main folder.
//==================================================================
// This script might be a little messy; I maintained this the least and made this the earliest
Msg("VSCRIPT [Orin]: Running 'c11m4_patch_alarm_blaring' SCRIPT;\n");

const ALARM_DURATION = 10
DirectorOptions <-
{
	// One of these when true, disables the Mob spawn cues I think
	LockTempo = true	// This works as the VDC describes
	PanicForever = true	// test this more

	MobMinSize = 5
	MobMaxSize = 7
	MobSpawnMinTime = 1
	MobSpawnMaxTime = 1
	MobMaxPending = 30
//	I don't think this belongs here, but with that StageInfo_Execute() function
/*	SpawnSetPosition = Vector(2700.272217, 3429.643555, 152.031250)
	SpawnSetRadius = 800
	SpawnSetRule = SPAWN_POSITIONAL

	PreferredMobDirection = SPAWN_POSITIONAL */
	PreferredMobDirection = SPAWN_FAR_AWAY_FROM_SURVIVORS
	PreferredSpecialDirection = SPAWN_SPECIALS_ANYWHERE

	MinimumStageTime = ALARM_DURATION // for director_debug, doesn't reliably turn shit off for me in a ScriptedPanicEvent
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
EntFire("@director", "AdvanceFinaleState", null, ALARM_DURATION)
EntFire("alarm_off_relay", "Trigger", null, ALARM_DURATION)
