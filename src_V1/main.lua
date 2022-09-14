--run code below
local Static = require('Static')

do
	local StringRadix = require('StringRadix')
    local nacl = require('naclModded')
    local secret = ''

	---@param s string
	local function getHexd(s)
        local digits = { StringRadix.hexdecimal.getDigitSequence(s:byte(1, 32)) }
		
		for i = 1, 32 do
            local v = digits[i]
			
			if #v == 1 then
				digits[i] = '0' .. v
			end
        end
		
		print(table.concat(digits))
	end
	
	for i = 1, 32 do
		secret = secret .. string.char(math.random(256) - 1)
	end

	getHexd(secret)

    local public = nacl.scalarmult(secret, nacl.base)
	
	Static.luarocks.loadModule'luaec25519'
    local curve = require 'luaec25519'
	if curve then
		print('got curve, ')
        local publicC = curve.public_key(secret)
		getHexd(publicC)
	end

	print('public modded')
    getHexd(public)
	
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