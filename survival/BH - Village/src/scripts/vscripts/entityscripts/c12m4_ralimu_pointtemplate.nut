Msg("VSCRIPT: Running c12m4_ralimu_pointtemplate SCRIPT; Orin's!\n")
// Don't use ConnectOutput() for this
calltolerancy_count <- 3

function OnEntitySpawned()
{
	local instanceauto1 = null
	while( instanceauto1 = Entities.FindByName(instanceauto1, "InstanceAuto1-*") )
		instanceauto1.Kill()

	EntFire("caralarm_light1", "Kill")
	EntFire("!self", "CallScriptFunction", "CallScriptEvent", 3)
}

function CallScriptEvent()
{
	calltolerancy_count--
	if( !Ent("anv_mapfixes_eventskip_commonhopa") || !Ent("anv_mapfixes_eventskip_commonhopb") )
		EntFire("!self", "CallScriptFunction", "CallScriptEvent", 3)
	else
		FireScriptEvent("ralimu_survival_post_entity", {})

	if( calltolerancy_count < 1 )
	{
		delete calltolerancy_count;
		throw "CallScriptEvent terminated";
	}
}
