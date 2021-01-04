Msg("Initiating Fuck_you c6m3_survival Script\n");

DirectorOptions <-
{
	CommonLimit = 30
	ZombieSpawnRange = 2250
	ZombieDiscardRange = 3500
}

NavMesh.UnblockRescueVehicleNav()

//Spawns L4D1 Survivors
EntFire( "info_l4d1_survivor_spawn", "SpawnSurvivor", "", 0.0 )

EntFire( "!francis", "SetGlowEnabled", "0", 0.0 )
EntFire( "!zoey", "SetGlowEnabled", "0", 0.0 )
EntFire( "!louis", "SetGlowEnabled", "0", 0.0 )

EntFire( "!francis", "TeleportToSurvivorPosition", "francis_station", 0.0 )
EntFire( "!zoey", "TeleportToSurvivorPosition", "zoey_station", 0.0 )

EntFire( "!francis", "ReleaseFromSurvivorPosition", "francis_station", 1.0 )
EntFire( "!zoey", "ReleaseFromSurvivorPosition", "zoey_station", 1.0 )
EntFire( "!louis", "ReleaseFromSurvivorPosition", "zoey_station", 1.0 )

EntFire( "l4d1_nav_blocker", "UnblockNav", "", 1.0 )

//Teleport ammo to the L4D1 Survivors
timer_done <- false;
last_set <- Time();

function Update()
{
	//Msg("Yes");
	if(!timer_done && Time() >= last_set + 0.5)
	{
		timer_done = true;

		local ammospawn_ent = null;
		local ammospawn_count = 0;

		while( ammospawn_ent = Entities.FindByClassname(ammospawn_ent, "weapon_ammo_spawn" ))
		{
			ammospawn_count += 1;
			printl("FOUND #" + ammospawn_count.tostring() + " WEAPON_AMMO_SPAWN")
			if( ammospawn_count == 1)
			{
			//	ammospawn_ent.SetModel("models/props/terror/incendiary_ammo.mdl") // lol
				ammospawn_ent.SetOrigin(Vector(280, -1040, 414))
		//		ammospawn_ent.ConnectOutput("OnPlayerTouch", "DebugTest")
				printl("L4D1 LOUIS FIRE AMMO SET")
			}
			else if( ammospawn_count == 2)
			{
				ammospawn_ent.SetAngles(QAngle(0, 47, 0))
				ammospawn_ent.SetOrigin(Vector(332, -364, 184))
				printl("L4D1 ZOEY / FRANCIS AMMO SET")
			}
			else
			{
				ammospawn_ent.Kill();
				printl("EXTRA AMMO DELETED")
			}
		}

		//Spawns an identical copy of all weapons except it can only be picked up once

		local weaponspawn_ent = null;

		while( weaponspawn_ent = Entities.FindByName(weaponspawn_ent, "survival_weapons" ))
		{
			local weapon_origin = weaponspawn_ent.GetOrigin();
			local weapon_angles = weaponspawn_ent.GetAngles();
			//local weapon_model = weaponspawn_ent.GetModelName();
			local weapon_skin = NetProps.GetPropInt(weaponspawn_ent, "m_nSkin");
			local weapon_class = weaponspawn_ent.GetClassname();
			
			if (weapon_class != "weapon_melee_spawn")
			{
				//printl(weapon_model)
				local kvs =
				{
					angles = weapon_angles.ToKVString()
					body = 0
					count = 1
					disableshadows = 1
					glowrange = 0
					skin = weapon_skin
					solid = 6
					spawnflags = 0
					//targetname = survival_items
					weaponskin = weapon_skin
					origin = weapon_origin.ToKVString()
				}
				SpawnEntityFromTable( weapon_class, kvs );
				weaponspawn_ent.Kill();
			}
		}
	}
}

const ZOMBIE_TANK = 8

function OnGameEvent_player_incapacitated( params )
{
	local Chance = RandomInt(1,3)
	if( Chance >= 2)
	{
		local player = GetPlayerFromUserID( params.userid )
		if( player.GetZombieType() == ZOMBIE_TANK )
		{
			Director.L4D1SurvivorGiveItem();
		}
	}
}

const Beign = "\x01"    // default color
const BrightGreen = "\x03"
const Orange = "\x04"
const OliveGreen = "\x05"

const HUD_PRINTNOTIFY = 1
const HUD_PRINTCONSOLE = 2
const HUD_PRINTTALK = 3
const HUD_PRINTCENTER = 4

L4D1Surv_T1Weapons <- [
    "smg",
    "smg_silenced",
    "smg_mp5",
    
    "pumpshotgun",
    "shotgun_chrome",
    
    "sniper_awp",            // THEY SUX
    "sniper_scout",
]

L4D1Surv_T2Weapons <- [
    "rifle",
    "rifle_desert",
    "rifle_ak47",
    "rifle_sg552",
    
    "autoshotgun",
    "shotgun_spas",
    
    "hunting_rifle",
    "sniper_military",
    
    "grenade_launcher",
]

tracked_terrorplayers <- {}    // I think the "<-" operator doesn't work with arrays

function OnGameEvent_ammo_pickup( params )
{
    local terrorplayer = GetPlayerFromUserID(params.userid)
    if (RandomInt(1,3) < 3)
    {    
        terrorplayer.GiveItem(L4D1Surv_T1Weapons[(RandomInt(1,L4D1Surv_T1Weapons.len()))])
    }
    else
    {    
        terrorplayer.GiveItem(L4D1Surv_T2Weapons[(RandomInt(1,L4D1Surv_T2Weapons.len()))])
    }
    tracked_terrorplayers <- terrorplayer
}

function OnGameEvent_weapon_drop( params )
{
    // this will fire also when the player is given an item
    local terrorplayer = GetPlayerFromUserID(params.userid)
    local droppedweaponentity = EntIndexToHScript(params.propid)
    ClientPrint(null, HUD_PRINTTALK, OliveGreen+"Terrorplayer val: "+terrorplayer);
    ClientPrint(null, HUD_PRINTTALK, BrightGreen+"tracked_terrorplayers TABLE VALS:");
    try
    {
        foreach(idx, val in tracked_terrorplayers)
        {
            ClientPrint(null, HUD_PRINTTALK, OliveGreen+"index: "+idx+" val: "+val);
            if(terrorplayer == tracked_terrorplayers) {
                ClientPrint(null, HUD_PRINTTALK, Orange+"OnGameEvent_weapon_drop: Deleting a weapon WE HATE VERY MUCH")
                droppedweaponentity.Kill() // KILLS
                delete terrorplayer[idx]    // are all tables internally very similar as arrays????? (c++ says so)
                break
            }
        }
    }
    catch(exception)
    {
        ClientPrint(null, HUD_PRINTTALK, Orange+"foreach Exception: "+exception);
    }
}