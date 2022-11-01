package.path = package.path .. ';./src_V1/?.lua;./src_V1/Objects/?.lua;./src_V1/Objects/?/init.lua'

require('Luvit').install('SinisterRectus/discordia')
local Static = require('Static')


io.write(Static.os.runBash('./luvit ./main.lua;pause')) -- possible debugging

