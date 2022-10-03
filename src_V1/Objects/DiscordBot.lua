---@meta

--[[spec]]

---@class DiscordBot
---@field new fun(apiKey: string?): DiscordBot.bot

---@class DiscordBot.bot
---@field endPoint cURL.object
---@field webServer WebServer.object
-- -@field handlePing fun(req: cURL.ClientRequest, res: cURL.ServerResponse): boolean
-- -@field verifyEd25519 fun(req: cURL.ClientRequest): boolean
---@field run fun()

---@class cjson
---@field decode fun(s: string): table
---@field encode fun(t: table): string

-- -@class utf8
-- -@field d fun(s: string) :string

--[[code]]

---@type DiscordBot
local DiscordBot = {}

-- deps
local Static = require('Static')
local Environment = require('Environment')
local Enum = require('Enum')
local cURL = require('cURL')

--[[
require('LuaRocks').construct()
    .load('lua-cjson')

-- -@type cjson
local json = require('cjson')
local ed25519 = require('ed25519')
--]]

---returns bot
---@param apiKey string? default is an Environment variable named "DiscordBotAPIKey"
---@param version integer? versioning of the api end point
---@return DiscordBot.bot
DiscordBot.new = function(apiKey, version)
	-- pre
    apiKey = assert(apiKey or Environment.get('DiscordBotToken'),
        'No api key, give argument or provide environment of index `DiscordBotToken` a valid token')
	version = version or 8

	-- main
	---@type DiscordBot.bot
    local object = {}

    local basicHeaders = {
        Authorization = apiKey;
        ['User-Agent'] = 'DiscordBot (Custom Bot Test)';
		['X-RateLimit-Precision'] = 'millisecond'
	}
	
	object.endPoint = cURL.bind(('https://discord.com/api/v%d'):format(version))

    --[[

		 require('WebServer')
    .new(nil, 3000)
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

end).keepAlive()
	.launch()
	
	]]

--
	
	---Runs the discord bot, this function should be called as the last step
    object.run = function()
        print(
			object.endPoint.get('/users/@me', nil, basicHeaders)
		)
	end


	return object
end

-- dead stuff that someone might use, idk 

	--[[
    ---handles discord interaction "ping"
	---@deprecated
	---@param req cURL.ClientRequest
	---@param res cURL.ServerResponse
	---@return boolean
	object.handlePing = function (req, res)
		local result = false

		if req.headers['User-Agent'] == interactionUA then
			local body = json.decode(req.body)
			
			if body.type == 1 then
		   		-- print(Static.table.toString(json.decode(req.body)))
				local edVerified ;-- = object.verifyEd25519(req)
				
				res.statusCode = edVerified and 200 or 401
				res.statusMessage = edVerified and 'OK' or 'invalid request signature'
                res.body = edVerified and '{"type":1}' or 'Bad Signature'
				
				if edVerified then
					res.headers['Content-Type'] = Enum.mimeTypes.json
				end

				result = true
			end
			
		end
		return result
	end

    ---verifies interaction, deprecated for being too slow
	---@deprecated
	---@param req cURL.ClientRequest
	---@return boolean
	object.verifyEd25519 = function (req)
		local result = false
		local edSig = req.headers['X-Signature-Ed25519']
		---@cast edSig string
		local timeStamp = req.headers['X-Signature-Timestamp']
		local body = req.body

        if edSig and timeStamp and body then
            print('|||got body')
			print(timeStamp .. body)
			print('||endbody')
            print('got sig: ', edSig)
			print('got apikey: ', apiKey)

			result = ed25519.verify(
					timeStamp .. body,
					ed25519.hexTo256(edSig),
					ed25519.hexTo256(apiKey)
            )
				print('ed verified: ', result)
		end

		return result
	end

	--]]


return DiscordBot