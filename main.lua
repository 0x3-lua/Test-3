-- [pre]
-- assert(require('init'), 'loading initial failed, check file')
package.path = package.path .. ';./src_V1/?.lua;./src_V1/Objects/?.lua;./src_V1/Objects/?/init.lua'

-- [main]
local Static = require('Static')
local discordia = require('discordia')

-- print(Static.table.toString(discordia))
print('done')