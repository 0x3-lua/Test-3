--run code below
local Static = require('Static')

-- [[
local WebServer = require('WebServer')
	.new(nil, 3000)
local cURL = require('cURL')
local DiscordBot = require('DiscordBot')

do
	local StringRadix = require('StringRadix')
    local nacl = require('naclModded')
    local secret = ''
	
	for i = 1, 32 do
		secret = secret .. string.char(math.random(256) - 1)
	end

	print(StringRadix.hexdecimal.getDigitSequence(secret:byte(1,32)))

    local public = nacl.scalarmult(secret, nacl.base)
	
	print(StringRadix.hexdecimal.getDigitSequence(public:byte(1,32)))
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