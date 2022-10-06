--[[spec]]
---@class Luvit
---@field isConstructed boolean
---@field construct fun(targetDirectory): Luvit

--[[code]]

-- pre
local Static = require'Static'

local path = Static.os.runBash('cd ~/\nif !test -d "luvit";then'
    .. ' mkdir luvit;fi;\ncd luvit;curl -L https://github.com/l'
	..'uvit/lit/raw/master/get-lit.sh | sh;pwd')

print(path)


local Luvit = {}



return Luvit