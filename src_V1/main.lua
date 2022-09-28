--run code below
local Static = require('Static')

do
    local ed = require('ed25519')
	
	local msg = '1664386204{"application_id":"1015102056647893073","id":"1024734743834673194","token":"aW50ZXJhY3Rpb246MTAyNDczNDc0MzgzNDY3MzE5NDp5VEVweEpVTHo4M2tYUTFVdG1waVVqQnhsTXBDQjdiSW81ZDB4ejZqZ2xSVzNqM0pMeUhnVk1jdk5adElFYlJ2a3ZjeDdqM241ZThkSWRuZGdtTHhFc3dnZkVWU3RzakdOdmgxY3o4RDhvMGRheWt5bFpld0JTbzdOYnplbmdacQ","type":1,"user":{"avatar":"c3d4a5d8dc2b00a24c94c6f90fa94bb8","avatar_decoration":null,"discriminator":"1424","id":"505584960997031947","public_flags":0,"username":"CHL"},"version":1}'

	local sig = '1ff57662aa5cd0252fc694352b49ecc3788c4bb46f13d004cc42887916e20ac1702e3e2088c0ba86fc8e28cc69d32c8f989d232b988155a1d507be0691a67e0a'

    local pk = '451f9f863f5d1cd8d92c74568cc9c0f4641d91bea5803e68dda7f00812f29a2f'
	
    print('got msg: ', msg)
    print('got sig: ', sig)
    print('got pk:', pk)
	
    print(
        'verified (should be false)',
        ed.verify(
            msg,
            ed.hexTo256(sig),
			ed.hexTo256(pk)
		)
	)
	
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
    if Bot.handlePing(req, res) then -- type 1
	print('type 1 met')
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