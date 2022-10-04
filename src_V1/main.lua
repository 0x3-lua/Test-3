--[[run code below]]
local Static = require('Static')
local DiscordBot = require('DiscordBot')
local Bot = DiscordBot.new() -- argument optional if environment variable `DiscordBotToken` is correctly set

Bot.run()

print(Static.table.toString(Bot.user))