-- Variables
local ESX = exports["es_extended"]:getSharedObject()

local blockedPeds = {
    "mp_m_freemode_01",
    "mp_f_freemode_01",
    "tony",
    "g_m_m_chigoon_02_m",
    "u_m_m_jesus_01",
    "a_m_y_stbla_m",
    "ig_terry_m",
    "a_m_m_ktown_m",
    "a_m_y_skater_m",
    "u_m_y_coop",
    "ig_car3guy1_m",
}

local lastSpectateCoord = nil
local isSpectating = false


local function Round(value, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(value * mult + 0.5) / mult
end

local function CopyToClipboard(dataType)
    local ped = PlayerPedId()
    if dataType == 'coords2' then
        local coords = GetEntityCoords(ped)
        local x = Round(coords.x, 2)
        local y = Round(coords.y, 2)
        SendNUIMessage({
         type="string", string = string.format('vector2(%s, %s)', x, y)
        })
        lib.notify({
            title = 'Admin Menu',
            description = "Koordinat disalin ke clipboard!",
            type = 'success',
            duration = 5000,
            style = {
                borderRadius = "13px",
            }
        })
    elseif dataType == 'coords3' then
        local coords = GetEntityCoords(ped)
        local x = Round(coords.x, 2)
        local y = Round(coords.y, 2)
        local z = Round(coords.z, 2)
        SendNUIMessage({
            type="string",   string = string.format('vector3(%s, %s, %s)', x, y, z)
        })
        lib.notify({
            title = 'Admin Menu',
            description = "Koordinat disalin ke clipboard!",
            type = 'success',
            duration = 5000,
            style = {
                borderRadius = "13px",
            }
        })
    elseif dataType == 'coords4' then
        local coords = GetEntityCoords(ped)
        local x = Round(coords.x, 2)
        local y = Round(coords.y, 2)
        local z = Round(coords.z, 2)
        local heading = GetEntityHeading(ped)
        local h = Round(heading, 2)
        SendNUIMessage({
            type="string",  string = string.format('vector4(%s, %s, %s, %s)', x, y, z, h)
        })
        lib.notify({
            title = 'Admin Menu',
            description = "Koordinat disalin ke clipboard!",
            type = 'success',
            duration = 5000,
            style = {
                borderRadius = "13px",
            }
        })
    elseif dataType == 'heading' then
        local heading = GetEntityHeading(ped)
        local h = Round(heading, 2)
        SendNUIMessage({
            type="string",   string = h
        })
        lib.notify({
            title = 'Admin Menu',
            description = "Heading disalin ke clipboard!",
            type = 'success',
            duration = 5000,
            style = {
                borderRadius = "13px",
            }
        })
    elseif dataType == 'freeaimEntity' then
        local entity = GetFreeAimEntity()

        if entity then
            local entityHash = GetEntityModel(entity)
            local entityName = Entities[entityHash] or "Unknown"
            local entityCoords = GetEntityCoords(entity)
            local entityHeading = GetEntityHeading(entity)
            local entityRotation = GetEntityRotation(entity)
            local x = Round(entityCoords.x, 2)
            local y = Round(entityCoords.y, 2)
            local z = Round(entityCoords.z, 2)
            local rotX = Round(entityRotation.x, 2)
            local rotY = Round(entityRotation.y, 2)
            local rotZ = Round(entityRotation.z, 2)
            local h = Round(entityHeading, 2)
            SendNUIMessage({
                type="string",  string = string.format('Model Name:\t%s\nModel Hash:\t%s\n\nHeading:\t%s\nCoords:\t\tvector3(%s, %s, %s)\nRotation:\tvector3(%s, %s, %s)', entityName, entityHash, h, x, y, z, rotX, rotY, rotZ)
            })
            lib.notify({
                title = 'Admin Menu',
                description = "Informasi entitas Freeaim disalin ke clipboard",
                type = 'success',
                duration = 5000,
                style = {
                    borderRadius = "13px",
                }
            })
        else
            lib.notify({
                title = 'Admin Menu',
                description = "Tidak ada informasi entitas freeaim yang akan disalin ke clipboard",
                type = 'error',
                duration = 5000,
                style = {
                    borderRadius = "13px",
                }
            })
        end
    end
end

local function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end


-- Events

RegisterNetEvent('um-admin:client:toggleshowcoords', function()
    local x = 0.4
    local y = 0.025
    showCoords = not showCoords
    CreateThread(function()
        while showCoords do
            local coords = GetEntityCoords(PlayerPedId())
            local heading = GetEntityHeading(PlayerPedId())
            local c = {}
            c.x = Round(coords.x, 2)
            c.y = Round(coords.y, 2)
            c.z = Round(coords.z, 2)
            heading = Round(heading, 2)
            Wait(0)
            Draw2DText(string.format('~w~'.."Kordinat : " .. '~b~ vector4(~w~%s~b~, ~w~%s~b~, ~w~%s~b~, ~w~%s~b~)', c.x, c.y, c.z, heading), 4, {66, 182, 245}, 0.4, x + 0.0, y + 0.0)
        end
    end)
end)

RegisterNetEvent('um-admin:client:togglevehicledev', function()
    local x = 0.4
    local y = 0.888
    vehicleDevMode = not vehicleDevMode
    CreateThread(function()
        while vehicleDevMode do
            local ped = PlayerPedId()
            Wait(0)
            if IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                local netID = VehToNet(vehicle)
                local hash = GetEntityModel(vehicle)
                local modelName = GetLabelText(GetDisplayNameFromVehicleModel(hash))
                local eHealth = GetVehicleEngineHealth(vehicle)
                local bHealth = GetVehicleBodyHealth(vehicle)
                Draw2DText('Vehicle Developer Data: ', 4, {66, 182, 245}, 0.4, x + 0.0, y + 0.0)
                Draw2DText('Entity ID: '..vehicle..' | Net ID: '..netID, 4, {255, 255, 255}, 0.4, x + 0.0, y + 0.025)
                Draw2DText('Model : '..modelName..' | Hash : '..hash, 4, {255, 255, 255}, 0.4, x + 0.0, y + 0.050)
                Draw2DText('Engine Health: '..Round(eHealth, 2)..' | Body Health:'..Round(bHealth, 2), 4, {255, 255, 255}, 0.4, x + 0.0, y + 0.075)
            end
        end
    end)
end)

RegisterNetEvent('um-admin:client:freeaim', function()
    ToggleEntityFreeView()
end)

RegisterNetEvent('um-admin:client:viewmode', function(mode)
    if mode == "vehicles" then
        ToggleEntityVehicleView()
    elseif mode == "peds" then
        ToggleEntityPedView()
    elseif mode == "objects" then
        ToggleEntityObjectView()
    end
end)



RegisterNetEvent('um-admin:client:inventory', function(targetPed)
    exports.ox_inventory:openInventory('player', targetPed)
end)

RegisterNetEvent('um-admin:client:spectate', function(targetPed)
    local myPed = PlayerPedId()
    local targetplayer = GetPlayerFromServerId(targetPed)
    local target = GetPlayerPed(targetplayer)
    if not isSpectating then
        isSpectating = true
        SetEntityVisible(myPed, false) -- Set invisible
        SetEntityCollision(myPed, false, false) -- Set collision
        SetEntityInvincible(myPed, true) -- Set invincible
        NetworkSetEntityInvisibleToNetwork(myPed, true) -- Set invisibility
        lastSpectateCoord = GetEntityCoords(myPed) -- save my last coords
        NetworkSetInSpectatorMode(true, target) -- Enter Spectate Mode
    else
        isSpectating = false
        NetworkSetInSpectatorMode(false, target) -- Remove From Spectate Mode
        NetworkSetEntityInvisibleToNetwork(myPed, false) -- Set Visible
        SetEntityCollision(myPed, true, true) -- Set collision
        SetEntityCoords(myPed, lastSpectateCoord) -- Return Me To My Coords
        SetEntityVisible(myPed, true) -- Remove invisible
        SetEntityInvincible(myPed, false) -- Remove godmode
        lastSpectateCoord = nil -- Reset Last Saved Coords
    end
end)

local function getVehicleFromVehList(hash)
	for _, v in pairs(UMShared.Vehicles) do
		if hash == v.hash then
			return v.model
		end
	end
end



RegisterNetEvent('um-admin:client:SaveCar', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), true)

    if veh ~= nil and veh ~= 0 then
        local props = ESX.Game.GetVehicleProperties(veh)
        local hash = props.model
        local vehname = getVehicleFromVehList(hash)
        if GetPedInVehicleSeat(veh, -1) == GetPlayerPed(PlayerId()) then
            TriggerServerEvent('um-admin:server:SaveCar', props)
            TriggerServerEvent('um-admin:log:minPage',"vehicle","savecar","blue")
        else
            lib.notify({
                title = 'Admin Menu',
                description = "Anda tidak dapat menyimpan kendaraan ini di garasi Anda.",
                type = 'error',
                duration = 5000,
                style = {
                    borderRadius = "13px",
                }
            })
        end
    else
        lib.notify({
            title = 'Admin Menu',
            description = "Anda tidak berada dalam kendaraan.",
            type = 'error',
            duration = 5000,
            style = {
                borderRadius = "13px",
            }
        })
    end
