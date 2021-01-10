//------------------------------------------------------
//		Module Author: mac
//		https://github.com/mac-O-mc
//------------------------------------------------------

//if (!("Clockwork" in getroottable()))
//{
	const DEFAULT_TICKRATE = 30 // :> its not a convar
	const STABLE_TICKRATE_FACTOR = 3

	IncludeScript("modules/flamboyance.nut")
	printl("Loading module: Clockwork.nut")
	
	function MathRound(floatnum)
	{
		local floornum = floor(floatnum)
		local ceilnum = ceil(floatnum)
		if(floatnum - floornum >= 0.5)
			return ceilnum
		else
			return floatnum
	}
	
	function MathToClosestMultipleOf(num, factor)
	{
		return factor * (MathRound(num / factor))
	}

	::Clockwork <- {
		UpdateTasksAwaiting = {}
		ThinkTasksAwaiting = {}
		UpdateCount = 0;
	}

	::Clockwork.AwaitUpdates <- function(counts, func)
	{
		if(!type(counts) == "integer"") {
			::Flamboyance.PrintToChatAll("Bad argument #1 to ::Clockwork.AwaitUpdates; Value was not integer.", "Beign")
			return false;
		}
		local UpdateTask = { ReUpdatesToAwait = counts, func = func, LastUpdateCount = UpdateCount }
		::Clockwork.AwaitUpdateTasks[UniqueString()] <- UpdateTask;
	}
// This is experimental code, not for github	
/*
	// Thinker
	Update = function()
	{
		local toDelete = [];
		UpdateCount++

		foreach(UniqueString, UpdateTask in ::Clockwork.UpdateTasksAwaiting)
		{
			if ((UpdateCount - UpdateTask.LastUpdateCount) >= UpdateTask.ReUpdatesToAwait)
			{
				try
				{
					timer.Func(timer.params);
				}
				catch(exception)
				{
					printl("Left4Timers.ThinkFunc - Exception: " + exception);
				}
				
				toDelete.append(timerName);
			}
		}
		
		foreach(timerName in toDelete)
		{
			if (timerName in ::Left4Timers.Timers)
				delete ::Left4Timers.Timers[timerName];
		}
	}	*/

/* 	::Clockwork.AwaitThinks <- function(seconds, func)
	{
		if(!type(seconds) == "integer" && !type(seconds) == "float") {
			::Flamboyance.PrintToChatAll("Bad argument #1 to ::Clockwork.AwaitThinks; Value was not integer or float.", "Beign")
			return false;
		}	
		// If seconds is less than 1 / 100, assume seconds is 1 / 100.
		// Think functions rethink every 100 ms
		if (!(seconds >= 1 / DEFAULT_TICKRATE)) // || seconds == RAND_MAX
			seconds = 1 / DEFAULT_TICKRATE;
			
		MathToClosestMultipleOf(seconds, DEFAULT_TICKRATE)
		::Clockwork.AwaitThinkTasks[seconds.tostring()] <- func;
	} */
// }
// else
	// ClientPrint(null, DirectorScript.HUD_PRINTTALK, Orange+"Clockwork.nut attempting to load, when an 'Clockwork' module already is loaded?")
