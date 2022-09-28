---@meta

---@class StopWatch
---@field new fun(): StopWatch.object

---@class StopWatch.object
---@field startingTime number
---@field start fun(): StopWatch.object
---@field lap fun(): number
---@field lapRestart fun(): number()

local StopWatch = {}

---@return StopWatch.object
StopWatch.new = function()
	---@type StopWatch.object
    local object = {}
	
	---@return StopWatch.object
	object.start = function ()
        object.startingTime = os.time()
		return object;
    end
	
	---@return number
	object.lap = function ()return os.time() - object.startingTime;end

	---@return number
	object.lapRestart = function ()
        local result = object.lap()
		
		object.start()

		return result
	end

	return object
end

return StopWatch