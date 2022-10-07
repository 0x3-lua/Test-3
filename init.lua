
local path = '/home/runner/' .. io.popen('echo $REPL_SLUG'):read('*a'):sub(1, -2)

package.path = ('%s;%s/?.lua;%s/src_V1/?.lua;%s/src_V1/Objects/?.lua;/home/runner/luvit/deps/?/init.lua'):format(
	package.path,
	path,
	path,
	path
)

require('main')