end)

local function LoadPlayerModel(skin)
    RequestModel(skin)
    while not HasModelLoaded(skin) do
      Wait(0)
    end
end

local function isPedAllowedRandom(skin)
    local retval = false
    for _, v in pairs(blockedPeds) do
        if v ~= skin then
            retval = true
        end
    end
    return retval
end

RegisterNetEvent('um-admin:client:SetModel', function(skin)
    local ped = PlayerPedId()
    local model = GetHashKey(skin)
    SetEntityInvincible(ped, true)

    if IsModelInCdimage(model) and IsModelValid(model) then
        LoadPlayerModel(model)
        SetPlayerModel(PlayerId(), model)

        if isPedAllowedRandom(skin) then
            SetPedRandomComponentVariation(ped, true)
        end

		SetModelAsNoLongerNeeded(model)
	end
	SetEntityInvincible(ped, false)
end)

local speed = false
RegisterNetEvent('um-admin:client:SetSpeed', function()
    local ped = PlayerId()
    speed = not speed
    if speed then
        SetRunSprintMultiplierForPlayer(ped, 1.49)
        SetSwimMultiplierForPlayer(ped, 1.49)
    else
        SetRunSprintMultiplierForPlayer(ped, 1.0)
        SetSwimMultiplierForPlayer(ped, 1.0)
    end
end)

