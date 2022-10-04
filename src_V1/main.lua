--[[run code below]]
local Static = require('Static')
local DiscordBot = require('DiscordBot')
local Bot = DiscordBot.new() -- argument optional if environment variable `DiscordBotToken` is correctly set

	.setRequestCallback(function(_, req, res)
	res.headers.connection = 'close'
	if req.webPage == '/' then
		res.body = 'home'
		res.statusCode = 200;
		res.statusMessage = 'ok'
		return;
	end

	

	print('met', Static.table.toString(req))
end)


	.run() -- last step