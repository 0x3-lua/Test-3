---@version 5.1

package.path = package.path .. ';./src_V1/?.lua;./src_V1/Objects/?.lua;./src_V1/Objects/?/init.lua'

local Luvit = require('Luvit').install('SinisterRectus/discordia')
local Static = require('Static')

local path = Static.os.runBash('pwd')

local out = 

Static.os.runBash(
	('cd %s./luvit %s/src_V1/main.lua'):format(
        Luvit.path,
		path:sub(1, -2)
	)
)

print(out)

return true;