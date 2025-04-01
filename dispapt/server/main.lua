-- Handle waypoint requests
RegisterNetEvent('dispatch:requestWaypoint')
AddEventHandler('dispatch:requestWaypoint', function(targetId)
    local source = source
    local sourceName = GetPlayerName(source)
    
    -- Send request to target player
    TriggerClientEvent('dispatch:receiveWaypointRequest', targetId, source, sourceName)
end)

-- Handle waypoint responses
RegisterNetEvent('dispatch:sendWaypoint')
AddEventHandler('dispatch:sendWaypoint', function(requesterId, coords)
    local source = source
    local responderName = GetPlayerName(source)
    
    -- Send waypoint to requester
    TriggerClientEvent('dispatch:receiveWaypoint', requesterId, coords, responderName)
end) 