Msg("VSCRIPT [Orin]: Running 'patch_da_alarm' \n");

const ERROR = -1
const PANIC = 0
const TANK = 1
const DELAY = 2
const SCRIPTED = 3

DirectorOptions <-
{
	A_CustomFinale_StageCount = 2

	A_CustomFinale1 = DELAY
	A_CustomFinaleValue1 = 3

	A_CustomFinale2 = SCRIPTED
	A_CustomFinaleValue2 = "patch_da_alarm2"

	// BUG: Waves cannot proceed once a SCRIPTED stage is reached in Scripted Panic Events.
	/*A_CustomFinale3 = PANIC
	A_CustomFinaleValue1 = 1*/
}

function OnBeginCustomFinaleStage(num, type)
{
	if( num == 2 )
	{
		DirectorOptions.ZombieSpawnRange = 2500
		DirectorOptions.ZombieDiscardRange = 3000
		Director.ResetSpecialTimers()
	}
}
