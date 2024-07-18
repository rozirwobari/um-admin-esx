fx_version 'cerulean'
game 'gta5'
description 'UM-Admin'
version '1.3.0'

ui_page 'web/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'checker/*.lua',
    'logs/*.lua'
}

files {
    'config.js',
    'web/index.html',
    'web/assets/js/*.js',
    'web/assets/css/*.css',
    'web/assets/img/*.png',
    'web/assets/img/*.jpg'
}

lua54 'yes'