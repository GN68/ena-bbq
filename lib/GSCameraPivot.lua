-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Camera Pivot Library" <GSCameraPivot>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- Adds the ability to conditionally attach the player's camera to specific model parts.
--
-- This library is fully documented. If you use Sumneko's Lua Language server, you will get
-- descriptions of each function, method, and field in this library.

local ID = "GSCameraPoint"
local VER = "1.0.0"
local FIG = {"0.1.4", "0.1.5"}


-- Lua globals
local error = error
local getmetatable = getmetatable
local setmetatable = setmetatable
local type = type

-- Math
local math = math
local m_atan2 = math.atan2
local m_asin = math.asin

-- Figura globals
local renderer = renderer

-- Vectors
local v_vec3 = vectors.vec3

-- Matrices
local mat_t4 = matrices.translate4

-- Constants
local VEC3_ZERO = v_vec3()


---This library allows the user to conditionally attach the player camera to a specific model part.
---
---The camera will follow the part's position and rotation.
---
---To begin using this library, create a camera object with `<Lib>.newCamera()`.  
---Then assign that camera as active with `<Lib>.setActiveCamera()`.
---@class Lib.GS.CameraPivot
---This library's perferred ID.
---@field _ID string
---This library's version.
---@field _VERSION string
---Enables error checking in the library. `true` by default.
---
---Turning off error checking will greatly reduce the amount of instructions used by this library
---at the cost of not telling you when you put in a wrong value.
---
---If an error pops up while this is `false`, try setting it to `true` and see if a different
---error pops up.
---@field safe boolean
---@field package _activeCamera? Lib.GS.CameraPivot.PivotPoint
local this = {safe = true}
local thismt = {
  __type = ID,
  __metatable = false,
  __index = {
    _ID = ID,
    _VERSION = VER
  }
}


---@class Lib.GS.CameraPivot.PivotPoint
---@field part ModelPart
---@field offset Vector3
---@field noroll boolean
---@field fpmhide boolean | ModelPart
---@field package _fpmhidden boolean
local AttachPoint = {}
local AttachPointMT = {__index = AttachPoint}

---Gets the part this camera point follows.
---@return ModelPart
function AttachPoint:getPart() return self.part end

---Gets the position offset of this camera point.
---@return Vector3
function AttachPoint:getOffset() return self.offset:copy() end

---Gets whether this camera point ignores rolling angles.
---@return boolean
function AttachPoint:getNoRoll() return self.noroll end

---Gets whether this camera point hides the model part it is attached to while in first-person.
---
---If this function returns a model part, that part is being hidden instead.
---@return boolean | ModelPart
function AttachPoint:getFpmHide() return self.fpmhide end

---Sets the part this camera point follows.
---@generic self
---@param self self
---@param part ModelPart
---@return self
function AttachPoint:setPart(part)
  ---@cast self Lib.GS.CameraPivot.PivotPoint
  if this.safe then
    if getmetatable(self) ~= AttachPointMT then
      error(("bad argument #1 to 'setPart' (AttachPoint expected, got %s)"):format(type(self)))
    elseif type(part) ~= "ModelPart" then
      error(("bad argument #2 to 'setPart' (Animation expected, got %s)"):format(type(part)))
    end
  end

  if self._fpmhidden and self.fpmhide then
    if self.fpmhide == true then
      self.part:setVisible(true)
    else
      self.fpmhide:setVisible(true)
    end
  end
  self._fpmhidden = false

  self.part = part
  return self
end

---Sets the position offset of this camera point.
---@generic self
---@param self self
---@param vec? Vector3
---@return self
function AttachPoint:setOffset(vec)
  ---@cast self Lib.GS.CameraPivot.PivotPoint
  if this.safe then
    if getmetatable(self) ~= AttachPointMT then
      error(("bad argument #1 to 'setOffset' (AttachPoint expected, got %s)"):format(type(self)))
    elseif vec ~= nil and type(vec) ~= "Vector3" then
      error(("bad argument #2 to 'setOffset' (Vector3 expected, got %s)"):format(type(vec)))
    end
  end

  self.offset = vec and vec:copy() or VEC3_ZERO
  return self
end

---Sets whether this camera point ignores rolling angles.
---@generic self
---@param self self
---@param state? boolean
---@return self
function AttachPoint:setNoRoll(state)
  ---@cast self Lib.GS.CameraPivot.PivotPoint
  if this.safe then
    if getmetatable(self) ~= AttachPointMT then
      error(("bad argument #1 to 'setOffset' (AttachPoint expected, got %s)"):format(type(self)))
    end
  end

  self.noroll = not not state
  return self
end

