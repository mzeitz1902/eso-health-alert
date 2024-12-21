local LowHealthAlert = {
    name = "LowHealthAlert",
    version = "1.0",
    author = "Your Name"
}

-- Initialize addon variables
local function Initialize()
    LowHealthAlert.lastPlayedSound = {}
    LowHealthAlert.healthThreshold = 0.80 -- 50% health threshold
end

-- Function to play sound
local function PlayAlertSound()
    PlaySound(SOUNDS.ABILITY_COMPANION_ULTIMATE_READY) -- You can change this to another game sound
end

-- Function to check unit health
local function CheckUnitHealth(unitTag)
    if not DoesUnitExist(unitTag) then return end
    if not IsUnitAttackable(unitTag) then return end

    -- Get current and max health
    local currentHealth = GetUnitHealth(unitTag)
    local maxHealth = GetUnitMaxHealth(unitTag)
    local healthPercent = currentHealth / maxHealth

    -- Check if health is below threshold and we haven't recently played a sound for this unit
    if healthPercent <= LowHealthAlert.healthThreshold then
        local unitId = GetUnitDisplayName(unitTag) or unitTag
        local currentTime = GetGameTimeMilliseconds()
        
        -- Only play sound if we haven't played one for this unit in the last 5 seconds
        if not LowHealthAlert.lastPlayedSound[unitId] or 
           (currentTime - LowHealthAlert.lastPlayedSound[unitId]) > 5000 then
            PlayAlertSound()
            LowHealthAlert.lastPlayedSound[unitId] = currentTime
        end
    end
end

-- Event handler for health changes
local function OnHealthChanged(_, unitTag, _, _, powerValue, _, powerMax)
    if powerValue and powerMax then
        CheckUnitHealth(unitTag)
    end
end

-- Register events when addon loads
local function OnAddonLoaded(event, addonName)
    if addonName ~= LowHealthAlert.name then return end
    
    Initialize()
    
    -- Register for combat events
    EVENT_MANAGER:RegisterForEvent(LowHealthAlert.name, EVENT_POWER_UPDATE, OnHealthChanged)
    EVENT_MANAGER:AddFilterForEvent(LowHealthAlert.name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
    EVENT_MANAGER:AddFilterForEvent(LowHealthAlert.name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "reticleover")
end

-- Register the initialization event
EVENT_MANAGER:RegisterForEvent(LowHealthAlert.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)