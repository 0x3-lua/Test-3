--[[spec]]
---@class Luvit
---@field isConstructed boolean
---@field construct fun(targetDirectory): Luvit

--[[code]]

-- pre
local Static = require'Static'

local path = Static.os.runBash('cd ~/;test -d "luvit"||'
    .. ' mkdir luvit;cd luvit;curl -L https://github.com/l'
	.. 'uvit/lit/raw/master/get-lit.sh | sh;pwd')

print(path)


local Luvit = {}



return Luvit