// Tools I used:
// Hammer - Entity Group generation with 'bin/export_entity_group.pl` using 'Run Map'
// Sublime Text 3 - My editor catered to programming
// Notepad++ - My editor catered to reading files of all kind, but doesn't mean I don't edit files with it
// L4D2VScriptEditorBeta - Taken from VDC, comes with the option to compile .nut into .nuc / decompile .nuc to .nut files. Some people say its just encrypting though
//
// Werteroee / Philipp used FireAlpaca for creating the images, and Asesprite to experiment resizing images (down) with no artifacts
//
Msg("VSCRIPT [Orin]: Running 'c11m4_reserved_wanderers' SCRIPT; ADDON\n");

DirectorOptions <-
{
	// Turn always wanderer on
	AlwaysAllowWanderers = 1

	// Set the number of infected that cannot be absorbed
	NumReservedWanderers = 15
}
//------------------------------------------------------

if( !Ent("info_scriptRanOnce") )
{
	Msg("=== Dead Air - Terminals DLC Patches ===\n")
	Msg("**********************\n")
	Msg("** Please report any concerns or script errors to: **\n")
	Msg("** Steam - Orin, Boomer **\n")
	Msg("** Gtihub - Orinuse, Smrekish **\n")
	Msg("** Copyright ©️ 2021 Orinuse; Under BSL License v1.0 **\n")
	Msg("**********************\n")

	// Van was made last
	IncludeScript("entitygroups/c11m4_missingweapons_group"); SpawnSingle( C11M4MissingWeapons.GetEntityGroup() )
	IncludeScript("entitygroups/c11m4_alarmholdout_group"); SpawnSingle( C11M4AlarmHoldout.GetEntityGroup() )
	IncludeScript("entitygroups/c11m4_vanpush_group"); SpawnSingle( C11M4VanPush.GetEntityGroup() )
	IncludeScript("entitygroups/c11m4_navpatch_group"); SpawnSingle( C11M4NavPatch.GetEntityGroup() )
	EntFire("@director", "RunScriptFile", "c11m4_patch_master", 0.1)
	SpawnEntityFromTable("info_target", { targetname = "info_scriptRanOnce"} )
}
else
	printl("Aborted; Script already ran once!")
