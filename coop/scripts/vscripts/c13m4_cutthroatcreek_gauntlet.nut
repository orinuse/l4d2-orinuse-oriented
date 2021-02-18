Msg("VSCRIPT: Running c13m4_cutthroatcreek_gauntlet.nut\n");

local trigger_once = null
if( trigger_once = Entities.FindByClassnameNearest("trigger_once", Vector(-2552, -1656.13, 240.57), 5 ) )
	trigger_once.Kill()

DirectorOptions <- 
{
	CustomTankKiteDistance = 2100
}