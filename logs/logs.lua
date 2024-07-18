local ESX = exports["es_extended"]:getSharedObject()
local function postWebHook(name, title, color, message, tagEveryone)
    local tag = tagEveryone or false
    local webHook = Config.WebHookDiscord[name] or Config.WebHookDiscord['default']
    local embedData = {
        {
            ['title'] = title,
            ['color'] = Config.WebHookColor[color] or Config.WebHookColor['default'],
            ['footer'] = {
                ['text'] = os.date('%c'),
            },
            ['description'] = message,
            ['author'] = {
                ['name'] = 'UM - Admin [Logs]',
                ['icon_url'] = Config.DiscordLogo,
            },
        }
    }
    PerformHttpRequest(webHook, function() end, 'POST', json.encode({ username = 'UM - Admin [Logs]', embeds = embedData}), { ['Content-Type'] = 'application/json' })
    Wait(100)
    if tag then
        PerformHttpRequest(webHook, function() end, 'POST', json.encode({ username = 'UM - Admin [Logs]', content = '@everyone'}), { ['Content-Type'] = 'application/json' })
    end
end

RegisterNetEvent('um-admin:log:minPage', function(webhook,event,color)
    local src = source
    postWebHook(webhook,event.." used",color,"**---------------------------------------------------------------**".."\n **ID:** `[" ..src.. "]`".."\n **CID:** `"..xPlayer.identifier.. "`".. "\n **Player Name:** `"..GetPlayerName(src).. "`".. "\n **Discord:** " .."`"..(GetPlayerIdentifierByType(src, "discord") or 'undefined').."`".. "\n **Steam: **".."`"..(GetPlayerIdentifierByType(src, "steam") or 'undefined').."`".. "\n **License: **".."`"..(GetPlayerIdentifierByType(src, "license") or 'undefined').."`")
    Wait(100)
end)

RegisterNetEvent('um-admin:log:playersEvent', function(src,webhook,event,color,targetPlayer)
    local src = src
    local xPlayer = ESX.GetPlayerFromId(src)
    local xTarget = ESX.GetPlayerFromId(targetPlayer)
    local everyone = false
    if webhook == 'ban' or webhook == 'cheater' then everyone = true end
    postWebHook(webhook,event,color,"**---------------------------------------------------------------**".."\n **[Admin]** \n \n **ID:** `[" ..src.. "]`".."\n **CID:** `"..xPlayer.identifier.. "`".. "\n **Player Name:** `"..GetPlayerName(src).. "`".. "\n **Discord:** " .."`"..(GetPlayerIdentifierByType(src, "discord") or 'undefined').."`".. "\n **Steam: **".."`"..(GetPlayerIdentifierByType(src, "steam") or 'undefined').."`".. "\n **License: **".."`"..(GetPlayerIdentifierByType(src, "license") or 'undefined').."`".."\n **---------------------------------------------------------------**".."\n **[Target]** \n \n **ID:** `[" ..targetPlayer.. "]`".."\n **CID:** `"..xTarget.identifier.. "`".. "\n **Player Name:** `"..GetPlayerName(xTarget.source).. "`".. "\n **Discord:** " .."`"..(GetPlayerIdentifierByType(xTarget.source, "discord") or 'undefined').."`".. "\n **Steam: **".."`"..(GetPlayerIdentifierByType(xTarget.source, "steam") or 'undefined').."`".. "\n **License: **".."`"..(GetPlayerIdentifierByType(xTarget.source, "license") or 'undefined').."`", everyone)
    Wait(100)
end)
