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
    message = [[Today, we're taking a look at the Sniper. Hailing from the lost country of New Zealand and raised in the unforgiving Australian outback, the Sniper is a tough and ready crack shot. The Sniper's main role on the battlefield is to pick off important enemy targets from afar using his Sniper Rifle and its ability to instantly kill a target with a headshot. He is effective at long range, but weakens with proximity, where he is forced to use his Submachine Gun. As a result, the Sniper tends to perch on high grounds or in hard-to-see places, where he can easily pin down enemies at chokepoints. Although he is typically known for instantaneously killing enemies at a distance, the Sniper can use the Huntsman to get closer to the enemy. Additionally, the Sydney Sleeper and the mysterious contents of Jarate allow him to take on a support role by causing enemies to take mini-crits. Now you want to be the Sniper? That's excellent, but also hard, since Team Fortress 2 needs a lot of skills and practice. It will destroy your soul, dreams and your own family. As a Sniper, it might happen that you fight enemy Snipers. But don't worry, it's mostly easy to fight back if you ambush those Snipers from unexpected places. You are most effective at long range, but don't stay at the same spot all the time, keep changing your shooting spots to destroy the most important targets. While you are sniping around, it might happen that a Spy will try to backstab you. Try to look around next time. Or use the Razorback. If you happen to spot an Engineer nest, but can't see the Engineer, shoot the Sentry or another building first, so the Engineer will show himself to repair it. You can finally call yourself a real Sniper. You can shoot people now. Have fun with your great accomplishment.]]
	
    print('msg: ' .. message)
	
	
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