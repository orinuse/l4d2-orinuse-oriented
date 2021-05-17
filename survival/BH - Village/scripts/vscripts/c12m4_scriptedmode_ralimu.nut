Msg("VSCRIPT: Running c12m4_barn_scriptedmode SCRIPT; Orin's!\n")

if( Director.GetGameModeBase() != "survival" )
{
	make_navblock( "_ralimu_survival", 2, 1, "-90 -94 -61.6488", "90 94 61.6488", "10454 -3586 74")
	return;
}

Msg("***********************************\n")
Msg("**  Ralimu's C12M4 Survival DLC  **\n")
Msg("**       scriptedmode_addon      **\n")
Msg("***********************************\n")

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
	//	"spawn_zombie_run",	// ill use this for debugging
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
	const ADDON_PREFIX = "_ralimu_survival"
	//--------------
	//- Exihibit B -
	//   Ladders
	//--------------
	// anv_mapfixes does not use this; It uses a custom math sequence.
	// NetProps.GetPropVector(Ent(742),"m_vecSpecifiedSurroundingMaxs")
	local VSSM_1 = Vector(10528.000000, -7510.000000, 10.000000)
	make_ladder( ADDON_PREFIX+"_ladders" , VSSM_1.ToKVString(), Vector(-4, 3972, -32).ToKVString(), "0 0 0", "0 1 0", 0)
	make_ladder( ADDON_PREFIX+"_ladders" , VSSM_1.ToKVString(), Vector(-132, 3932, -32).ToKVString(), "0 0 0", "0 1 0", 0)

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
		{ blocktype = BlockerType.Survivors, mins = "-111 -424 -68", maxs = "111 424 68", origin = Vector(10453, -3290, 328).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-26 -56 -784", maxs = "26 56 784", origin = Vector(10298, -8328, 944).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-32.0 -376.0 -800.0", maxs = "32.0 376.0 800.0", origin = Vector(10240, -8328, 944).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-111 -408 -177.5", maxs = "111 408 177.5", origin = Vector(10455, -3272, 82).ToKVString() },
	]
	for (local i = 0; i < blocker_data.len(); i++)
	{
		local blocker = blocker_data[i]
		local initialstate = 1
		make_clip( ADDON_PREFIX+"_blockers"+i, blocker.blocktype, initialstate, blocker.mins, blocker.maxs, blocker.origin)
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
		{ teamToBlock = TeamNum.Survivors, mins = "90, 94, 61.6488", maxs = "-90, -94, -61.6488", origin = Vector( 10454, -3586, -9.65 ).ToKVString() },
		{ teamToBlock = TeamNum.Survivors, mins = "82.0, 376.0, 80.0",   maxs = "-82.0, -376.0, -80.0",   origin = Vector( 10242, -8280, 176 ).ToKVString() },
	]
	for (local i = 0; i < navblock_data.len(); i++)
	{
		local navblock = navblock_data[i]
		local state = "Apply"
		make_navblock( ADDON_PREFIX+"_navblocks"+i, navblock.teamToBlock, state, navblock.mins, navblock.maxs, navblock.origin)
	}
}
