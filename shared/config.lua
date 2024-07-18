Config = {}
Config.Function = {}
Config.OpenMenu = "admin"
Config.DiscordLogo = 'https://cdn.discordapp.com/attachments/781483089264115712/1067103262089695232/logo_kopya.png'
Config.WebHookDiscord = {
    --- Self
    ['noclip'] = '',
    ['godmode'] = '',
    ['vehicle'] = '',
    ['revive'] = '',
    ['invisible'] = '',
    ['other'] = '',

    --- Players
    ["kill"] = '',
    ["revivep"] = '',
    ["freeze"]= '',
    ["spectate"]= '',
    ["gotobring"]= '',
    ["intovehicle"]= '',
    ["inventory"]= '',
    ["clothing"]= '',
    ["perms"] = '',
    ["givemoney"] = '',
    ["setmodel"] = '',

    --- Ban or Kick or Cheater
    ['kick'] = '',
    ['ban'] = '',
    ['cheater'] = '',

}
Config.WebHookColor = { -- https://www.spycolor.com/
    ['default'] = 14423100,
    ['blue'] = 255,
    ['red'] = 16711680,
    ['green'] = 65280,
    ['white'] = 16777215,
    ['black'] = 0,
    ['orange'] = 16744192,
    ['yellow'] = 16776960,
    ['pink'] = 16761035,
    ["lightgreen"] = 65309,
}
Config.Wardrobe = 'illenium-appearance'
Config.Cloth = { -- skin menus
    ['renzu_clothes'] = function()
        exports.renzu_clothes:OpenClotheInventory()
    end,
    ['fivem-appearance'] = function()
        return exports['fivem-appearance']:startPlayerCustomization() -- you could replace this with outfits events
    end,
    ['illenium-appearance'] = function()
        return TriggerEvent('illenium-appearance:client:openOutfitMenu')
    end,
    ['qb-clothing'] = function()
        return TriggerEvent('qb-clothing:client:openOutfitMenu')
    end,
    ['esx_skin'] = function()
        TriggerEvent('esx_skin:openSaveableMenu')
    end,
}
Config.HasPermission = {
    ['admin'] = true,
    ['superadmin'] = true,
    ['mod'] = true,
    ['user'] = false,
}
Config.DiscordInvite = 'https://discord.gg/z9z3Z8y'
Config.Function.HasPermission = function(permission)
    if Config.HasPermission[permission] then
        return true
    else
        return false
    end
end

Config.Function.Round = function (value, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(value * mult + 0.5) / mult
end