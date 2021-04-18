Msg("Initiating Onslaught Mutation\n");

DirectorOptions <-
{
	// This turns off tanks and witches.
	//ProhibitBosses = true
	DisallowThreatType = ZOMBIE_WITCH

	PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS
	PreferredSpecialDirection = SPAWN_ABOVE_SURVIVORS
	cm_CommonLimit = 30
	MobMaxPending = 10
	
	MobSpawnMinTime = 4
	MobSpawnMaxTime = 6
	MobSpawnSize = 5
	MegaMobSize = 60

	MaxSpecials = 2
	SpecialRespawnInterval = 20

	SustainPeakMinTime = 3
	SustainPeakMaxTime = 6
	IntensityRelaxThreshold = 1.01
	RelaxMinInterval = 3
	RelaxMaxInterval = 6
	RelaxMaxFlowTravel = 400

	EnforceFinaleNavSpawnRules = true
	ShouldAllowMobsWithTank = true 
	ShouldAllowSpecialsWithTank = true
	AlwaysAllowWanderers = true
	cm_WanderingZombieDensityModifier = 0.01
	//IntensityRelaxAllowWanderersThreshold = 0.99
	NumReservedWanderers = 10
	ZombieSpawnRange = 2500
	ZombieDiscardRange = 3500

	HordeEscapeCommonLimit = 30

	MusicDynamicMobSpawnSize = 10
	MusicDynamicMobStopSize = 8
	MusicDynamicMobScanStopSize = 4

	weaponsToConvert =
	{
		weapon_pipe_bomb =	"weapon_upgradepack_explosive"
		weapon_vomitjar =	"weapon_upgradepack_explosive"
		weapon_molotov =	"weapon_upgradepack_incendiary"
	}

	function ConvertWeaponSpawn( classname )
	{
		if ( classname in weaponsToConvert && Convars.GetStr( "z_difficulty" ).tolower() != "impossible" )
		{
			return weaponsToConvert[classname];
		}
		return 0;
	}	

	DefaultItems =
	[
		"weapon_pistol",
		"weapon_chainsaw", //Putting this here will make the survivor drop the first pistol making duel pistol not ruin the intro cutscenes
		"weapon_pistol",
	]

	function GetDefaultItem( idx )
	{
		if ( idx < DefaultItems.len() )
		{
			return DefaultItems[idx];
		}
		return 0;
	}
}

//Variables

const ZOMBIE_SMOKER = 1
const ZOMBIE_HUNTER = 3
const ZOMBIE_JOCKEY = 5
const ZOMBIE_CHARGER = 6
const ZOMBIE_TANK = 8
const MAXSPEED = 175

local CommonLimitMax = DirectorOptions.cm_CommonLimit
local MaxFlow = null
local FurthestFlow = null
local FurthestEscapeFlow = 3000
local FurthestSpawnBehindFlow = 1000

MobBuildUpMin <- 48
MobBuildUpMax <- 60
MobBuildUpLength <- RandomInt( MobBuildUpMin, MobBuildUpMax )
MobBuildUpTime <- 0.0

MobPeakFlowThreshold <- 50
MobPeakLength <- 20
MobPeakTimer <- 0

TankKiteDistance <- 2000
local SurvivorTankKiteDistance = null
local SurvivorTankKited = 0

HighTierWeapons <- {
	weapon_autoshotgun = 0
	weapon_rifle = 0
	weapon_hunting_rifle = 0
	weapon_rifle_desert = 0
	weapon_sniper_military = 0
	weapon_shotgun_spas = 0
	weapon_grenade_launcher = 0
	weapon_rifle_ak47 = 0
	weapon_rifle_sg552 = 0
	weapon_sniper_awp = 0
	weapon_rifle_m60 = 0
	//weapon_melee = 0
	weapon_chainsaw = 0
	weapon_upgradepack_incendiary = 0
	weapon_upgradepack_explosive = 0
}

