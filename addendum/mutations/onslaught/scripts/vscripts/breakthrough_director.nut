Msg("VSCRIPT: Running 'breakthrough_director';\n");
Msg("++ Founded by Boomer; Migrations and Customization support by Orin ++\n");
//-----------------------------------------------------------------------------
//		++	ONSLAUGHT - STRUCTURE SETUP ++
//-----------------------------------------------------------------------------
function StartBreakthroughDirector( options )
{
	Assert( type(options) != "table", "StartBreakthroughDirector() only accepts tables!" )
	local BaseOnslaughtOptions =
	{
		DisallowThreatType = DirectorScript.ZOMBIE_WITCH
		CommonLimit = 30
		MobSpawnSize = 5
		MegaMobSize = 60
		MobMaxPending = 12
		MobSpawnMinTime = 2
		MobSpawnMaxTime = 4
		PreferredMobDirection = DirectorScript.SPAWN_IN_FRONT_OF_SURVIVORS

		MaxSpecials = 2
		SpecialRespawnInterval = 20
		PreferredSpecialDirection = DirectorScript.SPAWN_ABOVE_SURVIVORS

		NumReservedWanderers = 8
		WanderingZombieDensityModifier = 0.005
		EnforceFinaleNavSpawnRules = true // ?
		ShouldAllowMobsWithTank = true
		ShouldAllowSpecialsWithTank = true
		ZombieSpawnRange = 2000
		ZombieDiscardRange = 2500

		SustainPeakMinTime = 3
		SustainPeakMaxTime = 6
		IntensityRelaxThreshold = 1.01
		RelaxMinInterval = 2
		RelaxMaxInterval = 5
		RelaxMaxFlowTravel = 400
		MusicDynamicMobSpawnSize = 10
		MusicDynamicMobStopSize = 8
		MusicDynamicMobScanStopSize = 4
	}
	foreach( key, val in BaseOnslaughtOptions )
	{
		if( !(key in options) )
			options[key] <- val
	}
}

//-----------------------------------------------------------------------------
//		++	ONSLAUGHT STATE - DRAMATIC PACING ++
//-----------------------------------------------------------------------------
//Don't know shit about enums so this is just to make it easier for my brain
const BUILD_UP = 0
const SUSTAIN_PEAK = 1
const PEAK_FADE = 2
const TANK_IN_PLAY = 4

const ZOMBIE_SMOKER = 1
const ZOMBIE_HUNTER = 3
const ZOMBIE_JOCKEY = 5
const ZOMBIE_CHARGER = 6

OSX =
{
	OnslaughtStage = BUILD_UP
	MaxFlow = GetMaxFlowDistance()
	FurthestFlow = null

	BaseMobSpawnSize = 1
	SurvivorQuality = 0
	MaxSpeed = 175

	MobSpawnTime = 2
	MobSpawnMaxTimeMultiplier = 2

	MobBuildUpMin = 40
	MobBuildUpMax = 60
	MobBuildUpLength = RandomInt( MobBuildUpMin, MobBuildUpMax )
	MobBuildUpTime = 0.0
	MobBuildUpMultiplier = 0.5

	PeakMovementThreshold = 64
	PeakLength = 15
	PeakTimer = 0
	ExtremePeakTimeMultipler = 2
	ExtremePeakMaxSpecials = 4

	PeakFadeLength = 12
	PeakFadeTimer = 0

	BonusTimeFlowThreshold = 400
	BonusTimeTimerLength = 8
	BonusTimeIncrement = 1
	BonusTimeMax = 5
	BonusTimeNextFlowDistance = 0
	BonusTimer = 0
	BonusTime = 0

	TankKiteFlowThreshold = 2500	// PSA: CustomTankKiteDistance by its name, is meant to limit how far ahead you can run from a Tank before any CI makes an appearance.
									// Though, it also sets when a Tank appears initially, iirc, so... lmao?
	TankKiteFlow = null
	TankKited = false
}
HighTierWeapons <-
{
	"weapon_autoshotgun",
	"weapon_rifle",
	"weapon_hunting_rifle",
	"weapon_rifle_desert",
	"weapon_sniper_military",
	"weapon_shotgun_spas",
	"weapon_grenade_launcher",
	"weapon_rifle_ak47",
	"weapon_rifle_sg552",
	"weapon_sniper_awp",
	"weapon_rifle_m60",
	"weapon_chainsaw",
	//weapon_melee,
	//weapon_upgradepack_incendiary,
	//weapon_upgradepack_explosive,
}