RegisterNetEvent("um-admin:client:reviveSelf", function()
    TriggerServerEvent('um-admin:server:revive')
end)

local devmode = false
RegisterNetEvent("um-admin:client:devMode", function()
    devmode = not devmode
    TriggerEvent('um-admin:client:godMode')
    TriggerEvent('um-admin:client:infiniteAmmo')
    TriggerEvent('um-admin:client:SetSpeed')
    lib.notify({
        title = 'Admin Menu',
        description = "Godmode,Infinite Ammo,Fast Speed | "..tostring(devmode),
        type = 'inform',
        duration = 5000,
        style = {
            borderRadius = "13px",
        }
    })
end)

local superJump = false
RegisterNetEvent("um-admin:client:superJump", function()
    superJump = not superJump
    while superJump do
        SetSuperJumpThisFrame(PlayerId(), 1000)
        Wait(5)
    end
end)

local godmode = false
RegisterNetEvent("um-admin:client:godMode", function()
    godmode = not godmode
    if godmode then
        lib.notify({
            title = 'Admin Menu',
            description = 'God Mode Diaktifkan',
            type = 'success',
            position = 'top'
        })
        while godmode do
            Wait(0)
            SetPlayerInvincible(PlayerId(), true)
        end
        SetPlayerInvincible(PlayerId(), false)
        return
    end
    lib.notify({
        title = 'Admin Menu',
        description = 'God Mode Di Nonaktifkan',
        type = 'warning',
        position = 'top'
    })
end)

