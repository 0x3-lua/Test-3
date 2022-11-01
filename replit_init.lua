package.path = package.path .. ';./src_V1/?.lua;./src_V1/Objects/?.lua;./src_V1/Objects/?/init.lua'

local Luvit = require('Luvit').install('SinisterRectus/discordia')
local Static = require('Static')

do
	print(Static.table.toString(Luvit))

	 return
end

local path = Static.os.runBash('pwd'):sub(1, -2)

local command = ('RelativePath="%s";cd %s;./luvit %s/init.lua'):format(
	path,
	Luvit.path,
	path
)

io.write(Static.os.runBash(command)) -- possible debugging

