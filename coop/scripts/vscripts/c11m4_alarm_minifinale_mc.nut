Msg("VSCRIPT: Running c11m4_alarm_minifinale_mc.nut\n");
IncludeScript("modules/flamboyance.nut")

const ERROR = -1
const PANIC = 0
const TANK = 1
const DELAY = 2
const SCRIPTED = 3 

DirectorOptions <-
{
	B_CustomFinale_StageCount = 2

	B_CustomFinale1 = DELAY
	B_CustomFinaleValue1 = 3

	B_CustomFinale2 = SCRIPTED
	B_CustomFinaleValue2 = "c11m4_alarm_blaringonslaught_mc"
	// BAD BUG: After a SCRIPTED stage for Scripted Panic Event, other waves below it seemignly can't be continued
}
Director.PlayMegaMobWarningSounds()

function OnBeginCustomFinaleStage(num, type)
{
	if( num == 2 )
	{
		DirectorOptions.ZombieSpawnRange = 2500
		DirectorOptions.ZombieDiscardRange = 3000

		EntFire("securityalarmsparks1_modded", "SparkOnce")
		Director.ResetSpecialTimers()
	}
}