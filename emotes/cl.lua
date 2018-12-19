local emoteNames = nil
local emotePlaying = false

Citizen.CreateThread(function()
    init()

    while true do
        if emotePlaying then
            for _, key in pairs(Config.CancelKeys) do
                if IsControlPressed(0, key) then
                    cancelEmoteSlowly()
                end
            end
        end

        Citizen.Wait(0)
    end
end)

function init()
    emoteNames = createListOfEmoteNames()
    registerChatSuggestions()
    registerEventsCalledByServer()
end

function createListOfEmoteNames()
    local emoteNames = {}
    for emoteName, _ in pairs(emotes) do
        table.insert(emoteNames, emoteName)
    end
    return table.concat(emoteNames, ', ')
end

function registerChatSuggestions()
    TriggerEvent('chat:addSuggestion', '/emote', 'Perform an emote. Stop by moving or using /cancelemote', {{name = 'emote', help = 'Available emotes: ' .. emoteNames}})
    TriggerEvent('chat:addSuggestion', '/cancelemote', 'Cancel the currently playing emote.')
end

function registerEventsCalledByServer()
    RegisterNetEvent('emote:invoke')
    AddEventHandler('emote:invoke', invokeHandler)
    RegisterNetEvent('emote:cancelEmoteImmediately')
    AddEventHandler('emote:cancelEmoteImmediately', cancelEmoteImmediately)
end

function cancelEmoteSlowly()
    ClearPedTasks(GetPlayerPed(-1))
    emotePlaying = false
end

function cancelEmoteImmediately()
    ClearPedTasksImmediately(GetPlayerPed(-1))
    emotePlaying = false
end

function invokeHandler(emoteDictionary)
    if not isEmoteDefinedInDictionary(emoteDictionary) then
        TriggerEvent('chatMessage', 'ERROR', {255,0,0}, 'Invalid emote name')
    else if playEmoteFromDictionary(Config.Emotes[emoteDictionary]) then
        drawSimpleNotification('Playing the emote "'..emoteDictionary..'"')
    end
end

function isEmoteDefinedInDictionary(emoteDictionary)
    return Config.Emotes[emoteDictionary] ~= nil
end

function playEmoteFromDictionary(emoteDictionary)
    if not doesPedExist() then
        return false
    end

    if isPedInVehicle() then
        drawSimpleNotification('~r~You must leave the vehicle first')
        return false
    end

    removeWeaponFromPedIfNeeded()

    startScenario(emoteDictionary)
    return true
end

function doesPedExist()
    return DoesEntityExist(GetPlayerPed(-1))
end

function isPedInVehicle()
    return IsPedInAnyVehicle(GetPlayerPed(-1))
end

function removeWeaponFromPedIfNeeded()
    if isPedHoldingWeapon() then
        SetCurrentPedWeapon(GetPlayerPed(-1), 0xA2719263, true)
        drawSimpleNotification('Please put away your weapon first next time!')
    end
end

function isPedHoldingWeapon()
    return IsPedArmed(GetPlayerPed(-1), 7)
end

function startScenario(emoteDictionary)
    TaskStartScenarioInPlace(GetPlayerPed(-1), emoteDictionary, 0, true)
    emotePlaying = true
end

function drawSimpleNotification(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, false)
end