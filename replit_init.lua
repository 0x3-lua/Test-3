---@version 5.1

package.path = package.path .. ';./src_V1/?.lua;./src_V1/Objects/?.lua;./src_V1/Objects/?/init.lua'

local Luvit = require('Luvit').install('SinisterRectus/discordia')
local Static = require('Static')

local path = Static.os.runBash('pwd')

local out = Static.os.runBash(
	('RelativePath="%s"cd %s./luvit %s/init.lua'):format(
		path,
        Luvit.path,
		path:sub(1, -2)
	)
)

print(out)

