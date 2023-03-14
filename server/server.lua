local mapConfig = {}
local playerLoaded = {}

AddEventHandler("playerSpawned", function()
    TriggerClientEvent("rsg_loadmaps:loadMap", -1)
end)

RegisterServerEvent("rsg_loadmaps:playerLoaded")
AddEventHandler("rsg_loadmaps:playerLoaded", function()
    local _source = source
    playerLoaded[_source] = true
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        for _, playerId in ipairs(GetPlayers()) do
            if playerLoaded[playerId] then
                local playerPed = GetPlayerPed(playerId)
                local playerCoords = GetEntityCoords(playerPed)
                local distance = Vdist2(playerCoords.x, playerCoords.y, playerCoords.z, mapConfig.X, mapConfig.Y, mapConfig.Z)

                if distance < (200 * 200) then
                    TriggerClientEvent("rsg_loadmaps:loadMap", playerId, mapConfig)
                end
            end
        end
    end
end)

RegisterServerEvent("rsg_loadmaps:syncMapConfig")
AddEventHandler("rsg_loadmaps:syncMapConfig", function(newMapConfig)
    mapConfig = newMapConfig
end)
function LoadMap(mapConfig)
    local mapName = Config.Map
    for mapKey, mapConfig in pairs(Config.Maps) do
        if mapConfig.Map == mapName then
            TriggerServerEvent('rsg_loadmaps:loadMap', mapConfig)
            
        end
    print('Map ' .. mapName .. ' does not exist in the config.')


        -- Calculate the position and rotation offsets
        local offsetX = mapConfig.X
        local offsetY = mapConfig.Y
        local offsetZ = mapConfig.Z
        local offsetRot = mapConfig.Rotation

        -- Move and rotate each entity in the ymap
        for i = 1, #mapConfig.entities do
            local entity = mapConfig.entities[i]

            -- Apply the position offset
            local posX = entity.position.x + offsetX
            local posY = entity.position.y + offsetY
            local posZ = entity.position.z + offsetZ

            -- Apply the rotation offset
            local quat = entity.rotation:ToQuaternion()
            quat = quaternion.from_euler_angles(math.rad(offsetRot), 0, 0) * quat
            local rotX, rotY, rotZ = quat:ToEulerAnglesXYZ()

            -- Set the new position and rotation
            SetEntityCoordsNoOffset(entity.handle, posX, posY, posZ, false, false, false, true)
            SetEntityRotation(entity.handle, rotX, rotY, rotZ, 2, true)
     
    local map = LoadInterior(interiorId)
    SetEntityCoords(GetPlayerPed(-1), posX, posY, posZ)
    SetEntityHeading(GetPlayerPed(-1), heading)
    print('Map ' .. mapName .. ' loaded.')
         end

    end
end

RegisterServerEvent('rsg_loadmaps:loadMap')
AddEventHandler('rsg_loadmaps:loadMap', function(mapName)
    local mapConfigs = mapName
    for i = 1, #mapConfigs do
        loadMap(mapConfigs[i])
    end
end)


RegisterServerEvent('myresource:loadMaps')
AddEventHandler('myresource:loadMaps', function()
    local mapConfigs = Config.Maps
    for i = 1, #mapConfigs do
        loadMap(mapConfigs[i])
    end
end)


local function loadMaps()
    local mapConfigs = exports.GetMapConfigs()
    for i=1, #Config.Maps[1] do
        TriggerClientEvent('myresource:loadMap', -1, mapConfigs[i])
    end
end