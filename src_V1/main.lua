--run code below
local Static = require('Static')

-- [[
local WebServer = require('WebServer')
	.new(nil, 3000)
local cURL = require('cURL')
local DiscordBot = require('DiscordBot')

do
    local bc = require('ByteCollection')
	local a = bc.new()

	local b = function(a)
		print(a:gsub('%x%x',function(b)
			return b .. ','
		end):sub(1,-2))
	end
	
	b(a.toHexString())                                  -- 00
	b(a.add(1).toHexString())                           -- 01
	b(a.add(255).toHexString())                         -- 01,00
	b(a.add(-1).toHexString())                          -- FF
	b(a.add(2).mult(2).toHexString())                   -- 02,02
	b(a.idiv(2).toHexString())                          -- 01,01
	b(a.idiv(2).toHexString())                          -- 80
	a.bitwiseFixedLength = 2                            -- sets length
	b(a.add(-0x80).bitwiseNot().toHexString())          -- 00   -> FF,FF
	b(a.add(-0xFF).bitwiseAnd(0xF0,0xF0).toHexString()) -- FF00 -> F0,00
	b(a.add(0xF00).bitwiseOr(0xF0F0).toHexString())     -- FF00 -> FF,0F
	b(a.add(-0xF0).bitwiseXor(0xF0F0).toHexString())    -- FF00 -> 0F,F0

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