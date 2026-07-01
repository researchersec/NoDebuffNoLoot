local addonName, ns = ...
local TalentScanner = CreateFrame("Frame")
ns.TalentScanner = TalentScanner

local talentCache = {} -- [unitName] = { talents = { [talentId_string] = rank } }
local lastInspectRequest = 0
local INSPECT_COOLDOWN = 2 -- Segundos entre inspecciones para evitar saturación

TalentScanner:RegisterEvent("INSPECT_READY")
TalentScanner:RegisterEvent("GROUP_ROSTER_UPDATE")

function TalentScanner:OnEvent(event, ...)
    if event == "INSPECT_READY" then
        local guid = ...
        self:ProcessInspect(guid)
    elseif event == "GROUP_ROSTER_UPDATE" then
        -- Podríamos limpiar el cache de gente que ya no está, o iniciar escaneo de nuevos
    end
end
TalentScanner:SetScript("OnEvent", TalentScanner.OnEvent)

function TalentScanner:RequestInspect(unit)
    if not unit or not CanInspect(unit) or not UnitIsConnected(unit) then return end
    
    local now = GetTime()
    if (now - lastInspectRequest) < INSPECT_COOLDOWN then return end
    
    lastInspectRequest = now
    NotifyInspect(unit)
end

function TalentScanner:ProcessInspect(guid)
    local unit = nil
    -- Encontrar la unidad por GUID
    if UnitGUID("player") == guid then unit = "player" 
    elseif IsInRaid() then
        for i=1, GetNumGroupMembers() do
            if UnitGUID("raid"..i) == guid then unit = "raid"..i; break end
        end
    elseif IsInGroup() then
        for i=1, GetNumGroupMembers() - 1 do
            if UnitGUID("party"..i) == guid then unit = "party"..i; break end
        end
    end

    if not unit then return end
    local name = UnitName(unit)
    talentCache[name] = { talents = {} }

    -- Escanear los debuffs definidos en ns.Data
    for debuffName, info in pairs(ns.Data.Debuffs) do
        if info.talentId and info.class == select(2, UnitClass(unit)) then
            local tab, index = tonumber(info.talentId[1]), tonumber(info.talentId[2])
            local isInspect = (unit ~= "player")
            
            -- La firma correcta para Classic/TBC es (tabIndex, talentIndex, isInspect)
            local nameTalent, _, _, _, rank = GetTalentInfo(tab, index, isInspect)
            
            if rank then
                talentCache[name].talents[tab .. "_" .. index] = rank
            end
        end
    end
end

function TalentScanner:HasTalent(unitName, talentIdTable)
    if not unitName or not talentIdTable then return false end
    local cache = talentCache[unitName]
    if not cache then return nil end -- No sabemos (no inspeccionado)
    
    local key = talentIdTable[1] .. "_" .. talentIdTable[2]
    return (cache.talents[key] or 0) > 0
end

-- Función para que Roster llame a inspeccionar a todos gradualmente
function TalentScanner:ScanGroup()
    if not IsInGroup() then return end
    
    local members = GetNumGroupMembers()
    local unitPrefix = IsInRaid() and "raid" or "party"
    
    -- Inspeccionamos al jugador mismo siempre
    self:ProcessInspect(UnitGUID("player"))

    -- Para los demás, usamos un ticker para no saturar
    local i = 1
    C_Timer.NewTicker(2, function(ticker)
        local unit = unitPrefix .. i
        if i == members and not IsInRaid() then unit = "player" end -- player ya se hizo
        
        if UnitExists(unit) and CanInspect(unit) then
            self:RequestInspect(unit)
        end
        
        i = i + 1
        if i > members then ticker:Cancel() end
    end, members)
end
