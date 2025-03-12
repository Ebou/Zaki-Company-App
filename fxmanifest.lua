fx_version "cerulean"
game "gta5"
lua54 'yes'
title "Zaki Company App"
description "A template for creating apps for the LB Phone."
author "Breze & Loaf"

client_script "client.lua"
server_script "server.lua"
shared_scripts {
    '@ox_lib/init.lua',
    "config.lua",
}
files {
    "ui/**/*"
}

ui_page "ui/index.html"
escrow_ignore "config.lua"