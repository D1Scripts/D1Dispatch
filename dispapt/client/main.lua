local currentChannel = 0
local displayEnabled = false
local talkingPlayers = {}
local activeWaypoint = nil
local lastCommand = nil
local altPressed = false

-- Initialize UI (hide everything by default)
Citizen.CreateThread(function()
    -- Wait a moment to ensure NUI is ready
    Wait(1000)
    
    -- Force hide all UIs on startup
    displayEnabled = false
    SendNUIMessage({
        type = 'toggleDisplay',
        show = false
    })
    SendNUIMessage({
        type = 'toggleDispatch',
        show = false
    })
    
    -- Check current radio channel from pma-voice
    local radioChannel = exports['pma-voice']:getRadioChannel()
    if radioChannel > 0 then
        currentChannel = radioChannel
        displayEnabled = true
        -- Only show radio UI, never show dispatch UI on startup
        SendNUIMessage({
            type = 'toggleDisplay',
            show = true
        })
        SendNUIMessage({
            type = 'toggleDispatch',
            show = false
        })
        UpdateRadioList()
    end
end)

-- Handle Alt key for cursor
Citizen.CreateThread(function()
    while true do
        Wait(0)
        -- Check if we're in dispatch mode (any configured channel)
        local inDispatchMode = Config.RadioFrequencies[currentChannel] ~= nil
        
        if inDispatchMode then
            -- Check if Alt is pressed (Left Alt)
            if IsDisabledControlPressed(0, 19) then -- Using DisabledControlPressed instead
                -- Disable all mouse and camera controls
                DisableControlAction(0, 1, true)   -- LookLeftRight
                DisableControlAction(0, 2, true)   -- LookUpDown
                DisableControlAction(0, 3, true)   -- VehicleLookLeftRight
                DisableControlAction(0, 4, true)   -- VehicleLookUpDown
                DisableControlAction(0, 5, true)   -- VehicleMouseControlOverride
                DisableControlAction(0, 6, true)   -- VehicleMouseControl
                DisableControlAction(0, 24, true)  -- Attack
                DisableControlAction(0, 25, true)  -- Aim
                DisableControlAction(0, 68, true)  -- Vehicle Aim
                DisableControlAction(0, 69, true)  -- Vehicle Attack
                DisableControlAction(0, 70, true)  -- Vehicle Attack 2
                DisableControlAction(0, 91, true)  -- Vehicle Passenger Aim
                DisableControlAction(0, 92, true)  -- Vehicle Passenger Attack
                
                -- Enable cursor
                if not IsPauseMenuActive() then -- Don't show cursor if pause menu is active
                    SetNuiFocus(true, true)
                end
            else
                -- Disable cursor when Alt is released
                SetNuiFocus(false, false)
            end
        else
            -- Ensure cursor is disabled when not in dispatch mode
            SetNuiFocus(false, false)
        end
    end
end)

-- Function to get street name and area
function GetLocationInfo()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    local area = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
    return street, area
end

-- Function to update location info
function UpdateLocationInfo()
    -- Check if we're in any configured dispatch channel
    if Config.RadioFrequencies[currentChannel] and displayEnabled then
        local street, area = GetLocationInfo()
        SendNUIMessage({
            type = 'updateLocation',
            street = street,
            area = area
        })
    end
end

-- Function to update radio list
function UpdateRadioList()
    if currentChannel > 0 and displayEnabled then
        local members = {}
        
        -- Add local player first
        local localId = GetPlayerServerId(PlayerId())
        local localName = GetPlayerName(PlayerId())
        
        -- Add local player to members list
        table.insert(members, {
            name = string.format("(%d) %s", localId, localName),
            id = localId,
            talking = talkingPlayers[localId] or false
        })
        
        -- Get all players in the current radio channel
        for _, playerId in ipairs(GetActivePlayers()) do
            local serverId = GetPlayerServerId(playerId)
            if serverId ~= localId then
                -- Check if player is in the same radio channel using state bag
                local playerState = Player(serverId).state
                if playerState and playerState.radioChannel == currentChannel then
                    local playerName = GetPlayerName(playerId)
                    if playerName then
                        table.insert(members, {
                            name = string.format("(%d) %s", serverId, playerName),
                            id = serverId,
                            talking = talkingPlayers[serverId] or false
                        })
                    end
                end
            end
        end

        -- Get configuration for current channel
        local config = GetRadioConfig(currentChannel)

        -- Update UI with members
        SendNUIMessage({
            type = 'updateMembers',
            members = members
        })

        -- Update channel info with custom title and style
        SendNUIMessage({
            type = 'updateChannel',
            channel = currentChannel,
            count = #members,
            title = config.name,
            style = config.style
        })
    end
end

-- Function to get radio configuration
function GetRadioConfig(frequency)
    return Config.RadioFrequencies[frequency] or {
        name = "Unit Stats",
        style = Config.DefaultStyle,
        color = Config.DefaultColor
    }
end

