
local StateDiff = require("lib.stateDiff")



local model = models.model


local timer = 999
function A() timer = 100 end -- used to force the player model to update

---@param state Animation?
---@param lastState Animation?
local animator = StateDiff.new(function (state, lastState)
	if state then
		state:play()
	end
	if lastState then
		lastState:stop()
	end
end)


local groundState = StateDiff.new(function (state, lastState, ...)
	if state then
		animations.model.fall:stop():play()
	end
end)


animations.model.breathing:setBlend(0.5)
animations.model.swingArm:overrideRot(true)

events.TICK:register(function ()
	if player:getSwingTime() == 1 then
		if player:getSwingArm() == "MAIN_HAND" then
			animations.model.swingArm:stop():play()
		else
			animations.model.swingArm2:stop():play()
		end
	end
end)

local lastSystemTime = client:getSystemTime()
models.model.midRender = function (_)
	if not player:isLoaded() then return end
	local systemTime = client:getSystemTime()
	local df = (systemTime - lastSystemTime) / 1000
	lastSystemTime = systemTime
	
	local vel = player:getVelocity()
	local byaw = player:getBodyYaw()
	local lvel = vectors.rotateAroundAxis(byaw, vel, vectors.vec3(0,1,0))
	
	local rot = player:getRot()
	rot.y = ((byaw - rot.y) + 180) % 360 - 180
	
	
	local isOnGround = player:isOnGround()
	local vehicle = player:getVehicle()
	
	
	if vehicle then
		animations.model.breathing:play()
		local type = vehicle:getType()
		if type == "minecraft:minecart" then
			animator:set(animations.model.sitMinecart)
		else
			animator:set(animations.model.sitHorse)
		end
	else
		if player:isClimbing() and not isOnGround then
			animations.model.breathing:play()
			animations.model.climb:setSpeed(lvel.y*7)
			animator:set(animations.model.climb)
		else
			animations.model.breathing:stop()
			groundState:set(isOnGround)
			if isOnGround then
				if math.abs(lvel.z) > 0.05 then
					if player:isSprinting() then
						animations.model.run:speed(lvel.z*9)
						animator:set(animations.model.run)
					else
						animations.model.walk:speed(lvel.z*11)
						animator:set(animations.model.walk)
					end
				else
					animator:set(animations.model.pose)
				end
			else
				if player:isInWater() then
					if player:isSprinting() then
						animator:set(animations.model.swimSprint)
					else
						animator:set(animations.model.swimLegs)
					end
				else
					animator:set(animations.model.jump)
				end
			end
		end
	end
	
	timer = timer + df
	if timer >= 0.25 then
		timer = 0
		
		-- tilt
		
		model.base.hips.torso:setRot(rot.x * 0.25,rot.y * 0.25,0)
		model.base.hips.torso.hed:setRot(rot.x * 0.5,rot.y * 0.25,0)
		model.base.hips.torso.hed.eyes.eyesOpened.pupil:setUV(rot.y/-1024,0)
		
		-- fly tilt
		if not isOnGround then
			local swing = math.clamp(lvel.z,-1,1)*45
			model.base.rleg:setRot(swing,0,0)
			model.base.lleg:setRot(swing,0,0)
			model.base.hips.torso.rarm:setRot(0,-swing,0)
			model.base.hips.torso.larm:setRot(0,swing,0)
			
		else
			model.base.rleg:setRot(0,0,0)
			model.base.lleg:setRot(0,0,0)
			model.base.hips.torso.rarm:setRot(0,0,0)
			model.base.hips.torso.larm:setRot(0,0,0)
		end
	end
end

