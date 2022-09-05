---@class DiscordBot
---@field new fun(apiKey: string?): DiscordBot.bot

---@class DiscordBot.bot
---@field verifyEd25519 fun(req: cURL.ClientRequest): boolean

---@type DiscordBot
local DiscordBot = {}
local Environment = require('Environment')

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

	---verifies interaction
	---@param req cURL.ClientRequest
	---@return boolean
	object.verifyEd25519 = function (req)
		local result = false
		local ed = req.headers['X-Signature-Ed25519']
		local timeStamp = req.headers['X-Signature-Timestamp']
		local body = req

		return result
	end


	return object
end




return DiscordBot