local currentMapConfig = {}

RegisterNetEvent('rsg_loadmaps:loadMap')
AddEventHandler('rsg_loadmaps:loadMap', function(config)
    currentMapConfig = config
end)

function LoadMap(currentMapConfig)
    local mapName = currentMapConfig.Map
    for mapKey, mapConfig in pairs(Config.Maps) do
        if mapConfig.Map == mapName then
            TriggerServerEvent('rsg_loadmaps:loadMap', currentMapConfig)
            return
        end
        print('Map ' .. mapConfig.Map .. ' does not exist in the config.')

    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, currentMapConfig.X, currentMapConfig.Y, currentMapConfig.Z)

        if distance < 200 then
            LoadMap(currentMapConfig)
        end
    end
end)