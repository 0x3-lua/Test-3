--[[spec]]
---@class Luvit
---@field path string
---@field install fun(name: string): Luvit

--[[code]]

-- pre
---@type Luvit
local Luvit = {}
local Static = require'Static'

local output = Static.os.runBash('cd ~/;test -d "luvit"&&'
    .. 'rm -R luvit;mkdir luvit;cd luvit;test -e "lit"|'
    .. '|curl -L https://github.com/luvit/lit/raw/maste'
	.. 'r/get-lit.sh | sh;pwd')
local lineSplit = Static.string.split(output, '\n')
Luvit.path = lineSplit[#lineSplit - 1]

Luvit.install = function(s)
	print('met')
	local command = ('cd %s;test -e "deps"&&rm -R deps;./lit install %s;')
		:format(
			Luvit.path,
			s
        )
		print('met2')
	Static.os.runBash(command)

	return Luvit
end

return Luvit