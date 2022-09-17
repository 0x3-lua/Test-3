--run code below
local Static = require('Static')

do
	local StringRadix = require('StringRadix')
    local nacl = require('nacl')

	-- local secret = ''

	Static.luarocks.loadModule('base64')


	---@param s string
    local function getHexd(s)
		assert(type(s) == 'string')
        local digits = { StringRadix.hexdecimal.getDigitSequence(s:byte(1, #s)) }
		
		for i = 1, #s do
            local v = digits[i]
			
			if #v == 1 then
				digits[i] = '0' .. v
			end
        end
		
		print(table.concat(digits))
	end
	
    local seed = nacl.getRandomString()

	print(Static.table.toString({[0] = 1; 2}))

	print('seed')
    getHexd(seed)
	local skp, pk = nacl.getKeyPair(seed)

	print('secret key prefix')
	getHexd(skp)

    print('public key')
	getHexd(pk)
	
	
	return
end

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