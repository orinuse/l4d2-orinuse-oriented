// Author: mac, Smrekish
Msg("VSCRIPT: Running c6m3_survival script\n");

DirectorOptions <-
{
	CommonLimit = 30
	ZombieSpawnRange = 2250
	ZombieDiscardRange = 3500
}

NavMesh.UnblockRescueVehicleNav()
//------------------------------------------------------
Msg("VSCRIPT: Running c6m3_survival ADDON script\n");
// DECLARE CONSTANTS
const Beign = "\x01"    // default color
const BrightGreen = "\x03"
const Orange = "\x04"
const OliveGreen = "\x05"

const HUD_PRINTNOTIFY = 1
const HUD_PRINTCONSOLE = 2
const HUD_PRINTTALK = 3
const HUD_PRINTCENTER = 4

const ZOMBIE_TANK = 8

L4D1Surv_T1Weapons <- [
	"smg", "smg_silenced", "smg_mp5",
	"pumpshotgun", "shotgun_chrome",
	"pistol_magnum",			// why not?
	"sniper_awp", "sniper_scout"	// They're not that great
]

L4D1Surv_T2Weapons <- [
	"rifle", "rifle_desert", "rifle_ak47", "rifle_sg552",
	"autoshotgun", "shotgun_spas",
	"hunting_rifle", "sniper_military",
	"grenade_launcher"
]
IncludeScript("modules/flamboyance.nut")
IncludeScript("modules/await.nut")

//------------------------------------------------------
//Manage L4D1 Survivors. We use Update() to make a makeshift timer.
timer_done <- false;
timer_task1done <- false;
last_set <- Time();

function Update()
{
	if(!timer_done)
	{
		if(!timer_task1done)
		{
			::Flamboyance.PrintToChatAll("Time now: "+Time(),"BrightGreen")
			if(Time() >= last_set + 1)
			{
				::Flamboyance.PrintToChatAll("Got desired time at: "+Time(),"OliveGreen")
				//Spawn L4D1 Survivors
				EntFire( "info_l4d1_survivor_spawn", "SpawnSurvivor", "", 0.0 )

			//	EntFire( "prop_minigun", "Kill" )

				EntFire( "!francis", "SetGlowEnabled", "0", 0.1 )
				EntFire( "!zoey", "SetGlowEnabled", "0", 0.1 )
				EntFire( "!louis", "SetGlowEnabled", "0", 0.1 )

				EntFire( "!francis", "TeleportToSurvivorPosition", "francis_station", 0.2 )
				EntFire( "!zoey", "TeleportToSurvivorPosition", "zoey_station", 0.2 )
				EntFire( "!louis", "TeleportToSurvivorPosition", "zoey_station", 0.2 )
				
				EntFire( "l4d1_nav_blocker", "UnblockNav", null, 0.3 )
			}
			timer_task1done = true;
		}
		else
		{
			if(Time() >= last_set + 2)
			{
				::Flamboyance.PrintToChatAll("Got ALSO desired time at: "+Time(),"OliveGreen")
				EntFire( "!francis", "ReleaseFromSurvivorPosition" )
				EntFire( "!zoey", "ReleaseFromSurvivorPosition" )
				EntFire( "!louis", "ReleaseFromSurvivorPosition" )
				//Gib starter weapons
				local player = null;
				local zoey_station = null;
				local zoey_station = Entities.FindByName(zoey_station, "zoey_station");
				while( player = Entities.FindByClassnameWithin(player, "player", zoey_station.GetOrigin(), 50))
				{	
					local player_currentweapon = player.GetActiveWeapon()
					if(!player_currentweapon.GetClassname() == "weapon_pistol") {
						::Flamboyance.PrintToChatAll("DIE, DIE, MY DARLINGS","BrightGreen")
						player_currentweapon.Kill();
					}	

					player.GiveItem(L4D1Surv_T1Weapons[(RandomInt(1,L4D1Surv_T1Weapons.len()-1))]);
					::Flamboyance.PrintToChatAll("Name: "+GetCharacterDisplayName(player),"Orange")
				}
				//Teleport ammo to the L4D1 Survivors
				local ammospawn_count = 0;
				local ammospawn_ent = null;
				while( ammospawn_ent = Entities.FindByClassname(ammospawn_ent, "weapon_ammo_spawn" ))
				{
					ammospawn_count += 1;
					if( ammospawn_count == 1)
					{
						ammospawn_ent.SetModel("models/props/terror/incendiary_ammo.mdl") // lol
						ammospawn_ent.SetOrigin(Vector(280, -1040, 414))
				//		ammospawn_ent.ConnectOutput("OnPlayerTouch", "DebugTest")
						printl("L4D1 LOUIS'S FAKE FIRE AMMO SET")
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
						printl("EXTRA AMMO DELETED; WHICH IS AMMO SPAWN #"+ammospawn_count.tostring())
					}
				}
				//Spawns an identical copy of all weapons except it can only be picked up once [twice now]
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
							angles = weapon_angles.ToKVString(),
							origin = weapon_origin.ToKVString(),
							disableshadows = 1,
							solid = 6,
							count = 2,
							skin = weapon_skin, weaponskin = weapon_skin,
						}
						SpawnEntityFromTable( weapon_class, kvs );
						weaponspawn_ent.Kill();
					}
				}
				timer_done = true;
			}
		}
	}
}

