--run code below
local Static = require('Static')

print(Static.table.toString(package.loaded, nil, 1))
pcall(function ()
	print('inpcall')
	print(require('json'))
end)

Static.luarocks.loadModule('lua-cjson')

print(require('json'))
print(Static.table.toString(package.loaded, nil ,1))

--[[
local WebServer = require('WebServer')
	.new(nil, 3000)
local cURL = require('cURL')
local DiscordBot = require('DiscordBot')
local Bot = DiscordBot.new()


-- sample:
-- let our domain be `https://google.com`

-- client sent http request to home, being `google.com`
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
end)

-- always last step
	.launch()
--]]