local LowHealthAlert = {
    name = "LowHealthAlert",
    version = "1.0",
    author = "Your Name"
}

-- Initialize addon variables
local function Initialize()
    LowHealthAlert.lastPlayedSound = {}
    LowHealthAlert.healthThreshold = 0.50 -- 50% health threshold
end

-- Function to play sound
local function PlayAlertSound()
    PlaySound(SOUNDS.DUEL_START)
end

-- Event handler for health changes
local function OnHealthChanged(eventCode, unitTag, powerType, powerValue, powerMax)
    -- Only proceed if we have valid health values and unit exists
    if not (powerValue and powerMax and DoesUnitExist(unitTag)) then return end
    if not IsUnitAttackable(unitTag) then return end

    local healthPercent = powerValue / powerMax

    -- Check if health is below threshold
    if healthPercent <= LowHealthAlert.healthThreshold then
        local unitId = unitTag
        local currentTime = GetGameTimeMilliseconds()
        
        -- Only play sound if we haven't played one for this unit in the last 5 seconds
        if not LowHealthAlert.lastPlayedSound[unitId] or 
           (currentTime - LowHealthAlert.lastPlayedSound[unitId]) > 5000 then
            PlayAlertSound()
            LowHealthAlert.lastPlayedSound[unitId] = currentTime
        end
    end
end

-- Register events when addon loads
local function OnAddonLoaded(event, addonName)
    if addonName ~= LowHealthAlert.name then return end
    
    Initialize()
    
    -- Register for combat events with correct health flag
    EVENT_MANAGER:RegisterForEvent(LowHealthAlert.name, EVENT_POWER_UPDATE, OnHealthChanged)
    EVENT_MANAGER:AddFilterForEvent(LowHealthAlert.name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
    EVENT_MANAGER:AddFilterForEvent(LowHealthAlert.name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "reticleover")
end

-- Register the initialization event
EVENT_MANAGER:RegisterForEvent(LowHealthAlert.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)