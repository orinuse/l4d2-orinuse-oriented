Msg("Initiating Onslaught Mutation\n");

MutationOptions <-
{
	DisallowThreatType = ZOMBIE_WITCH

	PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS
	PreferredSpecialDirection = SPAWN_ABOVE_SURVIVORS
	cm_CommonLimit = 30
	MobMaxPending = 12

	MobSpawnMinTime = 2
	MobSpawnMaxTime = 4
	MobSpawnSize = 5
	MegaMobSize = 60

	MaxSpecials = 2
	SpecialRespawnInterval = 20

	SustainPeakMinTime = 3
	SustainPeakMaxTime = 6
	IntensityRelaxThreshold = 1.01
	RelaxMinInterval = 2
	RelaxMaxInterval = 5
	RelaxMaxFlowTravel = 400

	EnforceFinaleNavSpawnRules = true
	ShouldAllowMobsWithTank = true
	ShouldAllowSpecialsWithTank = true
	cm_WanderingZombieDensityModifier = 0.005
	NumReservedWanderers = 8
	ZombieSpawnRange = 2000
	ZombieDiscardRange = 2500

	HordeEscapeCommonLimit = 30

	MusicDynamicMobSpawnSize = 10
	MusicDynamicMobStopSize = 8
	MusicDynamicMobScanStopSize = 4

	DefaultItems =
	[
		"weapon_pistol",
		"weapon_chainsaw", //Putting this here will make the survivor drop the first pistol making duel pistol not ruin the intro cutscenes
		"weapon_pistol",
	]
	ItemsToConvert =
	[
		"weapon_pipe_bomb_spawn",
		"weapon_molotov_spawn",
		"weapon_vomitjar_spawn"
	]
	// This function is fired to a CTerrorPlayer everytime it spawns in, which includes the IDLE featire.
	// Would be an easy server DDOS yo, no good!
	/*function GetDefaultItem( idx )
	{
		if ( idx < DefaultItems.len() )
		{
			return DefaultItems[idx];
		}
		return 0;
	}*/
}

// TODO: Actually put these in tests, as this is just something to start with
function OnScriptEvent_onslaught_give_defaults( params )
{
	local player = null
	while( player = Entities.FindByClassname(player, "player") )
	{
		if( player.ValidateScriptScope() )
		{
			if( !("HasDefaultItems" in player.GetScriptScope()) )
			{
				for (local i=0; i < MutationOptions.DefaultItems.len(); i++)
					player.GiveItem( MutationOptions.DefaultItems[i].slice(7) ) // If its the right number, should make it that it ignores the 'weapon_' part.

				player.GetScriptScope()["HasDefaultItems"] <- true
			}
		}
	}
}
function OnScriptEvent_onslaught_convert_grenades( params )
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

//Don't know shit about enums so this is just to make it easier for my brain
const BUILD_UP = 0
const SUSTAIN_PEAK = 1
const PEAK_FADE = 2
const TANK_IN_PLAY = 4

const ZOMBIE_SMOKER = 1
const ZOMBIE_HUNTER = 3
const ZOMBIE_JOCKEY = 5
const ZOMBIE_CHARGER = 6

OnslaughtState =
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

	TankKiteFlowThreshold = 2500
	TankKiteFlow = null
	TankKited = false

	HighTierWeapons =
	{
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
		weapon_chainsaw = 0
		//weapon_melee = 0
		//weapon_upgradepack_incendiary = 0
		//weapon_upgradepack_explosive = 0
	}
}

function ManageOnslaughtStage( stage )
{

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
				if ( ActiveWeapon.GetClassname() in OnslaughtState.HighTierWeapons )
				{
					OnslaughtState.SurvivorQuality++
				}
			}

			if ( player.IsDead() == false || player.IsIncapacitated() == false || player.IsHangingFromLedge() == false )
			{
				OnslaughtState.SurvivorQuality++
			}
		}
	}
	OnslaughtState.SurvivorQuality = SurvivorQuality
}

function RecalculateBonusTime()
{
	OnslaughtState.BonusTimer++

	if ( OnslaughtState.FurthestFlow >= OnslaughtState.BonusTimeNextFlowDistance )
	{
		if ( OnslaughtState.BonusTime > 0 )
		{
			OnslaughtState.BonusTime -= OnslaughtState.BonusTimeIncrement
		}

		OnslaughtState.BonusTimer = 0
		OnslaughtState.BonusTimeNextFlowDistance = OnslaughtState.FurthestFlow + OnslaughtState.BonusTimeFlowThreshold
	}
	if ( OnslaughtState.BonusTimer >= OnslaughtState.BonusTimeTimerLength )
	{
		if ( OnslaughtState.BonusTime < OnslaughtState.BonusTimeMax )
		{
			OnslaughtState.BonusTime += OnslaughtState.BonusTimeIncrement
		}

		OnslaughtState.BonusTimer = 0
	}

	DirectorOptions.MobSpawnMinTime = OnslaughtState.MobSpawnTime + OnslaughtState.BonusTime
	DirectorOptions.MobSpawnMaxTime = ( OnslaughtState.MobSpawnTime + OnslaughtState.BonusTime ) * OnslaughtState.MobSpawnMaxTimeMultiplier
}

function RecalculateLimits()
{
	OnslaughtState.MobBuildUpTime++

	local SpeedPenalty = Director.GetAveragedSurvivorSpeed() / OnslaughtState.MaxSpeed
	local BuildUpMob = ( OnslaughtState.MobBuildUpTime / OnslaughtState.MobBuildUpLength ) / OnslaughtState.MobPeakMultiplier

	DirectorOptions.MobSpawnSize = (( OnslaughtState.BaseMobSpawnSize * SpeedPenalty ) + ( OnslaughtState.BaseMobSpawnSize * BuildUpMob )) * OnslaughtState.MobBuildUpMultiplier

	if ( OnslaughtState.MobBuildUpTime == OnslaughtState.MobBuildUpLength )
	{
		ManageOnslaughtStage( SUSTAIN_PEAK )
	}
}

function SustainPeak()
{
	OnslaughtState.PeakTimer++
	if ( Director.GetAveragedSurvivorSpeed() < OnslaughtState.PeakFlowThreshold && OnslaughtState.PeakTimer >= OnslaughtState.PeakLength )
	{
		ManageOnslaughtStage( PEAK_FADE )
	}

	if ( OnslaughtState.PeakTimer > OnslaughtState.PeakLength * OnslaughtState.ExtremePeakTimeMultipler )
	{
		DirectorOptions.MaxSpecials = OnslaughtState.ExtremePeakMaxSpecials

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
		OnslaughtState.PeakFadeTimer++
		if ( PeakFadeTimer == PeakFadeLength )
		{
			ManageOnslaughtStage( BUILD_UP )
		}
	}
	else {
		OnslaughtState.PeakFadeTimer = 0
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
		switch( OnslaughtState.OnslaughtStage )
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

function OnGameEvent_round_start_post_nav( params )
{
	FireScriptEvent("onslaught_give_defaults", {})
	FireScriptEvent("onslaught_convert_grenades", {})
	OnslaughtState.MaxFlow = GetMaxFlowDistance()
}
