--run code below
local Static = require('Static')

-- [[
local WebServer = require('WebServer')
	.new(nil, 3000)
local cURL = require('cURL')
local DiscordBot = require('DiscordBot')
local Bot = DiscordBot.new()

print(
Static.table.toString(
Static.luarocks.loadModule('luasec')))

WebServer.onRequest('/', 'GET', function (client, req, res)
	res.statusCode = 200
	res.statusMessage = 'OK'
	res.headers.connection = 'close'
	res.body = 'Main page'

	print(
		"main", 
		Static.table.toString(req)
	)
end).onInvalidRequest(function (client, req, res)
	res.statusCode = 200
	res.statusMessage = 'OK'
	res.headers.connection = 'close'
	res.body = 'blank'

	print(
		Static.table.toString(req)
	)
end).launch()