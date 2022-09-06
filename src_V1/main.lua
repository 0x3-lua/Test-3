--run code below
local Static = require('Static')
-- local WebServerV3 = require('WebServerV3')
Static.luarocks.loadModule('pegasus')
local pegasus = require 'pegasus'

local server = pegasus:new({
  port='8080',
  location='example/root'
})

server:start(function (request, response)
	print "It's running..."
  
  print(Static.table.toString(request), Static.table.toString(response))
end)

--[[
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
--]]