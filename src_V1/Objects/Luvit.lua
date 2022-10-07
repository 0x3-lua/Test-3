--[[spec]]
---@class Luvit
---@field path string
---@field install fun(name: string): Luvit

--[[code]]

-- pre
---@type Luvit
local Luvit = {}
local Static = require'Static'

Luvit.path = Static.os.runBash('cd ~/;test -d "luvit"&&'
    .. 'rm -R luvit;mkdir luvit;cd luvit;test -e "lit"|'
    .. '|curl -L https://github.com/luvit/lit/raw/maste'
	.. 'r/get-lit.sh | sh;pwd')

Luvit.install = function(s)
	local command = ('cd %stest -e "deps"&&rm -R deps;./lit install %s;')
		:format(
			Luvit.path,
			s
		)
	Static.os.runBash(command)

	return Luvit
end

return Luvit