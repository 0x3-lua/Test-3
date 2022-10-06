---@meta

--[[Spec]]

---@class LuaRocks
---@field bashCommand BashCommand.object
---@field isConstructed boolean
---@field parser StringParser.object
---@field load fun(rockName: string): boolean
---@field getLoaded fun(): string[]
---@field integrityCheck fun(): LuaRocks
---@field construct fun(path: string?, cpath: string?): LuaRocks

---@class LuaRocks.rockspec
---@field package string
---@field version string

--[[code]]

local Static = require('Static')
local StringParser = require('StringParser')

---@type LuaRocks
local LuaRocks = {}
LuaRocks.bashCommand = require('BashCommand').new { command = 'luarocks' }
LuaRocks.isConstructed = false
LuaRocks.parser = StringParser.new('')

---@param path string?
---@param cpath string?
---@return LuaRocks
LuaRocks.construct = function(path, cpath)
    -- pre
	if LuaRocks.isConstructed then return LuaRocks;end
    -- assert(not LuaRocks.isConstructed, 'already constructed')
	path = path or Static.os.runBash'luarocks path --lr-path'
    cpath = cpath or Static.os.runBash'luarocks path --lr-cpath'
	
    -- main
	LuaRocks.isConstructed = true

    package.path = package.path .. ';' .. path;
	package.cpath = package.path .. ';' .. cpath
	
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
---@return boolean
LuaRocks.load = function(rockName)
	-- pre
    local loaded = LuaRocks.checkIntegrity()
		.getLoaded()[rockName]
	
	if loaded then return true end

    -- main
    LuaRocks.bashCommand.run('install --local ' .. rockName)
	
	return not not LuaRocks.getLoaded()[rockName]
end

---returns loaded rocks
---@return {[string]: LuaRocks.rockspec}
LuaRocks.getLoaded = function()
    local result = {}
	local parser = LuaRocks.parser.reset(LuaRocks.bashCommand.run('list'))
	
	parser.pop(36)

	while not parser.atEnd() do
        local rockName = parser.popUntil('\10   ', true)
        assert(rockName)
        local version = parser.popUntil(' ')
		assert(version)
		---@type LuaRocks.rockspec
        local struct = {
            package = rockName;
			version = version;
        }
		
		-- idk what to use this for, its gonna stay here
		if parser.cPop('(installed) ', true) then
			local _;
        end

		parser.popUntil('\10\10', true)
		
		result[rockName] = struct
	end


	return result
end


return LuaRocks