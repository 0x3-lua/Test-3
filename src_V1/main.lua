--run code below
local Static = require('Static')
local StopWatch = require('StopWatch').new()

if true then
    local e = require('ed25519')
    local rad = require('StringRadix')
	StopWatch.start()
    local sk, pk = 
		e.getKeyPair(
			e.hexTo256
            'D764C8CCE93255C4478D7AA05D83F3EAA2B7249B043E23CD2866211BFF3783D6'
        )
	print('lap,',StopWatch.lap())
    print(rad.hexdecimal.getDigitSequence(sk:byte(1, 64)))
	print(rad.hexdecimal.getDigitSequence(pk:byte(1,64)))

	return
elseif true then
    local ed = require('ed25519')
	
	local msg = '1664386204{"application_id":"1015102056647893073","id":"1024734743834673194","token":"aW50ZXJhY3Rpb246MTAyNDczNDc0MzgzNDY3MzE5NDp5VEVweEpVTHo4M2tYUTFVdG1waVVqQnhsTXBDQjdiSW81ZDB4ejZqZ2xSVzNqM0pMeUhnVk1jdk5adElFYlJ2a3ZjeDdqM241ZThkSWRuZGdtTHhFc3dnZkVWU3RzakdOdmgxY3o4RDhvMGRheWt5bFpld0JTbzdOYnplbmdacQ","type":1,"user":{"avatar":"c3d4a5d8dc2b00a24c94c6f90fa94bb8","avatar_decoration":null,"discriminator":"1424","id":"505584960997031947","public_flags":0,"username":"CHL"},"version":1}'

	local sig = 'DA512238E134B8ABE10444BCC7D722936949F6D1868D38106A7BC5C50276B6929BD3A6C28E88E35E0100A50AACF004411C9C3CAC26DFC37B809872DC5D54730C'

    local pk = '883CC7E299900430883B9F3CDF322BB8A500420B410C52AB253C1AD6F1BC6671'
	
    print('got msg: ', msg)
    print('got sig: ', sig)
    print('got pk:', pk)
	
	local last = os.time()

    print(
        'verified (should be true)',
        ed.verify(
            msg,
            ed.hexTo256(sig),
			ed.hexTo256(pk)
		)
    )
	
	print(os.time() - last)
	
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
end).onRequest('/interactions', 'POST', function (_, req, res)
    res.statusCode = 404
	res.statusMessage = 'found none'
    res.headers.connection = 'close'
	res.body = 'found none'

    print('met req')

	StopWatch.start()
	
    if Bot.handlePing(req, res) then -- type 1
        print('type 1 met')
        print(res.toString())
		
		print('got lap', StopWatch.lap())
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