--run code below
local Static = require('Static')

-- [[
local WebServer = require('WebServer')
	.new(nil, 3000)
local cURL = require('cURL')
local DiscordBot = require('DiscordBot')

do
    print(Static.table.toString(Static.luarocks.loadModule('luatweetnacl')))
    pcall(
		function ()
			print(Static.table.toString(require('luatweetnacl')))
			
		end
	)
	pcall(
		function ()
			print(Static.table.toString(require('nacl')))
			
		end
	)
	return
end





local Bot = DiscordBot.new()


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