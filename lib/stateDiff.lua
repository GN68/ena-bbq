


local StateDiffAPI = {}


---@class StateDiff
---@field onChange fun(state,lastState,...)
---@field state any?
---@field changeChecker fun(state,lastState)?
local StateDiff = {}
StateDiff.__index = StateDiff

---@param inputPreprocess (fun(state): any)?
---@param onChange fun(state,lastState,...)
---@param changeChecker (fun(state,lastState))?
---@return StateDiff
function StateDiffAPI.new(onChange, inputPreprocess,changeChecker)
	local new = {
		preprocess = inputPreprocess,
		onChange = onChange,
		changeChecker = changeChecker
	}
	new = setmetatable(new, StateDiff)
	return new
end

function StateDiff:set(value,...)
	local hasChanged = false
	if self.changeChecker then
		hasChanged = self.changeChecker(value, self.state)
	else
		hasChanged = self.state ~= value
	end
	if hasChanged then
		self.onChange(value,self.state,...)
		self.state = value
	end
end



return StateDiffAPI