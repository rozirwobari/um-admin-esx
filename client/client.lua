local ESX = exports["es_extended"]:getSharedObject()
local umadmin, minpage, disablecontrol = false, false, false
local vehicles, weapons = {}, {}


CreateThread(function()
    for k, v in pairs(UMShared.Vehicles) do
        local category = v["category"]
        if vehicles[category] == nil then
            vehicles[category] = {}
        end
        vehicles[category][k] = v
    end
    for _, v in pairs(UMShared.Weapons) do
        weapons[v.label] = v
    end
end)

local function nuiWalks(bool)
    disablecontrol = bool
    while disablecontrol do
        DisableControlAction(0, 1, true)   -- disable mouse look
        DisableControlAction(0, 2, true)   -- disable mouse look
        DisableControlAction(0, 3, true)   -- disable mouse look
        DisableControlAction(0, 4, true)   -- disable mouse look
        DisableControlAction(0, 5, true)   -- disable mouse look
        DisableControlAction(0, 6, true)   -- disable mouse look
        DisableControlAction(0, 263, true) -- disable melee
        DisableControlAction(0, 264, true) -- disable melee
        DisableControlAction(0, 257, true) -- disable melee
        DisableControlAction(0, 140, true) -- disable melee
        DisableControlAction(0, 141, true) -- disable melee
        DisableControlAction(0, 142, true) -- disable melee
        DisableControlAction(0, 143, true) -- disable melee
        DisableControlAction(0, 177, true) -- disable escape
        DisableControlAction(0, 200, true) -- disable escape
        DisableControlAction(0, 202, true) -- disable escape
        DisableControlAction(0, 322, true) -- disable escape
        --DisableControlAction(0, 245, true) -- disable chat
        DisableControlAction(0, 24, true)  -- disable
        Wait(5)
    end
end

--- Event [Nui]
RegisterNetEvent('um-admin:client:openMenu', function()
    if not umadmin then
        local result = lib.callback.await('um-admin:server:GetCurrentPlayers', false)
        SetNuiFocus(true, true)
        SendNUIMessage({ type = "panel", result = result })
        umadmin = true
    end
end)

RegisterNetEvent('um-admin:client:getPlayerProfile', function(data)
    SendNUIMessage({ type = "playerprofile", data = data })
end)

RegisterNetEvent('um-admin:client:getMoney', function(totalmoney, moneytype)
    SendNUIMessage({ type = "money", totalmoney = totalmoney, moneytype = moneytype })
end)


--- Callback [Nui]
RegisterNUICallback("um-admin:nuicallback:getPlayers", function()
    local players = lib.callback.await('um-admin:callback:getplayers', false)
    SendNUIMessage({ type = "getplayers", players = players })
end)

RegisterNUICallback("um-admin:nuicallback:setMinPage", function()
    SetNuiFocusKeepInput(true)
    nuiWalks(true)
end)

RegisterNUICallback("um-admin:nuicallback:getPlayerProfile", function(player)
    TriggerServerEvent('um-admin:server:getPlayerProfile', player)
end)

RegisterNUICallback('um-admin:nuicallback:getVehicles', function()
    SendNUIMessage({ type = "vehicles", vehicles = vehicles })
end)

RegisterNUICallback('um-admin:nuicallback:getWeapons', function()
    SendNUIMessage({ type = "weapons", weapons = weapons })
end)

RegisterNUICallback('um-admin:nuicallback:weather', function(weather)
    local data = {
        weather = weather,
        instantweather = true,
    }
    TriggerEvent('cd_easytime:SyncWeather', data)
    lib.notify({
        title = 'Admin Menu',
        description = "Cuaca diubah menjadi: " .. weather,
        type = 'success',
        duration = 5000,
        style = {
            borderRadius = "13px",
        }
    })
end)

RegisterNUICallback('um-admin:nuicallback:time', function(time)
    local data = {
        hours = time,
        mins = 00,
    }
    TriggerEvent('cd_easytime:SyncTime', data)
    lib.notify({
        title = 'Admin Menu',
        description = "Waktu diubah menjadi: " .. time,
        type = 'success',
        duration = 5000,
        style = {
            borderRadius = "13px",
        }
    })
end)