//------------------------------------------------------------------------------------------------------------
// These two game event functions, and that table, are responsible for deciding if
// an ammo pile should give a survivor player a random weapon.
//
// This is made so that L4D1 Survivors have random weapons throughout the course of survival mode
//------------------------------------------------------------------------------------------------------------
tracked_terrorplayers <- []    // I think the "<-" operator doesn't work with arrays
function OnGameEvent_ammo_pickup( params )
{
	local terrorplayer = GetPlayerFromUserID(params.userid)
	local player_currentweapon = terrorplayer.GetActiveWeapon()
	::Flamboyance.PrintToChatAll("Current Weapon: "+player_currentweapon.tostring(), "BrightGreen")
	if (RandomInt(1,3) < 3)
		terrorplayer.GiveItem(L4D1Surv_T1Weapons[(RandomInt(1,L4D1Surv_T1Weapons.len()-1))])
	else
		terrorplayer.GiveItem(L4D1Surv_T2Weapons[(RandomInt(1,L4D1Surv_T2Weapons.len()-1))])

	tracked_terrorplayers <- terrorplayer;
}
// this will fire also when the player is given an item, so lets use it to delete the previous weapon
//// Unstable: weapon_drop game event is not reliable.
/* function OnGameEvent_weapon_drop( params )
{
	local terrorplayer = GetPlayerFromUserID(params.userid)
	local droppedweaponentity = EntIndexToHScript(params.propid)
	::Flamboyance.PrintToChatAll("OnGameEvent_weapon_drop - Terrorplayer val: "+terrorplayer);
	try
	{
		for(local idx=1;(tracked_terrorplayers.len());idx+=1)
		{
			if(idx == 1)
				ClientPrint(null, HUD_PRINTTALK, BrightGreen+"tracked_terrorplayers TABLE VALS:");

			::Flamboyance.PrintToChatAll("val: "+tracked_terrorplayers[idx], "OliveGreen");
			if(terrorplayer == tracked_terrorplayers[idx]) {
				ClientPrint(null, HUD_PRINTTALK, Orange+"OnGameEvent_weapon_drop: Deleting a weapon WE HATE VERY MUCH")
				droppedweaponentity.Kill() // KILLS
				delete tracked_terrorplayers[idx]    // are all tables internally very similar as arrays????? (c++ says so)
				break;
			}
		}
	}
	catch(exception)
	{
		::Flamboyance.PrintToChatAll("OnGameEvent_weapon_drop - Exception: "+exception, "Orange");
	}
} */
// When a Tank's incapacitated, 1/3 chance of L4D1 Survivors asked to give an item. 
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
