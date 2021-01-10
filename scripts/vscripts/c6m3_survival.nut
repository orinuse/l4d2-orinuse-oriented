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
// DECLARE CONSTANTS (dose arrays technically count as constants too)
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
//	"grenade_launcher"	// this isn't allowed to use ammo pile, so we have to disable this for now;;;;
]
IncludeScript("modules/flamboyance.nut")
IncludeScript("modules/clockwork.nut")

//------------------------------------------------------
//Manage L4D1 Survivors. We use Update() to make a makeshift timer.
//// We now use a module, it still doesn't look very pretty though..

::Clockwork.AwaitWithUpdate(1, UpdateTask_SetupL4D1Survivors <- function() {
	EntFire( "info_l4d1_survivor_spawn", "SpawnSurvivor", "", 0.0 )

	EntFire( "!francis", "SetGlowEnabled", "0", 0.1 )
	EntFire( "!zoey", "SetGlowEnabled", "0", 0.1 )
	EntFire( "!louis", "SetGlowEnabled", "0", 0.1 )

	EntFire( "!francis", "TeleportToSurvivorPosition", "francis_station", 0.2 )
	EntFire( "!zoey", "TeleportToSurvivorPosition", "zoey_station", 0.2 )
	EntFire( "!louis", "TeleportToSurvivorPosition", "zoey_station", 0.2 )
	
	EntFire( "l4d1_nav_blocker", "UnblockNav", null, 0.3 )
	}
)

::Clockwork.AwaitWithUpdate(2, UpdateTask_SetupL4D1SurvivorsWeapons <- function() {
	EntFire( "prop_minigun", "Kill" )
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
		local L4D1Surv_T1Weapons = g_MapScript.LocalScript.L4D1Surv_T1Weapons
		player.GiveItem(L4D1Surv_T1Weapons[(RandomInt(1,(L4D1Surv_T1Weapons.len())-1))]);
	}
	EntFire( "!francis", "ReleaseFromSurvivorPosition" )
	EntFire( "!zoey", "ReleaseFromSurvivorPosition" )
	EntFire( "!louis", "ReleaseFromSurvivorPosition" )
})
// Was supposed to need only 1, after all
//// Perhaps ill leave it like this for readability
::Clockwork.AwaitWithUpdate(1, UpdateTask_ExploitExistingWeaponSpawns <- function()
{
	//Rob existing ammopiles and give to the L4D1 Survivors
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
		//	ammospawn_ent.Kill();
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
		if (!(weapon_class == "weapon_melee_spawn" && weapon_class == "weapon_ammo_spawn"))
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
})

/* function Update()
{
	if(!timer_done)
	{
		else
		{
			if(Time() >= last_set + 2)
			{
				timer_done = true;
			}
		}
	}
} */

//------------------------------------------------------------------------------------------------------------
// These two game event functions, and that table, are responsible for deciding if
// an ammo pile should give a survivor player a random weapon.
//
// This is made so that L4D1 Survivors have random weapons throughout the course of survival mode
//------------------------------------------------------------------------------------------------------------
function OnGameEvent_ammo_pickup( params )
{
	local terrorplayer = GetPlayerFromUserID(params.userid)
	terrorplayer.GetActiveWeapon().Kill()
	if (RandomInt(1,3) < 3)
		terrorplayer.GiveItem(L4D1Surv_T1Weapons[(RandomInt(1,L4D1Surv_T1Weapons.len()-1))])
	else
		terrorplayer.GiveItem(L4D1Surv_T2Weapons[(RandomInt(1,L4D1Surv_T2Weapons.len()-1))])
}

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
