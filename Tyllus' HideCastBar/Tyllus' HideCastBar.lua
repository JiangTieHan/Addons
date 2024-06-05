ConsoleExec( "threatShowNumeric 1" )

local pciscript = CreateFrame("Frame")
pciscript:RegisterEvent("PLAYER_ENTERING_WORLD")
pciscript:RegisterEvent("ADDON_LOADED")
pciscript:RegisterEvent("PLAYER_LOGIN")
pciscript:RegisterEvent("PLAYER_LOGOUT")

local function eventHandler(self,event)
 if event == "ADDON_LOADED" then
	if TyllusHideCastBar == 1 then
	 PlayerCastingBarFrame:RegisterAllEvents()
	else
	 PlayerCastingBarFrame:UnregisterAllEvents()
	end
 end
end
pciscript:SetScript("OnEvent",eventHandler)


SLASH_HCB1 = "/hcb";
local function handler(msg, editbox)
	if TyllusHideCastBar == 1 then
	TyllusHideCastBar = 0
	PlayerCastingBarFrame:UnregisterAllEvents()
	print ('TyllusHideCastBar: Original CastBar is |cfcc3300fOFF|r');
	else
	PlayerCastingBarFrame:RegisterAllEvents()
	TyllusHideCastBar = 1
	print ('TyllusHideCastBar: Original CastBar is |cf00cc00fON|r');
	end
end
SlashCmdList["HCB"] = handler;