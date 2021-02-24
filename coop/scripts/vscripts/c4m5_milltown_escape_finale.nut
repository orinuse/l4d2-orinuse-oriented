
//-----------------------------------------------------
local PANIC = 0
local TANK = 1
local DELAY = 2
//-----------------------------------------------------

// default finale patten - for reference only //pattern*. I fixed it valve!

/*
CustomFinale1 <- PANIC
CustomFinaleValue1 <- 2

CustomFinale2 <- DELAY
CustomFinaleValue2 <- 10

CustomFinale3 <- TANK
CustomFinaleValue3 <- 1

CustomFinale4 <- DELAY
CustomFinaleValue4 <- 10

CustomFinale5 <- PANIC
CustomFinaleValue5 <- 2

CustomFinale6 <- DELAY
CustomFinaleValue6 <- 10

CustomFinale7 <- TANK
CustomFinaleValue7 <- 1

CustomFinale8 <- DELAY
CustomFinaleValue8 <- 2
*/

DirectorOptions <-
{
	//-----------------------------------------------------

	// 3 waves of mobs in between tanks

	A_CustomFinale_StageCount = 8
	
	A_CustomFinale1 = PANIC
	A_CustomFinaleValue1 = 2 //1
	A_CustomFinaleMusic1 = ""
	
	A_CustomFinale2 = DELAY
	A_CustomFinaleValue2 = 10
	A_CustomFinaleMusic2 = ""
	
	A_CustomFinale3 = TANK
	A_CustomFinaleValue3 = 1
	A_CustomFinaleMusic3 = ""
	
	A_CustomFinale4 = DELAY
	A_CustomFinaleValue4 = 10
	A_CustomFinaleMusic4 = ""
	
	A_CustomFinale5 = PANIC
	A_CustomFinaleValue5 = 2 //1
	A_CustomFinaleMusic5 = "Event.FinaleWave4" //Doesn't really fit l4d2 but why not
	
	A_CustomFinale6 = DELAY
	A_CustomFinaleValue6 = 10
	A_CustomFinaleMusic6 = ""
	
	A_CustomFinale7 = TANK
	A_CustomFinaleValue7 = 1 //Tested with 2 lmao, didn't go so well
	A_CustomFinaleMusic7 = ""
	
	A_CustomFinale8 = DELAY
	A_CustomFinaleValue8 = 15
	A_CustomFinaleMusic8 = ""

	HordeEscapeCommonLimit = 20 //15
	CommonLimit = 20
	SpecialRespawnInterval = 55 //80
	ShouldAllowSpecialsWithTank = false

	//Added

	//Hopefully adding these would make the infected surround the building instead of storming from a few directions at a time
	PreferredMobDirection = SPAWN_NEAR_IT_VICTIM //Tested with SPAWN_ANYWHERE, SPAWN_NO_PREFERRENCE, SPAWN_FAR_AWAY_FROM_SURVIVORS and this seems to work best
	ZombieSpawnInFog = true
	ZombieSpawnRange = 3000
}


if ( "DirectorOptions" in LocalScript && "ProhibitBosses" in LocalScript.DirectorOptions )
{
	delete LocalScript.DirectorOptions.ProhibitBosses
}

//Should we kill the logic_director_query? I'm keeping it to add some randomness to the storm and make it seem non-scripted a bit less
//TODO: Remove the output from the logic_director_query
local isTankStage = 0
local TankStage = 0

local logic_director_query = null
while( logic_director_query = Entities.FindByClassname(logic_director_query , "logic_director_query" ) )
{
	if ( logic_director_query.GetName() != "ldq_stormtime" )
		break
}

function OnBeginCustomFinaleStage( num, type )
{
	local RandomTime = RandomInt( 0, 10 )

	if ( type == TANK )
	{
		printl( "TAANK!!!" );
		isTankStage = 1

		if ( TankStage >= 1 )
			DirectorOptions.ShouldAllowSpecialsWithTank = true
		else
			TankStage++

		EntFire( "fx_skybox_general_lightning", "Stop", "", RandomTime )
		EntFire( "relay_storm_start", "Trigger", "", RandomTime )

		EntFire( "timer_stormtime", "RefireTime", 9999, RandomTime + 3.5)
		EntFire( "timer_stormtime", "ResetTimer", "", RandomTime + 3.6)

		EntityOutputs.RemoveOutput( logic_director_query, "On20SecondsToMob", "relay_storm_start", "Trigger", "" ) //Just in time Valve
	}
	else
	{
		if ( isTankStage == 1 && num < DirectorOptions.A_CustomFinale_StageCount )
		{
			printl( "Tank Stage Cleared!" );
			isTankStage = 0
			EntFire( "timer_stormtime", "FireTimer", "", RandomTime )
			EntityOutputs.AddOutput( logic_director_query, "On20SecondsToMob", "relay_storm_start", "Trigger", "", 15, -1 )
		}
	}
}

/*
*/
