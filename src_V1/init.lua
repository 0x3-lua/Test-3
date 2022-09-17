---@version 5.1

-- modified require
local overridenRequire = require

---overriden Require, can be better
---@param mod string
require = function(mod)
	local result

	local fullName = io.popen(
			('find -name \'%s.lua\''):format(mod)
		):read '*a'
		
	if not fullName or #fullName == 0 then
		result = overridenRequire(mod)
	else
		local subName = fullName:sub(1, -2)
		local func = loadfile(subName)

		if not func then
			error('possible parsing error, please check: ' .. subName)
		else
			result = func()
		end
	end

	return result
end

require('main')

return true;