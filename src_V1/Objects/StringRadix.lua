---@meta

---@class StringRadix
---@field new fun(hashMap: {[integer]: string}, decimal: string?): StringRadix.object
---@field binary StringRadix.object
---@field hexdecimal StringRadix.object

---@class StringRadix.object
---@field mantissaLimit integer
---@field getNumericalValue fun(...: string): number
---@field getDigitSequence fun(...: number): string

---@type StringRadix
local StringRadix = {}
local Static = require'Static'
local Radix = require('Radix')

function StringRadix.new(hashMap, decimal)
	-- pre
	assert(type(hashMap) == 'table')
	for i, v in next, hashMap do
		assert(type(i) == 'number' and type(v) == 'string')
	end
	
	
	local object = {}
	local objectRadix = Radix.new(hashMap, decimal)
	
	function object.getNumericalValue(...)
		-- pre
		local args = {...}
		
		for i, v in next, args do
			assert(type(v) == 'string')
			
			args[i] = Static.string.split(v, '')
		end
		-- main
		
		return objectRadix.getNumericalValue(unpack(args))
	end
	
	function object.getDigitSequence(...)
		local collection = {objectRadix.getDigitSequence(...)}
		
		for i, v in next, collection do
			collection[i] = table.concat(v)
		end
		
		return unpack(collection)
	end
	
	return object
end

StringRadix.binary = StringRadix.new({[0] = '0','1'})

local temp = Static.string.split('0123456789ABCDEF', '')
temp[0] = table.remove(temp, 1)

StringRadix.hexdecimal = StringRadix.new(temp)

return StringRadix