RegisterNUICallback("um-admin:nuicallback:toggleMutePlayer", function(player)
    exports['pma-voice']:toggleMutePlayer(player)
end)

RegisterNUICallback('um-admin:client:viewdistance', function(value)
    SetEntityViewDistance(value)
    lib.notify({
        title = 'Admin Menu',
        description = "Jarak pandang entitas diatur ke: " .. value .. " meter",
        type = 'success',
        duration = 5000,
        style = {
            borderRadius = "13px",
        }
    })
end)

RegisterNUICallback("um-admin:nuicallback:event", function(data)
    if data[1] == 'client' then
        TriggerEvent(data[2], data[3])
    elseif data[1] == 'server' then
        TriggerServerEvent(data[2], data[3])
    elseif data[1] == 'serverall' then
        TriggerServerEvent(data[2], data)
    elseif data[1] == 'command' then
        ExecuteCommand(data[2] .. ' ' .. data[3])
    elseif data[1] == 'adminserver' then
        TriggerServerEvent("um-admin:server:" .. data[2], data[3])
    elseif data[1] == 'kickorban' then
        TriggerServerEvent("um-admin:server:" .. data[2], data)
    end
end)

RegisterNUICallback("um-admin:nuicallback:toFullPage", function()
    nuiWalks(false)
    SetNuiFocusKeepInput(false)
end)

RegisterNUICallback("um-admin:nuicallback:escapeNui", function()
    nuiWalks(false)
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
    umadmin = false
end)

lib.callback.register('um-admin:client:getStatus', function()
    local nearbyVehicles = lib.getNearbyVehicles(GetEntityCoords(cache.ped), radius, true)
    return nearbyVehicles
end)

RegisterNetEvent('um-admin:client:SyncTime')
AddEventHandler('um-admin:client:SyncTime', function(data)
    local xPlayer = ESX.GetPlayerData()
    if Config.Function.HasPermission(xPlayer.group) then
        TriggerServerEvent('cd_easytime:ForceUpdate', data)
    end
end)

