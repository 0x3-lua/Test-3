--run code below
local Static = require('Static')

-- [[
local WebServer = require('WebServer')
	.new(nil, 3000)
local cURL = require('cURL')
local DiscordBot = require('DiscordBot')

print(Static.table.toString(Static.luarocks.loadModule('kong-plugin-paseto')))

local Bot = DiscordBot.new()


-- print(loadstring(cURL.get('https://raw.githubusercontent.com/philanc/luazen/master/src/x25519.c').body))

WebServer.onRequest('/', 'GET', function (_, _, res)
	res.statusCode = 200
	res.statusMessage = 'OK'
	res.headers.connection = 'close'
	res.body = 'Main page'
end).onInvalidRequest(function (_, req, res)
	res.statusCode = 200
	res.statusMessage = 'OK'
	res.headers.connection = 'close'
	res.body = 'blank'

	print(
		Static.table.toString(req)
	)

	Bot.handlePing(req, res)
end).launch()
--]]