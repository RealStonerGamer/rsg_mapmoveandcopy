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
                local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, mapConfig.X, mapConfig.Y, mapConfig.Z)

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

function LoadMaps(mapConfig)
    for i, mapConfig in ipairs(Config.Maps) do

    local ymapName = mapConfig.Map
    local ymapLoaded = false
    local ymapFile = LoadResourceFile(GetCurrentResourceName(), "maps/stream/" .. ymapName .. ".ymap")
    if ymapFile ~= nil then
        ymapLoaded = true
    else
        print("Error loading ymap file: " .. ymapName)
    end

    -- Extract the entities from the ymap file
    local entities = {}
    if ymapLoaded then
        local ymap = LoadYMapFromMemory(ymapFile)
        for j = 0, ymap.entityCount - 1 do
            local entity = ymap:GetEntity(j)
            local position = entity:GetPosition()
            local rotation = entity:GetRotation()
            local handle = entity:GetHandle()
            table.insert(entities, {
                handle = handle,
                position = position,
                rotation = rotation
            })
        end
        UnloadYMap(ymap)
    

    -- Pass the extracted entities to the 'rsg_loadmaps:loadMap' event
    TriggerClientEvent('rsg_loadmaps:loadMap', -1, {
        Map = mapConfig.Name,
        X = mapConfig.X,
        Y = mapConfig.Y,
        Z = mapConfig.Z,
        Rotation = mapConfig.Rotation,
        Interior = mapConfig.Interior,
        Heading = mapConfig.Heading,
        entities = entities
    })
        end

    end
end


RegisterServerEvent('rsg_loadmaps:loadMap')
AddEventHandler('rsg_loadmaps:loadMap', function(mapConfig)
    -- Calculate the position and rotation offsets
    local offsetX = mapConfig.X
    local offsetY = mapConfig.Y
    local offsetZ = mapConfig.Z
    local offsetRot = mapConfig.Rotation

    -- Move and rotate each entity in the ymap
    for i = 1, #mapConfig.entities do
        local entity = mapConfig.entities[i]
    
        -- Retrieve position, rotation, and other information for this entity
        local entityPos = entity.position
        local entityRot = entity.rotation
        local entityModel = GetHashKey(entity.archetypeName)
        local entityHandle = 0 -- Handle of the spawned entity
    
        -- Apply the position offset
        entityPos.x = entityPos.x + offsetX
        entityPos.y = entityPos.y + offsetY
        entityPos.z = entityPos.z + offsetZ
    
        -- Apply the rotation offset
        local quat = entityRot:ToQuaternion()
        quat = quaternion.from_euler_angles(math.rad(offsetRot), 0, 0) * quat
        local rotX, rotY, rotZ = quat:ToEulerAnglesXYZ()
        entityRot = vector4(rotX, rotY, rotZ, entityRot.w)
    
        -- Spawn the entity
        RequestModel(entityModel)
        while not HasModelLoaded(entityModel) do
            Citizen.Wait(1)
        end
        entityHandle = CreateObject(entityModel, entityPos.x, entityPos.y, entityPos.z, true, false, true)
    
        -- Set the entity properties
        SetEntityRotation(entityHandle, entityRot.x, entityRot.y, entityRot.z, 2, true)
        SetModelAsNoLongerNeeded(entityModel)
    end
end)

Citizen.CreateThread(function(mapConfig)
    for i, mapConfig in ipairs(Config.Maps) do
        LoadMaps(mapConfig)
    end
end)

RegisterServerEvent('rsg_loadmaps:loadMap')
AddEventHandler('rsg_loadmaps:loadMap', function(mapName)
    local mapConfigs = mapName
    for i = 1, #mapConfigs do
        LoadMaps(mapConfig)
    end
end)





