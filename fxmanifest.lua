fx_version "adamant"

games { 'gta5'}
lua54 'yes'

client_scripts {
	'configs/clientConfig.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
	'configs/serverConfig.lua',
    'server/*.lua'
}

dependencies {
    "plouffe_lib"
}

server_exports {
    "AdminSendToJail",
    "AdminRemoveFromJail"
}