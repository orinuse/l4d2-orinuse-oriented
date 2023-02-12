Msg("VSCRIPT: Running director_tankinplaypipes SCRIPT; Orin's!\n")
Msg("** [TankInPlay Pipes] v0.3 **\n")
// Moved to director_base_addon.nut for good reason, as scriptedmode_addon.nut had its own mind with game events:
// __RunEventCallbacks[OnGameEvent_]: Invalid 'event' name: player_death. No listeners registered for that event.

// Generate the config vscript file if it doesn't exist
const PATH_CONFIG = "/orin/tankinplaypipes/config.nut"
local SettingsTable = FileToString(PATH_CONFIG)
if( !SettingsTable || SettingsTable.len() == 0 || developer() > 2 )
{
	local defaultfile =
	[
		"/* *******************************************************************************",
		"**	This configuration is only loaded on every new 'round' / 'scenario'.",
		"**	Editing it mid-session will still work, but keep that in mind.",
		"******************************************************************************* */",
		"Configuration <-",
		"{",
		"	// Newly used pipes are 50% shorter when a Tank is active ('pipe_bomb_timer_duration')",
		"	//// This also changes the beep interval's settings accordingly ('pipe_bomb_initial_beep_interval' and 'pipe_bomb_beep_interval_delta', where delta means 'distance')",
		"	tankinplaypipes_duration_percent = 0.5",
		"}",
	]

	local newfile = "";
	foreach( str in defaultfile ) { newfile = newfile + str + "\n"; }
	StringToFile(PATH_CONFIG, newfile)
	if( developer() > 2 )
	{
		Msg("++ With 'developer 3' active, the file has been forcefully generated for testing! ++\n")
		printl("*********** NEW FILE ***********")
		printl(newfile)
		printl("*********** NEW FILE ***********")
		Msg("++ With 'developer 3' active, the file has been forcefully generated for testing! ++\n")
	}
	else if( developer() > 0 ) {
		Msg("Default configuration file doesn't exist.. generated a default!\n")
	}
}

/*===================================================================
	SETUP
===================================================================*/
/* we don't need 'weapon_fire'
enum L4DWeapon {
	PISTOL = 1,
	SMG = 2,
	PUMPSHOTGUN = 3,
	AUTOSHOTGUN = 4,
	RIFLE = 5,
	HUNTING_RIFLE = 6,

	SMG_SILENCED = 7,
	SHOTGUN_CHROME = 8,
	RIFLE_DESERT = 9,
	SNIPER_MILITARY = 10,
	SHOTGUN_SPAS = 11,

	FIRST_AID_KIT = 12,
	MOLOTOV = 13,
	PIPE_BOMB = 14,
	PAIN_PILLS = 15,
	GASCAN = 16,
	PROPANETANK = 17,
	OXYGENTANK = 18,

	MELEE = 19,
	CHAINSAW = 20,
	GRENADE_LAUNCHER = 21,
	ADRENALINE = 23,
	DEFIBRILLATOR = 24,
	VOMITJAR = 25,

	RIFLE_AK47 = 26,
	GNOME = 27,
	COLA_BOTTLES = 28,
	FIREWORKS_CRATE = 29,
	UPGRADEPACK_INCENDIARY = 30,
	UPGRADEPACK_EXPLOSIVE = 31,

	PISTOL_MAGNUM = 32,
	SMG_MP5 = 33,
	RIFLE_SG552 = 34,
	SNIPER_AWP = 35,
	SNIPER_SCOUT = 36,
	RIFLE_M60 = 37,

	TANK_CLAW = 38,
	HUNTER_CLAW = 39,
	CHARGER_CLAW = 40,
	BOOMER_CLAW = 41,
	SMOKER_CLAW = 42,
	SPITTER_CLAW = 43,
	JOCKEY_CLAW = 44,

	MINIGUN = 54
}
*/

local _addonScope = this.TankInPlayPipes <- {}
IncludeScript("../../ems"+PATH_CONFIG, _addonScope)
local configuration = _addonScope.Configuration
_addonScope.Cache <-
{
	pipe_bomb_timer_duration = {
		old = Convars.GetFloat("pipe_bomb_timer_duration"),
		new = Convars.GetFloat("pipe_bomb_timer_duration") * configuration["tankinplaypipes_duration_percent"],
	},
	pipe_bomb_initial_beep_interval = {
		old = Convars.GetFloat("pipe_bomb_initial_beep_interval"),
		new = Convars.GetFloat("pipe_bomb_initial_beep_interval") * configuration["tankinplaypipes_duration_percent"],
	},
	pipe_bomb_beep_interval_delta = {
		old = Convars.GetFloat("pipe_bomb_beep_interval_delta"),
		new = Convars.GetFloat("pipe_bomb_beep_interval_delta") * configuration["tankinplaypipes_duration_percent"],
	},
}
enum VALTYPE { OLD = 0, NEW = 1 }
_addonScope.ApplyCacheOfType <- function(oldOrNew)
{
	local valType = (oldOrNew == VALTYPE.OLD ? "old" : "new");
	foreach( idx, val in _addonScope.Cache ) {
		Convars.SetValue(idx, val[valType])
	}
}

// ++ GAME EVENTS ++
// -----------------
// 'DeepPrintTable(getroottable().GameEventCallbacks)' and look at the insides of each array index.. the script scopes are crazy without this

const _prefixGameEvent = "OnGameEvent_"

function __MakeGameEventHook(eventname, func)
{
	if( type(eventname) != "string" )	throw "That 'eventname' is no string!";
	if( type(func) != "function" )		throw "That 'func' is no user-defined function!";

	if("GameEventCallbacks" in getroottable() != true)
		::GameEventCallbacks <- {};

	local eventCallbacks = ::GameEventCallbacks
	local eventHookName = _prefixGameEvent+eventname
	if( eventHookName in eventCallbacks != true )
	{
		_addonScope[eventHookName] <- func;
		eventCallbacks[eventname] <- [];
	}

	eventCallbacks[eventname].append(_addonScope.weakref())
	RegisterScriptGameEventListener(eventname);
}

__MakeGameEventHook("player_death", function(params)
{
	if( ("userid" in params) != true)
		return;

	local player = GetPlayerFromUserID(params.userid)
	if( player.GetZombieType() == DirectorScript.ZOMBIE_TANK )
	{
		// If there are other Tanks
		if( !Director.IsTankInPlay() ) {
			ApplyCacheOfType(VALTYPE.OLD)
		}
	}
})
__MakeGameEventHook("round_start", function(params) { ApplyCacheOfType(VALTYPE.OLD) })

// Its better to apply the tank takes damage for the 1st time instead
__MakeGameEventHook("spawned_as_tank", function(params) { ApplyCacheOfType(VALTYPE.NEW) })
