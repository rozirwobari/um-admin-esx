local ESX = exports["es_extended"]:getSharedObject()
local players = {}
local PlayerKill = {}
local frozen = false
local permissions = {
    ['kill'] = 'admin',
    ['ban'] = 'admin',
    ['noclip'] = 'admin',
    ['kickall'] = 'admin',
    ['kick'] = 'admin',
    ["revive"] = "admin",
    ["freeze"] = "admin",
    ["goto"] = "admin",
    ["spectate"] = "admin",
    ["intovehicle"] = "admin",
    ["bring"] = "admin",
    ["inventory"] = "admin",
    ["clothing"] = "admin"
}

-- Callback
lib.callback.register('um-admin:callback:getplayers', function(source, item, metadata, target)
    return players
end)

lib.callback.register('um-admin:callback:kill', function(source, identifer)
    if PlayerKill[identifer] ~= nil then
        PlayerKill[identifer] = nil
        return true
    else
        return false
    end
end)

-- Functions
local function BanPlayer(src)
    MySQL.insert('INSERT INTO um_bans (name, identifier, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(src),
        GetPlayerIdentifierByType(src, "steam"),
        GetPlayerIdentifierByType(src, "license"),
        GetPlayerIdentifierByType(src, "discord"),
        GetPlayerIdentifierByType(src, "ip"),
        "Trying to revive theirselves or other players",
        os.date('%Y-%m-%d %H:%M:%S', 2147483647),
        'um-admin'
    })
    TriggerEvent('um-admin:log:playersEvent',src,"cheater","Banned Cheater \n Trying to trigger admin options which they dont have permission for","red",src)
    DropPlayer(src, 'You were permanently banned by the server for: Exploiting')
end

-- Events
RegisterNetEvent('um-admin:server:GetPlayersForBlips', function()
    local src = source
    TriggerClientEvent('um-admin:client:Show', src, players)
end)

