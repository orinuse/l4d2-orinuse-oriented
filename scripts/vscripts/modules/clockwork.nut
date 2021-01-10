//------------------------------------------------------
//		Module Author: mac
//		https://github.com/mac-O-mc
//------------------------------------------------------

// if (!("Clockwork" in getroottable()))
// {
//	const DEFAULT_TICKRATE = 30 // :> its not a convar
//	const STABLE_TICKRATE_FACTOR = 3

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
		UpdateTasksAwaiting = {},
		ThinkTasksAwaiting = {},
		UpdateCount = 0
	}

	::Clockwork.GetCurrentUpdateCount <- function()
	{
		return ::Clockwork.UpdateCount
	}

	::Clockwork.AwaitWithUpdate <- function(counts, func)
	{
		if(!type(counts) == "integer") {
			::Flamboyance.PrintToChatAll("Bad argument #1 to ::Clockwork.AwaitWithUpdate; Value was not integer.", "Beign")
			return false;
		}
		local UpdateTask = { ReUpdatesToAwait = counts, Func = func, LastUpdateCount = ::Clockwork.GetCurrentUpdateCount() }
		::Clockwork.UpdateTasksAwaiting[UniqueString()] <- UpdateTask
	}
	
	// Thinker
	Update = function()
	{
		local toDelete = []
		::Clockwork.UpdateCount+=1;

		foreach(UniqueTaskString, UpdateTask in ::Clockwork.UpdateTasksAwaiting)
		{
			if ((::Clockwork.UpdateCount - UpdateTask.LastUpdateCount) >= UpdateTask.ReUpdatesToAwait)
			{
				if( developer() ) {
					::Flamboyance.PrintToChatAll("Clockwork UPDATE - running found task @"+Time(), "Orange");
					::Flamboyance.PrintToChatAll("Current Update Count -> "+::Clockwork.UpdateCount, "Orange");
				}
				try
				{
					UpdateTask.Func();
				}
				catch(exception)
				{
					::Flamboyance.PrintToChatAll("Clockwork UPDATE - Exception: " + exception,"Orange")
					if( developer() ) {
						if( exception.find("does not exist", 9) )
						::Flamboyance.PrintToChatAll("Perhaps do 'DeepPrintTable(getroottable().g_MapScript)' and verify you are referencing the correct expression?", "OliveGreen");
					}
				}
				if( developer() )
					::Flamboyance.PrintToChatAll("THE TASK is done, @"+Time(), "BrightGreen");
				
				toDelete.append(UniqueTaskString)
			}
		}
		
		foreach(UniqueTaskString in toDelete)
		{
			if (UniqueTaskString in ::Clockwork.UpdateTasksAwaiting)
				delete ::Clockwork.UpdateTasksAwaiting[UniqueTaskString]
		}
	}
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
