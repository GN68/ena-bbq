
local SNAP_FIX = true

local DOWN = vec(0,0.5,0)

local last_ground_offset = 0
local ground_offset = 0
if SNAP_FIX then
	events.TICK:register(function ()
		last_ground_offset = ground_offset
		local ppos = player:getPos()
		local block, hitpos, side = raycast:block(ppos,ppos - DOWN,"COLLIDER")
		ground_offset = (hitpos.y-ppos.y) * 16
		if ground_offset < -0.49 * 16 then
			ground_offset = 0
		end
	end)
end

events.RENDER:register(function (delta, ctx, matrix)
	if ctx == "RENDER" then
		local offset = (player:isCrouching() and 2.14 or 0) + math.lerp(last_ground_offset, ground_offset, delta)
		
		models.model:setPos(0,offset,0)
	end
end)