local InfiniteAmmo = false
RegisterNetEvent("um-admin:client:infiniteAmmo", function()
    InfiniteAmmo = not InfiniteAmmo
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    if InfiniteAmmo then
        if GetAmmoInPedWeapon(ped, weapon) < 6 then SetAmmoInClip(ped, weapon, 10) Wait(50) end
        while InfiniteAmmo do
            weapon = GetSelectedPedWeapon(ped)
            SetPedInfiniteAmmo(ped, true, weapon)
            RefillAmmoInstantly(ped)
            Wait(250)
        end
    else
        SetPedInfiniteAmmo(ped, false, weapon)
    end
end)

local invisible = false
RegisterNetEvent("um-admin:client:invisible", function()
    invisible = not invisible
    TriggerServerEvent('um-admin:log:minPage',"invisible","invisible","black")
    if invisible then
        SetEntityVisible(PlayerPedId(), false, 0)
    else
        SetEntityVisible(PlayerPedId(), true, 0)
    end
end)


local VehicleGodmode = false
RegisterNetEvent("um-admin:client:vehicleGodMode", function()
    VehicleGodmode = not VehicleGodmode
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if VehicleGodmode then
        SetEntityInvincible(vehicle, true)
        SetEntityCanBeDamaged(vehicle, false)
        lib.notify({
            title = 'Admin Menu',
            description = 'God Mode Vehicle Diaktifkan',
            type = 'success',
            position = 'top'
        })
        while VehicleGodmode do
            vehicle = GetVehiclePedIsIn(ped, false)
            SetVehicleBodyHealth(vehicle, 1000.0)
            SetVehicleFixed(vehicle)
            SetVehicleEngineHealth(vehicle, 1000.0)
            Wait(250)
        end
    else
        SetEntityInvincible(vehicle, false)
        SetEntityCanBeDamaged(vehicle, true)
        lib.notify({
            title = 'Admin Menu',
            description = 'God Mode Vehicle Di Nonaktifkan',
            type = 'warning',
            position = 'top'
        })
    end
end)


RegisterNetEvent('qb-weapons:client:SetWeaponAmmoManual', function(weapon, ammo)
    local ped = PlayerPedId()
    if weapon ~= "current" then
        weapon = weapon:upper()
        SetPedAmmo(ped, GetHashKey(weapon), ammo)
        lib.notify({
            title = 'Admin Menu',
            description = ammo.." amunisi untuk "..tostring(weapon),
            type = 'success',
            duration = 5000,
            style = {
                borderRadius = "13px",
            }
        })
    else
        weapon = GetSelectedPedWeapon(ped)
        if weapon ~= nil then
            SetPedAmmo(ped, weapon, ammo)
            lib.notify({
                title = 'Admin Menu',
                description = ammo.." amunisi untuk "..tostring(weapon),
                type = 'success',
                duration = 5000,
                style = {
                    borderRadius = "13px",
                }
            })
        else
            lib.notify({
                title = 'Admin Menu',
                description = "Anda tidak memegang senjata",
                type = 'error',
                duration = 5000,
                style = {
                    borderRadius = "13px",
                }
            })
        end
    end
end)

RegisterNetEvent('um-admin:client:GiveNuiFocus', function(focus, mouse)
    SetNuiFocus(focus, mouse)
end)

local performanceModIndices = { 11, 12, 13, 15, 16 }
function PerformanceUpgradeVehicle(vehicle, customWheels)
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
end

RegisterNetEvent('um-admin:client:copyToClipboard', function(dataType)
    CopyToClipboard(dataType)
end)