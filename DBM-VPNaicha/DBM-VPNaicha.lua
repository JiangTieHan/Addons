local Naicha = CreateFrame("Frame")
Naicha:RegisterEvent("PLAYER_ENTERING_WORLD")
local NaichaEvent = function()
    if not DBM_AllSavedOptions["Default"] then 
        DBM_AllSavedOptions["Default"] = {} 
    end
    DBM_AllSavedOptions["Default"]["ChosenVoicePack"] = "Naicha"
end
Naicha:SetScript("OnEvent", NaichaEvent)