-- Function to handle radio command
function HandleRadioCommand(frequency)
    lastCommand = 'radio' .. frequency
    -- Set radio channel using pma-voice
    exports['pma-voice']:setRadioChannel(frequency)
    currentChannel = frequency
    
    -- Get configuration for this frequency
    local config = GetRadioConfig(frequency)
    
    -- Check if this is a special command (like radio22, radio23, etc.)
    local isSpecialCommand = Config.RadioFrequencies[frequency] ~= nil
    
    -- Enable display and show UIs based on command type
    displayEnabled = true
    
    -- For special commands, show both UIs
    if isSpecialCommand then
        SendNUIMessage({
            type = 'toggleDisplay',
            show = true,
            style = config.style,
            title = config.name
        })
        SendNUIMessage({
            type = 'toggleDispatch',
            show = true,
            style = config.style,
            title = config.name
        })
    else
        -- For regular radio commands, only show dispatch UI
        SendNUIMessage({
            type = 'toggleDisplay',
            show = false
        })
        SendNUIMessage({
            type = 'toggleDispatch',
            show = true,
            style = config.style,
            title = config.name
        })
    end

    -- Update the radio list immediately
    UpdateRadioList()

    -- Update channel info with custom title
    SendNUIMessage({
        type = 'updateChannel',
        channel = frequency,
        count = 1,
        title = config.name
    })

    TriggerEvent('chat:addMessage', {
        color = config.color,
        args = {'SYSTEM', 'Connected to ' .. config.name .. ' channel (' .. frequency .. ')'}
    })
end

-- Dispatch SAST command (auto-join channel 22)
RegisterCommand('dispatchsast', function()
    HandleRadioCommand(22)
end)

-- Special Radio 22 command
RegisterCommand('radio22', function()
    HandleRadioCommand(22)
end)

-- Special Radio 23 command
RegisterCommand('radio23', function()
    HandleRadioCommand(23)
end)

-- Special Radio 55 command
RegisterCommand('radio55', function()
    HandleRadioCommand(55)
end)

-- Dynamic radio command registration
Citizen.CreateThread(function()
    print('[Dispatch] Starting dynamic command registration...')
    for frequency, config in pairs(Config.RadioFrequencies) do
        print('[Dispatch] Registering command for frequency:', frequency, 'with name:', config.name)
        RegisterCommand('radio' .. frequency, function()
            print('[Dispatch] Command triggered for frequency:', frequency)
            HandleRadioCommand(frequency)
        end)
    end
    print('[Dispatch] Dynamic command registration complete')
end)

-- Regular radio command
RegisterCommand('radio', function(source, args)
    if #args < 1 then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'SYSTEM', 'Usage: /radio [frequency]'}
        })
        return
    end

    local frequency = tonumber(args[1])
    if not frequency then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'SYSTEM', 'Invalid frequency!'}
        })
        return
    end

    -- Set radio channel using pma-voice
    exports['pma-voice']:setRadioChannel(frequency)
    currentChannel = frequency
    
    -- Get configuration for this frequency
    local config = GetRadioConfig(frequency)
    
    -- Enable display
    displayEnabled = true
    
    -- Hide radio UI for regular radio command
    SendNUIMessage({
        type = 'toggleDisplay',
        show = false
    })

    -- Show dispatch UI for regular radio command
    SendNUIMessage({
        type = 'toggleDispatch',
        show = true,
        style = config.style,
        title = "Radio " .. frequency
    })

    -- Get all players in the current radio channel
    local members = {}
    local localId = GetPlayerServerId(PlayerId())
    local localName = GetPlayerName(PlayerId())
    
    -- Add local player to members list
    table.insert(members, {
        name = string.format("(%d) %s", localId, localName),
        id = localId,
        talking = talkingPlayers[localId] or false
    })
    
    -- Get all players in the current radio channel
    for _, playerId in ipairs(GetActivePlayers()) do
        local serverId = GetPlayerServerId(playerId)
        if serverId ~= localId then
            -- Check if player is in the same radio channel using state bag
            local playerState = Player(serverId).state
            if playerState and playerState.radioChannel == frequency then
                local playerName = GetPlayerName(playerId)
                if playerName then
                    table.insert(members, {
                        name = string.format("(%d) %s", serverId, playerName),
                        id = serverId,
                        talking = talkingPlayers[serverId] or false
                    })
                end
            end
        end
    end

    -- Update UI with members
    SendNUIMessage({
        type = 'updateMembers',
        members = members
    })

    -- Update channel info with custom title
    SendNUIMessage({
        type = 'updateChannel',
        channel = frequency,
        count = #members,
        title = "Radio " .. frequency,
        style = config.style
    })

    TriggerEvent('chat:addMessage', {
        color = config.color,
        args = {'SYSTEM', 'Connected to radio channel ' .. frequency}
    })
end)

