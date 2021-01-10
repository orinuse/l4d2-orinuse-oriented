//------------------------------------------------------
//		Flamboyance: Prints to chatbox easily
//		https://github.com/mac-O-mc
//------------------------------------------------------

if (!("Flamboyance" in getroottable()))
{
	printl("Loading module: Flamboyance.nut")
	::Flamboyance <- {}
	
	local function ParseEnums(val)
	{
		try{
			if(type(val) == "string")
			{
				switch(val) {
					case "Beign"			: return "\x01";
					case "BrightGreen"	: return "\x03";
					case "Orange"		: return "\x04";
					case "OliveGreen"		: return "\x05";
					
					case "HUD_PRINTNOTIFY"		: return "1";
					case "HUD_PRINTCONSOLE"	: return "2";
					case "HUD_PRINTTALK"		: return "3";
					case "HUD_PRINTCENTER"		: return "4";
				}
			}
			else
				return val;
		}catch(exception)
			ClientPrint(null, DirectorScript.HUD_PRINTTALK, Orange+"FLAMOYANCE MODULE - ParseEnums EXCEPTION: "+exception);
	}

	::Flamboyance.CustomizedPrint <- function(string, client, printdest = 3, colorcode = "Orange")
	{
		try{
			ClientPrint(client, ParseEnums(printdest), (ParseEnums(colorcode))+string);
		}
		catch(exception)
			ClientPrint(null, printdest, (ParseEnums(colorcode))+"::Flamboyance.Print throwing exception: "+exception);
	}

	::Flamboyance.PrintToChatAll <- function(string, colorcode = "Orange")
	{
		try{
			ClientPrint(null, DirectorScript.HUD_PRINTTALK, (ParseEnums(colorcode))+string);
		}
		catch(exception)
			ClientPrint(null, DirectorScript.HUD_PRINTTALK, (ParseEnums(colorcode))+"::Flamboyance.PrintToChatAll throwing exception: "+exception);
	}
}
