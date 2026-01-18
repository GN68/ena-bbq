if not host:isHost() then
	models.firstPerson:setVisible(false)
	return
end
local StateDiff = require("lib.stateDiff")
local extraEvents = require("lib.extraEvents")

---@type Minecraft.itemID[]
local GUI_ITEMS = {
	"minecraft:trident",
	"minecraft:shield"
}

local model = models.firstPerson
model:setParentType("HUD")

---@param a ItemStack
---@param b ItemStack
local function changeItemCheck(a,b)
	if (not b) or (not a) then return true end
	return a.id ~= b.id
end

extraEvents.SHADER_CHANGED:register(function (shader)
	if shader then model:setPrimaryRenderType("TRANSLUCENT")
	else model:setPrimaryRenderType("CUTOUT_EMISSIVE_SOLID") end
end)
local rightItemDisplay = model.base.right.rightPivot.rightItem:newItem("RightItem"):item("air"):scale(0.2):light(15,15)
local rightHandState = StateDiff.new(function (state, lastState, ...)
	if state.id ~= "minecraft:air" then
		rightItemDisplay:item(state)
		if state:isBlockItem() then
			rightItemDisplay:scale(0.15)
		else
			rightItemDisplay:scale(0.2)
		end
		animations.firstPerson.rightOn:stop():play()
		animations.firstPerson.rightOff:stop()
	else
		animations.firstPerson.rightOn:stop()
		animations.firstPerson.rightOff:stop():play()
	end
	
	local shouldGUI = false
	for _, id in pairs(GUI_ITEMS) do
		if state.id == id then
			shouldGUI = true
			break
		end
	end
	rightItemDisplay:setDisplayMode(shouldGUI and "GUI" or "NONE")
end,nil,changeItemCheck)

local leftItemDisplay = model.base.left.leftPivot.leftItem:newItem("LeftItem"):item("air"):scale(0.2):light(15,15)
local leftHandState = StateDiff.new(function (state, lastState, ...)
	if state.id ~= "minecraft:air" then
		leftItemDisplay:item(state)
		if state:isBlockItem() then
			leftItemDisplay:scale(0.15)
		else
			leftItemDisplay:scale(0.2)
		end
		animations.firstPerson.leftOn:stop():play()
		animations.firstPerson.leftOff:stop()
	else
		animations.firstPerson.leftOn:stop()
		animations.firstPerson.leftOff:stop():play()
	end
	local shouldGUI = false
	for _, id in pairs(GUI_ITEMS) do
		if state.id == id then
			shouldGUI = true
			break
		end
	end
	leftItemDisplay:setDisplayMode(shouldGUI and "GUI" or "NONE")
end,nil,changeItemCheck)

local airItem = world.newItem("minecraft:air")




local lspeed, speed = 0,0
events.TICK:register(function ()
	
	
	local vel = player:getVelocity()
	lspeed = speed
	speed = vel.xz:length()
	local mainItem = player:getHeldItem()
	local offHandItem = player:getHeldItem(true)
	
	if player:isLeftHanded() then
		mainItem, offHandItem = offHandItem, mainItem
	end
	
	vanilla_model.HELD_ITEMS:setVisible(true)
	
	
	
	if mainItem.id == "minecraft:filled_map" then
		vanilla_model.RIGHT_ITEM:setVisible(true)
		mainItem = airItem
	end
	if offHandItem.id == "minecraft:filled_map" then
		vanilla_model.LEFT_ITEM:setVisible(true)
		offHandItem = airItem
	end
	
	rightHandState:set(mainItem)
	leftHandState:set(offHandItem)
end)


animations.firstPerson.idle:play():speed(0.75)

local firstPerson = true
events.WORLD_RENDER:register(function (delta)
	
	local tspeed = math.min(math.lerp(lspeed,speed,delta), 1)
	local time = client:getSystemTime()/1000
	
	local size = client:getScaledWindowSize()
	
	model
	:setPos((size).xy_:mul(-0.5,-1))
	:setScale(size.yyy*0.1)
	
	model.base:setPos(math.sin(time*6)*tspeed*2,math.cos(time*11)*tspeed,0)
	model:setVisible(firstPerson)
	firstPerson = false
end)

events.RENDER:register(function (delta, ctx)
	if ctx == "FIRST_PERSON" then
		firstPerson = true
	end
end)