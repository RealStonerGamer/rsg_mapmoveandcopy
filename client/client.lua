local mapConfig = {}

RegisterNetEvent('rsg_loadmaps:loadMap')
AddEventHandler('rsg_loadmaps:loadMap', function(config)
    mapConfig = config
  --  print(mapConfig)

end)

function LoadMap(mapConfig)
    local mapName = mapConfig
    for mapKey, mapConfig in pairs(Config.Maps) do
        if mapConfig.Map == mapName then
   -- print(mapConfig)
    TriggerServerEvent('rsg_loadmaps:loadMap', mapConfig[mapKey])
    return
      end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, mapConfig.X, mapConfig.Y, mapConfig.Z)

            LoadMap(mapConfig)
            print(mapConfig)
    
        end
end)