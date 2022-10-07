--[[spec]]
---@class Luvit
---@field path string
---@field install fun(name: string): Luvit

--[[code]]

-- pre
---@type Luvit
local Luvit = {}
local Static = require'Static'

Luvit.path = Static.os.runBash('cd ~/;test -d "luvit"||'
	.. ' mkdir luvit;cd luvit;test -e "lit"||curl -L ht'
	.. 'tps://github.com/luvit/lit/raw/master/get-lit.s'
	.. 'h | sh;pwd')

Luvit.install = function(s)
	local command = ('cd %stest -e "deps"&&rm -R deps;./lit install %s;')
		:format(
			Luvit.path,
			s
		)
	Static.os.runBash(command)

	print(command)

	return Luvit
end

return Luvit