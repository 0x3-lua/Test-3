-- load path
package.path = package.path .. ';./src_V1/?.lua;./src_V1/Objects/?.lua;./src_V1/Objects/?/init.lua'

-- load luvit and discordia

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




local path = '/home/runner/' .. io.popen('echo $REPL_SLUG'):read('*a'):sub(1, -2)

package.path = ('%s;%s/?.lua;%s/src_V1/?.lua;%s/src_V1/Objects/?.lua;/home/runner/luvit/deps/?/init.lua'):format(
	package.path,
	path,
	path,
	path
)

return true;