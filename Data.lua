local addonName, ns = ...
ns.Data = {}

-- Debuffs críticos de TBC por clase y especialización (Talentos)
-- talentId: { tabIndex, talentIndex } conforme a GetTalentInfo()
ns.Data.Debuffs = {
    -- GUERRERO
    ["Sunder Armor"] = { id = 25225, class = "WARRIOR", priority = "S", icon = "Interface\\Icons\\Ability_Warrior_Sunder" },
    ["Thunder Clap"] = { id = 25264, class = "WARRIOR", priority = "A", icon = "Interface\\Icons\\Spell_Nature_ThunderClap" },
    ["Demoralizing Shout"] = { id = 25203, class = "WARRIOR", priority = "A", icon = "Interface\\Icons\\Ability_Warrior_WarCry" },
    ["Blood Frenzy"] = { id = 29859, class = "WARRIOR", priority = "S", talentId = {1, 15}, icon = "Interface\\Icons\\Ability_Warrior_BloodFrenzy" },
    
    -- DRUIDA
    ["Faerie Fire"] = { id = 26993, class = "DRUID", priority = "S", icon = "Interface\\Icons\\Spell_Nature_FaerieFire" },
    ["Improved Faerie Fire"] = { id = 26993, class = "DRUID", priority = "S", talentId = {1, 16}, icon = "Interface\\Icons\\Spell_Nature_FaerieFire" },
    ["Demoralizing Roar"] = { id = 8983, class = "DRUID", priority = "C", icon = "Interface\\Icons\\Ability_Druid_DemoralizingRoar" },
    ["Mangle"] = { id = 33876, class = "DRUID", priority = "S", talentId = {2, 18}, icon = "Interface\\Icons\\Ability_Druid_Mangle" },
    ["Insect Swarm"] = { id = 27013, class = "DRUID", priority = "B", talentId = {1, 10}, icon = "Interface\\Icons\\Spell_Nature_InsectSwarm" },

    -- CAZADOR
    ["Hunter's Mark"] = { id = 14325, class = "HUNTER", priority = "A", talentId = {2, 3}, icon = "Interface\\Icons\\Ability_Hunter_Snares" },
    ["Expose Weakness"] = { id = 34503, class = "HUNTER", priority = "S", talentId = {3, 18}, icon = "Interface\\Icons\\Ability_Hunter_ExposeWeakness" },
    ["Scorpid Sting"] = { id = 3043, class = "HUNTER", priority = "B", icon = "Interface\\Icons\\Ability_Hunter_CriticalShot" },
    ["Screech"] = { id = 31480, class = "HUNTER", priority = "C", icon = "Interface\\Icons\\Ability_Hunter_Pet_Bat" },

    -- PÍCARO
    ["Expose Armor"] = { id = 8647, class = "ROGUE", priority = "A", icon = "Interface\\Icons\\Ability_Rogue_ExposeArmor" },
    ["Improved Expose Armor"] = { id = 8647, class = "ROGUE", priority = "S", talentId = {1, 5}, icon = "Interface\\Icons\\Ability_Rogue_ExposeArmor" },

    -- MAGO
    ["Improved Scorch"] = { id = 22959, class = "MAGE", priority = "S", talentId = {2, 9}, icon = "Interface\\Icons\\Spell_Fire_SoulBurn" },
    ["Winters Chill"] = { id = 12579, class = "MAGE", priority = "S", talentId = {3, 10}, icon = "Interface\\Icons\\Spell_Frost_IceFloes" },

    -- BRUJO
    ["Curse of Elements"] = { id = 27228, class = "WARLOCK", priority = "S", icon = "Interface\\Icons\\Spell_Shadow_ChillTouch" },
    ["Malediction"] = { id = 27228, class = "WARLOCK", priority = "S", talentId = {1, 12}, icon = "Interface\\Icons\\Spell_Shadow_ChillTouch" },
    ["Curse of Recklessness"] = { id = 27223, class = "WARLOCK", priority = "A", icon = "Interface\\Icons\\Spell_Shadow_UnholyStrength" },
    ["Curse of Weakness"] = { id = 30909, class = "WARLOCK", priority = "B", icon = "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth" },

    -- SACERDOTE
    ["Shadow Weaving"] = { id = 15258, class = "PRIEST", priority = "S", talentId = {3, 11}, icon = "Interface\\Icons\\Spell_Shadow_BlackPlague" },
    ["Misery"] = { id = 33191, class = "PRIEST", priority = "S", talentId = {3, 18}, icon = "Interface\\Icons\\Spell_Shadow_Misery" },

    -- CHAMÁN
    ["Stormstrike"] = { id = 17364, class = "SHAMAN", priority = "A", icon = "Interface\\Icons\\Spell_Holy_SealOfMight" },

    -- PALADÍN
    ["Judgement of Light"] = { id = 20185, class = "PALADIN", priority = "S", icon = "Interface\\Icons\\Spell_Holy_RighteousFury" },
    ["Judgement of Wisdom"] = { id = 20186, class = "PALADIN", priority = "S", icon = "Interface\\Icons\\Spell_Holy_RighteousnessAura" },
    ["Judgement of the Crusader"] = { id = 27159, class = "PALADIN", priority = "B", icon = "Interface\\Icons\\Spell_Holy_HolySmite" },
    ["Heart of the Crusader"] = { id = 27159, class = "PALADIN", priority = "A", talentId = {3, 4}, icon = "Interface\\Icons\\Spell_Holy_HolySmite" },
}

-- Función auxiliar para obtener el ID de un hechizo por nombre (soporta localizado)
function ns.Data.GetSpellID(name)
    if not name or name == "" then return nil end
    
    -- Limpiar las etiquetas visuales inyectadas por el recomendador
    local cleanName = string.gsub(name, " %(.+%)", "")
    
    -- 1. Intentar búsqueda por clave directa (Inglés)
    local data = ns.Data.Debuffs[name] or ns.Data.Debuffs[cleanName]
    if data then return data.id end
    
    -- 2. Intentar búsqueda por nombre localizado
    for _, info in pairs(ns.Data.Debuffs) do
        local locName = GetSpellInfo(info.id)
        if locName then
            local lLower = string.lower(locName)
            if lLower == string.lower(name) or lLower == string.lower(cleanName) then
                return info.id
            end
        end
    end
    
    return nil
end
