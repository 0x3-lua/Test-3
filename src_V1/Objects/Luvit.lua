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

local folderExists = Static.os.runBash('if [test -e "luvit"]then\n\techo 1\nelif true then\n\techo 0') == '1'

print(folderExists)

if not folderExists and false then
	Static.os.runBash('mkdir luvit')
end

--[[cd ~/
mkdir luvit
cd luvit
curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh
./lit install SinisterRectus/discordia]]

local Luvit = {}



return Luvit