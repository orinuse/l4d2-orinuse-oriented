//------------------------------------------------------
//		Module Author: mac
//		https://github.com/mac-O-mc
//------------------------------------------------------
if( developer() )
	::Flamboyance.PrintToChatAll("Clockwork - DEV Mode detected", "Beign")

// if(!("Clockwork" in getroottable()))
// {
	local IsPostMapLoad = g_UpdateRanOnce // this is from `mapspawn.nut`, used by anv_functions.nut
	
	const DEFAULT_TICKRATE = 30 // :> its not a convar
	const STABLE_TICKRATE_FACTOR = 3

	IncludeScript("modules/flamboyance.nut")
	printl("Loading module: Clockwork.nut")
//--== Math ==--
	local function MathRound (floatnum)
	{
		local floornum = floor(floatnum)
		local ceilnum = ceil(floatnum)
		if(floatnum - floornum >= 0.5)
			return ceilnum
		else
			return floatnum
	}
	local function MathToClosestMultipleOf (num, factor)
	{
		return factor * (MathRound(num / factor))
	}
	local function developerVerbose()
	{
		if( Convars.GetFloat("developer") >= 2)
			return true
	}

//--== Clockwork ==--
	::Clockwork <- {
		UpdateTasksAwaiting = {},
		ThinkTasksAwaiting = {},
		ThinkEnt = null
	}
//-- Hooks
	// isn't called in this script, has to be put in g_MapScript scope
	/* InterceptChat <- function(message, speaker) // will need sm_utilies.nut's InjectTable? What's everything in that file anyways?
	{
		if( message.find("clockwork") )
		{
			::Flamboyance.PrintToChatAll("Success","OliveGreen")
		}
	} */
//-- Module specific functions
	::Clockwork.AwaitWithThink <- function(seconds, func, ID = UniqueString(), repeat = false, rethinkrate = 0.33, unprotected = false)
	{
		try
		{
			if(!type(seconds) == "integer" && !type(seconds) == "float")
				throw("Key 'seconds' was not integer or float.")

			// If seconds is less than 1 / 100, assume seconds is 1 / DEFAULT_TICKRATE.
			if (!(seconds >= 1 / DEFAULT_TICKRATE)) 
				seconds = 1 / DEFAULT_TICKRATE

			if(ID == null || ID == "")
			{
				if( developerVerbose() ) {
					::Flamboyance.PrintToChatAll("Clockwork - Key 'ID' must be a valid string! Falling back to UniqueString().","Orange")
				}
				ID = UniqueString()
			}

			rethinkrate = MathToClosestMultipleOf(rethinkrate, STABLE_TICKRATE_FACTOR)
			local ThinkTask = { SecondsToAwait = seconds, Func = func, Repeat = repeat, RethinkRate = rethinkrate, Unprotected = unprotected, LastTime = Time() }
			::Clockwork.ThinkTasksAwaiting[ID] <- ThinkTask
		}
		catch(exception)
		{
			::Flamboyance.PrintToChatAll("::Clockwork.AwaitWithThink - Exception: "+exception,"Orange")
		}
	}
	::Clockwork.GetThinkTask <- function(ID)
	{
		try
		{
			if(typeof ID != "string")
				throw("Key 'ID' must be a string!")
			if(ID == null || ID == "")
				throw("Key 'ID' cannot be null, or empty string!")

			foreach(ThinkTaskID, ThinkTask in ::Clockwork.ThinkTasksAwaiting)
			{
				if (ThinkTaskID == ID)
					return ThinkTask
			}
		}
		catch(exception)
		{
			::Flamboyance.PrintToChatAll("::Clockwork.GetThinkTask - Exception: "+exception,"Orange")
		}
	}
	::Clockwork.DeleteThinkTask <- function(ID)
	{
		try
		{
			if(typeof ID != "string")
				throw("Key 'ID' must be a string!")
			if(ID == null || ID == "")
				throw("Key 'ID' cannot be null, or empty string!")

			foreach(ThinkTaskID, ThinkTask in ::Clockwork.ThinkTasksAwaiting)
			{
				if (ThinkTaskID == ID) {
					delete ::Clockwork.ThinkTasksAwaiting[ThinkTaskID]
					if( developerVerbose() )
						::Flamboyance.PrintToChatAll("Clockwork - Deleted Think Task: "+ThinkTaskID)

					return true
				}
			}
		}
		catch(exception)
		{
			::Flamboyance.PrintToChatAll("::Clockwork.DeleteThinkTask - Exception: "+exception,"Orange")
		}
	}
