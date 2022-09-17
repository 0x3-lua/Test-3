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
			local file = io.open(subName,'r+b')
			if not file then
				--print(subName:byte(1,#subName))
				error(
					(
						'unfound module file: \nfile: %s\nfullname'
							.. ': %s'
					)
					:format(subName, fullName)
				)
			else
				local fileContent = file:read'*a'
				local func = loadstring(fileContent)
				file:close()
				
				if func then
					result = func()
                else
                    local errorMessage = 'error met' or ('unfound file: \nname:'
						..' %s\ncontent: %s')
						:format(
                            fullName,
							fileContent
                        )
                    print 'Met error:'
                    print(func)
					print(loadstring('return "foo"'))
					-- print(errorMessage)
					error(errorMessage)
				end

			end
		else
			result = func()
		end
	end

	return result
end

require('main')

return true;