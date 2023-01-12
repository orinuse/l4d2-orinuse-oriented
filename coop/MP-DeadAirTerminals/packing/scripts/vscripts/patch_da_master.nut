Msg("VSCRIPT [Orin]: Running 'patch_da_master' \n");

// - BONUS: escalator remark -
local remark_Farm02_path06_kvs =
{
	targetname = "farm02_path06"
	origin = Vector(-420, 5136, 348).ToKVString() // ToKVString isn't necessary for Vectors in this case, but ill keep using it
	contextsubject = "farm02_path06"
}
SpawnEntityFromTable("info_remarkable", remark_Farm02_path06_kvs)

// - luggage carts mincpulevel/mingpulevel error -
local luggage_carts_origins =
[
	Vector(-94.25, 4274.63, 28.9688),
	Vector(199.969, 3815.97, 16.4688),
	Vector(61.5625, 3819.47, 16.4688),
]
foreach( vector in luggage_carts_origins )
{
	Entities.FindByClassnameNearest("prop_physics", vector, 10).Kill()
	// 'reported ENTITY_CHANGE_NONE but 'm_nMinGPULevel' changed.'
	// These keys don't work in an ENTITY_CHANGE_NONE state report.. Kill input it'll be
	/* local luggage_cart_prop = Entities.FindByClassnameNearest("prop_physics", vector, 10)
	luggage_cart_prop.__KeyValueFromInt("mincpulevel", 0)
	luggage_cart_prop.__KeyValueFromInt("mingpulevel", 0) */
}

// - push -
local van_push_trigs = [
	"van_push1_trigger",
	"van_push2_trigger",
	"van_push3_trigger",
	"van_push4_trigger",
	"van_push5_trigger",
	"van_push6_trigger",
]

local van_start_relay = Ent("van_start_relay")
foreach (triggerName in van_push_trigs)
{
	EntFire(triggerName, "Kill")
	EntityOutputs.RemoveOutput(van_start_relay, "OnTrigger", triggerName, "Enable", "")
}

// - holdout -
local van_button = Ent("van_button")
EntityOutputs.AddOutput(van_button, "OnPressed", "@director", "PanicEvent", "", 2, -1)
EntityOutputs.RemoveOutput(van_button, "OnPressed", "@director", "BeginScript", "c11m4_minifinale")
EntityOutputs.RemoveOutput(van_button, "OnPressed", "van_endscript_relay", "Trigger", "")
Ent("van_endscript_relay").Kill()

// - holdout (cleanup) -
// All exact outputs might not be here; some are in the EGroup script
EntFire("onslaught_hint_kill", "Kill")
EntFire("onslaught_hint_trigger", "Kill")
EntFire("onslaught_template", "Kill")
EntFire("alarm_safety_relay", "Kill")
EntFire("spawn_zombie_alarm", "Kill")

// Low settings make the fade look ridiculous; This is an important object so we'll turn down the fade!
//// on higher settings the model might never fade out? But shouldn't be an issue / concern
local securityalarmbase1 = Ent("securityalarmbase1")
// another kv affected by 'reported ENTITY_CHANGE_NONE' quirk, oh well
/* securityalarmbase1.__KeyValueFromInt("fademindist", 700)
securityalarmbase1.__KeyValueFromInt("fademaxdist", 900) */
securityalarmbase1.__KeyValueFromInt("fadescale", 0.2)

// - holdout (new outputs) -
local alarm_on_relay = Ent("alarm_on_relay")
local alarm_off_relay = Ent("alarm_off_relay")
EntityOutputs.AddOutput(alarm_on_relay, "OnTrigger", "@director", "PanicEvent", "", 0, -1)
EntityOutputs.AddOutput(alarm_on_relay, "OnTrigger", "@director", "ScriptedPanicEvent", "patch_da_alarm", 1, -1)
EntityOutputs.RemoveOutput(alarm_on_relay, "OnTrigger", "@director", "BeginScript", "c11m4_onslaught")
EntityOutputs.RemoveOutput(alarm_on_relay, "OnTrigger", "@director", "EndScript", "")

// ValidateScriptScope creates a script scope if it doesnt exist
alarm_on_relay.ValidateScriptScope()

alarm_on_relay.GetScriptScope()["InputTrigger"] <- function()
{
	// THIS CRASHES THE GAME IF YOU APPEND NULL!!!
	QueueSpeak(activator, "ResponseSoftDispleasureSwear", 0.5, "")
	return true
}

alarm_off_relay.ValidateScriptScope()

alarm_off_relay.GetScriptScope()["InputTrigger"] <- function()
{
	// no good way to make the feedback of the alarm stopping louder
	for ( local ent=null; ent = Entities.FindByClassname( ent, "player" ); )
		// doesn't matter if we check if its not a bot
		if (ent.IsSurvivor())
		{ EmitSoundOnClient("Breakable.Computer", ent); }
		// Shadowysn: protip, if you want to use ? with a dummy : fallback that does nothing
		// just use the standard if()
		// ent.IsSurvivor() ? EmitSoundOnClient("Breakable.Computer", ent) : 0

	return true
}

// - saferoom -
// Scripted Panic Events look for finale cameras too! Move it to a sensible spot.
local camera_finale = Ent("camera_finale")
camera_finale.SetOrigin( Vector( 3131.328, 5090.564, 262.837 ) )
camera_finale.SetAngles( QAngle( -7.2125, -102.7496, 0.00000 ) )

// Prevent Concept 'PlayerNearCheckpoint' so 'SurvivorNearCheckpointC11M4[X]' won't start
// Otherwise survivors say things like "MOVE!" which only make sense for gauntlets
local worldspawn = Entities.First()
if( !worldspawn.GetContext("worldSaidSafeSpotAhead") )
{ worldspawn.SetContext("worldSaidSafeSpotAhead", "1", -1) }
// SetContext's 2nd argument dislikes numbers

// The remark did nothing before, I thought was why survivors speak as they almost reach saferoom.
// Just make the remark cause them to actually speak
Ent("airport04_09").__KeyValueFromString("contextsubject", "hospital03_path01")
