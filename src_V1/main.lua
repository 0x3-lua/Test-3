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
end).onRequest('/keepalive', 'GET', function (_,_,res)
    res.statusCode = 200;
	res.statusMessage = 'OK'
    res.headers.connection = 'close'
    res.body = 'got ping'
	print('pong')
end).onInvalidRequest(function (_, req, res)
	res.statusCode = 404
	res.statusMessage = 'found none'
	res.headers.connection = 'close'
	res.body = 'found none'

	print(
		Static.table.toString(req)
	)

end).launch()
    .keepAlive('https://Test-3.0x2.repl.co/keepalive', function()
	print('met pre')
        local result = not cURL.get('https://paste.ee/p/7TDya').body:find('404')
	
	print(result)
	return result
end)

print(Static.coroutine.iterationsPerSecond)