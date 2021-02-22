
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
	
	A_CustomFinale2 = DELAY
	A_CustomFinaleValue2 = 10
	
	A_CustomFinale3 = TANK
	A_CustomFinaleValue3 = 1
	
	A_CustomFinale4 = DELAY
	A_CustomFinaleValue4 = 10
	
	A_CustomFinale5 = PANIC
	A_CustomFinaleValue5 = 2 //1
	A_CustomFinaleMusic5 = "Event.FinaleWave4" //Doesn't really fit l4d2 but why not
	
	A_CustomFinale6 = DELAY
	A_CustomFinaleValue6 = 10
	
	A_CustomFinale7 = TANK
	A_CustomFinaleValue7 = 1 //Tested with 2 lmao, didn't go so well
	
	A_CustomFinale8 = DELAY
	A_CustomFinaleValue8 = 15
	 
	 
	HordeEscapeCommonLimit = 20 //15
	CommonLimit = 20
	SpecialRespawnInterval = 55 //80

	//Added

	//Hopefully adding these would make the infected surround the building instead of storming from a few directions at a time
	PreferredMobDirection = SPAWN_FAR_AWAY_FROM_SURVIVORS //Tested with SPAWN_ANYWHERE, SPAWN_NO_PREFERRENCE and this seems to work best
	ZombieSpawnInFog = true
	ZombieSpawnRange = 3000
}


if ( "DirectorOptions" in LocalScript && "ProhibitBosses" in LocalScript.DirectorOptions )
{
	delete LocalScript.DirectorOptions.ProhibitBosses
}

/*
*/