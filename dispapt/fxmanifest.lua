fx_version 'cerulean'
game 'gta5'

description 'Radio UI for pma-voice with Dispatch System'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/dispatch.css',
    'html/dispatch.js'
}

dependencies {
    'pma-voice'
} 