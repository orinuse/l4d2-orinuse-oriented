Msg("Initiating C11M4 Onslaught ADDON\n");

DirectorOptions <-
{
	LockTempo = true
	MaxSpecials = 3
	DominatorLimit = 2
	SmokerLimit = 2
	PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS
	PreferredSpecialDirection = SPAWN_SPECIALS_ANYWHERE
}
local spawn_zombie_alarm2 = null
while( spawn_zombie_alarm2 = Entities.FindByName(spawn_zombie_alarm2, "spawn_zombie_alarm2") )
	EntFire("!self", "SpawnZombie", null, (RandomFloat(0.2, 0.4)), spawn_zombie_alarm2)

local director = null
if( director = Entities.FindByName(director, "@director") )
{
	// Auto creates a script scope if it doesnt exist
	// without this, GetScriptScope() returns: (null : 0x00000000)
	if( director.ValidateScriptScope() )
	{
		local scrscope = director.GetScriptScope()
		scrscope["OnPanicEventFinishedV"] <- function()
		{
			Msg("Ending C11M4 Onslaught ADDON\n")
			EntFire("@director", "EndScript")
		}
		// when the alarm breaks down, this is fired
		scrscope["OnUserDefinedScriptEvent1V"] <- function()
		{
			local DirectorOptions = g_MapScript.LocalScript.DirectorOptions
			DirectorOptions.LockTempo = false
			EntFire("securityalarmsparksidle1_modded", "StopSpark")
			EntFire("securityalarmsparksidle1_modded", "Kill", null, 0.1)
		}
		director.ConnectOutput("OnPanicEventFinished", "OnPanicEventFinishedV()")
		director.ConnectOutput("OnUserDefinedScriptEvent1", "OnUserDefinedScriptEvent1V()")
	}
}
