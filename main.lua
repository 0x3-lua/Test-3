-- [pre]
assert(require('init'), 'loading initial failed, check ')

-- [main]

local Static = require('Static')
local discordia = require('discordia')

print(Static.table.toString(discordia))

-- post
-- return true