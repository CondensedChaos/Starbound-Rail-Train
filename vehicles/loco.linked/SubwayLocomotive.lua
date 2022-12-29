require "/scripts/rails.lua"
require "/scripts/util.lua"

function init()
  sb.logInfo("\nInit() of car " .. tostring(storage.carNumber) .. " begin")
  message.setHandler("positionTileDamaged", function()
      if not world.isTileProtected(mcontroller.position()) then
        destroyVehicle()
      end
    end)

  mcontroller.setRotation(0)
  

  local railConfig = config.getParameter("railConfig", {})
  railConfig.facing = config.getParameter("initialFacing", 1)

  self.railRider = Rails.createRider(railConfig)
  sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " init() function called Rails.createRider(railConfig)")
  self.railRider:init(storage.railStateData)
  sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " init() function called self.railRider:init(storage.railStateData)")
  
  self.onRail = false
  self.volumeAdjustTimer = 0
  self.volumeAdjustTime = 0.1  
  self.speedWasSet = false
  
  storage.numberOfCars = config.getParameter("numberOfCars")
  storage.carNumber = config.getParameter("carNumber")
  storage.lastCar = config.getParameter("lastCar")
  storage.firstCar = config.getParameter("firstCar")
  storage.parentCarEid = config.getParameter("parentCarEid")
  storage.childCarDistance = config.getParameter("carDistance")
  storage.spawnedCarOffsetX = config.getParameter("spawnedCarOffsetX")
  storage.spawnedCarOffsetY = config.getParameter("spawnedCarOffsetY")
  self.imgPath = config.getParameter("imgPath")
  storage.color = config.getParameter("color")
  storage.livery = config.getParameter("livery")
  storage.reversed = config.getParameter("reversed")
  storage.trainsetData = config.getParameter("trainsetData")
  storage.pantographVisible = config.getParameter("pantograph")
  storage.doorLocked = config.getParameter("doorLocked")
  
  storage.decalsTable = config.getParameter("decals")
  
  if storage.trainsetData then
    storage.color = tostring(storage.trainsetData[storage.carNumber][2])
	storage.livery = tostring(storage.trainsetData[storage.carNumber][3])
	storage.pantographVisible = storage.trainsetData[storage.carNumber][4]
	storage.doorLocked = storage.trainsetData[storage.carNumber][5]
  end
  
  animator.setPartTag("bodyColor", "partImage", tostring(self.imgPath) .. tostring(storage.color) .. ".png")
  animator.setPartTag("liveryColor", "partImage", tostring(self.imgPath) .. "Livery" .. tostring(storage.livery) .. ".png")
  
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " carDistance " .. tostring(storage.childCarDistance))
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " numberOfCars " .. tostring(storage.numberOfCars))
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " carNumber " .. tostring(storage.carNumber))
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " lastCar " .. tostring(storage.lastCar))
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " firstCar " .. tostring(storage.firstCar))
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " parentCarEid " .. tostring(storage.parentCarEid))
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " spawnedCarOffsetX " .. tostring(storage.spawnedCarOffsetX)) 
 
  --animator.setFlipped(self.railRider.facing < 0)
  self.oldfacing = self.railRider.facing
  if self.railRider.facing <0 then
	if not storage.reversed then animator.scaleTransformationGroup("flip", {-1, 1}) end
  else
	if storage.reversed then animator.scaleTransformationGroup("flip", {-1, 1}) end
  end
	
  if storage.pantographVisible then
    animator.setAnimationState("pantograph", "visible")
  else
	animator.setAnimationState("pantograph", "hidden")
  end
  
  self.timerdt = 0
  self.displayspeedtimer = 0
  
  if storage.carNumber > 1 then
    vehicle.setPersistent(false)
	sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " not persistent set")
  end

  
  --self.railMaterial = self.railRider:checkTile(mcontroller.position())

  if (not storage.oldTrainSet) and (not storage.lastCar) then
    sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " init() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
	storage.oldTrainSet = false
    self.childCar = spawnCarNumber(storage.carNumber + 1)
  end
  if storage.oldTrainSet then
    sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " init() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
    self.childCar = nil
	if (not storage.firstCar) then
	  destroyVehicle()
	end
  end

  message.setHandler("destroyVehicle", handleDestroyVehicle)
  message.setHandler("childCarDeleted", handleChildCarDeleted)
  sb.logInfo("\nInit() of car " .. tostring(storage.carNumber) .. " ended")
  --message.setHandler("OpenDoors" )
  --message.setHandler("CloseDoors" )
  
end


