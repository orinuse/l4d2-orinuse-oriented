// Tools I used:
// Hammer - Entity Group generation with 'bin/export_entity_group.pl` using 'Run Map'
// Sublime Text 3 - My editor catered to programming
// Notepad++ - My editor catered to reading files of all kind, but doesn't mean I don't edit files with it
// L4D2VScriptEditorBeta - Taken from VDC, comes with the option to compile .nut into .nuc / decompile .nuc to .nut files. Some people say its just encrypting though
//
// Werteroee / Philipp used FireAlpaca for creating the images, and Asesprite to experiment resizing images (down) with no artifacts
//
Msg("VSCRIPT [Orin]: Running 'c11m4_reserved_wanderers' ADDON\n");

DirectorOptions <-
{
	// Turn always wanderer on
	AlwaysAllowWanderers = 1

	// Set the number of infected that cannot be absorbed
	NumReservedWanderers = 15
}
//------------------------------------------------------

if( !Entities.FindByName(null, "info_scriptRanOnce") )
{
	Msg("****************************\n")
	Msg("**      DLC Patch\n")
	Msg("** Dead Air - Terminals\n")
	Msg("****************************\n")

	// Van was made last
	IncludeScript("entitygroups/patch_da_weaponsgroup"); SpawnSingle( C11M4MissingWeapons.GetEntityGroup() )
	IncludeScript("entitygroups/patch_da_alarmgroup"); SpawnSingle( C11M4AlarmHoldout.GetEntityGroup() )
	IncludeScript("entitygroups/patch_da_vangroup"); SpawnSingle( C11M4VanPush.GetEntityGroup() )
	IncludeScript("entitygroups/patch_da_navgroup"); SpawnSingle( C11M4NavPatch.GetEntityGroup() )
	EntFire("@director", "RunScriptFile", "patch_da_master", 0.1)
	SpawnEntityFromTable("info_target", { targetname = "info_scriptRanOnce"} )
}