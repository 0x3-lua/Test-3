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
	
	print('attempting signing')

    local message = "CHL WAS HERE" -- someone wanted to name bytecollection this so now its here
	
    print('got message: ', message)

	local signature = ed.getSignature(message, sk)

    print('got signature: ')
	getHexd(signature)

    print 'got verification of false sig'
    print(ed.verify(
        message,
        base64.decode('P9uLwTRjNVC6tAwB+Bo/ouqPVJNOMLUCKXoCM+cpAkHMhkwnoS7hq64ksfBUM2yLKYGqG4TChxljSTWD2qbUCQ=='),
        pk
	))
	
    print('got verification of false message')
    print(ed.verify('foo', signature, pk))

	print('got verification of false pk')
    print(ed.verify(message, signature, ed.getRandomString(32)))

	print('got verification of true set')
    print(ed.verify(message, signature, pk))
	
    print('test 2')
    message = [[I need a double cheeseburger and hold the lettuce
Don't be frontin' son no seeds on the bun
We be up in this drive thru
Order for two
I gots a craving for a number nine like my shoe
We need some chicken up in here
In this hizzle
For rizzle my mizzle
Extra salt on the frizzle
Dr. Pepper my brother
Another for your mother
Double double super size
And don't forget the fries.]]
	
    print('msg: ' .. message)

    signature = ed.getSignature(message, sk)
	print('sig:', signature)
	
	
    print 'got verification of false sig'
    print(ed.verify(
        message,
        base64.decode('LacDwEY4rPnEt3Nkvg/Lg9FaIp4rRkcLHTj1vVT87YJCvyG7xoaN8AMuBa747Oa3Zgjz7vm4pge/3YBhmsTeAw=='),
        pk
	))
	
    print('got verification of false message')
    print(ed.verify('foo', signature, pk))

	print('got verification of false pk')
    print(ed.verify(message, signature, ed.getRandomString(32)))

	print('got verification of true set')
    print(ed.verify(message, signature, pk))
	

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