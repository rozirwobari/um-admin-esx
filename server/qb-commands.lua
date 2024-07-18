local ESX = exports["es_extended"]:getSharedObject()

RegisterCommand(Config.OpenMenu, function(source, args, user)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Function.HasPermission(xPlayer.group) then
        TriggerClientEvent('um-admin:client:openMenu', source)
    end
end, false)

RegisterServerEvent('um-admin:server:announce')
AddEventHandler('um-admin:server:announce', function(data)
    local msg = data[3]
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Function.HasPermission(xPlayer.group) then
        if msg ~= '' then
            TriggerClientEvent('chat:addMessage', -1, {
                color = { 255, 0, 0 },
                multiline = true,
                args = { "Announcement", msg }
            })
        end
    end
end)

RegisterServerEvent('um-admin:server:kickall')
AddEventHandler('um-admin:server:kickall', function(data)
    local reason = data[3]
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Function.HasPermission(xPlayer.group) then
        for _, PlayerId in pairs(GetPlayers()) do
            local xTarget = ESX.GetPlayerFromId(PlayerId)
            if xTarget ~= nil and xTarget.group == 'user' then
                DropPlayer(xTarget.source, reason ~= '' and reason or 'KOTA SEDANG TERJADI BADAI')
            end
        end
    end
end)

RegisterServerEvent('um-admin:server:setmodelself')
AddEventHandler('um-admin:server:setmodelself', function(data)
    local src = data[4] or source
    local xPlayer = ESX.GetPlayerFromId(src)
    if Config.Function.HasPermission(xPlayer.group) then
        local model = data[3]
        if model ~= nil or model ~= '' then
            TriggerClientEvent('um-admin:client:setmodelself', xPlayer.source, tostring(model))
        else
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                title = 'Admin Menu',
                description = "Anda tidak mengatur model.",
                type = 'error',
                duration = 5000,
                style = {
                    borderRadius = "13px",
                }
            })
        end
    end
end)