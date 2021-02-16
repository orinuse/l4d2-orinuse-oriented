Msg("Initiating C11M4 Reserved Wanderers ADDON\n");

DirectorOptions <-
{
	// Turn always wanderer on
	AlwaysAllowWanderers = 1

	// Set the number of infected that cannot be absorbed
	NumReservedWanderers = 15
}

local scriptRanOnce = null
if( !(scriptRanOnce = Entities.FindByName(scriptRanOnce, "info_scriptRanOnce")) )
{
	IncludeScript("entitygroups/c11m4_missingweapons_group.nut")
	SpawnSingle( C11M4MissingWeapons.GetEntityGroup() )

	EntFire("onslaught_hint_kill", "Kill")
	EntFire("onslaught_template", "Kill")
	EntFire("alarm_safety_relay", "Kill")
	EntFire("spawn_zombie_alarm", "Kill")
	EntFire("securityalarmtrigger1", "AddOutput", "OnTrigger @director:PanicEvent::0:1") // forces a hint in
	EntFire("securityalarmtrigger1", "AddOutput", "OnTrigger securityalarmsparksidle1_modded:StopSpark::0:1")
	EntFire("securityalarmtrigger1", "AddOutput", "OnTrigger onslaught_env_hint_pre:Kill::1.0:1")

	// Buncha stuff about spawning entities down here
	local securityalarmbase1 = null
	local securityalarmsparks1_modded = null
	if( securityalarmbase1 = Entities.FindByName(securityalarmbase1, "securityalarmbase1") )
	{
		// entity kvs, moving them here for organizing
		local onslaught_env_hint_pre_kvs =
		{
			targetname = "onslaught_env_hint_pre"
			origin = securityalarmbase1.GetOrigin()

			hint_target = "securityalarmbase1"
			hint_caption = "#L4D_Instructor_explain_panic_button2"
			hint_icon_onscreen = "icon_alert_red"
			hint_icon_offscreen = "icon_alert_red"
			hint_color = "255 255 255"
			hint_icon_offset  = 12

			hint_range = 500
			hint_name = "explain_metal_detector_modded"
			hint_display_limit = 2
			hint_forcecaption = 1
			hint_instance_type = 2
			hint_auto_start = 1
		}
		local securityalarmsparksidle1_modded_kvs =
		{
			targetname = "securityalarmsparksidle1_modded"
			origin = securityalarmbase1.GetOrigin()
			spawnflags = 64

			MaxDelay = 2
			Magnitude = 2
			TrailLength = 1
		}
		local securityalarmsparks1_modded_kvs =
		{
			targetname = "securityalarmsparks1_modded"
			origin = securityalarmbase1.GetOrigin()

			MaxDelay = 2
			Magnitude = 6
			TrailLength = 2
		}

		// now, spawning them
		SpawnEntityFromTable("env_instructor_hint", onslaught_env_hint_pre_kvs)
		SpawnEntityFromTable("env_spark", securityalarmsparks1_modded_kvs)
		SpawnEntityFromTable("env_spark", securityalarmsparksidle1_modded_kvs)
	}

	local alarm_on_relay = null
	if( alarm_on_relay = Entities.FindByName(alarm_on_relay, "alarm_on_relay") )
	{
		// Auto creates a script scope if it doesnt exist
		if( alarm_on_relay.ValidateScriptScope() )
		{
			local scrscope = alarm_on_relay.GetScriptScope()
			scrscope["InputTrigger"] <- function()
			{
				QueueSpeak(activator, "ResponseSoftDispleasureSwear", 0.5, null)
				return true
			}
		}
	}

	local alarm_off_relay = null
	if( alarm_off_relay = Entities.FindByName(alarm_off_relay, "alarm_off_relay") )
	{
		if( alarm_off_relay.ValidateScriptScope() )
		{
			local scrscope = alarm_off_relay.GetScriptScope()
			scrscope["InputTrigger"] <- function()
			{
				EntFire("securityalarmsparks1_modded", "SparkOnce")
				// sucks no good way to make the feedback of the alarm stopping louder
				local survivor = null
				while( survivor = Entities.FindByClassname(survivor, "survivor") )
					survivor.IsSurvivor() ? EmitSoundOnClient("Breakable.Computer", survivor) : 0

				return true
			}
		}
	}

	local scriptRanOnce_ent = SpawnEntityFromTable("info_target", { targetname = "info_scriptRanOnce"} )
}