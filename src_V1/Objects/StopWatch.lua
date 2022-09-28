---@class StopWatch
---@field new fun(): StopWatch.object

---@class StopWatch.object
---@field startingTime number
---@field start fun(): StopWatch.object
---@field lap fun(): number

local StopWatch = {}

---@return StopWatch.object
StopWatch.new = function()
	---@type StopWatch.object
    local object = {}
	
	object.start = function ()
        object.startingTime = os.time()
		return object;
    end
	
	object.lap = function ()return os.time() - object.startingTime;end

	return object
end

return StopWatch