---Sets whether this camera point hides a part in first person.
---
---If a model part is given, that specific part is hidden instead of the part that this camera point is attached to.
---@generic self
---@param self self
---@param hide? boolean | ModelPart
---@return self
function AttachPoint:setFpmHide(hide)
  ---@cast self Lib.GS.CameraPivot.PivotPoint
  if this.safe then
    if getmetatable(self) ~= AttachPointMT then
      error(("bad argument #1 to 'setOffset' (AttachPoint expected, got %s)"):format(type(self)))
    elseif hide ~= nil and type(hide) ~= "boolean" and type(hide) ~= "ModelPart" then
      error(("bad argument #2 to 'setOffset' (boolean or ModelPart expected, got %s)"):format(type(hide)))
    end
  end

  if hide ~= self.fpmhide then
    if self._fpmhidden and self.fpmhide then
      if self.fpmhide == true then
        self.part:setVisible(true)
      else
        self.fpmhide:setVisible(true)
      end
    end
    self._fpmhidden = false
  end

  self.fpmhide = hide ~= nil and hide or false
  return self
end


---Creates a new camera point attached to `part`.
---
---`offset` is how far from the pivot the camera should be,  
---`noroll` determines if the camera should not roll, (Note that some extreme rotations may still need to roll to
---work properly!)  
---`fpmhide` has two modes: if set to `true`, the model part `part` is hidden when in first person. If set to a model
---part, that model part is hidden when in first person.
---@param part ModelPart
---@param offset? Vector3
---@param noroll? boolean
---@param fpmhide? boolean | ModelPart
---@return Lib.GS.CameraPivot.PivotPoint
function this.newCamera(part, offset, noroll, fpmhide)
  local o = setmetatable({}, AttachPointMT)
  return o:setPart(part):setOffset(offset):setNoRoll(noroll):setFpmHide(fpmhide)
end

---Sets the active camera point.
---
---If given `nil`, the camera is detached and restored to its default position.
---@param cam? Lib.GS.CameraPivot.PivotPoint
function this.setActiveCamera(cam)
  local active_cam = this._activeCamera
  if cam == active_cam then return end

  local fpmhide = active_cam and active_cam.fpmhide
  if fpmhide and active_cam._fpmhidden then
    (type(fpmhide) == "ModelPart" and fpmhide or active_cam.part):setVisible(true)
    active_cam._fpmhidden = false
  end

  if cam == nil then renderer:offsetCameraPivot():offsetCameraRot() end
  this._activeCamera = cam
end


if host:isHost() then
  local bad_parents = {
    Hud = true, Camera = true,
    Skull = true, Portrait = true,
    Arrow = true, Trident = true, Item = true
  }
  local fp_context = {FIRST_PERSON = true, OTHER = true}

  events.RENDER:register(function(dt, ctx)
    local active_cam = this._activeCamera
    if not active_cam then return end

    local org_part = active_cam.part
    local part = org_part
    local is_world = false

    -- Only hide/unhide the target part if necessary. This is used to determine if the part needs to be unhidden later.
    local fpmhide = active_cam.fpmhide
    if fpmhide then
      local fpmhide_part = type(fpmhide) == "ModelPart" and fpmhide or part
      if renderer:isFirstPerson() and fp_context[ctx] then
        if not active_cam._fpmhidden and fpmhide_part:getVisible() then
          fpmhide_part:setVisible(false)
          active_cam._fpmhidden = true
        end
      elseif not fpmhide_part:getVisible() then
        fpmhide_part:setVisible(true)
        active_cam._fpmhidden = false
      end
    end

    -- Get matrix stack down to model root.
    local mat = mat_t4(part:getPivot())
    while part do
      mat:multiply(part:getPositionMatrix())
      local ptype = part:getParentType()
      if bad_parents[ptype] then
        error(
          ("The camera attached to '%s' is inside of '%s' which has an unsupported parent type '%s'"):format(
            org_part:getName(), part:getName(), ptype
          )
        )
      elseif part:getParentType() == "World" then
        is_world = true
        break
      end
      part = part:getParent()
    end

    -- Create rotation from matrix.
    local rot = v_vec3(
      0,--m_asin(mat.v23),
      0,--m_atan2(-mat.v13, mat.v33),
      active_cam.noroll and 0 or m_atan2(-mat.v21, mat.v22)
    ):toDeg()

    -- Create position from matrix.
    local scale = is_world and (1 / 16) or (math.playerScale / 16)
    if not is_world then mat:rotateY(-player:getBodyYaw(dt)) end

    local pos = mat
      :apply(active_cam.offset) -- Difference between the head pivot and the eye position.
      :scale(scale)
      :mul(1, 1, 1)
      :sub(0, 0, 0)

    renderer:offsetCameraPivot(pos):offsetCameraRot(rot)
  end)
end


return setmetatable(this, thismt)
