local CamPivot = require"lib.GSCameraPivot"


local model = models.model
model:setRot(0,180,0):setPrimaryRenderType("EMISSIVE_SOLID")

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

local idleTimer = 0
local lookTimer = 5
local idlelook = vec(0,0)
local isIdle = false
local delta = 0

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

local lastSystemTime = client:getSystemTime()
events.WORLD_RENDER:register(function (_)
	if not player:isLoaded() then return end
	local systemTime = client:getSystemTime()
	local df = (systemTime - lastSystemTime) / 1000
	lastSystemTime = systemTime
	
	timer = timer + df
	delta = delta + df
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
				isIdle = false
				setState(animations.model.walk)
				idleTimer = 0
				lookTimer = 5
			else
				idleTimer = idleTimer - delta
				lookTimer = lookTimer - delta
				if lookTimer < 0 then
					lookTimer = math.random(3,15)
					idlelook = vec(math.random() * 2 - 1,math.random() * 2 - 1)
				end
				if idleTimer < 0 then
					idleTimer = math.random(5,20)
					local i = "idle"..(isIdle and math.random(1,4) or 1)
					setState(animations.model[i])
					isIdle = true
				end
			end
		else
			idleTimer = 0
			lookTimer = 5
			isIdle = false
			setState(animations.model.jump)
		end
		
		-- tilt

		if isIdle then
			rot.y = rot.y + idlelook.y * 90
			rot.x = rot.x + idlelook.x * 45
		end
		
		model.base.hips.torso:setRot(rot.x * 0.25,rot.y * 0.25,0)
		model.base.hips.torso.hed:setRot(rot.x * 0.5,rot.y * 0.25,0)
		model.base.hips.torso.hed.eyes.eyesOpened.pupil:setUV(rot.y/-1024,0)
		delta = 0
	end
end)

nameplate.ENTITY
:setBackgroundColor(0,0,0,0)
:setOutline(true)
nameplate.ALL:setText("${badges} ${name}")
