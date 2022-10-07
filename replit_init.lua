---@version 5.1

package.path = package.path .. ';./src_V1/?.lua;./src_V1/Objects/?.lua;./src_V1/Objects/?/init.lua'

local Luvit = require('Luvit').install('SinisterRectus/discordia')
local Static = require('Static')

local path = Static.os.runBash('pwd')

local command = ('RelativePath="%s";cd %s./luvit %s/init.lua'):format(
	path:sub(1,-2),
	Luvit.path,
	path:sub(1, -2)
)

local out = Static.os.runBash(command)

print(command, out)