// By the way, Thinker implementation is based on Left 4 Bots's timer system. Its a good method and I don't see a better alternative I can come up with.
//// Author's named Goben, check their bot system out on Steam Workshop
	::Clockwork.Think <- function()
	{
		local RethinkRate = 0.33
		// last one is just to be safe.... as cuz thinks run alot so it worries me a little :>
		if(IsPostMapLoad == true && ::Clockwork.ThinkTasksAwaiting.len() != 0)
		{
			local curtime = Time();
			local toDelete = []

			foreach(ThinkTaskID, ThinkTask in ::Clockwork.ThinkTasksAwaiting)
			{
				if ((curtime - ThinkTask.LastTime) >= ThinkTask.SecondsToAwait)
				{		
					if(!ThinkTask.Unprotected)
					{
						try
						{
							if( developerVerbose() ) {
								::Flamboyance.PrintToChatAll("Clockwork Think - running found task @"+Time(), "Orange");
							}
							ThinkTask.Func()
							RethinkRate = ThinkTask.RethinkRate
						}
						catch(exception)
						{
							printl(type(exception))
							::Flamboyance.PrintToChatAll("Clockwork Think - Exception: " + exception,"Orange")
							if( developer() && exception.find("does not exist", 9)) {
								::Flamboyance.PrintToChatAll("Perhaps verify you are referencing the correct expression?", "OliveGreen");
								::Flamboyance.PrintToChatAll("To start doing so, in console execute the command: 'script (g_ModeScript.DeepPrintTable(getroottable().g_MapScript))'", "OliveGreen");
							}
						}

						if (ThinkTask.Repeat)
							ThinkTask.LastTime = curtime
						else
							toDelete.push(ThinkTaskID)	// push and append are the same thing, apparently
					}
					else
					{
						if( developerVerbose() ) {
							::Flamboyance.PrintToChatAll("Clockwork Think - running UNPROTECTED task @"+Time(), "Orange");
						}
						ThinkTask.Func()
						RethinkRate = ThinkTask.RethinkRate
					}
				}
			}
			
			foreach(ThinkTaskID in toDelete)
			{
				if (ThinkTaskID in ::Clockwork.ThinkTasksAwaiting)
					delete ::Clockwork.ThinkTasksAwaiting[ThinkTaskID]
				
				if( developerVerbose() )
					::Flamboyance.PrintToChatAll("ThinkTasks left: "+::Clockwork.ThinkTasksAwaiting.len(), "BrightGreen");
			}
		}
		return RethinkRate
	}
// }

ScriptDebugAddTextFilter("::Clockwork.Think")

if (!::Clockwork.ThinkEnt || !::Clockwork.ThinkEnt.IsValid())
{
	::Clockwork.ThinkEnt = SpawnEntityFromTable("info_target", { targetname = "ClockworkThink" });
	if (::Clockwork.ThinkEnt)
	{
		::Clockwork.ThinkEnt.ValidateScriptScope();
		local scope = ::Clockwork.ThinkEnt.GetScriptScope();
		scope["ClockworkThink"] <- ::Clockwork.Think;
		AddThinkToEnt(::Clockwork.ThinkEnt, "ClockworkThink");
		ScriptDebugAddTextFilter("ClockworkThink")
		if( developer() ) {
			::Flamboyance.PrintToChatAll("Clockwork - Think ENT: Spawned", "OliveGreen");
		}
	}
	else
	{
		if( developer() ) {
			::Flamboyance.PrintToChatAll("Clockwork - Think ENT: Spawn failure", "OliveGreen");
		}
	}
}
else
{
	if( developer() ) {
		::Flamboyance.PrintToChatAll("Clockwork - Think ENT: Already spawned", "OliveGreen");
	}
}
