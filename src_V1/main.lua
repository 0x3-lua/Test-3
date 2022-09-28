--run code below
local Static = require('Static')
local WebServer = require('WebServer')
	.new(nil, 3000)
local cURL = require('cURL')
local DiscordBot = require('DiscordBot')

local Bot = DiscordBot.new()


WebServer.onRequest('/', 'GET', function (_, _, res)
	res.statusCode = 200
	res.statusMessage = 'OK'
	res.headers.connection = 'close'
	res.body = 'Main page'
end).onRequest('/interactions', 'POST', function (_, req, res)
    res.statusCode = 404
	res.statusMessage = 'found none'
    res.headers.connection = 'close'
	res.body = 'found none'

	if Bot.handlePing(req, res) then -- type 1
		return
    end
	print('non ping:', Static.table.toString(req))
end).onInvalidRequest(function (_, req, res)
	res.statusCode = 404
	res.statusMessage = 'found none'
	res.headers.connection = 'close'
	res.body = 'found none'

	print(
		Static.table.toString(req)
	)

end).launch()
--]]