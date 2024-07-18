local ESX = exports["es_extended"]:getSharedObject()


Citizen.CreateThread(function()
    MySQL.query(
    [[
        CREATE TABLE IF NOT EXISTS `um_bans` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `name` mediumtext DEFAULT NULL,
            `identifier` varchar(100) DEFAULT NULL,
            `license` mediumtext DEFAULT NULL,
            `discord` mediumtext DEFAULT NULL,
            `ip` varchar(100) DEFAULT NULL,
            `reason` longtext DEFAULT NULL,
            `expire` datetime DEFAULT current_timestamp(),
            `bannedby` mediumtext DEFAULT NULL,
            PRIMARY KEY (`id`)
        );
    ]]
    , {}, function(result)
        if result and result.warningStatus == 0 then
            print("^3[UM-ADMIN]^0 ^2Table um_bans Tidak Ditemukan!, Sedang Membaut Table...^0")
            Wait(3000)
            print("^3[UM-ADMIN]^0 ^2Table um_bans Berhasil Dibuat.^0")
        else
            print("^3[UM-ADMIN]^0 ^2Table um_bans Sudah Tersedia.^0")
        end
    end)
end)

Citizen.CreateThread(function()
MySQL.query(
    [[
        SHOW COLUMNS FROM owned_vehicles;
    ]],
    {},
    function(result)
        local columnExists = false
        if result then
            for _, row in pairs(result) do
                if row.Field == 'parking_name' then
                    columnExists = true
                end
            end
            if not columnExists then
                print("^3[UM-ADMIN]^0 ^1Colum parking_name Tidak Ditemukan!, Sedang Membaut Colum...^0")
                MySQL.query(
                    [[
                        ALTER TABLE owned_vehicles ADD COLUMN parking_name VARCHAR(60) AFTER parking;
                    ]]
                )
                Wait(3000)
                print("^3[UM-ADMIN]^0 ^2Colum parking_name Berhasil Dibuat.^0")
            end
        end
    end
)
end)


lib.callback.register('um-admin:server:GetCurrentPlayers', function(source)
    return #GetPlayers()
end)

--- Event [Nui]
RegisterNetEvent('um-admin:server:getMoney', function(moneytype)
    local src = source
    local result = MySQL.query.await('SELECT accounts FROM users', {})
    if result then
        local totalMoney = 0
        for k, value in pairs(result) do
            local account = json.decode(value.accounts)
            totalMoney += account[moneytype]
        end
        TriggerClientEvent('um-admin:client:getMoney', src, totalMoney, moneytype)
    end
end)

local function setWeather(weather)
    local validWeatherType = false
    for _, weatherType in pairs(Config.AvailableWeatherTypes) do
        if weatherType == string.upper(weather) then
            validWeatherType = true
        end
    end
    if not validWeatherType then return false end
    CurrentWeather = string.upper(weather)
    newWeatherTimer = Config.NewWeatherTimer
    TriggerEvent('qb-weathersync:server:RequestStateSync')
    return true
end

RegisterNetEvent('qb-weathersync:server:setWeather', function(weather)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Function.HasPermission(xPlayer.group) then
        local data = {
            weather = weather,
            instantweather = true,
        }
        TriggerClientEvent('cd_easytime:SyncWeather', -1, data)
    end
end)

RegisterNetEvent('qb-weathersync:server:setTime', function(time)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Function.HasPermission(xPlayer.group) then
        local data = {
            hours = tonumber(time),
            mins = 00,
            instanttime = true,
        }
        TriggerClientEvent('um-admin:client:SyncTime', xPlayer.source, data)
    end
end)

RegisterNetEvent('um-admin:server:getPlayerProfile', function(player)
    local xPlayer = ESX.GetPlayerFromId(player)
    local hunger = 0
    local thirst = 0
    local stress = 0
    TriggerEvent('esx_status:getStatus', xPlayer.source, 'hunger', function(status)
        hunger = status.percent
    end)
    TriggerEvent('esx_status:getStatus', xPlayer.source, 'thirst', function(status)
        thirst = status.percent
    end)
    local steam = GetPlayerIdentifierByType(xPlayer.source, "steam")
    local discord = GetPlayerIdentifierByType(xPlayer.source, "discord")
    local license = GetPlayerIdentifierByType(xPlayer.source, "license")
    local data = {
        ["name"] = xPlayer.name,
        ["status"] = {
            food = math.floor(hunger),
            water = math.floor(thirst),
            armor = 0,
            stress = math.floor(stress),
        },
        ["citizenid"] = xPlayer.identifier,
        ["license"] = license,
        ["steam"] = steam,
        ["steampic"] = steam,
        ["discord"] = discord,
        ["discordpic"] = discord,
        ["cash"] = xPlayer.getAccount('money').money,
        ["bank"] = xPlayer.getAccount('bank').money,
        ["job"] = xPlayer.job.label,
        ["gang"] = '',
        ["phone"] = '',
        ["player"] = xPlayer.source,
    }
    TriggerClientEvent('um-admin:client:getPlayerProfile', xPlayer.source, data)
end)


AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    deferrals.defer()
    local source = source
    local identifier = GetPlayerIdentifierByType(source, "steam")
    local license = GetPlayerIdentifierByType(source, "license")
    local discord = GetPlayerIdentifierByType(source, "discord")
    local ip = GetPlayerIdentifierByType(source, "ip")
    local data = MySQL.query.await('SELECT * FROM um_bans', {})
    deferrals.update("Memeriksa Akunmu Secara Rutin... [3 Detik]")
    Wait(1000)
    deferrals.update("Memeriksa Akunmu Secara Rutin... [2 Detik]")
    Wait(1000)
    deferrals.update("Memeriksa Akunmu Secara Rutin... [1 Detik]")
    Wait(1000)
    for key, value in pairs(data) do
        value['paspor'] = GetPlayerName(source)
        if value['identifier'] == identifier then
            showccard(deferrals, value)
            return
        end
        if value['license'] == license then
            showccard(deferrals, value)
            return
        end
        if value['discord'] == discord then
            showccard(deferrals, value)
            return
        end
        if value['ip'] == ip then
            showccard(deferrals, value)
            return
        end
    end
    deferrals.done()
end)


function showccard(deferrals, data)
    print('[' .. data['paspor'] .. '][' .. data['identifier'] .. '] Banned')
    local passwordCard = {
        ["type"] = "AdaptiveCard",
        ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
        ["version"] = "1.5",
        ["body"] = {
            {
                ["type"] = "Image",
                ["url"] = Config.DiscordLogo,
                ["altText"] = 'This UM ADMIN',
                ["horizontalAlignment"] = 'center',
                ["height"] = '100px',
            },
            {
                ["type"] = "Container",
                ["items"] = {
                    {
                        ["type"] = "TextBlock",
                        ["text"] = "UM ADMIN",
                        ["wrap"] = true,
                        ["fontType"] = 'Default',
                        ["size"] = 'ExtraLarge',
                        ["weight"] = 'Bolder',
                        ["color"] = 'Light',
                        ["horizontalAlignment"] = 'Center',
                    },
                    {
                        ["type"] = "TextBlock",
                        ["text"] = data.reason,
                        ["wrap"] = true,
                        ["fontType"] = 'Default',
                        ["size"] = 'medium',
                        ["weight"] = 'Bolder',
                        ["color"] = 'Light',
                        ["horizontalAlignment"] = 'Center',
                    },
                }
            },
        },
    }
    deferrals.presentCard(passwordCard, function(data1, data2) end)
end