local Event = require("lib.event")
local model = models.model
model:setRot(0,180,0)


local extraEvents = {
	SHADER_CHANGED = Event.new()
}

local wasShader = false
events.TICK:register(function ()
	local isShader = client:hasShaderPack()
	if wasShader ~= isShader then
		wasShader = isShader
		extraEvents.SHADER_CHANGED:invoke(isShader and client:getShaderPackName() or nil)
	end
end)


return extraEvents