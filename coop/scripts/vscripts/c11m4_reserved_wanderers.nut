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
	local securityalarmbase1 = null
	local securityalarmsparks1_modded = null
	if( securityalarmbase1 = Entities.FindByName(securityalarmbase1, "securityalarmbase1") )
	{
		local onslaught_env_hint_pre = SpawnEntityFromTable("env_instructor_hint", {
			targetname = "onslaught_env_hint_pre"
			origin = securityalarmbase1.GetOrigin()

			hint_target = "securityalarmbase1"
			hint_caption = "#L4D_Instructor_explain_panic_button2"
			hint_icon_onscreen = "icon_alert_red"
			hint_icon_offscreen = "icon_alert_red"
			hint_color = "255 255 255"
			hint_icon_offset  = 10

			hint_range = 500
			hint_name = "explain_metal_detector_modded"
			hint_display_limit = 2
			hint_instance_type = 2
			hint_auto_start = 1
		})
		securityalarmsparks1_modded = SpawnEntityFromTable("env_spark", {
			targetname = "securityalarmsparks1_modded"
			origin = securityalarmbase1.GetOrigin()

			Magnitude = 5
			TrailLength = 2
		})
	}

	local securityalarmtrigger1 = null
	if( securityalarmtrigger1 = Entities.FindByName(securityalarmtrigger1, "securityalarmtrigger1") )
	{
		// Auto creates a script scope if it doesnt exist
		if( securityalarmtrigger1.ValidateScriptScope() )
		{
			local scrscope = securityalarmtrigger1.GetScriptScope()
			scrscope["OnTriggerV"] <- function()
			{
				local onslaught_env_hint_active = SpawnEntityFromTable("env_instructor_hint", {
					targetname = "onslaught_env_hint_active"
					origin = securityalarmtrigger1.GetOrigin()

					hint_caption = "#L4D_Instructor_explain_panic_disturbance_triggered2"
					hint_icon_onscreen = "icon_alert_red"
					hint_icon_offscreen = "icon_alert_red"
					hint_color = "255 255 255"
					hint_timeout = 4

					hint_name = "panic_metal_detector_modded"
					hint_instance_type = 3
					hint_auto_start = 1
				})
				EntFire("onslaught_env_hint_pre", "Kill")
				securityalarmtrigger1.DisconnectOutput("OnTrigger", "OnTriggerV()")
			}
			securityalarmtrigger1.ConnectOutput("OnTrigger", "OnTriggerV()")
		}
	}
	EntFire("onslaught_hint_kill", "Kill")
	EntFire("onslaught_template", "Kill")
	EntFire("alarm_safety_relay", "Kill")
	EntFire("spawn_zombie_alarm", "Kill")

	local alarm_off_relay = null
	if( alarm_off_relay = Entities.FindByName(alarm_off_relay, "alarm_off_relay") )
	{
		// Auto creates a script scope if it doesnt exist
		if( alarm_off_relay.ValidateScriptScope() )
		{
			local scrscope = alarm_off_relay.GetScriptScope()
			scrscope["Precache"] <- function()
			{
			//	if( !IsSoundPrecached("ambient/energy/spark5.wav") )
			//		PrecacheSound("ambient/energy/spark5.wav")
			//	if( !IsSoundPrecached("ambient/energy/spark6.wav") )
			//		PrecacheSound("ambient/energy/spark6.wav")
				self.PrecacheScriptSound("Breakable.Computer") // what if it only precaches this sound for the entity?
			}
			scrscope["InputTrigger"] <- function()
			{
				EntFire("securityalarmsparks1_modded", "SparkOnce")
				EmitSoundOn("Breakable.Computer", securityalarmsparks1_modded)
				Director.UserDefinedEvent1()
				return true
			}
			alarm_off_relay.ConnectOutput("OnTrigger", "OnTriggerV()")
		}
	}
	EntFire("securityalarmtrigger1", "AddOutput", "OnTrigger onslaught_env_hint_pre:Kill::1.0:1")
	EntFire("securityalarmtrigger1", "AddOutput", "OnTrigger @director:PanicEvent::1.0:1")
	EntFire("securityalarmtrigger1", "AddOutput", "OnTrigger alarm_off_relay:Trigger::8.0:1")

	local scriptRanOnce_ent = SpawnEntityFromTable("info_target", { targetname = "info_scriptRanOnce"} )
}