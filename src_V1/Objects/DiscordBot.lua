---@class DiscordBot
---@field new fun(apiKey: string?): DiscordBot.bot

---@class DiscordBot.bot
---@field handlePing fun(req: cURL.ClientRequest, res: cURL.ServerResponse): boolean
---@field verifyEd25519 fun(req: cURL.ClientRequest): boolean

---@class cjson
---@field decode fun(s: string): table
---@field encode fun(t: table): string

---@class luazen
---@field x25519_sign_public_key fun(s: string): string

---@class utf8
---@field d fun(s: string) :string

---@type DiscordBot
local DiscordBot = {}

-- deps
local Static = require('Static')
local Environment = require('Environment')

Static.luarocks.loadModule('lua-cjson')
---@type cjson
local json = require('cjson')

--[[
Static.luarocks.loadModule('luazen')
---@type luazen
local luazen = require('luazen')

print(
	'luaz',
	type(
		luazen
)
)
--]]
Static.luarocks.loadModule('utf8')
---@type utf8
local utf8 = require('lua-utf8')

print('ut', Static.table.toString(utf8))


-- main?


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
			print(Static.table.toString(json.decode(req.body)))
		end
		return result
	end

	---verifies interaction
	---@param req cURL.ClientRequest
	---@return boolean
	object.verifyEd25519 = function (req)
		local result = false
		local ed = req.headers['X-Signature-Ed25519']
		local timeStamp = req.headers['X-Signature-Timestamp']
		local body = req.body

		if ed and timeStamp and body then
			
		end

		return result
	end


	return object
end




return DiscordBot