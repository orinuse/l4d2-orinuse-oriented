// Dead Air - Terminals DLC Patches, of Orin's
// Copyright ©️ 2021 Orinuse (https://steamcommunity.com/id/orinuse/)
//// For full details on GNU General Public License v3.0, see the addon / repository's main folder.
//==================================================================
Msg("VSCRIPT: Running c11m4_patch_alarm_minifinale.nut\n");

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
	A_CustomFinaleValue2 = "c11m4_patch_alarm_blaring"
	// BUG: After a SCRIPTED stage for Scripted Panic Event, other waves below it seemignly can't be continued
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