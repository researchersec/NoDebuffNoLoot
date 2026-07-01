local addonName, ns = ...
local Assignments = {}
ns.Assignments = Assignments

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot")
local AceSerializer = LibStub("AceSerializer-3.0")

local COMM_PREFIX = "NDNL_SYNC"

function Assignments:Set(debuffId, primaryPlayer, backupPlayer)
    -- This function is kept for backwards compatibility or programmatic use
    table.insert(NoDebuffNoLoot.db.profile.assignments, {
        spellId = debuffId,
        primary = primaryPlayer,
        backup = backupPlayer
    })
    
    NoDebuffNoLoot:Print(string.format("Asignado %s a %s (Backup: %s)", GetSpellInfo(debuffId) or debuffId, primaryPlayer, backupPlayer or "N/A"))
    if IsInRaid() or IsInGroup() then
        self:PushConfiguration()
    end
end

function Assignments:Clear(debuffId)
    local list = NoDebuffNoLoot.db.profile.assignments
    for i = #list, 1, -1 do
        if list[i].spellId == debuffId then
            table.remove(list, i)
        end
    end
end

function Assignments:PushConfiguration()
    if not (IsInRaid() or IsInGroup()) then return end
    
    -- Solo el líder o asistentes pueden enviar la configuración
    local isLeader = UnitIsGroupLeader("player")
    local isAssistant = UnitIsGroupAssistant("player")
    
    if not (isLeader or isAssistant) then return end

    local data = NoDebuffNoLoot.db.profile.assignments
    local serialized = AceSerializer:Serialize(data)
    
    NoDebuffNoLoot:SendCommMessage(COMM_PREFIX, serialized, "RAID")
    NoDebuffNoLoot:Print(L["SYNC_SENT"])
end

function Assignments:OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= COMM_PREFIX or sender == UnitName("player") then return end
    
    -- Validar que el remitente es Líder o Ayudante antes de aceptar cambios
    -- Buscamos el rango del remitente en el grupo/raid
    local senderIsAuthorized = false
    local numGroup = GetNumGroupMembers()
    
    if IsInRaid() then
        for i = 1, numGroup do
            local name, rank = GetRaidRosterInfo(i)
            if name == sender then
                if rank > 0 then senderIsAuthorized = true end -- 1 = Assistant, 2 = Leader
                break
            end
        end
    else
        -- En Party, el líder es el único con autoridad
        if UnitIsGroupLeader(sender) then
            senderIsAuthorized = true
        end
    end

    if not senderIsAuthorized then 
        -- Opcional: Loggear intento de desincronización no autorizada? Por ahora ignorar.
        return 
    end
    
    local success, data = AceSerializer:Deserialize(message)
    if success then
        NoDebuffNoLoot.db.profile.assignments = data
        NoDebuffNoLoot:Print(string.format(L["SYNC_RECEIVED"], sender))
        NoDebuffNoLoot:UpdateTracker()
    end
end
