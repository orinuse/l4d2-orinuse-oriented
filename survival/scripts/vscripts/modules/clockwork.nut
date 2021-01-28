//------------------------------------------------------
//		Module Author: mac
//		https://github.com/mac-O-mc
//------------------------------------------------------
if( developer() )
	::Flamboyance.PrintToChatAll("Clockwork - DEV Mode detected", "Beign")

// if(!("Clockwork" in getroottable()))
// {
	const DEFAULT_TICKRATE = 30 // :> its not a convar
	const STABLE_TICKRATE_FACTOR = 3

	IncludeScript("modules/flamboyance.nut")
	printl("Loading module: Clockwork.nut")
//--== Util ==--
	local function MathRound(floatnum)
	{
		local floornum = floor(floatnum)
		local ceilnum = ceil(floatnum)
		if(floatnum - floornum >= 0.5)
			return ceilnum
		else
			return floatnum
	}
	local function MathToClosestMultipleOf(num, factor)
	{
		return factor * (MathRound(num / factor))
	}
	local function developerVerbose()
	{
		if( Convars.GetFloat("developer") >= 2)
			return true
	}
	local function IsPostMapLoad()
	{
		return ::Clockwork.UpdateRanOnce
		// This will be false for all community maps :/
	//	return g_UpdateRanOnce // this is from `mapspawn.nut`, used by anv_functions.nut
	}

