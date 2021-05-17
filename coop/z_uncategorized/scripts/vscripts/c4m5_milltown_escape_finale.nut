
//-----------------------------------------------------
local PANIC = 0
local TANK = 1
local DELAY = 2
//-----------------------------------------------------

// default finale patten - for reference only //pattern*. I fixed it valve!

const A_StageDelay = 10

const B_StageDelay = 12

const C_StageDelay = 5

const D_StageDelay = 10


const PreEscapeDelay = 15

DirectorOptions <-
{
	//-----------------------------------------------------

	// 3 waves of mobs in between tanks

	A_CustomFinale_StageCount = 8
	B_CustomFinale_StageCount = 8
	C_CustomFinale_StageCount = 8
	D_CustomFinale_StageCount = 10

//Option A
	A_CustomFinale1 = PANIC
	A_CustomFinaleValue1 = 2 //1
	A_CustomFinaleMusic1 = ""
	
	A_CustomFinale2 = DELAY
	A_CustomFinaleValue2 = A_StageDelay
	A_CustomFinaleMusic2 = ""
	
	A_CustomFinale3 = TANK
	A_CustomFinaleValue3 = 1
	A_CustomFinaleMusic3 = ""
	
	A_CustomFinale4 = DELAY
	A_CustomFinaleValue4 = A_StageDelay
	A_CustomFinaleMusic4 = ""
	
	A_CustomFinale5 = PANIC
	A_CustomFinaleValue5 = 2 //1
	A_CustomFinaleMusic5 = "Event.FinaleWave4"
	
	A_CustomFinale6 = DELAY
	A_CustomFinaleValue6 = A_StageDelay
	A_CustomFinaleMusic6 = ""
	
	A_CustomFinale7 = TANK
	A_CustomFinaleValue7 = 1
	A_CustomFinaleMusic7 = ""
	
	A_CustomFinale8 = DELAY
	A_CustomFinaleValue8 = PreEscapeDelay
	A_CustomFinaleMusic8 = ""

//Option B
	B_CustomFinale1 = PANIC
	B_CustomFinaleValue1 = 2
	B_CustomFinaleMusic1 = ""
	
	B_CustomFinale2 = DELAY
	B_CustomFinaleValue2 = B_StageDelay
	B_CustomFinaleMusic2 = ""
	
	B_CustomFinale3 = TANK
	B_CustomFinaleValue3 = 1
	B_CustomFinaleMusic3 = ""
	
	B_CustomFinale4 = DELAY
	B_CustomFinaleValue4 = B_StageDelay
	B_CustomFinaleMusic4 = ""
	
	B_CustomFinale5 = PANIC
	B_CustomFinaleValue5 = 3
	B_CustomFinaleMusic5 = "Event.FinaleWave4"
	
	B_CustomFinale6 = DELAY
	B_CustomFinaleValue6 = B_StageDelay
	B_CustomFinaleMusic6 = ""
	
	B_CustomFinale7 = TANK
	B_CustomFinaleValue7 = 1
	B_CustomFinaleMusic7 = ""
	
	B_CustomFinale8 = DELAY
	B_CustomFinaleValue8 = PreEscapeDelay
	B_CustomFinaleMusic8 = ""

//Option C
	C_CustomFinale1 = PANIC
	C_CustomFinaleValue1 = 1
	C_CustomFinaleMusic1 = ""
	
	C_CustomFinale2 = DELAY
	C_CustomFinaleValue2 = C_StageDelay
	C_CustomFinaleMusic2 = ""
	
	C_CustomFinale3 = TANK
	C_CustomFinaleValue3 = 1
	C_CustomFinaleMusic3 = ""
	
	C_CustomFinale4 = DELAY
	C_CustomFinaleValue4 = C_StageDelay
	C_CustomFinaleMusic4 = ""
	
	C_CustomFinale5 = PANIC
	C_CustomFinaleValue5 = 1
	C_CustomFinaleMusic5 = "Event.FinaleWave4"
	
	C_CustomFinale6 = DELAY
	C_CustomFinaleValue6 = PreEscapeDelay
	C_CustomFinaleMusic6 = ""
	
	C_CustomFinale7 = TANK
	C_CustomFinaleValue7 = 2
	C_CustomFinaleMusic7 = ""
	
	C_CustomFinale8 = DELAY
	C_CustomFinaleValue8 = PreEscapeDelay
	C_CustomFinaleMusic8 = ""

//Option D
	D_CustomFinale1 = TANK
	D_CustomFinaleValue1 = 1
	D_CustomFinaleMusic1 = ""
	
	D_CustomFinale2 = DELAY
	D_CustomFinaleValue2 = D_StageDelay
	D_CustomFinaleMusic2 = ""
	
	D_CustomFinale3 = PANIC
	D_CustomFinaleValue3 = 1
	D_CustomFinaleMusic3 = ""
	
	D_CustomFinale4 = DELAY
	D_CustomFinaleValue4 = D_StageDelay
	D_CustomFinaleMusic4 = ""
	
	D_CustomFinale5 = TANK
	D_CustomFinaleValue5 = 1
	D_CustomFinaleMusic5 = ""
	
	D_CustomFinale6 = DELAY
	D_CustomFinaleValue6 = D_StageDelay
	D_CustomFinaleMusic6 = ""
	
	D_CustomFinale7 = PANIC
	D_CustomFinaleValue7 = 2
	D_CustomFinaleMusic7 = "Event.FinaleWave4"
	
	D_CustomFinale8 = DELAY
	D_CustomFinaleValue8 = D_StageDelay
	D_CustomFinaleMusic8 = ""
	
	D_CustomFinale9 = TANK //This and later can show up at random after the final stage of other options lul, I find it fun tho
	D_CustomFinaleValue9 = 1
	D_CustomFinaleMusic9 = ""

	D_CustomFinale10 = DELAY
	D_CustomFinaleValue10 = PreEscapeDelay
	D_CustomFinaleMusic10 = ""


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
local TankStage = 0

local logic_director_query = null
while( logic_director_query = Entities.FindByClassname(logic_director_query , "logic_director_query" ) )
{
	if ( logic_director_query.GetName() != "ldq_stormtime" )
		break
}

function OnBeginCustomFinaleStage( num, type )
{
	printl( "Stage: " + num + " Type: " + type )
	local RandomTime = RandomInt( 0, 10 )

	if ( type == TANK )
	{
		printl( "TAANK!!!" );

		if ( TankStage >= 1 )
			DirectorOptions.ShouldAllowSpecialsWithTank = true

		TankStage++

		EntFire( "fx_skybox_general_lightning", "Stop", "", RandomTime )
		EntFire( "relay_storm_start", "Trigger", "", RandomTime )

		EntFire( "timer_stormtime", "RefireTime", 9999, RandomTime + 3.5)
		EntFire( "timer_stormtime", "ResetTimer", "", RandomTime + 3.6)

		EntityOutputs.RemoveOutput( logic_director_query, "On20SecondsToMob", "relay_storm_start", "Trigger", "" ) //Just in time Valve
	}
	else
	{
		if ( TankStage < 2 ) //Perma storm after second tank
		{
			printl( "Tank Stage Cleared!" );
			EntFire( "timer_stormtime", "FireTimer", "", RandomTime )
			EntityOutputs.AddOutput( logic_director_query, "On20SecondsToMob", "relay_storm_start", "Trigger", "", 15, -1 )
		}
	}
}

/*
*/