function update(dt)

  if storage.firstCar and self.railRider.moving then
    self.displayspeedtimer = self.displayspeedtimer + dt
	if self.displayspeedtimer >= 1 then
      sb.logInfo("\nCAR 1 SPEED " .. tostring(self.railRider.speed))
	  self.displayspeedtimer = 0
	end
  end

  if storage.oldTrainSet then
    self.timerdt = self.timerdt + dt
  else
    self.timerdt = 0
  end

  if mcontroller.atWorldLimit() then
    vehicle.destroy()
    return
  end

  if mcontroller.isColliding() then
	destroyVehicle()
  else
  
    if self.railRider:onRail() then
      checkbooster()
    end
  
    self.railRider:update(dt)
	
    if storage.oldTrainSet and (storage.firstCar) and (self.timerdt >= 5) then
      sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " update() function checked " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
	  sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " update() function trying to spawn car n " .. tostring(storage.carNumber +1) )
      self.childCar = spawnCarNumber(storage.carNumber + 1)
	  storage.oldTrainSet = false
	  sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " update() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
	  self.timerdt = 0
    elseif (self.timerdt >= 5) then
      self.timerdt = 0
    end
	
    if self.railRider:onRail() then
	  checkrotation()
	  sfxVolumeAdjust(dt)
	  if self.childCar then
	    if world.entityExists(self.childCar) then
          regulateSpeedOfChildcar(self.childCar)
		end
      end
	end
	  storage.railStateData = self.railRider:stateData()
  end
   
    --animator.setFlipped(self.railRider.facing < 0)
	if self.railRider.facing ~= self.oldfacing then
	  animator.scaleTransformationGroup("flip", {-1, 1})
	end
	self.oldfacing = self.railRider.facing
	
	--if self.railRider:onRail()
	  --checkrotation()
	--end
    
	if self.speedWasSet then
	  self.speedWasSet = false
	else
	  self.railRider.useGravity = true
	end	
	
  --if storage.firstCar then
     if storage.firstCar then 
	   operateDoors()
	 end
  --elseif world.entityExists(self.childCar) and self.childCar ~= 0 then
     --world.callScriptedEntity(self.childCar, "operateDoors",  self.railMaterial, self.doorOperating)
  --end
	
end

function flip()
  animator.scaleTransformationGroup("flip", {-1, 1})
end

function operateDoors()
  if self.railRider:checkTile(mcontroller.position()) == "metamaterial:railstop" and not self.doorOperating then
       --self.doorOperating = true
       OpenDoors()
  elseif self.railRider:checkTile(mcontroller.position()) ~= "metamaterial:railstop" and self.doorOperating then
       --self.doorOperating = false
      CloseDoors()
  end
  
end

function OpenDoors()
  if (not self.doorOperating) then
    if not storage.doorLocked then animator.setAnimationState("rail", "opening") end
	self.doorOperating = true
	if self.childCar then
      if world.entityExists(self.childCar) then world.callScriptedEntity(self.childCar, "OpenDoors") end
    end
  end

end

function CloseDoors()
  if self.doorOperating then
    if not storage.doorLocked then animator.setAnimationState("rail", "closing") end
	self.doorOperating = false
	if self.childCar then
	  if world.entityExists(self.childCar) then world.callScriptedEntity(self.childCar, "CloseDoors") end
    end
  end
  
end

function checkrotation()

 local vel = vec2.norm(mcontroller.velocity())
 local angle = math.atan(vel[2], vel[1])
   if ((vel[1] ~= 0) or (vel[2] ~= 0)) then
     if self.railRider.facing > 0 and self.railRider:checkTile(mcontroller.position()) ~= "metamaterial:railreverse" then
	   animator.rotateGroup("cockpit", angle)
     elseif self.railRider:checkTile(mcontroller.position()) ~= "metamaterial:railreverse" then
	   animator.rotateGroup("cockpit", angle + math.pi)
     end
   end
   
end

function sfxVolumeAdjust(dt)

local volumeAdjustment = math.max(0.5, math.min(1, self.railRider.speed / 20))

  if self.railRider.speed > 0.01 and self.railRider.moving then 
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

function checkbooster()

  local dirVector = self.railRider:dirVector()
  
  if self.railRider.speed < 2 and dirVector[2] >= 0 and self.railRider.useGravity and self.railRider:checkTile(mcontroller.position()) ~= "metamaterial:railbooster" then
    self.railRider.speed = 3
	self.railRider.useGravity = false
  end

  if self.railRider.useGravity == false and (dirVector[2] < 0 or self.railRider:checkTile(mcontroller.position()) == "metamaterial:railbooster") then
	self.railRider.useGravity = true
  end
  
end