function OnScriptEvent_breakthrough_director_convert_grenades( params )
{
	local ItemsToConvert = MutationOptions.ItemsToConvert
	//This must be fired with round_start_post_nav, otherwise a problem occurs where the grenade is killed but the upgradepack dont spawn
	for (local i = 0 ; i < ItemsToConvert.len() ; i++)
	{
		local ent = null
		while( ent = Entities.FindByClassname(ent , ItemsToConvert[i] ) )
		{
			local kvs =
			{
				angles = ent.GetAngles().ToKVString(),
				origin = ent.GetOrigin().ToKVString(),
				disableshadows = 1,
				solid = 6,
			}

			local RandomNum = RandomInt(0,4)
			if ( RandomNum == 0 )
				SpawnEntityFromTable( "weapon_upgradepack_explosive", kvs )
			else if ( RandomNum == 1 )
				SpawnEntityFromTable( "weapon_upgradepack_incendiary", kvs )

			ent.Kill()
		}
	}
}
function GetSurvivorsInfo()
{
	local SurvivorQuality = 0
	while( player = Entities.FindByClassname(player, "player") )
	{
		if ( player.IsSurvivor() )
		{
			local ActiveWeapon = player.GetActiveWeapon()
			if ( ActiveWeapon )
			{
				if ( ActiveWeapon.GetClassname() in HighTierWeapons )
				{
					OSX.SurvivorQuality++
				}
			}

			if ( player.IsDead() == false || player.IsIncapacitated() == false || player.IsHangingFromLedge() == false )
			{
				OSX.SurvivorQuality++
			}
		}
	}
	OSX.SurvivorQuality = SurvivorQuality
}

function RecalculateBonusTime()
{
	OSX.BonusTimer++

	if ( OSX.FurthestFlow >= OSX.BonusTimeNextFlowDistance )
	{
		if ( OSX.BonusTime > 0 )
		{
			OSX.BonusTime -= OSX.BonusTimeIncrement
		}

		OSX.BonusTimer = 0
		OSX.BonusTimeNextFlowDistance = OSX.FurthestFlow + OSX.BonusTimeFlowThreshold
	}
	if ( OSX.BonusTimer >= OSX.BonusTimeTimerLength )
	{
		if ( OSX.BonusTime < OSX.BonusTimeMax )
		{
			OSX.BonusTime += OSX.BonusTimeIncrement
		}

		OSX.BonusTimer = 0
	}

	DirectorOptions.MobSpawnMinTime = OSX.MobSpawnTime + OSX.BonusTime
	DirectorOptions.MobSpawnMaxTime = ( OSX.MobSpawnTime + OSX.BonusTime ) * OSX.MobSpawnMaxTimeMultiplier
}

function RecalculateLimits()
{
	OSX.MobBuildUpTime++

	local SpeedPenalty = Director.GetAveragedSurvivorSpeed() / OSX.MaxSpeed
	local BuildUpMob = ( OSX.MobBuildUpTime / OSX.MobBuildUpLength ) / OSX.MobPeakMultiplier

	DirectorOptions.MobSpawnSize = (( OSX.BaseMobSpawnSize * SpeedPenalty ) + ( OSX.BaseMobSpawnSize * BuildUpMob )) * OSX.MobBuildUpMultiplier

	if ( OSX.MobBuildUpTime == OSX.MobBuildUpLength )
	{
		ManageOnslaughtStage( SUSTAIN_PEAK )
	}
}

function SustainPeak()
{
	OSX.PeakTimer++
	if ( Director.GetAveragedSurvivorSpeed() < OSX.PeakFlowThreshold && OSX.PeakTimer >= OSX.PeakLength )
	{
		ManageOnslaughtStage( PEAK_FADE )
	}

	if ( OSX.PeakTimer > OSX.PeakLength * OSX.ExtremePeakTimeMultipler )
	{
		DirectorOptions.MaxSpecials = OSX.ExtremePeakMaxSpecials

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
}

function PeakFade()
{
	if ( Director.GetPendingMobCount() == 0 )
	{
		OSX.PeakFadeTimer++
		if ( PeakFadeTimer == PeakFadeLength )
		{
			ManageOnslaughtStage( BUILD_UP )
		}
	}
	else {
		OSX.PeakFadeTimer = 0
	}
}

function TankInPlay()
{

}

function Update()
{
	if ( Director.HasAnySurvivorLeftSafeArea() )
	{
		GetSurvivorsInfo()
		RecalculateBonusTime()
		switch( OSX.OnslaughtStage )
		{
			case BUILD_UP:
			{
				RecalculateLimits()
				break;
			}
			case SUSTAIN_PEAK:
			{
				RecalculateLimits()
				SustainPeak()
				break;
			}
			case PEAK_FADE:
			{
				PeakFade()
				break;
			}
			case TANK_IN_PLAY:
			{
				TankInPlay()
				break;
			}
		}
	}
}
