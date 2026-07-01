local addonName, ns = ...

-- DataBroker is optional, so we check if LibDataBroker is loaded
local LDB = LibStub("LibDataBroker-1.1", true)
if not LDB then return end

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot")

-- Create the DataBroker Object
local ndnlLDB = LDB:NewDataObject("NoDebuffNoLoot", {
    type = "data source",
    text = "NDNL",
    icon = "Interface\\AddOns\\NoDebuffNoLoot\\logo",
    OnClick = function(self, button)
        if button == "RightButton" then
            NoDebuffNoLoot:OpenOptions()
        elseif button == "LeftButton" and IsShiftKeyDown() then
            if ns.ConfigUI and ns.ConfigUI.Show then
                ns.ConfigUI:Show()
            end
        else
            if NoDebuffNoLoot.db.profile.hud.shown then
                NoDebuffNoLoot.db.profile.hud.shown = false
                ns.UI:Clear()
            else
                NoDebuffNoLoot.db.profile.hud.shown = true
                NoDebuffNoLoot:UpdateTracker()
            end
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("NoDebuffNoLoot")
        tooltip:AddLine(" ")
        tooltip:AddLine(L["SHOW_HUD_DESC"], 1, 1, 1)
        tooltip:AddDoubleLine("Status:", NoDebuffNoLoot.db.profile.hud.shown and "|cFF00FF00Show|r" or "|cFFFF0000Hide|r")
        tooltip:AddLine(L["LDB_CLICK_TOGGLE"])
        tooltip:AddLine(L["LDB_SHIFT_CLICK_ASSIGNMENTS"])
        tooltip:AddLine(L["LDB_RIGHT_CLICK_OPTIONS"])
    end,
})

-- Initialize DBIcon if available (Minimap Button)
local icon = LibStub("LibDBIcon-1.0", true)
if icon then
    -- We register in OnInitialize or slightly after to ensure DB is loaded
    local f = CreateFrame("Frame")
    f:SetScript("OnEvent", function()
        if NoDebuffNoLoot and NoDebuffNoLoot.db then
             icon:Register("NoDebuffNoLoot", ndnlLDB, NoDebuffNoLoot.db.profile.minimap)
             ns.LDBIcon = icon
        end
    end)
    f:RegisterEvent("PLAYER_LOGIN")
end
