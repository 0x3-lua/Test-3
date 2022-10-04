--[[run code below]]
local Static = require('Static')
local DiscordBot = require('DiscordBot')
local Bot = DiscordBot.new() -- argument optional if environment variable `DiscordBotToken` is correctly set

.setRequestCallback(function (c, req, res)
	print('met', Static.table.toString(req))
end)


.run() -- last step