//--== Clockwork ==--
	::Clockwork <- {
		UpdateTasksAwaiting = {},
		ThinkTasksAwaiting = {},
		UpdateRanOnce = false,
		UpdateRanCount = 0,
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
	// with default variables in use, every parameter that may be empty MUST have a default argument
	::Clockwork.ThinkWait <- function(seconds, func, args = [], ID = null, repeat = false, rethinkrate = 0.033, unprotected = false)
	{
		try
		{
			if(!type(seconds) == "integer" && !type(seconds) == "float")
				throw("Key 'seconds' was not integer or float.")

			// If seconds is less than 1 / 100, assume seconds is 1 / DEFAULT_TICKRATE.
			if(!(seconds >= 1 / DEFAULT_TICKRATE)) 
				seconds = 1 / DEFAULT_TICKRATE

			if(typeof args != "array") {
				if( developer() )
					::Flamboyance.PrintToChatAll("::Clockwork.ThinkWait - 'args' must be a array","Orange")

				return false
			}

			if(ID == null || ID == "")
			{
				if( developer() && ID == "" )
					::Flamboyance.PrintToChatAll("::Clockwork.ThinkWait - 'ID' is actually zero byte string? Damn, I thought nobody does that","Orange")

				ID = UniqueString()
			}

			rethinkrate = MathToClosestMultipleOf(rethinkrate, STABLE_TICKRATE_FACTOR)
			local ThinkTask = { SecondsToAwait = seconds, Func = func, Args = args, Repeat = repeat, RethinkRate = rethinkrate, Unprotected = unprotected, LastTime = Time() }

			::Clockwork.ThinkTasksAwaiting[ID] <- ThinkTask
		}
		catch(exception)
		{
			::Flamboyance.PrintToChatAll("::Clockwork.ThinkWait - Exception: "+exception,"Orange")
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
		local RethinkRate = 0.033
		// first one's just to be safe.... thinks run alot so it worries me a little :>
		if(IsPostMapLoad() == true && ::Clockwork.ThinkTasksAwaiting.len() != 0)
		{
			local curtime = Time()
			local toDelete = []

			foreach(ThinkTaskID, ThinkTask in ::Clockwork.ThinkTasksAwaiting)
			{
				local wait_time = ThinkTask.LastTime + ThinkTask.SecondsToAwait
				if (curtime > wait_time)
				{		
					if(!ThinkTask.Unprotected)
					{
						try
						{
							if( developerVerbose() )
								::Flamboyance.PrintToChatAll("Clockwork THINK FUNC - running found task @"+Time(), "Orange")

							// UGH the if statement got tiring lol, time to condense
							ThinkTask.Args.len() != 0 ? ThinkTask.Func.acall(ThinkTask.Args) : ThinkTask.Func.call(this)
							RethinkRate = ThinkTask.RethinkRate
						}
						catch(exception)
						{
							::Flamboyance.PrintToChatAll("Clockwork THINK FUNC - Exception: " + exception,"Orange")
							if( developer() && exception.find("does not exist", 11)) {
								::Flamboyance.PrintToChatAll("Perhaps verify you are referencing the correct expression?", "OliveGreen")
								::Flamboyance.PrintToChatAll("To start doing so, in console execute the command: 'script (g_ModeScript.DeepPrintTable(getroottable().g_MapScript))'", "OliveGreen")
							}
							else if( developer() && exception.find("number of parameters", 6) )
							{
								::Flamboyance.PrintToChatAll("Does your function have at least one parameter?", "OliveGreen")
							}
						}
						if (ThinkTask.Repeat)
							ThinkTask.LastTime = curtime
						else
							toDelete.push(ThinkTaskID)	// push and append are the same thing, apparently
					}
					else // same shit but without try{}catch{} to give you fancy chat msgs
					{
						if( developerVerbose() )
							::Flamboyance.PrintToChatAll("Clockwork THINK FUNC - running UNPROTECTED task @"+Time(), "Orange")

						ThinkTask.Args.len() != 0 ? ThinkTask.Func.acall(ThinkTask.Args) : ThinkTask.Func.call(this)
						RethinkRate = ThinkTask.RethinkRate
						if (ThinkTask.Repeat)
							ThinkTask.LastTime = curtime
						else
							toDelete.push(ThinkTaskID)
					}
			
					foreach(ThinkTaskID in toDelete)
					{
						if( developerVerbose() )
							::Flamboyance.PrintToChatAll("ThinkTasks: "+::Clockwork.ThinkTasksAwaiting.len(), "BrightGreen")

						if (ThinkTaskID in ::Clockwork.ThinkTasksAwaiting)
							delete ::Clockwork.ThinkTasksAwaiting[ThinkTaskID]
						
						if( developerVerbose() )
							::Flamboyance.PrintToChatAll("ThinkTasks left: "+::Clockwork.ThinkTasksAwaiting.len(), "BrightGreen")
					}
				}
			}
		}
		return RethinkRate
	}
// }

ScriptDebugAddTextFilter("::Clockwork.Think")

function Update()
{
	if( !::Clockwork.UpdateRanOnce )
	{
		if( ::Clockwork.UpdateRanCount >= 1 )
		{
			::Clockwork.UpdateRanOnce = true
		}
		if( ::Clockwork.UpdateRanCount <= 1 )
			::Clockwork.UpdateRanCount++
	}
}

ScriptDebugAddTextFilter("Update")

if (!::Clockwork.ThinkEnt || !::Clockwork.ThinkEnt.IsValid())
{
	// these are needed when debugging
	local FindByName = null
	if(FindByName = Entities.FindByName(::Clockwork.ThinkEnt, "ClockworkThink")) {
		::Clockwork.ThinkEnt = FindByName
		if( developer() )
			::Flamboyance.PrintToChatAll("Clockwork - Think ENT: Found existing one", "OliveGreen")
	}
	else {
		::Clockwork.ThinkEnt = SpawnEntityFromTable("info_target", { targetname = "ClockworkThink" })
		if( developer() )
			::Flamboyance.PrintToChatAll("Clockwork - Think ENT: Creating one", "OliveGreen")
	}

	if (::Clockwork.ThinkEnt)
	{
		::Clockwork.ThinkEnt.ValidateScriptScope()
		local scope = ::Clockwork.ThinkEnt.GetScriptScope()
		scope["ClockworkThink"] <- ::Clockwork.Think
		AddThinkToEnt(::Clockwork.ThinkEnt, "ClockworkThink")
		ScriptDebugAddTextFilter("ClockworkThink")
		if( developer() ) {
			::Flamboyance.PrintToChatAll("Clockwork - Think ENT: Intialized", "OliveGreen")
		}
	}
	else
	{
		if( developer() ) {
			::Flamboyance.PrintToChatAll("Clockwork - Think ENT: Intialize failure", "OliveGreen")
		}
	}
}
else
{
	if( developer() ) {
		::Flamboyance.PrintToChatAll("Clockwork - Think ENT: Already Intialized", "OliveGreen")
	}
}
