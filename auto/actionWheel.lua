
local ARMOR_UPDATE_INTERVAL = 60

local page = action_wheel:newPage()

config:setName(avatar:getName())
local armor = config:load("armor")
if type(armor) == "nil" then
	armor = true
end


local function updateArmor()
	vanilla_model.ARMOR:setVisible(armor)
	vanilla_model.HELMET_ITEM:setVisible(true)
end
updateArmor()

function pings.toggleArmor(toggle)
	armor = toggle
	updateArmor()
end
if not host:isHost() then return end

page:newAction():onToggle(function (state, self)
	config:setName(avatar:getName())
	config:save("armor",state)
	pings.toggleArmor(state)
	updateArmor()
end):toggled(armor):item("minecraft:iron_chestplate")


local updateTimer = ARMOR_UPDATE_INTERVAL
events.WORLD_TICK:register(function ()
	updateTimer = updateTimer - 1
	if updateTimer <= 0 then
		updateTimer = ARMOR_UPDATE_INTERVAL
		pings.toggleArmor(armor)
	end
end)


action_wheel:setPage(page)