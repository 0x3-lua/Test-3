-- [pre]
-- assert(require('init'), 'loading initial failed, check file')
package.path = package.path .. ';./src_V1/?.lua;./src_V1/Objects/?.lua;./src_V1/Objects/?/init.lua'

-- [main]
local Static = require('Static')
local Environment = require('Environment')
local discordia = require('discordia')

local client = discordia.Client()


client:run('Bot ' .. Environment.get('DiscordBotToken'))