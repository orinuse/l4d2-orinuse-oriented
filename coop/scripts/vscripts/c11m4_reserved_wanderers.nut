// Dead Air - Terminals DLC Patches, of Orin's
// Copyright ©️ 2021 Orinuse (http://steamcommunity.com/profiles/76561198294712284)
//// For full details on the license, see the addon / repository's main folder.
//==================================================================
// Tools I used:
// Hammer - Entity Group generation with 'bin/export_entity_group.pl` using 'Run Map'
// Sublime Text 3 - My editor catered to programming
// Notepad++ - My editor catered to reading files of all kind, but doesn't mean I don't edit files with it
// L4D2VScriptEditorBeta - Taken from VDC, comes with the option to compile .nut into .nuc / decompile .nuc to .nut files. Some people say its just encrypting though
//
// My thumbnail isn't made as of writing this; My installed image editing programs are GIMP and paint.net. I've been giving these resources to start at:
// - Gradient Mapping
// - Something to do with image masking for shaders or something..?
// - Beveling
// - Embossing
//

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
