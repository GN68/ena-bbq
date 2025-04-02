local CamPivot = require"lib.GSCameraPivot"


local model = models.model
model:setParentType("WORLD"):setRot(0,180,0):setPrimaryRenderType("EMISSIVE_SOLID")

model.base.hips.torso.hed.HelmetItemPivot:scale(0.5)
model.base.hips.torso.hed.HelmetPivot:scale(0.5)

models:addChild(model.base.hips.torso.hed.hat:copy("skull"):setParentType("SKULL"):setPrimaryRenderType("EMISSIVE_SOLID"):pos(0,-48,-0.5):rot(0,180,0):scale(1.9))

renderer:setShadowRadius(0)
vanilla_model.PLAYER:setVisible(false)
avatar:store("color","#21655a")

animations.model.walk:speed(2)


local timer = 999
function A() timer = 100 end -- used to force the player model to update

local lastAnimation ---@type Animation
local currentAnimation ---@type Animation


local function setState(newState)
	if currentAnimation ~= newState then
		
		lastAnimation = currentAnimation
		currentAnimation = newState
		
		if lastAnimation then
			lastAnimation:stop()
		end
		
		if currentAnimation then
			currentAnimation:play()
		end
	end
end


events.RENDER:register(function (delta, ctx, matrix)
	if host:isHost() then
		model:setVisible(ctx ~= "FIRST_PERSON")
	end
end)

local lastSystemTime = client:getSystemTime()
events.WORLD_RENDER:register(function (_)
	if not player:isLoaded() then return end
	local systemTime = client:getSystemTime()
	local delta = (systemTime - lastSystemTime) / 1000
	lastSystemTime = systemTime
	
	timer = timer + delta
	if timer >= 10 then
		timer = 0
		local vel = player:getVelocity()
		local byaw = player:getBodyYaw()
		local lvel = vectors.rotateAroundAxis(byaw, vel, vectors.vec3(0,1,0))
		
		local rot = player:getRot()
		rot.y = ((byaw - rot.y) + 180) % 360 - 180
		
		local walkSpeed = math.abs(lvel.z)
		
		animations.model.walk:speed(lvel.z*11)
		
		if player:isOnGround() then
			if walkSpeed > 0.05 then
				setState(animations.model.walk)
			else
				setState(animations.model.idle2)
			end
		else
			setState(animations.model.jump)
		end
		
		-- tilt
		model
		:setPos(player:getPos()*16)
		:setRot(0,-byaw)
		
		model.base.hips.torso:setRot(rot.x * 0.25,rot.y * 0.25,0)
		model.base.hips.torso.hed:setRot(rot.x * 0.5,rot.y * 0.25,0)
		model.base.hips.torso.hed.eyes.eyesOpened.pupil:setUV(rot.y/-1024,0)
		
		nameplate.ENTITY:setVisible(false)
	end
end)