local LEFT_HAND = models.model.base.hips.torso.larm
local RIGHT_HAND = models.model.base.hips.torso.rarm

animations.model.lockHands:setPriority(69 --[[ nice ]])

local wasUsingItem = false
events.RENDER:register(function (delta, ctx, matrix)
	if ctx == "RENDER" then
		local isUsingItem = player:isUsingItem()
		if isUsingItem then
			LEFT_HAND:setOffsetRot(vanilla_model.LEFT_ARM:getOriginRot():mul(-1,1,1))
			RIGHT_HAND:setOffsetRot(vanilla_model.RIGHT_ARM:getOriginRot():mul(-1,1,1))
		end
		if wasUsingItem ~= isUsingItem then
			wasUsingItem = isUsingItem
			animations.model.lockHands:setPlaying(isUsingItem)
			if not isUsingItem then
				LEFT_HAND:setOffsetRot()
				RIGHT_HAND:setOffsetRot()
			end
		end
	end
end)