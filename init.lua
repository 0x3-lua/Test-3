local initParent = io.popen('echo $RelativePath'):read('*a')

print('met', initParent)
do return end
require('main')