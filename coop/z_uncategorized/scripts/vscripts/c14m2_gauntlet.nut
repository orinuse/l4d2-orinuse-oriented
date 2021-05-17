//Could be abused by picking up gascans very slowly //Infinite CI and SI solves the problem

Msg("Beginning Lighthouse Scavenge Upgraded.\n")
DirectorOptions <-
{
	CommonLimit = 5
	MobSpawnMinTime = 10
	MobSpawnMaxTime = 12
	MobSpawnSize = 3
	MobMaxPending = 5
	IntensityRelaxThreshold = 0.99
	RelaxMinInterval = 2
	RelaxMaxInterval = 4
	RelaxMaxFlowTravel = 400
	SpecialRespawnInterval = 30
	LockTempo = false
	PreferredMobDirection = SPAWN_ANYWHERE
	PanicForever = true
}

if ( Director.GetGameModeBase() == "versus" )
	DirectorOptions.MobSpawnSize = 4;

Director.ResetMobTimer();

local CommonMin = 5
local CommonMax = 20
local MobMin = 3

local DirectorIntensity = 0
local DirectorIntensityMax = 40
local DirectorIntensityMin = 0

function RecalculateLimits()
{
	DirectorOptions.MobSpawnSize = MathRound( DirectorIntensity / 4 ) + MobMin
	DirectorOptions.CommonLimit = MathRound( DirectorOptions.MobSpawnSize * 1.5 ) + CommonMin

	if ( DirectorOptions.CommonLimit > CommonMax )
		DirectorOptions.CommonLimit = CommonMax
}

function GasCanTouched()
{
	DirectorIntensity += 3
	if ( DirectorIntensity > DirectorIntensityMax )
		DirectorIntensity = DirectorIntensityMax

	GasCansTouched++;
	if ( developer() > 0 )
		Msg(" Touched: " + GasCansTouched + "\n");
}

function GasCanPoured()
{
	//Summon mobs before increasing the intensity to be more forgiving to teams who pour one at a time //You should still pour all at once lmao
	Director.ResetMobTimer()

	DirectorIntensityMin += 1
	DirectorIntensity += 8
	if ( DirectorIntensity > DirectorIntensityMax )
		DirectorIntensity = DirectorIntensityMax

	GasCansPoured++;
	ScavengeCansPoured++;
	if ( developer() > 0 )
		Msg(" Poured: " + GasCansPoured + "\n");

	if ( GasCansPoured == 1 )
		EntFire( "explain_fuel_generator", "Kill" );
	else if ( GasCansPoured == NumCansNeeded )
	{
		DirectorOptions.MobMaxPending = 30
		if ( developer() > 0 )
			Msg(" needed: " + NumCansNeeded + "\n");
		EntFire( "relay_generator_ready", "Trigger", "", 0.1 );
		EntFire( "weapon_scavenge_item_spawn", "TurnGlowsOff" );
		EntFire( "weapon_scavenge_item_spawn", "Kill" );
		EntFire( "director", "EndCustomScriptedStage", "", 5 );
	}
	
	if ( Director.GetGameModeBase() == "versus" && ScavengeCansPoured == 2 && GasCansPoured < NumCansNeeded )
	{
		ScavengeCansPoured = 0;
		EntFire( "radio", "AdvanceFinaleState" );
	}
}

function Update()
{
	RecalculateLimits();
	if ( DirectorIntensity > DirectorIntensityMin )
		DirectorIntensity--
}

function MathRound(floatnum)
{
	local floornum = floor(floatnum)
	local ceilnum = ceil(floatnum)
	if(floatnum - floornum >= 0.5)
		return ceilnum
	else
		return floatnum
}
