local wasCrouching = false

events.TICK:register(function ()
	local isCrouching = player:isCrouching()
	if wasCrouching ~= isCrouching then
		wasCrouching = isCrouching
		if isCrouching then
			animations.model.crouch:stop():play()
		else
			animations.model.crouch:stop()
		end
	end
end)