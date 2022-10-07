
local path = '/home/runner/' .. io.popen('echo $REPL_SLUG'):read('*a')

package.path = ('%s;%s/?.lua;%s/src_V1/?.lua;%s/src_V1/Objects/?.lua'):format(
    package.path,
    path,
    path,
	path
)

print(package.path)

-- do return end
require('main')