function RecalculateLimits()
{
	MobBuildUpTime += 1.0
	FurthestFlow = Director.GetFurthestSurvivorFlow()
	local BaseMobSpawnSize = 10


	local SurvivorWeaponTier = 0
	local ActiveWeapon = null
	local player = null
	while( player = Entities.FindByClassname(player, "player") )
	{
		if ( player.IsSurvivor() )
		{
			ActiveWeapon = player.GetActiveWeapon()
			//printl( "Active Weapon: " + ActiveWeapon )
			if ( ActiveWeapon != null )
			{
				if ( ActiveWeapon.GetClassname() in HighTierWeapons )
				{
					SurvivorWeaponTier++
				}
			}
		}
	}
	BaseMobSpawnSize += SurvivorWeaponTier

	local SpeedPenalty = Director.GetAveragedSurvivorSpeed() / MAXSPEED
	local BuildUpMob = ( MobBuildUpTime / MobBuildUpLength ) / 2

	if ( FurthestFlow > MaxFlow - FurthestEscapeFlow )
	{
		MobBuildUpTime += 2
		if ( FurthestFlow > MaxFlow - FurthestSpawnBehindFlow )
		{
			DirectorOptions.PreferredMobDirection = SPAWN_BEHIND_SURVIVORS
		}
	}

	if ( Director.IsTankInPlay() )
	{	
		if ( SurvivorTankKited == 0 )
		{
			MobBuildUpTime = 0.0
			SpeedPenalty = 0.0
			BuildUpMob = 0.1
			if ( SurvivorTankKiteDistance == null )
			{
				SurvivorTankKiteDistance = FurthestFlow + TankKiteDistance
			}
			else {
				if ( FurthestFlow > SurvivorTankKiteDistance )
				{
					printl("TANK KITED!")
					SurvivorTankKited = 1
					MobBuildUpTime = MobBuildUpLength
				}
			}
		}
	}

	if ( MobBuildUpTime >= MobBuildUpLength )
	{
		MobPeakTimer += 1
		if ( Director.GetAveragedSurvivorSpeed() < MobPeakFlowThreshold && MobPeakTimer >= MobPeakLength )
		{
			MobBuildUpLength = RandomInt( MobBuildUpMin , MobBuildUpMax )
			MobBuildUpTime = 0
			MobPeakTimer = 0
			if ( developer() )
			{
				printl( "======================================" )
				printl("Phase: Build Up")
			}
		}
		else
		{
			BuildUpMob *= 2
			if ( developer() )
			{
				printl( "======================================" )
				printl("Phase: PEAK!")
			}
		}
		// commons can only do so much when people start rushing
		if ( MobPeakTimer > MobPeakLength * 2 )
		{
			if ( developer() )
				printl("Extreme Anger: Bombing more specials")

			++DirectorOptions.MaxSpecials
			if ( DirectorOptions.MaxSpecials > 4 )
				DirectorOptions.MaxSpecials = 4

			local randnum = RandomInt(1,4)
			switch( randnum )
			{	// lazy to wrap them in brackets, converses one line space at the same time
				case 1:
					ZSpawn( { type = ZOMBIE_SMOKER } ); break
				case 2:
					ZSpawn( { type = ZOMBIE_HUNTER } ); break
				case 3:
					ZSpawn( { type = ZOMBIE_JOCKEY } ); break
				case 4:
					ZSpawn( { type = ZOMBIE_CHARGER } ); break
			}
		}
		else
		{
			--DirectorOptions.MaxSpecials
			if ( DirectorOptions.MaxSpecials < 2 )
				DirectorOptions.MaxSpecials = 2
		}
	}

	if ( developer() )
	{
		printl( "======================================" )

		printl( "Base Mob Size: " + BaseMobSpawnSize )
		printl( "Build Up Time: " + MobBuildUpTime )
		printl( "Build Up Length: " + MobBuildUpLength )
		printl( "Speed Penalty: " + SpeedPenalty )
		printl( "Build Up Mob Size: " + BuildUpMob )
	}
	
	//Get the average between the two plus BuildUpMob
	DirectorOptions.MobSpawnSize = ( BaseMobSpawnSize * SpeedPenalty ) + (( BaseMobSpawnSize * BuildUpMob ))
	//DirectorOptions.cm_CommonLimit = DirectorOptions.MobSpawnSize * 1.5
	//if ( DirectorOptions.cm_CommonLimit > CommonLimitMax )
	//	DirectorOptions.cm_CommonLimit = CommonLimitMax
}

const MobSpawnTimeMin = 4
const MobSpawnTimeMax = 6

const BonusTimeFlowThreshold = 400
const BonusTimeTimerLength = 8
const BonusTimeIncrement = 1
const BonusTimeMax = 10

local BonusTimeNextFlowDistance = 0
local BonusTimer = 0 // I'm too lazy to make a global timer lul
local BonusTime = 0

