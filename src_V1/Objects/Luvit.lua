--[[spec]]
---@class Luvit
---@field isConstructed boolean
---@field construct fun(targetDirectory): Luvit

--[[code]]

-- pre
local Static = require'Static'

local path = Static.os.runBash('cd ~/;if !test -d "luvit";then'
	..' mkdir luvit;fi;cd luvit;curl -L https://github.com/luvit/lit/r'
	..'aw/master/get-lit.sh | sh;pwd')

print(path)


local Luvit = {}



return Luvit