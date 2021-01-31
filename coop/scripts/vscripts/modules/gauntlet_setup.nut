Msg("VSCRIPT: Running gauntlet_setup.nut\n");

local this_script_scope = this
local DirectorOptions = g_MapScript.LocalScript.DirectorOptions 

// we need some kind of notation that this is custom, not official
MC_Gauntlet <-
{
	Options <-
	{
		MC_GauntletCommonLimitMin = 5
		MC_GauntletCommonLimitMax = 30
		MC_GauntletMobSpawnTimeMin = 2
		MC_GauntletMobSpawnTimeMax = 4

		MC_GauntletCommonRecheckDelay = 3
		MC_GauntletFlowThresholdEasy = 400
		MC_GauntletFlowThresholdNormal = 350
		MC_GauntletFlowThresholdAdvanced = 300
		MC_GauntletFlowThresholdExpert = 250
	}
	State <-
	{
		MaxMapFlow = GetMaxFlowDistance()
		InitialSurvivorFlow = Director.GetFurthestSurvivorFlow()
		RecheckCount = 0
	}
}

function StartGauntletFlowLogic(optionstable)
{	
	// we'll only want to setup idle gauntlet logic, so lets not modify DirectorOptions
	local GauntletOptions = MC_Gauntlet.Options
	foreach( idx, val in GauntletOptions )
	{
		if( idx in optionstable )
			GauntletOptions[idx] = optionstable[idx]
	}
	try
		DirectorOptions.CommonLimit = GauntletOptions.MC_GauntletCommonLimitMin
	catch(exception)
		DirectorOptions <- CommonLimit = GauntletOptions.MC_GauntletCommonLimitMin

	// Now, the game's slower rethink function
	this_script_scope.Update <- function()
	{
		local GauntletOptions = MC_Gauntlet.Options
		local GauntletState = MC_Gauntlet.State
		local GauntletFlowThreshold = 0
		local curdiff = Convars.GetStr("z_difficulty")
		switch( curdiff )
		{
			case "Easy":
			{
				GauntletFlowThreshold = GauntletOptions.MC_GauntletFlowThresholdEasy
				break
			}
			case "Normal":
			{
				GauntletFlowThreshold = GauntletOptions.MC_GauntletFlowThresholdNormal
				break
			}
			case "Hard":
			{
				GauntletFlowThreshold = GauntletOptions.MC_GauntletFlowThresholdAdvanced
				break
			}
			case "Impossible":
			{
				GauntletFlowThreshold = GauntletOptions.MC_GauntletFlowThresholdExpert
				break
			}

		}

		if(  Director.GetFurthestSurvivorFlow() - GauntletState.InitialSurvivorFlow >= GauntletFlowThreshold )
		{
			printl("I AM ANGRY")
			DirectorOptions.CommonLimit++
			// value clamping
			if( DirectorOptions.CommonLimit < MC_GauntletCommonLimitMin )
				DirectorOptions.CommonLimit = MC_GauntletCommonLimitMin
			if( DirectorOptions.CommonLimit < MC_GauntletCommonLimitMax )
				DirectorOptions.CommonLimit = MC_GauntletCommonLimitMax
		}
	}
}

// stocks
// function GetSurvivorCount()
// {
// 	local count = 0
// 	local player;
// 	while( player = Entities.FindByClassname(player, "player") )
// 	{
// 		/* This format is used to keep consistency with the Director which also
// 		* uses 0.0 for calm and 1.0 for stressed */
// 		if( player.IsSurvivor() )
// 			count++
// 	}
// 	return count
// }

// function GetAveragedSurvivorIntensity()
// {
// 	local survivorintensity_array = []
// 	//Setup
// 	local player;
// 	while( player = Entities.FindByClassname(player, "player") )
// 	{
// 		/* This format is used to keep consistency with the Director which also
// 		* uses 0.0 for calm and 1.0 for stressed */
// 		if( player.IsSurvivor() )
// 			survivorintensity_array.append( (GetPropInt(player, "m_clientIntensity")) / 100 )
// 	}
// 	// Calculate
// 	local totalteamintensity = 0
// 	foreach( val in survivorintensity_array )
// 		totalteamintensity = totalteamintensity + survivorintensity_array[i]

// 	return totalteamintensity / (survivorintensity_array.len()-1)
// }
// REF:
OnslaughtOptions <-
{
	MobSpawnSize = 5
	CommonLimit = 5

	GauntletMovementThreshold = 500.0
	GauntletMovementTimerLength = 5.0
	GauntletMovementBonus = 2.0
	GauntletMovementBonusMax = 30.0

	// length of bridge to test progress against.
	BridgeSpan = 20000

	MobSpawnMinTime = 5
	MobSpawnMaxTime = 5

	MobSpawnSizeMin = 5
	MobSpawnSizeMax = 20

	minSpeed = 50
	maxSpeed = 200

	speedPenaltyZAdds = 15

	CommonLimitMax = 30
}
