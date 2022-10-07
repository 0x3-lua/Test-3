
print'met init'
local initParent = '/home/runner/' .. io.popen('echo $REPL_SLUG'):read('*a')
print'finished'
print('met', initParent)
do return end
require('main')