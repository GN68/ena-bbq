


avatar:store("color","#21655a")
renderer:setShadowRadius(0.25)
vanilla_model.PLAYER:setVisible(false)

models.model.base.hips.torso.hed.HelmetItemPivot:scale(0.5)
models.model.base.hips.torso.hed.HelmetPivot:scale(0.5)

animations.model.fall:setBlend(0.5):setSpeed(3)


local model = models.model
model:setRot(0,180,0)
