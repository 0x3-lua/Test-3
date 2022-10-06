--[[spec]]
---@class Luvit
---@field isConstructed boolean
---@field construct fun(targetDirectory): Luvit

--[[code]]

-- pre
local Static = require'Static'

local path = Static.os.runBash('cd ~/;test -d "luvit"||'
    .. ' mkdir luvit;cd luvit;test -e "lit"||curl -L ht'
    .. 'tps://github.com/luvit/lit/raw/master/get-lit.s'
	.. 'h | sh;pwd')

print(path)


local Luvit = {}



return Luvit