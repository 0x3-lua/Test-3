--[[spec]]
---@class Luvit
---@field isConstructed boolean
---@field construct fun(targetDirectory): Luvit

--[[code]]

-- pre
local Static = require'Static'

-- install check for luvit existance
local current = Static.os.runBash('pwd')
Static.os.runBash('cd ~/')

print("|"..Static.os.runBash('cd luvit')..'|')



--[[cd ~/
mkdir luvit
cd luvit
curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh
./lit install SinisterRectus/discordia]]

local Luvit = {}



return Luvit