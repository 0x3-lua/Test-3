-- spec

---@meta

---@class IntegerWrapper
---@field new fun(n: integer?): IntegerWrapper.object

---@class IntegerWrapper.object
---@field int integer
---@field urn fun(): IntegerWrapper.object
---@field add IntegerWrapper.object.arithmeticFunction
---@field sub IntegerWrapper.object.arithmeticFunction
---@field mult IntegerWrapper.object.arithmeticFunction
---@field idiv IntegerWrapper.object.arithmeticFunction
---@field bAnd IntegerWrapper.object.BitwiseFunction
---@field bOr IntegerWrapper.object.BitwiseFunction
---@field bXor IntegerWrapper.object.BitwiseFunction
---@field bNot fun(isSet: boolean?): IntegerWrapper.object.validInputA
---@field arithRShift fun(iterations: integer?, isSet: boolean?): IntegerWrapper.object.validInputA

---@alias IntegerWrapper.object.validInputA IntegerWrapper.object | integer
---@alias IntegerWrapper.object.arithmeticFunction fun(...: IntegerWrapper.object.validInputA): IntegerWrapper.object
---@alias IntegerWrapper.object.BitwiseFunction fun(arg: IntegerWrapper.object.validInputA, isSet: boolean?): IntegerWrapper.object.validInputA

-- implementation
local IntegerWrapper = {}
local Static = require('Static')

---Integer wrapper
---@param n integer?
---@return IntegerWrapper.object
IntegerWrapper.new = function(n)
	---@type IntegerWrapper.object
    local object
	
	---@param func fun(a: integer, b: integer): integer
	---@return fun(...: IntegerWrapper.object.validInputA) : IntegerWrapper.object
	local function arithmeticFunction(func)
		return function(...)
			for i = 1, select('#', ...) do
				local v = select(i, ...)

				object.int = func(object.int, type(v) == 'table' and v.int or v)
			end

			return object
		end
	end

	---bitwise operation
	---@param func fun(a:integer,b:integer): integer
	---@return fun(a: integer, isSet: boolean?): IntegerWrapper.object.validInputA
	local function bitWiseOperation(func)
		return function (arg, isSet)
            local bitwiseResult = 0
			
			for i = 0, Static.math.getDigits(object.int, 2) do
				bitwiseResult = bitwiseResult + 
                    func(
                        Static.math.getDigit(object.int, 2, i),
						Static.math.getDigit(arg, 2, i)
					) * 2 ^ i
            end

            if isSet then
				object.int = bitwiseResult
                return object
            else
				return bitwiseResult
			end
		end
	end

	object = {
        int = n or 0;

		---self urns
		---@return IntegerWrapper.object
        urn = function()object.int = -object.int return object end;

		---self adds
        add = arithmeticFunction(function (a, b)return a + b;end);
		
		---self subs
		sub = arithmeticFunction(function (a, b)return a - b end);
		
		---self mult
		mult = arithmeticFunction(function (a, b)return a * b;end);
		
		---self divs
        idiv = arithmeticFunction(function(a, b) return math.floor(a / b) end);
		
		---Bitwise And
        bAnd = bitWiseOperation(function(a, b) return a * b; end);
		
		---Bitwise Or
        bOr = bitWiseOperation(function(a, b) return math.min(a + b, 1) end);

		---Bitwise Xor
        bXor = bitWiseOperation(function(a, b) return (a + b) % 2; end);

		---bitwise not
		---@param isSet boolean?
		---@return IntegerWrapper.object.validInputA
		bNot = function (isSet)
            local bitwiseResult = -object.int - 1
			
			if isSet then
				object.int = bitwiseResult
                return object
            else
				return bitwiseResult
			end
		end;

		---arithmetic right shift
		---@param iterations integer?
        ---@param isSet boolean?
		---@return IntegerWrapper.object.validInputA
        arithRShift = function(iterations, isSet)
			local old = object.int
			
			for i = 1, iterations do
                local isNegative = object.int < 0

				if isNegative then
					object.int = math.abs(object.int)
                end
				
                object.idiv(2)
				
				if isNegative then
					object.add(2 ^ 31)
				end
			end
			
			if isSet then
				return object
            else
                local result = object.int
                object.int = old
				return result
			end
		end
	}
	
	return object
end

return IntegerWrapper