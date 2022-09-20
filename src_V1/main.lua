--run code below
local Static = require('Static')

do
	local StringRadix = require('StringRadix')
    local ed = require('ed25519')
	Static.luarocks.loadModule('base64')
	local base64 = require('base64')

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
	
    -- used https://ed25519.herokuapp.com/ for testing
	
    local seed = ed.getRandomString()
	
	print('attempting keypair: \nseed')
    getHexd(seed)
	local sk, pk = ed.getKeyPair(seed)

	--print(Static.table.toString({sk:byte(1, #sk)}))
	--print(Static.table.toString({pk:byte(1, #pk)}))

    print('secret key')
    getHexd(sk)
	print(base64.encode(sk))

    print('public key')
    getHexd(pk)
    print(base64.encode(pk))
	
    do return end
	
	print('attempting signing')

    local message = "robert" -- someone wanted to name bytecollection this so now its here
	
    print('got message: ', message)

	local signature = ed.getSignature(sk, message)

	print('got signature: ', signature)
	
	
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