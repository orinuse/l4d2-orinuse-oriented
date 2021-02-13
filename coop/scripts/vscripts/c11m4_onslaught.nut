Msg("Initiating C11M4 Onslaught ADDON\n");

const ZOMBIE_WITCH = 7
DirectorOptions <-
{
	LockTempo = true
	PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS
	PreferredSpecialDirection = SPAWN_BEHIND_SURVIVORS
}
while( spawn_zombie_alarm2 = Entities.FindByName(spawn_zombie_alarm2, "spawn_zombie_alarm2") )
	EntFire("!self", "SpawnZombie", null, (RandomFloat(0.2, 0.4)), spawn_zombie_alarm2)

local director = null
if( director = Entities.FindByName(director, "@director") )
{
	// Auto creates a script scope if it doesnt exist
	// without this, GetScriptScope() returns: (null : 0x00000000)
	director.ValidateScriptScope()
	local scrscope = director.GetScriptScope()
	scrscope["OnPanicEventFinishedV"] <- function()
	{
		local DirectorOptions = g_MapScript.LocalScript.DirectorOptions
		DirectorOptions.PreferredMobDirection = SPAWN_NO_PREFERENCE
		DirectorOptions.PreferredSpecialDirection = SPAWN_NO_PREFERENCE
		EntFire("@director", "EndScript")
	}
	scrscope["OnUserDefinedScriptEventV"] <- function()
	{
		local DirectorOptions = g_MapScript.LocalScript.DirectorOptions
		DirectorOptions.LockTempo = false
	}
	director.ConnectOutput("OnPanicEventFinished", "OnPanicEventFinishedV()")
	director.ConnectOutput("OnUserDefinedScriptEvent1", "OnUserDefinedScriptEventV()")
}