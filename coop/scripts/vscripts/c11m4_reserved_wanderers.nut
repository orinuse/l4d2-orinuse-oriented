// Dead Air - Terminals DLC Patches, of Orin's
// Copyright ©️ 2021 Orinuse (https://steamcommunity.com/id/orinuse/)
//// For full details on GNU General Public License v3.0, see the addon / repository's main folder.
//==================================================================
Msg("VSCRIPT: Running c11m4_reserved_wanderers.nut ADDON\n");

DirectorOptions <-
{
	// Turn always wanderer on
	AlwaysAllowWanderers = 1

	// Set the number of infected that cannot be absorbed
	NumReservedWanderers = 15
}
//------------------------------------------------------

if( !Entities.FindByName(null, "info_scriptRanOnce") )
{	// Van was made last
	IncludeScript("entitygroups/c11m4_missingweapons_group.nut"); SpawnSingle( C11M4MissingWeapons.GetEntityGroup() )
	IncludeScript("entitygroups/c11m4_alarmholdout_group.nut"); SpawnSingle( C11M4AlarmHoldout.GetEntityGroup() )
	IncludeScript("entitygroups/c11m4_vanpush_group.nut"); SpawnSingle( C11M4VanPush.GetEntityGroup() )
	IncludeScript("entitygroups/c11m4_navpatch_group.nut"); SpawnSingle( C11M4NavPatch.GetEntityGroup() )
	
	EntFire("@director", "RunScriptFile", "c11m4_patch_master", 0.1)
	SpawnEntityFromTable("info_target", { targetname = "info_scriptRanOnce"} )
}
else
	Msg("Aborted; Already ran!\n");
