require "/scripts/rails.lua"
require "/scripts/util.lua"

function init()
  message.setHandler("positionTileDamaged", function()
      if not world.isTileProtected(mcontroller.position()) then
        popVehicle()
      end
    end)

  mcontroller.setRotation(0)

  local railConfig = config.getParameter("railConfig", {})
  railConfig.facing = config.getParameter("initialFacing", 1)

  self.railRider = Rails.createRider(railConfig)
  self.railRider:init(storage.railStateData)

  self.popOnInteract = config.getParameter("popOnInteract", true)
  self.facingDirection = self.railRider.facing
  
  self.onRail = false
  self.volumeAdjustTimer = 0
  self.volumeAdjustTime = 0.1  
  self.wasOnRail = false
  
  self.railMaterial = self.railRider:checkTile(mcontroller.position())
  
end


function update(dt)
  if mcontroller.atWorldLimit() then
    vehicle.destroy()
    return
  end

  if mcontroller.isColliding() then
	popVehicle()
  else
  
  self.railMaterial = self.railRider:checkTile(mcontroller.position())
  operateDoors()
  
	  local dirVector = self.railRider:dirVector()
	  local railMat = self.railRider:checkTile(mcontroller.position()) 
	  if self.railRider.speed < 2 and dirVector[2] >= 0 and self.railRider.useGravity and railMat ~= "metamaterial:railbooster" then
	    self.railRider.speed = 3
		self.railRider.useGravity = false
	  end
	  
	  if self.railRider.useGravity == false and (dirVector[2] < 0 or railMat == "metamaterial:railbooster") then
	    self.railRider.useGravity = true
	  end

  
    self.railRider:update(dt)
    if self.wasOnRail == false and self.railRider:onRail() then self.wasOnRail = true end
	storage.railStateData = self.railRider:stateData()
	
	local volumeAdjustment = math.max(0.5, math.min(1, self.railRider.speed / 20))
	if self.railRider:onRail() and self.railRider.speed > 0.01 and self.railRider.moving then
	  
	  if self.onRail == false then
	    self.onRail = true
	    animator.playSound("grind", -1)
        animator.setSoundVolume("grind", volumeAdjustment, 0)
	  end
	  
	  self.volumeAdjustTimer = math.max(0, self.volumeAdjustTimer - dt)
      if self.volumeAdjustTimer == 0 then
        animator.setSoundVolume("grind", volumeAdjustment, self.volumeAdjustTime)
        self.volumeAdjustTimer = self.volumeAdjustTime
      end
	else
	  self.onRail = false
	  animator.stopAllSounds("grind")
	end
  end

  	local vel = vec2.norm(mcontroller.velocity())
	local moveRotation = math.atan(vel[2], vel[1])
	if vel[1] ~= 0 or vel[2] ~= 0 then
	  self.railMaterial = self.railRider:checkTile(mcontroller.position())
	  checkrotation(moveRotation)
	end

	
end

function operateDoors()
  if self.railMaterial == "metamaterial:railstop" and not self.doorOperating then
    self.doorOperating = true
	animator.setAnimationState("rail", "opening")
  elseif self.railMaterial ~= "metamaterial:railstop" and self.doorOperating then
    animator.setAnimationState("rail", "closing")
	self.doorOperating = false
  end
end

function checkrotation(moving)
     self.facingDirection = self.railRider.facing
     if self.facingDirection > 0 and self.railMaterial ~= "metamaterial:railreverse" then
		  animator.rotateGroup("platform", moving)
     elseif self.railMaterial ~= "metamaterial:railreverse" then
		  animator.rotateGroup("platform", moving + 3.1459)
     end
end

function uninit()
  self.railRider:uninit()
end

function popVehicle()
  local popItem = config.getParameter("popItem")
  if popItem then
    world.spawnItem(popItem, entity.position(), 1)
  end
  vehicle.destroy()
end
