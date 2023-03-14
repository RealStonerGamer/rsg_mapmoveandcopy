fx_version "cerulean"

games {"rdr3","gta5"}

author 'RealStonerGamer'
description 'mapcopyandmove'
version '1.0'

lua54 'yes'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'


server_scripts {
    "config.lua",
    "server/*.lua",

}

client_scripts {
    "config.lua",
    "client/*.lua",
}
