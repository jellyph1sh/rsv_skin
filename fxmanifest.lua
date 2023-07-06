fx_version "cerulean"
game "gta5"

version "1.0"
description "Customize your character's appearance."
author "JellyPh1sh"

client_scripts {
    -- UI:
    "ui/RageUI.lua",
    "ui/uuid.lua",
    "ui/menu/*.lua",
    "ui/menu/functions/**/*.lua",
    "client/*.lua"
}

server_scripts {
    "server/*.lua"
}

shared_scripts {
    "shared/*.lua"
}