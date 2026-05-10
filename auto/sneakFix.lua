
local SNAP_FIX = true

local DOWN = vec(0,0.5,0)

-- we have to raycast twice because sublevel rotation gives some offset
local sabelSubLevelOffset = vec(0, 10000, 0)
---@param pos Vector3
---@return Vector3
local function sableSublevelToWorld(pos)
   local pos1 = pos + sabelSubLevelOffset
   local pos2 = pos - sabelSubLevelOffset
   local _, hitPos1 = raycast:block(pos1, pos1)
   local _, hitPos2 = raycast:block(pos2, pos2)
   return (hitPos1 + hitPos2) * 0.5
end

local last_ground_offset = 0
local ground_offset = 0
if SNAP_FIX then
	events.TICK:register(function ()
		last_ground_offset = ground_offset
		local ppos = player:getPos()
		local block, hitpos, side = raycast:block(ppos,ppos - DOWN,"COLLIDER")
		hitpos = sableSublevelToWorld(hitpos)
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

