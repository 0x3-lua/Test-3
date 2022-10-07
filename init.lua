print'met init'
local initParent = io.popen('echo $RelativePath'):read('*a')
print'finished'
print('met', initParent)
do return end
require('main')