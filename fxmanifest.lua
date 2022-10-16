fx_version "adamant"

name         'plouffe_jail'
author       'PlouffeLuL'
version      '1.0.0'
repository   'https://github.com/plouffelul/plouffe_jail'
description  'Jail and community services script'

games { 'gta5'}
lua54 'yes'
use_experimental_fxv2_oal 'yes'

client_scripts {
	"client/*.lua"
}

server_scripts {
	'configs/serverConfig.lua',
	'server/*.lua'
}

dependencies {
    "plouffe_lib"
}