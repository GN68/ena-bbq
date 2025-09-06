local extraEvents = require("lib.extraEvents")

models:setPrimaryRenderType("EMISSIVE_SOLID")

extraEvents.SHADER_CHANGED:register(function (name)
	models:setPrimaryRenderType(name and "CUTOUT_CULL" or "EMISSIVE_SOLID")
end)