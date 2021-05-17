Msg("VSCRIPT: Running c12m4_ralimu_instanceauto1 SCRIPT; Orin's!\n")
/* Contents of the EntityGroup from logic_script
EntityGroup
[
	"InstanceAuto1-caralarm_car1"
	"InstanceAuto1-caralarm_glass1_off"
] */

function Precache()
{
	local instanceauto1 = null
	while( instanceauto1 = Entities.FindByName(instanceauto1, "InstanceAuto1-*") )
	{
	//	if( instanceauto1 in EntityGroup )
	//		continue;

		instanceauto1.Kill()
	}

	// forget about the car for now, I'll eventually re-add this car back as a regular prop!
	/*for( local i=0; i<EntityGroup.len(); i++)
	{
		local ent = EntityGroup[i]
		NetProps.SetPropString(ent, "m_iClassname", "prop_dynamic")
		NetProps.SetPropString(ent, "m_iName", "ralimu_survival_car")
		EntFire("!self", "Enable", "", 0, ent)
	}*/
	EntFire("!self", "CallScriptFunction", "CallScriptEvent", 3)
}

function CallScriptEvent()
{
	if( !Ent("anv_mapfixes_eventskip_commonhopa") || !Ent("anv_mapfixes_eventskip_commonhopb") )
		EntFire("!self", "CallScriptFunction", "CallScriptEvent", 3)
	else
		FireScriptEvent("ralimu_survival_post_entity", {})
}
