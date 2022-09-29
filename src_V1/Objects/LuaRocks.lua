---@meta

--[[Spec]]

---@class LuaRocks
---@field bashCommand BashCommand.object
---@field load fun(rockName: string): LuaRocks
---@field getLoaded fun(): string[]
---@field isConstructed boolean
---@field integrityCheck fun(): LuaRocks
---@field construct fun(path: string?, cpath: string?): LuaRocks

--[[code]]

local Static = require('Static')

---@type LuaRocks
local LuaRocks = {}
LuaRocks.bashCommand = require('BashCommand').new { command = 'luarocks' }
LuaRocks.isConstructed = false

---@param path string?
---@param cpath string?
---@return LuaRocks
LuaRocks.construct = function(path, cpath)
	-- pre
	assert(not LuaRocks.isConstructed, 'already constructed')
	path = path or '../.luarocks/share/lua/5.1/?.lua;/home/runner/.luarocks/share/lua/5.1/?/init.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;./?.lua;/usr/local/lib/lua/5.1/?.lua;/usr/local/lib/lua/5.1/?/init.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua'

    cpath = cpath or
        '../.luarocks/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/?.so;./?.so;/usr/lib/x86_64-linux-gnu/lua/5.1/?.so;/usr/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
	
    -- main
	LuaRocks.isConstructed = true

	Static.os.runBash('eval "$(luarocks path --bin)"')

	--[[
    package.path = path;
	package.cpath = cpath;
	--]]
	return LuaRocks
end

---checks integrity
---@return LuaRocks
LuaRocks.checkIntegrity = function()
	assert(LuaRocks.isConstructed, 'inconstructed object')

    return LuaRocks
end

---loads a rock
---@param rockName string
---@return LuaRocks
LuaRocks.load = function(rockName)
	-- pre
    LuaRocks.checkIntegrity()
	
	-- main
		.bashCommand.run('install --local ' .. rockName)
	return LuaRocks
end

---returns loaded rocks
---@return string[]
LuaRocks.getLoaded = function()

    local result = {}
	
    local list = LuaRocks.bashCommand.run('list')
	
	print('list, ' .. require('StringParser').parseString(list, {delimStart = '"'}))
	for a in list:gmatch'\10\10([.]+)\10' do
		table.insert(result, a)
	end

	return result
end


return LuaRocks