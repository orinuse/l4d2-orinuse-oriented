Msg("VSCRIPT: Running scriptedmode_addon SCRIPT; Orin's!\n")

if( Director.GetMapName() == "c12m4_barn" )
{
	local director = Ent("director")
	if( director )
	{
		director.ValidateScriptScope()
		local director_scope = director.GetScriptScope()
		if( !("RoundCalled" in director_scope) )
		{
			// still dunno what r weakrefs for
			Msg("***********************************\n")
			Msg("**   Orin's C12M4 Survival DLC   **\n")
			Msg("**      scriptedmode_addon       **\n")
			Msg("***********************************\n")

			EntFire("director", "BeginScript", "c12m4_scriptedmode_ralimu")
			director_scope["RoundCalled"] <- true
		}
		else
		{
			printl("Yeah, scriptedmode_addon.nut will run twice... Not sure why? - Orin")
		}
	}
}

// RAGE
//// SOMEONE needs to overwrite this function!!! 'allowNameFixup' is always GODDAMN true AGHH
/*function InstanceTemplateSpawnTables( templateSpawnInfo, entityGroupSet, allowNameFixup )
{
	CacheSpawnTables( entityGroupSet.OriginalGroup )
	InstanceTemplateGroup( templateSpawnInfo, entityGroupSet, allowNameFixup )
}*/
