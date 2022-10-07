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
	Static.os.runBash(
		('cd %stest -e "deps"&&rm -R deps;./lit install %s;')
		:format(
			Luvit.path,
			s
		)
	)

	return Luvit
end

return Luvit