--run code below
local Static = require('Static')

-- [[
local WebServer = require('WebServer')
	.new(nil, 3000)
local cURL = require('cURL')
local DiscordBot = require('DiscordBot')

do
    Static.luarocks.loadModule('luaec25519')
	Static.luarocks.loadModule('base64')

	---@type encoder
    local b64 = require('base64')
    ---@type curve25519
    local curve255519 = require('luaec25519')
    print(Static.table.toString(curve255519))
	
	local secretKey = curve255519.randombytes(32)
    print('s:', b64.encode(secretKey))
    local publicKey = curve255519.public_key(secretKey)
	print('P', #publicKey, b64.encode(publicKey))


	return
end





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