Msg("Initiating Gauntlet Upgraded\n");

DirectorOptions <-
{
	PanicForever = true
	PausePanicWhenRelaxing = true

	IntensityRelaxThreshold = 0.99
	RelaxMinInterval = 3
	RelaxMaxInterval = 5
	RelaxMaxFlowTravel = 400

	LockTempo = 0
	SpecialRespawnInterval = 20
	PreTankMobMax = 30
	ZombieSpawnRange = 3000
	ZombieSpawnInFog = true

	MobSpawnSize = 3
	MobSpawnMinTime = 5
	MobSpawnMaxTime = 5

	MobMaxPending = 15
	CommonLimit = 30

	GauntletMovementThreshold = 600.0
	GauntletMovementTimerLength = 6.0
	GauntletMovementBonus = 1.0
	GauntletMovementBonusMax = 10.0 //Would make 6 the max bonus time but made it 10 instead for teams who need it
}

GrenadeDeletus <- [
	"weapon_pipe_bomb_spawn", "weapon_molotov_spawn", "weapon_vomitjar_spawn"
]

//TODO: Check for grenades near survivors and dont convert them to ammo upgrades when the script starts
for (local i = 0 ; i < GrenadeDeletus.len() ; i++)
{
	local ent = null
	while( ent = Entities.FindByClassname(ent , GrenadeDeletus[i] ) )
	{
		local item_angles = ent.GetAngles();
		local item_origin = ent.GetOrigin();

		local kvs =
		{
			angles = item_angles.ToKVString(),
			origin = item_origin.ToKVString(),
			disableshadows = 1,
			solid = 6,
		}
		if ( RandomInt(0,1) == 1 )
		{
			SpawnEntityFromTable( "weapon_upgradepack_explosive_spawn", kvs );
		}
		else
		{
			SpawnEntityFromTable( "weapon_upgradepack_incendiary_spawn", kvs );
		}
		ent.Kill()
	}
}

//Variables
CommonLimitMax <- 30

//Max Flow to test progress against.
//TODO: Check if the trigger_finale exist
//NOTE: Actually fuck checking for the trigger_finale max flow alone will do

MaxFlow <- ( GetMaxFlowDistance() ) / 1.2

printl( "Max Flow: " + MaxFlow );

MobSpawnSizeReference <- 12

MaxSpeed <- 175

MobBuildUpMin <- 40
MobBuildUpMax <- 48
MobBuildUpLength <- RandomInt( MobBuildUpMin , MobBuildUpMax )
MobBuildUpTime <- 0.0

MobPeakFlowThreshold <- 50
MobPeakLength <- 20
MobPeakTimer <- 0

function RecalculateLimits()
{
	printl("Build Up Time:" + MobBuildUpTime);
	//Increase mobs based on progress 
	local ProgressPenalty = (( Director.GetFurthestSurvivorFlow() ) / MaxFlow )
	if ( ProgressPenalty < 0.0 )
	{
		ProgressPenalty = 0.0
	}
	if ( ProgressPenalty > 1.0 )
	{
		ProgressPenalty = 1.0
	}
	printl( "Progress Penalty: " + ProgressPenalty );

	//Increase mobs based on speed
	local SpeedPenalty = ( Director.GetAveragedSurvivorSpeed() / MaxSpeed )
	if ( SpeedPenalty > 1.0 )
	{
		SpeedPenalty = 1.0
	}
	printl( "Speed Penalty: " + SpeedPenalty );

	//Build Up Mob
	local BuildUpMob = (( MobBuildUpTime / MobBuildUpLength ) / 2 )

	if ( MobBuildUpTime >= MobBuildUpLength )
	{
		MobPeakTimer += 1

		if ( Director.GetAveragedSurvivorSpeed() < MobPeakFlowThreshold && MobPeakTimer >= MobPeakLength )
		{
			printl("Phase: Build Up");
			MobBuildUpLength = RandomInt( MobBuildUpMin , MobBuildUpMax )
			MobBuildUpTime = 0
			MobPeakTimer = 0
		}
		else
		{
			BuildUpMob *= 2
			printl("Phase: PEAK!");
		}
	}
	printl( "Build Up Mob Size: " + BuildUpMob );
	
	//Get the average between the two plus BuildUpMob
	DirectorOptions.MobSpawnSize = ((( MobSpawnSizeReference * ProgressPenalty ) + ( MobSpawnSizeReference * SpeedPenalty )) / 2) + (( MobSpawnSizeReference * BuildUpMob ) * 1.25)

	DirectorOptions.CommonLimit = DirectorOptions.MobSpawnSize * 1.5
	if ( DirectorOptions.CommonLimit > CommonLimitMax )
	{
		DirectorOptions.CommonLimit = CommonLimitMax
	}
}

function Update()
{
	MobBuildUpTime += 1.0
	RecalculateLimits();
}