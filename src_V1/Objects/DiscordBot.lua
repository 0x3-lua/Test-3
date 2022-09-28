---@class DiscordBot
---@field new fun(apiKey: string?): DiscordBot.bot

---@class DiscordBot.bot
---@field handlePing fun(req: cURL.ClientRequest, res: cURL.ServerResponse): boolean
---@field verifyEd25519 fun(req: cURL.ClientRequest): boolean

---@class cjson
---@field decode fun(s: string): table
---@field encode fun(t: table): string

-- -@class utf8
-- -@field d fun(s: string) :string

---@type DiscordBot
local DiscordBot = {}

-- deps
local Static = require('Static')
local Environment = require('Environment')
local Enum        = require('Enum')

Static.luarocks.loadModule('lua-cjson')
---@type cjson
local json = require('cjson')
local ed25519 = require('ed25519')
local StringRadix = require('StringRadix')

local interactionUA = 'Discord-Interactions/1.0 (+https://discord.com)'

---returns bot
---@param apiKey string? default is an Environment variable named "DiscordBotAPIKey"
---@return DiscordBot.bot
DiscordBot.new = function(apiKey)
	-- pre
	apiKey = assert(
		apiKey or Environment.get('DiscordBotAPIKey'),
		'No api key'
	)

	-- main
	---@type DiscordBot.bot
	local object = {}

	---handles discord interaction "ping"
	---@param req cURL.ClientRequest
	---@param res cURL.ServerResponse
	---@return boolean
	object.handlePing = function (req, res)
		local result = false

		if req.headers['User-Agent'] == interactionUA then
			local body = json.decode(req.body)
			
			if body.type == 1 then
		   		-- print(Static.table.toString(json.decode(req.body)))
				local edVerified = object.verifyEd25519(req)
				
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

	---verifies interaction
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


	return object
end




return DiscordBot