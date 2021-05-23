Msg("VSCRIPT: Running c12m4_barn_scriptedmode SCRIPT; Orin's!\n")

const ADDON_PREFIX = "_ralimu_survival"
//--------------
//-  GLOBAL A  -
//  Auto Crouch
//--------------
// All mins must be negative while maxs must be positive
local trigmove_data =
[
	{ mins = "-48 -284 -44", maxs = "48 284 44", origin = Vector( 10680, -5804, -132 ).ToKVString() },
]
for (local i = 0; i < trigmove_data.len(); i++)
{
	local trigmove = trigmove_data[i]
	make_trigmove( ADDON_PREFIX+"_trigmove"+i, "Duck", trigmove.mins, trigmove.maxs, trigmove.origin)
}

// Scope BREAK
if( Director.GetGameModeBase() != "survival" )
	return;

Msg("***********************************\n")
Msg("**  Ralimu's C12M4 Survival DLC  **\n")
Msg("**       scriptedmode_addon      **\n")
Msg("***********************************\n")

// RAGE
function InstanceTemplateSpawnTables( templateSpawnInfo, entityGroupSet, allowNameFixup )
{
	CacheSpawnTables( entityGroupSet.OriginalGroup )
	InstanceTemplateGroup( templateSpawnInfo, entityGroupSet, false )
}

// Spawn our entity group!
IncludeScript("entitygroups/c12m4_ralimu_group")
SpawnSingle( C12M4RalimuSurvival.GetEntityGroup() )

// Neat fade-in.. to hide the teleport
local FADE_ALPHA = 255
local FADE_TIME = 2
local FADE_HOLD = 1
local FADEFLAG_FADEIN = (1 << 0)

local player = null
while( player = Entities.FindByClassname(player,"player") )
{
	ScreenFade(player, 0, 0, 0, FADE_ALPHA, FADE_TIME, FADE_HOLD, FADEFLAG_FADEIN)
}
// OK, we just did the screenfade. Let's teleport the players now
TeleportPlayersToStartPoints("ralimu_survival_positions") // on mapspawn
TeleportPlayersToStartPoints("_1_ralimu_survival_positions") // on non-mapspawn... Thanks egroups for forcefully doing this :/

