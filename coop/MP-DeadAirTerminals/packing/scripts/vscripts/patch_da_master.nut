Msg("VSCRIPT [Orin]: Running 'patch_da_master' \n");

// ++ VAN ++
// ---------
// Create an escalator remark
SpawnEntityFromTable("info_remarkable", {
	targetname = "farm02_path06"
	origin = Vector(-420, 5136, 348)
	contextsubject = "farm02_path06"
})

// Remove luggage cart props that dissapear on low settings
local origins =
[
	Vector(-94.25, 4274.63, 28.9688),
	Vector(199.969, 3815.97, 16.4688),
	Vector(61.5625, 3819.47, 16.4688)
]
foreach( vector in origins )
{
	// Changing "mincpulevel" or "mingpulevel" post-spawn does nothing.
	Entities.FindByClassnameNearest("prop_physics", vector, 10).Kill()
}

// Push Triggers
local van_start_relay = Ent("van_start_relay")
for ( local i = 1; i < 7; i++ )
{
	EntFire( format("van_push%i_trigger", i) , "Kill")
	EntityOutputs.RemoveOutput(van_start_relay, "OnTrigger", triggerName, "Enable", "")
}

// Misc.
local van_button = Ent("van_button")
EntityOutputs.AddOutput(van_button, "OnPressed", "@director", "PanicEvent", "", 2, -1)
EntityOutputs.RemoveOutput(van_button, "OnPressed", "@director", "BeginScript", "c11m4_minifinale")
EntityOutputs.RemoveOutput(van_button, "OnPressed", "van_endscript_relay", "Trigger", "")
Ent("van_endscript_relay").Kill()

// ++ ALARM ++
// -----------
EntFire("onslaught_hint_kill", "Kill")
EntFire("onslaught_hint_trigger", "Kill")
EntFire("onslaught_template", "Kill")
EntFire("alarm_safety_relay", "Kill")
EntFire("spawn_zombie_alarm", "Kill")

// Low settings make the fade look ridiculous on this important prop
local securityalarmbase1 = Ent("securityalarmbase1")
securityalarmbase1.__KeyValueFromInt("fadescale", 0.2)

// Outputs to set up the new holdout event
local alarm_on_relay = Ent("alarm_on_relay")
local alarm_off_relay = Ent("alarm_off_relay")
EntityOutputs.AddOutput(alarm_on_relay, "OnTrigger", "@director", "PanicEvent", "", 0, -1)
EntityOutputs.AddOutput(alarm_on_relay, "OnTrigger", "@director", "ScriptedPanicEvent", "patch_da_alarm", 1, -1)
EntityOutputs.RemoveOutput(alarm_on_relay, "OnTrigger", "@director", "BeginScript", "c11m4_onslaught")
EntityOutputs.RemoveOutput(alarm_on_relay, "OnTrigger", "@director", "EndScript", "")

// ValidateScriptScope creates a script scope if it doesnt exist
alarm_on_relay.ValidateScriptScope()
alarm_off_relay.ValidateScriptScope()

alarm_on_relay.GetScriptScope()["InputTrigger"] <- function()
{
	QueueSpeak(activator, "ResponseSoftDispleasureSwear", 0.5, "")
	return true
}
alarm_off_relay.GetScriptScope()["InputTrigger"] <- function()
{
	for ( local ent=null; ent = Entities.FindByClassname( ent, "player" ); )
	{
		if (ent.IsSurvivor())
		{
			EmitSoundOnClient("Breakable.Computer", ent);
		}
	}
	return true
}

// ++ SAFEROOM ++
// --------------
// Turns out "Scripted Panic Events" look for finale cameras, instead of deleting it we'll move it to a sensible spot.
local camera_finale = Ent("camera_finale")
camera_finale.SetOrigin( Vector( 3131.328, 5090.564, 262.837 ) )
camera_finale.SetAngles( QAngle( -7.2125, -102.7496, 0.00000 ) )

// Block Concept 'PlayerNearCheckpoint' so 'SurvivorNearCheckpointC11M4[X]' won't start
//// otherwise, survivors make comments of no sense outside gauntlets
local worldspawn = Entities.First()
if( !worldspawn.GetContext("worldSaidSafeSpotAhead") )
{
	// SetContext's 2nd argument should not be a number type
	worldspawn.SetContext("worldSaidSafeSpotAhead", "1", -1)
}

// Dummy remark that now does nothing, so lets give it purpose.
Ent("airport04_09").__KeyValueFromString("contextsubject", "hospital03_path01")
