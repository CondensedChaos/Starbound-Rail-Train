require "/scripts/rect.lua"

function init()
  self.placementRange = config.getParameter("placementRange")
  self.placementBounds = config.getParameter("placementBounds")
  self.platformType = config.getParameter("platformType")
  activeItem.setScriptedAnimationParameter("previewImage", config.getParameter("placementPreviewImage"))
end

function activate(fireMode, shiftHeld)
  local placePos = activeItem.ownerAimPosition()
  if placementValid(placePos) then
    world.spawnVehicle(self.platformType, placePos, {initialFacing = mcontroller.facingDirection()})
    item.consume(1)
  end
end

function update(dt, fireMode, shiftHeld)
  local placePos = activeItem.ownerAimPosition()
  activeItem.setScriptedAnimationParameter("previewPosition", placePos)
  activeItem.setScriptedAnimationParameter("previewValid", placementValid(placePos))

  local aimAngle, aimDirection = activeItem.aimAngleAndDirection(0, placePos)
  activeItem.setFacingDirection(aimDirection)
  activeItem.setScriptedAnimationParameter("facing", aimDirection)
end

function placementValid(pos)
  if world.isTileProtected(pos) then return false end

  if world.magnitude(mcontroller.position(), pos) > self.placementRange then return false end

  if world.lineCollision(mcontroller.position(), pos, {"Null", "Block", "Dynamic"}) then return false end

  local placementRect = rect.translate(self.placementBounds, pos)
  return not world.rectCollision(placementRect, {"Null", "Block", "Dynamic"})
end