function OnScriptEvent_ralimu_survival_post_entity(params)
{
	Convars.SetValue("scavenge_item_respawn_delay", 20)
	//--------------
	//- Exihibit A -
	//   Removal
	//--------------
	local EntitiesIHate =
	[
		"anv_mapfixes_eventskip_commonhopa",
		"anv_mapfixes_eventskip_commonhopb",
		"anv_mapfixes_eventskip_fence_trigonce",
		"window_trigger",

		// These are minor
		"onslaught",
		"zombie_spawn_relay",
		"spawn_zombie_run",
		"spawn_zombie_end",
	]
	foreach(classname in EntitiesIHate)
	{
		local ent = null
		while( ent = Entities.FindByName(Entities.First(), classname) )
			ent != null ? ent.Kill() : 0
	}
	// Some have NO NAMES!!! Thus I must do this
	local radius = 20
	local ent = null
	if( ent = Entities.FindByClassnameNearest("trigger_once", Vector(10453, -3702, -16), radius) )
		ent.Kill()
	if( ent = Entities.FindByClassnameNearest("trigger_once", Vector(10456, -728, 80), radius) )
		ent.Kill()

	//--------------
	//- Exihibit B -
	//   Ladders
	//--------------
	// NetProps.GetPropVector(Ent(742),"m_vecSpecifiedSurroundingMaxs")
	//
	// anv_mapfixes does not use the above netprop for critial reasons, thus fetching this is unreliable even for us!
	//// It uses a custom math sequence instead. See 'anv_functions.nut' for more info!
	//
	/*
	**	Facing towards the ladder's "TOOLS/CLIMB_VERSUS" texture this is how
	**	the Normals work -- there is a rough tolerance of 0.2 on the "raycast"
	**	that determines the Normal, so 0.8 and 1.0 may yield identical results:
	**
	**		0 1 0		exactly North
	**		0 -1 0		exactly South
	**		1 0 0		exactly West
	**		-1 0 0		exactly East
	//
	// This does not mean which side will be climbable, but rather at which brush side it starts the trace at, seemingly
	*/
	local VSSM_1 = Vector(10528.000000, -7510.000000, 10.000000)
	make_ladder( ADDON_PREFIX+"_ladders" , VSSM_1.ToKVString(), Vector(-4, 3972, -32).ToKVString(), "0 0 0", "0 1 0", 3)
	make_ladder( ADDON_PREFIX+"_ladders" , VSSM_1.ToKVString(), Vector(-132, 3932, -32).ToKVString(), "0 0 0", "0 1 0", 3)

	local VSSM_2 = Vector(8357, -9218, 407)
	make_ladder( ADDON_PREFIX+"_ladders" , VSSM_2.ToKVString(), Vector(2916, 4705, -681).ToKVString(), "0 0 0", "1 0 0", 0)
	local VSSM_3 = Vector(10514, -7002, 19)
	make_ladder( ADDON_PREFIX+"_ladders" , VSSM_3.ToKVString(), Vector(730, 2492, -218).ToKVString(), "0 0 0", "1 0 0", 0)

	//--------------
	//- Exihibit C -
	//    Clips
	//--------------
	enum BlockerType
	{
		Everyone = "Everyone",
		Survivors = "Survivors",
		SI_Players = "SI Players",
		SI_Players_and_AI = "SI Players and AI",
		All_and_Physics = "All and Physics"
	}
	// All mins must be negative while maxs must be positive if the blocktype isn't "BlockerType.All_and_Physics"
	local blocker_data =
	[
		// Pre-Train Station - Cliff Drop
		{ blocktype = BlockerType.Survivors, mins = "-32.0 -376.0 -800.0", maxs = "32.0 376.0 800.0", origin = Vector(10240, -8280, 928).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-26 -80 -784", maxs = "26 80 784", origin = Vector(10298, -8304, 944).ToKVString() },

		// Bridge - Barricade Beyondance
		{ blocktype = BlockerType.Survivors, mins = "-111 -424 -68", maxs = "111 424 68", origin = Vector(10453, -3290, 328).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-111 -408 -177.5", maxs = "111 408 177.5", origin = Vector(10455, -3272, 82).ToKVString() },

		// Train Station - Roof
		{ blocktype = BlockerType.Survivors, mins = "-256 -768 -800", maxs = "256 768 800", origin = Vector(10880, -8328, 928).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-232 -208 -780", maxs = "232 208 780", origin = Vector(11368, -8048, 948).ToKVString() },

		// Train Station - Station Checkpoint's Cliffside
		{ blocktype = BlockerType.Survivors, mins = "-132 -196 -800", maxs = "132 196 800", origin = Vector(10140, -7708, 964).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-96 -76 -748", maxs = "96 76 748", origin = Vector(10104, -7436, 980).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-88 -64 -744", maxs = "88 64 744", origin = Vector(10096, -7296, 984).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-76 -96 -744", maxs = "76 96 744", origin = Vector(10084, -7136, 984).ToKVString() },
	]
	for (local i = 0; i < blocker_data.len(); i++)
	{
		local blocker = blocker_data[i]
		make_clip( ADDON_PREFIX+"_blockers"+i, blocker.blocktype, true, blocker.mins, blocker.maxs, blocker.origin)
	}

	//--------------
	//- Exihibit D -
	//  FUNC_BRUSH
	//--------------
	local brush_data =
	[
		{ mins = "-46 -14 -61.5", maxs = "46 14 61.5", origin = Vector(10418, -3594, -9.65).ToKVString() }
		{ mins = "-46 -14 -61.5", maxs = "46 14 61.5", origin = Vector(10498, -3554, -9.65).ToKVString() }
	]
	for (local i = 0; i < brush_data.len(); i++)
	{
		local brush = brush_data[i]
		make_brush( ADDON_PREFIX+"_brushes"+i, brush.mins, brush.maxs, brush.origin)
	}

	//--------------
	//- Exihibit E -
	//   Nav Block
	//--------------
	enum TeamNum
	{
		Everyone = "Everyone",
		Survivors = "Survivors",
		Infected = "Infected"
	}
	// All mins must be negative while maxs must be positive
	local navblock_data =
	[
		/*
		// ??? Why is this specific nav blocker (the first one) somehow gigantic even with the tiny size that's given?
		//
		// I found the cause, the first nav blocker used the SAME data as the one last in the list, so I made all the nav blockers have unique entity targetnames
		*/
		{ teamToBlock = TeamNum.Everyone, mins = "-90 -94 -61.6488", maxs = "90 94 61.6488", origin = Vector( 10454, -3586, -9.65 ).ToKVString() },
		{ teamToBlock = TeamNum.Survivors, mins = "-82.0 -376.0 -80.0", maxs = "82.0 376.0 80.0", origin = Vector( 10242, -8280, 176 ).ToKVString() },
	]
	for (local i = 0; i < navblock_data.len(); i++)
	{
		local navblock = navblock_data[i]
		make_navblock( ADDON_PREFIX+"_navblocks"+i, navblock.teamToBlock, "Apply", navblock.mins, navblock.maxs, navblock.origin)
	}
}
