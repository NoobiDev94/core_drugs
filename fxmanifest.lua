
fx_version 'adamant'

game 'gta5'

ui_page 'html/form.html'

files {
	'html/form.html',
	'html/css.css',
	'html/script.js',
	'html/jquery-3.4.1.min.js',
	'html/img/*.png',
}

client_scripts{
    "@vrp/lib/utils.lua",
    'config.lua',
    'client/main.lua',
   
}

server_scripts{
    "@vrp/lib/utils.lua",
    'config.lua',
    'server/main.lua',
    'TriggerItems.lua'

}