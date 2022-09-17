--run code below
local Static = require('Static')

do
	local StringRadix = require('StringRadix')
    local nacl = require('nacl')
    local secret = '3TQlyPJUmdKG2b3YVdyzbRn17O0YDrJQn2qBTrc7Oth+RSrxvkij3aoKrKL0QQMll/Spdyt3a3/h3eVtYQOWKg=='

	Static.luarocks.loadModule('base64')

    local base64 = require('base64')
	print('secret')
	secret = base64.decode(secret)

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
	
	-- for i = 1, 64 do secret = secret .. string.char(math.random(256) - 1)end

    getHexd(secret)
	
	local test = secret:sub(1, 32)
	local test2 = secret:sub(33)

	print'test'
	getHexd(test)
    print('test2')
    getHexd(test2)
	
    local public = nacl.scalarmult(test, nacl.base)
	--[[
	Static.luarocks.loadModule'luaec25519'
    local curve = require 'luaec25519'
	if curve then
		print('got curve, ')
        local publicC = curve.public_key(secret)
		getHexd(publicC)
	end
	--]]
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