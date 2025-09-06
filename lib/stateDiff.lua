


local StateDiffAPI = {}


---@class StateDiff
---@field preprocess (fun(state): any)?
---@field onChange fun(state,lastState,...)
---@field state any?
---@field lastState any?
local StateDiff = {}
StateDiff.__index = StateDiff

---@param inputPreprocess (fun(state): any)?
---@param onChange fun(state,lastState,...)
---@return StateDiff
function StateDiffAPI.new(onChange, inputPreprocess)
	local new = {
		preprocess = inputPreprocess,
		onChange = onChange
	}
	new = setmetatable(new, StateDiff)
	return new
end

function StateDiff:set(value,...)
	self.state = self.preprocess and self.preprocess(value) or value
	if self.lastState ~= self.state then
		self.onChange(self.state, self.lastState,...)
		self.lastState = self.state
	end
end



return StateDiffAPI