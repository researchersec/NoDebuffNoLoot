local addonName, ns = ...
local UI = {}
ns.UI = UI

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot")

local frame

function UI:Init()
    if frame then return end
    
    frame = CreateFrame("Frame", "NoDebuffNoLootHUD", UIParent)
    frame:SetSize(200, 50)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Fondo semi-transparente
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(0, 0, 0, 0.5)
    
    frame.rows = {}
    frame:Hide()
    
    -- Aplicar estado inicial de bloqueo
    if NoDebuffNoLoot and NoDebuffNoLoot.db then
        self:SetLocked(NoDebuffNoLoot.db.profile.hud.locked)
    end
end

function UI:SetLocked(locked)
    if not frame then return end
    frame:SetMovable(not locked)
    frame:EnableMouse(not locked)
    if locked then
        frame:SetScript("OnDragStart", nil)
        frame:SetScript("OnDragStop", nil)
    else
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    end
end

function UI:FlashScreen()
    if not NoDebuffNoLoot.db.profile.alerts.visual_flash then return end
    
    local f = _G["NDNL_FlashFrame"]
    if not f then
        f = CreateFrame("Frame", "NDNL_FlashFrame", UIParent)
        f:SetFrameStrata("FULLSCREEN_DIALOG")
        f:SetAllPoints(UIParent) -- Asegurar anclaje a UIParent explícitamente
        -- Crear 4 texturas para formar un borde (menos invasivo)
        local thickness = 50 
        local alpha = 0.6
        
        local function CreateBorder(point1, point2, w, h)
            local t = f:CreateTexture(nil, "BACKGROUND")
            t:SetColorTexture(0, 1, 1, alpha)
            t:SetBlendMode("ADD")
            t:SetPoint(point1)
            t:SetPoint(point2)
            if w then t:SetWidth(w) end
            if h then t:SetHeight(h) end
            return t
        end
        
        f.top = CreateBorder("TOPLEFT", "TOPRIGHT", nil, thickness)
        f.bottom = CreateBorder("BOTTOMLEFT", "BOTTOMRIGHT", nil, thickness)
        f.left = CreateBorder("TOPLEFT", "BOTTOMLEFT", thickness, nil)
        f.right = CreateBorder("TOPRIGHT", "BOTTOMRIGHT", thickness, nil)
        
        f:SetAlpha(0)
    end
    
    -- UIFrameFlash(frame, fadeInTime, fadeOutTime, flashDuration, showWhenFlashFinishes, flashInHoldTime, flashOutHoldTime)
    UIFrameFlash(f, 0.5, 0.5, 2.0, false, 0, 0)
    
    if NoDebuffNoLoot.db.profile.alerts.sound then
        PlaySound(8959) -- RAID_WARNING
    end
end

function UI:Clear()
    if not frame then return end
    for _, row in pairs(frame.rows) do
        row:Hide()
    end
    frame:Hide()
end

function UI:SetStatus(debuffId, debuffName, status, timeLeft, assignedPlayer, backupPlayer, iconPath, talentError)
    if not frame then self:Init() end
    frame:Show()
    
    local row = frame.rows[debuffId]
    if not row then
        row = CreateFrame("Frame", nil, frame)
        row:SetSize(200, 20)
        
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(16, 16)
        icon:SetPoint("LEFT", 5, 0)
        row.icon = icon
        
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        row.text = text

        -- Textura de brillo/alerta (Glow)
        local glow = row:CreateTexture(nil, "OVERLAY")
        glow:SetColorTexture(1, 0.2, 0, 0.4) -- Naranja/Rojo transparente
        glow:SetBlendMode("ADD")
        glow:SetAllPoints(row)
        glow:Hide()
        row.glow = glow
        
        -- Icono de error de talento
        local warnIcon = row:CreateTexture(nil, "OVERLAY")
        warnIcon:SetSize(12, 12)
        warnIcon:SetPoint("RIGHT", 0, 0)
        warnIcon:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
        warnIcon:Hide()
        row.warnIcon = warnIcon
        
        frame.rows[debuffId] = row
    end
    
    -- Manejar error de talento (icono de advertencia)
    if talentError then
        row.warnIcon:Show()
    else
        row.warnIcon:Hide()
    end
    
    row:Show()
    row.icon:SetTexture(iconPath)
    
    local color, statusText
    if status == "MISSING" then
        color = "|cFFFF0000" -- Rojo
        statusText = L["STATUS_MISSING"] or "Missing"
        if not row.glow:IsShown() then
            row.glow:Show()
            UIFrameFlash(row.glow, 0.5, 0.5, -1, true, 0, 0)
        end
    elseif status == "PENDING" then
        color = "|cFFFFFF00" -- Amarillo/Naranja
        statusText = L["STATUS_MISSING"] or "Missing"
        row.glow:Hide()
        UIFrameFlashStop(row.glow)
    elseif status == "IDLE" then
        color = "|cFF888888" -- Gris
        statusText = L["STATUS_IDLE"] or "Waiting Target..."
        row.glow:Hide()
        UIFrameFlashStop(row.glow)
    else
        row.glow:Hide()
        UIFrameFlashStop(row.glow)
        if timeLeft < 5 then
            color = "|cFFFFFF00" -- Amarillo
            statusText = string.format("%s: %.1fs", L["STATUS_ACTIVE"], timeLeft)
        else
            color = "|cFF00FF00" -- Verde
            statusText = string.format("%s: %.1fs", L["STATUS_ACTIVE"], timeLeft)
        end
    end
    
    local backupStr = ""
    if backupPlayer and backupPlayer ~= "" then
        backupStr = " | |cFF888888[B:" .. backupPlayer .. "]|r"
    end
    
    row.text:SetText(string.format("%s%s (%s)%s|r - %s", color, debuffName, assignedPlayer, backupStr, statusText))
    
    self:UpdateLayout()
end

function UI:HideRow(debuffName)
    if not frame or not frame.rows[debuffName] then return end
    frame.rows[debuffName]:Hide()
    self:UpdateLayout()
end

function UI:UpdateLayout()
    if not frame then return end
    
    local i = 0
    -- Iterar respetando estrictamente el orden de las asignaciones en la BD
    for _, assignment in ipairs(NoDebuffNoLoot.db.profile.assignments) do
        local debuffId = assignment.spellId
        if debuffId and frame.rows[debuffId] then
            local r = frame.rows[debuffId]
            if r:IsShown() then
                r:SetPoint("TOP", frame, "TOP", 0, -i * 20)
                i = i + 1
            end
        end
    end
    
    if i == 0 then
        frame:Hide()
    else
        frame:SetHeight(math.max(20, i * 20))
    end
end