function RecalculateBonusTime()
{
	BonusTimer++

	if ( FurthestFlow >= BonusTimeNextFlowDistance )
	{
		BonusTimer = 0

		if ( BonusTime > 0 )
		{
			BonusTime -= BonusTimeIncrement
		}
		BonusTimeNextFlowDistance = FurthestFlow + BonusTimeFlowThreshold
	}

	if ( BonusTimer >= BonusTimeTimerLength )
	{
		if ( BonusTime < BonusTimeMax )
		{
			BonusTime += BonusTimeIncrement
		}
		BonusTimer = 0

		//BonusTimeNextFlowDistance = FurthestFlow + BonusTimeFlowThreshold //Made mob spawn too slow for slow teams 
	}

	if ( developer() )
	{
		printl( "======================================" )

		printl( "Mob Spawn Min Time: " + DirectorOptions.MobSpawnMinTime )
		printl( "Mob Spawn Max Time: " + DirectorOptions.MobSpawnMaxTime )
		printl( "Bonus Time Next Flow Distance: " + BonusTimeNextFlowDistance )
		printl( "Bonus Time : " + BonusTimer )
		printl( "Bonus Time: " + BonusTime )
	}

	DirectorOptions.MobSpawnMinTime = MobSpawnTimeMin + BonusTime
	DirectorOptions.MobSpawnMaxTime = MobSpawnTimeMax + BonusTime
}

local finaleStarted = 0
local panicEvent = 0
local finaleWave = 0

function Update()
{
	if ( Director.HasAnySurvivorLeftSafeArea() && panicEvent == 0 )
	{
		RecalculateLimits();
		if ( finaleStarted == 0 )
		{
			RecalculateBonusTime();
		}
		else {
			DirectorOptions.MobSpawnMinTime = MobSpawnTimeMin
			DirectorOptions.MobSpawnMaxTime = MobSpawnTimeMax
		}
	}
}

function OnGameEvent_tank_killed( params ) {
	printl( "Tank Killed!" );
	SurvivorTankKited = 0
	SurvivorTankKiteDistance = null
}

function OnGameEvent_player_now_it( params ) {
	MobBuildUpTime = 0.0
}

function OnGameEvent_player_no_longer_it( params ) {
	MobBuildUpTime = 0.0
}

function OnGameEvent_create_panic_event( params ) {
	printl( "PANIC!" );
	panicEvent = 1
	DirectorOptions.MobMaxPending = 1000
	//	DirectorOptions.cm_CommonLimit = 30
	DirectorOptions.PreferredMobDirection = SPAWN_ANYWHERE
	if ( finaleStarted == 1 ) 
	{
		finaleWave++
		DirectorOptions.PreferredMobDirection = SPAWN_FAR_AWAY_FROM_SURVIVORS
		if ( finaleWave == 2 ) {
			printl( "WAVE 2!" );
			DirectorOptions.cm_CommonLimit = 30
			DirectorOptions.MegaMobSize = 100

			local player = null
			while( player = Entities.FindByClassname(player, "player") )
			{
				EmitSoundOnClient( "Event.FinaleWave4", player )
			}
		}
	}
}

function OnGameEvent_panic_event_finished( params ) {
	printl( "Panic event finished!" );
	panicEvent = 0
	DirectorOptions.MobMaxPending = 10
	MobBuildUpTime = 0.0
	DirectorOptions.PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS
}

function OnGameEvent_finale_start( params ) {
	printl( "Finale started!" );
	finaleStarted = 1
	DirectorOptions.cm_CommonLimit = 25
	DirectorOptions.MegaMobSize = 75
	DirectorOptions.MobSpawnSize = 5
	DirectorOptions.ZombieSpawnRange = 6000
	DirectorOptions.ZombieDiscardRange = 8000
	DirectorOptions.NumReservedWanderers = 0
}

function OnGameEvent_finale_escape_start( params ) {
	printl( "ESCAPE!" );
	DirectorOptions.cm_CommonLimit = 30
	DirectorOptions.HordeEscapeCommonLimit = 30
	DirectorOptions.MobSpawnSize = 100

	MobBuildUpTime = MobBuildUpTime
	MobBuildUpLength = 9999
	//ZSpawn( { type = ZOMBIE_TANK } )
}

function OnGameEvent_finale_vehicle_ready( params ) {
	printl( "Rescue vehicle ready!" );
	DirectorOptions.cm_CommonLimit = 40
	DirectorOptions.HordeEscapeCommonLimit = 40
	ZSpawn( { type = ZOMBIE_TANK } )
}

function OnGameEvent_finale_vehicle_leaving( params ) {
	printl( "Rescue vehicle leaving!" );
	DirectorOptions.cm_CommonLimit = 60
	DirectorOptions.HordeEscapeCommonLimit = 60
	ZSpawn( { type = ZOMBIE_TANK } )
}

function OnGameEvent_round_start_post_nav( params ) {
	MaxFlow = GetMaxFlowDistance()
	printl( "Max Flow: " + MaxFlow )
}
//pls help