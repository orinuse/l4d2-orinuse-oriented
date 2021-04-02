Msg("VSCRIPT: Running c11m4_patch_master.nut ADDON\n");

// == VAN HOLDOUT ==
// - push -
EntFire("van_push1_trigger", "Kill")
EntFire("van_push2_trigger", "Kill")
EntFire("van_push3_trigger", "Kill")
EntFire("van_push4_trigger", "Kill")
EntFire("van_push5_trigger", "Kill")
EntFire("van_push6_trigger", "Kill")

local van_start_relay = Ent("van_start_relay")
EntityOutputs.RemoveOutput(van_start_relay, "OnTrigger", "van_push1_trigger", "Enable", "")
EntityOutputs.RemoveOutput(van_start_relay, "OnTrigger", "van_push2_trigger", "Enable", "")
EntityOutputs.RemoveOutput(van_start_relay, "OnTrigger", "van_push3_trigger", "Enable", "")
EntityOutputs.RemoveOutput(van_start_relay, "OnTrigger", "van_push4_trigger", "Enable", "")
EntityOutputs.RemoveOutput(van_start_relay, "OnTrigger", "van_push5_trigger", "Enable", "")
EntityOutputs.RemoveOutput(van_start_relay, "OnTrigger", "van_push6_trigger", "Enable", "")

// - holdout -
local van_button = Ent("van_button")
EntityOutputs.AddOutput(van_button, "OnPressed", "@director", "PanicEvent", "", 2, -1)
EntityOutputs.RemoveOutput(van_button, "OnPressed", "@director", "BeginScript", "c11m4_minifinale")
EntityOutputs.RemoveOutput(van_button, "OnPressed", "van_endscript_relay", "Trigger", "")
Ent("van_endscript_relay").Kill()

// == ALARM HOLDOUT ==
// All the outputs aren't here; new entity specifics are in the EGroup script
EntFire("onslaught_hint_kill", "Kill")
EntFire("onslaught_hint_trigger", "Kill")
EntFire("onslaught_template", "Kill")
EntFire("alarm_safety_relay", "Kill")
EntFire("spawn_zombie_alarm", "Kill")

local alarm_on_relay = Ent("alarm_on_relay")
local alarm_off_relay = Ent("alarm_off_relay")
EntityOutputs.AddOutput(alarm_on_relay, "OnTrigger", "@director", "PanicEvent", "", 0, -1)
EntityOutputs.AddOutput(alarm_on_relay, "OnTrigger", "@director", "ScriptedPanicEvent", "c11m4_patch_alarm_minifinale", 1, -1)
EntityOutputs.RemoveOutput(alarm_on_relay, "OnTrigger", "@director", "BeginScript", "c11m4_onslaught")
EntityOutputs.RemoveOutput(alarm_on_relay, "OnTrigger", "@director", "EndScript", "")

// Buncha stuff about spawning entities down here
//// ValidateScriptScope creates a script scope if it doesnt exist
//// if statements are strictly for organizing
if( alarm_on_relay.ValidateScriptScope() )
{
	// THIS IS CRASHING THE GAME!!!
	alarm_on_relay.GetScriptScope()["InputTrigger"] <- function()
	{
		QueueSpeak(activator, "ResponseSoftDispleasureSwear", 0.5, "")
		return true
	}
}
if( alarm_off_relay.ValidateScriptScope() )
{
	alarm_off_relay.GetScriptScope()["InputTrigger"] <- function()
	{
		// sucks no good way to make the feedback of the alarm stopping louder
		local player = null
		while( player = Entities.FindByClassname(player, "player") )
			// doesn't matter if we check if its not a bot, btw
			player.IsSurvivor() ? EmitSoundOnClient("Breakable.Computer", player) : 0

		return true
	}
}
