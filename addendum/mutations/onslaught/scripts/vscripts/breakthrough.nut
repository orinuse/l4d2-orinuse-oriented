Msg("VSCRIPT: Running 'breakthrough'\n");
Msg("++ Prototypes by Boomer; Migrations and Refinements by Orin ++\n");
::g_BreakthroughDirector <- {}
IncludeScript("breakthrough_director", ::g_BreakthroughDirector)
MutationOptions <-
{
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
}
StartBreakthroughDirector(MutationOptions)

// Supplementary 'Director' Options, using events
function OnGameEvent_round_start_post_nav( params )
{
	FireScriptEvent("breakthrough_give_defaults", {})
	FireScriptEvent("breakthrough_director_convert_grenades", {})
//	OnslaughtState.MaxFlow = GetMaxFlowDistance()
}
function OnScriptEvent_breakthrough_give_defaults( params )
{
	local player = null
	while( player = Entities.FindByClassname(player, "player") )
	{
		if( player.ValidateScriptScope() )
		{
			if( !("HasDefaultItems" in player.GetScriptScope()) )
			{
				local DefaultItems = MutationOptions.DefaultItems
				for (local i=0; i < DefaultItems.len(); i++)
					player.GiveItem( DefaultItems[i].slice(7) ) // If its the right number, should make it that it ignores the 'weapon_' part.

				player.GetScriptScope()["HasDefaultItems"] <- true
			}
		}
	}
}
//-----------------------------------------------------------------------------
//		++	ONSLAUGHT - DRAMATIC PACING ++
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

function OnGameEvent_round_start_post_nav( params )
{
	FireScriptEvent("onslaught_give_defaults", {})
	FireScriptEvent("onslaught_convert_grenades", {})
	OnslaughtState.MaxFlow = GetMaxFlowDistance()
}

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

	TankKiteFlowThreshold = 2500	// PSA: CustomTankKiteDistance by its name, is meant to limit how far ahead you can run from a Tank before any CI makes an appearance.
									// Though, it also sets when a Tank appears initially, iirc, so... lmao?
	TankKiteFlow = null
	TankKited = false

	HighTierWeapons =
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