RegisterNetEvent('um-admin:client:setmodelself')
AddEventHandler('um-admin:client:setmodelself', function(skin)
    local xPlayer = ESX.GetPlayerData()
    if Config.Function.HasPermission(xPlayer.group) then
        local ped = PlayerPedId()
        local model = GetHashKey(skin)
        SetEntityInvincible(ped, true)

        if IsModelInCdimage(model) and IsModelValid(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end
            SetPlayerModel(PlayerId(), model)
            SetModelAsNoLongerNeeded(model)
        end
        SetEntityInvincible(ped, false)
    end
end)

RegisterNetEvent('um-admin:client:fixvehicle')
AddEventHandler('um-admin:client:fixvehicle', function()
    local xPlayer = ESX.GetPlayerData()
    if Config.Function.HasPermission(xPlayer.group) then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            SetVehicleFixed(vehicle)
            SetVehicleDirtLevel(vehicle, 0.0)
            SetVehicleEngineHealth(vehicle, 1000.0)
            SetVehiclePetrolTankHealth(vehicle, 1000.0)
            SetVehicleBodyHealth(vehicle, 1000.0)
        end
    end
end)

RegisterNetEvent('um-admin:client:maxmodVehicle')
AddEventHandler('um-admin:client:maxmodVehicle', function(customWheels)
    local xPlayer = ESX.GetPlayerData()
    if Config.Function.HasPermission(xPlayer.group) then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local performanceModIndices = { 11, 12, 13, 15, 16 }
        customWheels = customWheels or false
        local max
        if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
            SetVehicleModKit(vehicle, 0)
            for _, modType in ipairs(performanceModIndices) do
                max = GetNumVehicleMods(vehicle, tonumber(modType)) - 1
                SetVehicleMod(vehicle, modType, max, customWheels)
            end
            ToggleVehicleMod(vehicle, 18, true) -- Turbo
            SetVehicleFixed(vehicle)
        end
        lib.notify({
            title = 'Admin Menu',
            description = 'Berhasil Memperbaiki Dan Upgrade Kendaraan',
            type = 'success',
            position = 'top'
        })
    end
end)

RegisterNetEvent('um-admin:client:getVector')
AddEventHandler('um-admin:client:getVector', function(dataType)
    local xPlayer = ESX.GetPlayerData()
    if Config.Function.HasPermission(xPlayer.group) then
        local ped = PlayerPedId()
        if dataType == 'vector2' then
            local coords = GetEntityCoords(ped)
            local x = Config.Function.Round(coords.x, 2)
            local y = Config.Function.Round(coords.y, 2)
            lib.setClipboard(string.format('vector2(%s, %s)', x, y))
            lib.notify({
                title = 'Admin Menu',
                description = 'Berhasil Menyalin Vectore 2',
                type = 'success',
                position = 'top',
            })
        elseif dataType == 'vector3' then
            local coords = GetEntityCoords(ped)
            local x = Config.Function.Round(coords.x, 2)
            local y = Config.Function.Round(coords.y, 2)
            local z = Config.Function.Round(coords.z, 2)
            lib.setClipboard(string.format('vector3(%s, %s, %s)', x, y, z))
            lib.notify({
                title = 'Admin Menu',
                description = 'Berhasil Menyalin Vectore 3',
                type = 'success',
                position = 'top',
            })
        elseif dataType == 'vector4' then
            local coords = GetEntityCoords(ped)
            local x = Config.Function.Round(coords.x, 2)
            local y = Config.Function.Round(coords.y, 2)
            local z = Config.Function.Round(coords.z, 2)
            local heading = GetEntityHeading(ped)
            local h = Config.Function.Round(heading, 2)
            lib.setClipboard(string.format('vector4(%s, %s, %s, %s)', x, y, z, h))
            lib.notify({
                title = 'Admin Menu',
                description = 'Berhasil Menyalin Vectore 4',
                type = 'success',
                position = 'top',
            })
        elseif dataType == 'heading' then
            local heading = GetEntityHeading(ped)
            local h = Config.Function.Round(heading, 2)
            lib.setClipboard(h)
            lib.notify({
                title = 'Admin Menu',
                description = 'Berhasil Menyalin Heading',
                type = 'success',
                position = 'top',
            })
        elseif dataType == 'freeaimEntity' then
            local entity = GetFreeAimEntity()

            if entity then
                local entityHash = GetEntityModel(entity)
                local entityName = Entities[entityHash] or 'Unknown'
                local entityCoords = GetEntityCoords(entity)
                local entityHeading = GetEntityHeading(entity)
                local entityRotation = GetEntityRotation(entity)
                local x = Config.Function.Round(entityCoords.x, 2)
                local y = Config.Function.Round(entityCoords.y, 2)
                local z = Config.Function.Round(entityCoords.z, 2)
                local rotX = Config.Function.Round(entityRotation.x, 2)
                local rotY = Config.Function.Round(entityRotation.y, 2)
                local rotZ = Config.Function.Round(entityRotation.z, 2)
                local h = Config.Function.Round(entityHeading, 2)
                SendNUIMessage({
                    string = string.format(
                    'Model Name:\t%s\nModel Hash:\t%s\n\nHeading:\t%s\nCoords:\t\tvector3(%s, %s, %s)\nRotation:\tvector3(%s, %s, %s)',
                        entityName, entityHash, h, x, y, z, rotX, rotY, rotZ)
                })
            else
                lib.notify({
                    title = 'Admin Menu',
                    description = 'Tidak ada info entitas tujuan gratis untuk disalin ke papan klip!',
                    type = 'error',
                    position = 'top',
                })
            end
        end
    end
end)


RegisterNetEvent('um-admin:client:cloth')
AddEventHandler('um-admin:client:cloth', function()
    local xPlayer = ESX.GetPlayerData()
    if Config.Function.HasPermission(xPlayer.group) then
        return Config.Cloth[Config.Wardrobe]()
    end
end)

RegisterNetEvent('um-admin:client:kill')
AddEventHandler('um-admin:client:kill', function(target)
    local killed = lib.callback.await('um-admin:callback:kill', false, target)
    if killed then
        SetEntityHealth(PlayerPedId(), 0)
    end
end)