Msg("VSCRIPT: Running director_gauntlet.nut ADDON\n");

DirectorOptions <-
{
	PanicForever = true
	PausePanicWhenRelaxing = true

	// Do these do anything 
	IntensityRelaxThreshold = 0.99
	RelaxMinInterval = 3
	RelaxMaxInterval = 6
	RelaxMaxFlowTravel = 800

	SpecialRespawnInterval = 20
	PreTankMobMax = 20
	ZombieSpawnRange = 3000
	ZombieSpawnInFog = true

	MobSpawnSize = 5 //These guys spawn when the finale start. Make it low or high
	MobSpawnMinTime = 5
	MobSpawnMaxTime = 5

	MobMaxPending = 5
	CommonLimit = 30
	// Setting this to 1000.0 makes the gauntlet felt a little formulated
	// The original threshold was really bad lol
	//// Note: Is it true that bonus time prevents new CIs from spawning?
	GauntletMovementThreshold = 800
	GauntletMovementTimerLength = 6
	GauntletMovementBonus = 2
	GauntletMovementBonusMax = 10.0 //Would make 6 the max bonus time but made it 10 instead for teams who need it

	MusicDynamicMobSpawnSize = 6
	MusicDynamicMobStopSize = 4
	MusicDynamicMobScanStopSize = 3
}

local GrenadeDeletus =
[
	"weapon_pipe_bomb_spawn", "weapon_molotov_spawn", "weapon_vomitjar_spawn"
]

//TODO: Check for grenades near survivors and dont convert them to ammo upgrades when the script starts
//// we'll use flow to determine, for now
for (local i = 0 ; i < GrenadeDeletus.len() ; i++)
{
	local ent = null
	while( ent = Entities.FindByClassname(ent , GrenadeDeletus[i] ) )
	{
		local kvs =
		{
			angles = ent.GetAngles().ToKVString(),
			origin = ent.GetOrigin().ToKVString(),
			disableshadows = 1,
			solid = 6,
		}

		if ( RandomInt(0,1) == 1 )
			SpawnEntityFromTable( "weapon_upgradepack_explosive_spawn", kvs );
		else
			SpawnEntityFromTable( "weapon_upgradepack_incendiary_spawn", kvs );

		ent.Kill()
	}
}

//Variables
const ZOMBIE_SMOKER = 1
const ZOMBIE_HUNTER = 3
const ZOMBIE_JOCKEY = 5
const ZOMBIE_CHARGER = 6
const ZOMBIE_TANK = 8
const MAXSPEED = 175

local CommonLimitMax = DirectorOptions.CommonLimit
local BaseMobSpawnSize = 12

//Max Flow to test progress against.
local InitialSurvivorFlow = Director.GetFurthestSurvivorFlow()
local MaxFlow = ( GetMaxFlowDistance() - InitialSurvivorFlow ) / 1.2

if( developer() )
{
	printl( "Initial Survivor Flow: " + InitialSurvivorFlow );
	printl( "Max Flow: " + MaxFlow );
}
// I can't take it anymore I need a way to organize code
GauntletState <-
{
	MobBuildUpMin = 40
	MobBuildUpMax = 48
	MobBuildUpLength = 44
	MobBuildUpTime = 0.0

	MobPeakFlowThreshold = 50
	MobPeakLength = 20
	MobPeakTimer = 0

	IsEscapeSequence = 0
}
GauntletState.MobBuildUpLength = RandomInt( GauntletState.MobBuildUpMin, GauntletState.MobBuildUpMax )

function RecalculateLimits()
{
	//// Do These:
	// Increase mobs based on progress (DONT)
	// Increase mobs based on speed
	// Build Up Mob since it doesn't by itself
	////
	local SpeedPenalty = Director.GetAveragedSurvivorSpeed() / MAXSPEED
	local BuildUpMob = ( GauntletState.MobBuildUpTime / GauntletState.MobBuildUpLength ) / 2

	if ( GauntletState.IsEscapeSequence ) 
		BuildUpMob = 1.0

	local MobBuildUpMin = GauntletState.MobBuildUpMin
	local MobBuildUpMax = GauntletState.MobBuildUpMax
	local MobBuildUpLength = GauntletState.MobBuildUpLength
	local MobBuildUpTime = GauntletState.MobBuildUpTime

	local MobPeakFlowThreshold = GauntletState.MobPeakFlowThreshold
	local MobPeakLength = GauntletState.MobPeakLength
	local MobPeakTimer = GauntletState.MobPeakTimer

	local IsEscapeSequence = GauntletState.IsEscapeSequence

	if ( MobBuildUpTime >= MobBuildUpLength )
	{
		MobPeakTimer += 1
		if ( Director.GetAveragedSurvivorSpeed() < GauntletState.MobPeakFlowThreshold && GauntletState.MobPeakTimer >= GauntletState.MobPeakLength )
		{
			MobBuildUpLength = RandomInt( MobBuildUpMin , MobBuildUpMax )
			MobBuildUpTime = 0
			MobPeakTimer = 0
			if ( developer() )
				printl("Phase: Build Up")
		}
		else
		{
			BuildUpMob *= 2
			if ( developer() )
				printl("Phase: PEAK!")
		}
		// commons can only do so much when people start rushing
		if ( MobPeakTimer > MobPeakLength * 2 )
		{
			if ( developer() )
				printl("Extreme Anger: Bombing more specials")

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

	if ( developer() )
	{
		printl( "Build Up Time:" + MobBuildUpTime );
		printl( "Speed Penalty: " + SpeedPenalty );
		printl( "Survivor Progress: " + ((Director.GetFurthestSurvivorFlow() - InitialSurvivorFlow ) / MaxFlow) )
		printl( "Build Up Mob Size: " + BuildUpMob );
	}
	
	//Get the average between the two plus BuildUpMob
	DirectorOptions.MobSpawnSize = ( BaseMobSpawnSize * SpeedPenalty ) + (( BaseMobSpawnSize * BuildUpMob ) * 1.25)
	DirectorOptions.CommonLimit = DirectorOptions.MobSpawnSize * 1.5
	if ( DirectorOptions.CommonLimit > CommonLimitMax )
		DirectorOptions.CommonLimit = CommonLimitMax

}

function Update()
{
	GauntletState.MobBuildUpTime += 1.0
	RecalculateLimits();
}

//This is here to amplify the mobs when the escape hits
function OnGameEvent_finale_vehicle_ready( params ) {
	GauntletState.IsEscapeSequence = 1
}

//Lower the mob after the tank dies
function OnGameEvent_player_incapacitated( params )
{
	local player = GetPlayerFromUserID( params.userid )
	if( player.GetZombieType() == ZOMBIE_TANK )
		GauntletState.MobBuildUpTime = 0.0
}

// Yeah why not
EntFire("info_director", "RunScriptFile", Director.GetMapName()+"_"+"gauntlet", 1)