RegisterNetEvent('um-admin:server:kill', function(target)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local xTarget = ESX.GetPlayerFromId(target)
    if Config.Function.HasPermission(xPlayer.group) then
        TriggerClientEvent('um-admin:client:kill', xTarget.source, xTarget.identifier)
        PlayerKill[xTarget.identifier] = {
            identifier_admin = xPlayer.identifier,
            identifier_target = xTarget.identifier,
        }
        TriggerEvent('um-admin:log:playersEvent',src,"kill","Killed".."["..xTarget.name.."]","black", xPlayer.source)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('um-admin:server:revive', function(player)
    local src = player or source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        TriggerClientEvent('esx_ambulancejob:revive', xPlayer.source)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('um-admin:server:kick', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        TriggerEvent('um-admin:log:playersEvent',src,"kick","Kicked".."["..data[3].."] \n Reason: "..data[4],"yellow",data[3])
        DropPlayer(data[3], 'Anda telah dikeluarkan dari server :\n' .. data[4] .. '\n\n' .. "🔸 Check our Discord for more information: " .. Config.DiscordInvite)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('um-admin:server:ban', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        time = tonumber(data[4])
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then
            banTime = 2147483647
        end
        local timeTable = os.date('*t', banTime)
        MySQL.insert('INSERT INTO um_bans (name, identifier, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(src),
            GetPlayerIdentifierByType(src, "steam"),
            GetPlayerIdentifierByType(src, "license"),
            GetPlayerIdentifierByType(src, "discord"),
            GetPlayerIdentifierByType(src, "ip"),
            data[5],
            os.date('%Y-%m-%d %H:%M:%S', banTime),
            GetPlayerName(src)
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = "<div class=chat-message server'><strong>ANNOUNCEMENT | {0} has been banned:</strong> {1}</div>",
            args = {GetPlayerName(data[3]), data[5]}
        })
        TriggerEvent('um-admin:log:playersEvent',src,"ban","Banned".."["..data[3].."] \n Reason: "..data[5],"red",data[3])
        if banTime >= 2147483647 then
            DropPlayer(data[3], "You have been banned: " .. '\n' .. data[5] .. "\n\nYour ban is permanent.\n🔸 Check our Discord for more information: " .. Config.DiscordInvite)
        else
            DropPlayer(data[3], "You have been banned: " .. '\n' .. data[5] .. "\n\nBan expires: ".. timeTable['day'] .. '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'] .. '\n🔸 Check our Discord for more information: ' .. Config.DiscordInvite)
        end
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('um-admin:server:spectate', function(player)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        local targetped = GetPlayerPed(player)
        local coords = GetEntityCoords(targetped)
        TriggerClientEvent('um-admin:client:spectate', src, player, coords)
        TriggerEvent('um-admin:log:playersEvent',src,"spectate","Spectate".."["..player.."]","black",player)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('um-admin:server:freeze', function(player)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        TriggerEvent('um-admin:log:playersEvent',src,"freeze","Freeze".."["..player.."]","black",player)
        local target = GetPlayerPed(player)
        if not frozen then
            frozen = true
            FreezeEntityPosition(target, true)
        else
            frozen = false
            FreezeEntityPosition(target, false)
        end
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('um-admin:server:goto', function(player)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        local admin = GetPlayerPed(src)
        local coords = GetEntityCoords(GetPlayerPed(player))
        SetEntityCoords(admin, coords)
        TriggerEvent('um-admin:log:playersEvent',src,"gotobring","Goto".."["..player.."]","black",player)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('um-admin:server:intovehicle', function(player)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        local admin = GetPlayerPed(src)
        local targetPed = GetPlayerPed(player)
        local vehicle = GetVehiclePedIsIn(targetPed,false)
        local seat = -1
        if vehicle ~= 0 then
            for i=0,8,1 do
                if GetPedInVehicleSeat(vehicle,i) == 0 then
                    seat = i
                    break
                end
            end
            if seat ~= -1 then
                SetPedIntoVehicle(admin,vehicle,seat)
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Admin Menu',
                    description = "Player Telah Dipindahkan.",
                    type = 'success',
                    duration = 5000,
                    style = {
                        borderRadius = "13px",
                    }
                })
                TriggerEvent('um-admin:log:playersEvent',src,"intovehicle","Into vehicle".."["..player.."]","black",player)
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Admin Menu',
                    description = "Kendaraan tidak memiliki tempat duduk kosong!",
                    type = 'warning',
                    duration = 5000,
                    style = {
                        borderRadius = "13px",
                    }
                })
            end
        end
    else
        BanPlayer(src)
    end
end)


RegisterNetEvent('um-admin:server:bring', function(player)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        local admin = GetPlayerPed(src)
        local coords = GetEntityCoords(admin)
        local target = GetPlayerPed(player)
        SetEntityCoords(target, coords)
        TriggerEvent('um-admin:log:playersEvent',src,"gotobring","Bring".."["..player.."]","black",player)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('um-admin:server:inventory', function(player)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        TriggerClientEvent('um-admin:client:inventory', src, player)
        TriggerEvent('um-admin:log:playersEvent',src,"inventory","Open Inventory".."["..player.."]","black",player)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('um-admin:server:cloth', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        TriggerClientEvent('um-admin:client:cloth', xPlayer.source)
    else
        BanPlayer(src)
    end
end)

RegisterServerEvent('um-admin:giveWeapon', function(weapon)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        xPlayer.addInventoryItem(weapon, 1)
    else
        BanPlayer(src)
    end
end)

RegisterServerEvent('um-admin:server:givemoneyadmin', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        if Player then
            xPlayer.addInventoryItem('money', tonumber(data[5]))
            TriggerEvent('um-admin:log:playersEvent',src,"givemoney","Give Money".."[Type:"..tostring(data[4].money).."] Total:"..tonumber(data[5]),"black",tonumber(data[3]))
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Admin Menu',
                description = "Pemain tidak online",
                type = 'error',
                duration = 5000,
                style = {
                    borderRadius = "13px",
                }
            })
        end
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('um-admin:server:SaveCar', function(vehicle)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        local result = MySQL.query.await('SELECT plate FROM player_vehicles WHERE plate = ?', { vehicle.plate })
        if result[1] == nil then
            MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored, parking, parking_name) VALUES (?,?,?,?,?,?,?)', {
                xPlayer.identifier,
                vehicle.plate,
                json.encode(vehicle),
                'car',
                1,
                'Garasi Import',
                'garasi_import',
            })
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Admin Menu',
                description = "Kendaraan sekarang menjadi milik Anda!",
                type = 'success',
                duration = 5000,
                style = {
                    borderRadius = "13px",
                }
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Admin Menu',
                description = "Kendaraan sekarang menjadi milik Anda!",
                type = 'success',
                duration = 5000,
                style = {
                    borderRadius = "13px",
                }
            })
        end
    else
        BanPlayer(src)
    end
end)

-- Loop
CreateThread(function()
    while true do
        local tempPlayers = {}
        for _, PlayerId in pairs(GetPlayers()) do
            local targetped = GetPlayerPed(PlayerId)
            local xPlayer = ESX.GetPlayerFromId(PlayerId)
            if xPlayer ~= nil then
                tempPlayers[#tempPlayers + 1] = {
                    name = xPlayer.name,
                    id = PlayerId,
                    currentping = GetPlayerPing(PlayerId)
                }
            end
        end
        -- Sort players list by source ID (1,2,3,4,5, etc) --
        table.sort(tempPlayers, function(a, b)
            return a.id < b.id
        end)
            players = tempPlayers
        Wait(1500)
    end
end)