-- Leave radio command
RegisterCommand('leaveradio', function()
    lastCommand = nil
    if currentChannel == 0 then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'SYSTEM', 'You are not in any radio channel!'}
        })
        return
    end

    -- Leave radio channel using pma-voice
    exports['pma-voice']:setRadioChannel(0)
    currentChannel = 0
    displayEnabled = false
    talkingPlayers = {}

    -- Clear and hide UI
    SendNUIMessage({
        type = 'toggleDisplay',
        show = false
    })
    SendNUIMessage({
        type = 'toggleDispatch',
        show = false
    })

    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        args = {'SYSTEM', 'Left radio frequency'}
    })
end)

-- Request waypoint command
RegisterCommand('reqwp', function(source, args)
    if #args < 1 then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'SYSTEM', 'Usage: /reqwp [id]'}
        })
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'SYSTEM', 'Invalid ID!'}
        })
        return
    end

    -- Send waypoint request to target player
    TriggerServerEvent('dispatch:requestWaypoint', targetId)
end)

-- Receive waypoint request
RegisterNetEvent('dispatch:receiveWaypointRequest')
AddEventHandler('dispatch:receiveWaypointRequest', function(requesterId, requesterName)
    if Config.RadioFrequencies[currentChannel] then
        SendNUIMessage({
            type = 'addWaypointRequest',
            id = requesterId,
            name = requesterName
        })
    end
end)

-- Accept waypoint request callback
RegisterNUICallback('acceptWaypoint', function(data, cb)
    local requesterId = data.id
    
    -- Get current location
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Send location to requester
    TriggerServerEvent('dispatch:sendWaypoint', requesterId, coords)
    
    -- Update active waypoint temporarily
    activeWaypoint = GetPlayerName(GetPlayerFromServerId(requesterId))
    SendNUIMessage({
        type = 'updateActiveWaypoint',
        name = activeWaypoint
    })
    
    -- Reset active waypoint after 5 seconds
    Citizen.SetTimeout(5000, function()
        activeWaypoint = nil
        SendNUIMessage({
            type = 'updateActiveWaypoint',
            name = 'None'
        })
    end)
    
    -- Hide cursor after accepting
    SetNuiFocus(false, false)
    
    cb('ok')
end)

-- Receive waypoint
RegisterNetEvent('dispatch:receiveWaypoint')
AddEventHandler('dispatch:receiveWaypoint', function(coords, responderName)
    -- Set waypoint on map
    SetNewWaypoint(coords.x, coords.y)
    
    -- Reset active waypoint for the responder
    if activeWaypoint then
        activeWaypoint = nil
        SendNUIMessage({
            type = 'updateActiveWaypoint',
            name = 'None'
        })
    end
    
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        args = {'SYSTEM', responderName .. ' accepted your waypoint request'}
    })
end)

-- Track player talking state using pma-voice events
RegisterNetEvent('pma-voice:radioActive')
AddEventHandler('pma-voice:radioActive', function(talking)
    if currentChannel > 0 and displayEnabled then
        local playerId = GetPlayerServerId(PlayerId())
        talkingPlayers[playerId] = talking
        UpdateRadioList()
    end
end)

-- Listen for other players talking
RegisterNetEvent('pma-voice:setTalkingOnRadio')
AddEventHandler('pma-voice:setTalkingOnRadio', function(player, talking)
    if currentChannel > 0 and displayEnabled then
        talkingPlayers[player] = talking
        UpdateRadioList()
    end
end)

-- Update radio list and location periodically
Citizen.CreateThread(function()
    while true do
        if currentChannel > 0 and displayEnabled then
            UpdateRadioList()
            -- Update location if we're in a configured channel
            if Config.RadioFrequencies[currentChannel] then
                UpdateLocationInfo()
            end
        end
        Wait(1000)
    end
end)

-- Listen for pma-voice radio state changes
RegisterNetEvent('pma-voice:radioChanged')
AddEventHandler('pma-voice:radioChanged', function(enabled)
    if not enabled then
        currentChannel = 0
        displayEnabled = false
        talkingPlayers = {}
        SendNUIMessage({
            type = 'toggleDisplay',
            show = false
        })
        SendNUIMessage({
            type = 'toggleDispatch',
            show = false
        })
    end
end)

-- Listen for pma-voice radio channel changes
RegisterNetEvent('pma-voice:setRadioChannel')
AddEventHandler('pma-voice:setRadioChannel', function(channel)
    if channel > 0 then
        currentChannel = channel
        displayEnabled = true
        SendNUIMessage({
            type = 'toggleDisplay',
            show = true
        })
        -- Show dispatch UI if it's a configured channel
        if Config.RadioFrequencies[channel] then
            local config = GetRadioConfig(channel)
            SendNUIMessage({
                type = 'toggleDispatch',
                show = true,
                style = config.style,
                title = config.name
            })
        else
            SendNUIMessage({
                type = 'toggleDispatch',
                show = false
            })
        end
        UpdateRadioList()
    else
        lastCommand = nil
        currentChannel = 0
        displayEnabled = false
        talkingPlayers = {}
        SendNUIMessage({
            type = 'toggleDisplay',
            show = false
        })
        SendNUIMessage({
            type = 'toggleDispatch',
            show = false
        })
    end
end) 