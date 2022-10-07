
print'met init'
local initParent = io.popen('pwd'):read('*a')
print'finished'
print('met', initParent)
do return end
require('main')