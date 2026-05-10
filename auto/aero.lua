if host:isHost() then
	events.WORLD_RENDER:register(function(delta)
		if not player:isLoaded() then return end
		renderer:setCameraRot(((player:getRot(delta).xy_ + vec(0, renderer:isCameraBackwards() and 180 or 0, 0))) *
		vec(renderer:isCameraBackwards() and -1 or 1, 1, 1))
	end)
end