function regulateSpeedOfChildcar(childCarEid)

  if self.railRider.moving then
	local distanceToChildCar = world.magnitude(mcontroller.position(), world.entityPosition(childCarEid))
	--local newSpeed = self.railRider.speed * self.railRider.speed * ((2 * distanceToChildCar) / storage.childCarDistance)
	--world.callScriptedEntity(currentCarEid, "setChildCarSpeed", newSpeed)
		 
	--world.callScriptedEntity(currentCarEid, "setChildCarSpeed", springSpeed(currentCarEid))
	world.callScriptedEntity(childCarEid, "setChildCarSpeed", (self.railRider.speed * ((2 * distanceToChildCar) / storage.childCarDistance)))
  else
	  world.callScriptedEntity(childCarEid, "setChildCarSpeed", 0)
  end

end

function setChildCarSpeed(speed)
  self.railRider.speed = speed
  self.speedWasSet = true
  self.railRider.useGravity = false
end

function springSpeed(carEid) --target 50% max distance
  local distance = world.magnitude(mcontroller.position(), world.entityPosition(carEid))
  local t = 2 * distance / storage.childCarDistance
  return self.railRider.speed * t
end

function uninit()
  animator.stopAllSounds("grind")
  storage.oldTrainSet = true
  sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " uninit() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
  self.railRider:uninit()
  	if (not storage.firstCar) then
	  destroyVehicle()
	end
  self.childCar = nil
end

function spawnCarNumber(spawnedcarNumber)
  local carParams = {}
  local vehicleName = storage.trainsetData[spawnedcarNumber][1]
  
  carParams.carNumber = spawnedcarNumber
  carParams.initialFacing = self.railRider.facing
  carParams.parentCarEid = entity.id()
  carParams.numberOfCars = storage.numberOfCars
  carParams.firstCar = false
  --carParams.carDistance = storage.childCarDistance
  carParams.carDistance = storage.trainsetData[storage.numberOfCars+1][spawnedcarNumber]
  --carParams.spawnedCarOffsetX = storage.spawnedCarOffsetX
  --carParams.spawnedCarOffsetY = storage.spawnedCarOffsetY
  carParams.color = storage.trainsetData[spawnedcarNumber][2]
  carParams.livery = storage.trainsetData[spawnedcarNumber][3]
  carParams.pantographVisible = storage.trainsetData[spawnedcarNumber][4]
  carParams.doorLocked = storage.trainsetData[spawnedcarNumber][5]
  carParams.trainsetData = storage.trainsetData
  
  local spawnOffsetX = (storage.childCarDistance - 0.25) / 2
  
  if spawnedcarNumber == storage.numberOfCars then
	carParams.lastCar = true
  else
    carParams.lastCar = false
  end
  
  local carEid
  
  if self.railRider.facing >0 then
    carEid = world.spawnVehicle(vehicleName, vec2.add(mcontroller.position(), {-spawnOffsetX , storage.spawnedCarOffsetY}), carParams)
  else
    carEid = world.spawnVehicle(vehicleName, vec2.add(mcontroller.position(), {spawnOffsetX , storage.spawnedCarOffsetY}), carParams)
  end

  if carEid then
	sb.logInfo("\ncar number " .. tostring(spawnedcarNumber) .. " spawned by car number " .. tostring(storage.carNumber) )
	sb.logInfo("\nEntity ID of car " .. tostring(spawnedcarNumber) .. " is " .. tostring(carEid) )
	return carEid
  else
	sb.logInfo("\nFAILED to spawn car number " .. tostring(spawnedcarNumber) .. " by car number " .. tostring(storage.carNumber) )
	return nil
  end
  
end

function handleDestroyVehicle(_, _)
  sb.logInfo("\nCar number" .. storage.carNumber .. "received message from parent car: SELF-DESTRUCT")
  destroyVehicle()
end

function handleChildCarDeleted(_, _, carNumber)
  sb.logInfo("\nCar number" .. storage.carNumber .. "received message from child car: CAR " .. tostring(carNumber) .. " DELETED")
  storage.oldTrainSet = true
  storage.childCar = nil
  sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " handleChildDeleted() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
  if storage.parentCarEid and (not storage.firstCar) then
    if world.entityExists(storage.parentCarEid) then world.sendEntityMessage(storage.parentCarEid, "childCarDeleted", storage.carNumber) end
	destroyVehicle()
  end
end

function destroyVehicle()

  local popItem = config.getParameter("popItem")
  if popItem and storage.firstCar then
    world.spawnItem(popItem, entity.position(), 1)
  end
  
 if self.childCar and (not storage.lastCar) then
   if world.entityExists(self.childCar) then world.sendEntityMessage(self.childCar, "destroyVehicle") end
 end

  if storage.parentCarEid and (not storage.firstCar) then
    if world.entityExists(storage.parentCarEid) then world.sendEntityMessage(storage.parentCarEid, "childCarDeleted", storage.carNumber) end
  end
  
  sb.logInfo("\nCar number " .. tostring(storage.carNumber) .. " DESTROYED")
  vehicle.destroy()
  
end