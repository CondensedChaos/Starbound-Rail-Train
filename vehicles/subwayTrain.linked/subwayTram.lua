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
  
  self.listOfCars = root.assetJson("/objects/crafting/trainConfigurator/listOfCars.json")
  
  storage.numberOfCars = config.getParameter("numberOfCars")
  storage.parentCarEid = config.getParameter("parentCarEid")
  --storage.spawnedCarOffsetX = config.getParameter("spawnedCarOffsetX")
  storage.spawnedCarOffsetY = config.getParameter("spawnedCarOffsetY")
  self.imgPath = config.getParameter("imgPath")
  storage.color = config.getParameter("color")
  storage.cockpitColor = config.getParameter("cockpitColor")
  --storage.livery = config.getParameter("livery")
  self.decalNames = config.getParameter("decalNames")
  self.decalsTable = config.getParameter("decals")
  storage.reversed = config.getParameter("reversed")
  storage.specular = config.getParameter("specular")
  storage.pantographVisible = config.getParameter("pantographVisible")
  storage.doorLocked = config.getParameter("doorLocked")
  
  self.trainsetOriginal = config.getParameter("trainsetData")
  self.trainsetInverted = {}
  for i=1,storage.numberOfCars do
	self.trainsetInverted[i] = self.trainsetOriginal[storage.numberOfCars-(i-1)]
  end
  
  if storage.inverted ~= nil then
    sb.logInfo("\ncar " .. storage.carNumber .. " storage.inverted ~= nil")
    if storage.inverted then
	  sb.logInfo("\n" .. storage.carNumber .. " storage.inverted == TRUE")
	  self.trainsetData = self.trainsetInverted
	else
	  sb.logInfo("\n" .. storage.carNumber .. " storage.inverted == FALSE")
      self.trainsetData = self.trainsetOriginal
	end
	--storage.lastCar = self.trainsetData[storage.carNumber].lastCar
    --storage.firstCar = self.trainsetData[storage.carNumber].firstCar
  else
    sb.logInfo("\nstorage.inverted == nil")
    self.trainsetData = self.trainsetOriginal
	storage.inverted = false
	storage.carNumber = config.getParameter("carNumber")
	storage.lastCar = config.getParameter("lastCar")
    storage.firstCar = config.getParameter("firstCar")
  end
  
  if not storage.lastCar then 
    local thisVehicle = self.trainsetData[storage.carNumber].name
	local childVehicle = self.trainsetData[storage.carNumber + 1].name
	local thisVehiclePxLen = tonumber(self.listOfCars[thisVehicle].carLenghtPixels)
	local childVehiclePxLen = tonumber(self.listOfCars[childVehicle].carLenghtPixels)
	self.targetDistance = ( ((thisVehiclePxLen/2) + (childVehiclePxLen / 2)) / 8) + 1.75
  end
  
  animator.setPartTag("bodyColor", "partImage", tostring(self.imgPath) .. tostring(storage.color) .. ".png")
  sb.logInfo("\n" .. tostring(self.imgPath) .. tostring(storage.color) .. ".png")
  animator.setPartTag("cockpit", "partImage", tostring(self.imgPath) .. "cockpit" .. tostring(storage.cockpitColor) .. ".png")
  sb.logInfo("\n" .. tostring(self.imgPath) .. "cockpit" .. tostring(storage.cockpitColor) .. ".png")
  
  local vehicleName = config.getParameter("name")
  local vehicleNameHasDecals = self.listOfCars[vehicleName].hasDecals
  
  self.flipTable = {true,true,true}
  
  if vehicleNameHasDecals then
    local decalsFlippableTable = self.listOfCars[vehicleName].decalsFlippable
	local decalsIndexes = self.listOfCars[vehicleName].decals
	
    local numberOfDecals = #self.decalNames
    for i=1,numberOfDecals do
	  currentDecal = tostring(self.decalNames[i])
	  currentDecalSprite = tostring(self.decalsTable[currentDecal])
	  local currentDecalBaseString = "decal" .. currentDecal
	  
	  self.flipTable[3+i] = decalsFlippableTable[currentDecal][indexOf(decalsIndexes[currentDecal], currentDecalSprite)]
	  
	  if currentDecalSprite ~= "0" then
	    animator.setPartTag(currentDecalBaseString, "partImage", self.imgPath .. currentDecalBaseString .. currentDecalSprite .. ".png")
	  else
	    animator.setPartTag(currentDecalBaseString, "partImage", self.imgPath .. "decalPlaceholder.png")
	  end
	end
	for i=numberOfDecals+1,10 do
	  self.flipTable[3+i] = false
	end
  else
    for i=1,10 do
	  self.flipTable[3+i] = false
	end
  end
  
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " carDistance " .. tostring(self.spawnedCarOffsetX))
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " numberOfCars " .. tostring(storage.numberOfCars))
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " carNumber " .. tostring(storage.carNumber))
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " lastCar " .. tostring(storage.lastCar))
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " firstCar " .. tostring(storage.firstCar))
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " parentCarEid " .. tostring(storage.parentCarEid))
  --sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " spawnedCarOffsetX " .. tostring(storage.spawnedCarOffsetX)) 
 
  --animator.setFlipped(self.railRider.facing < 0)
  self.oldfacing = self.railRider.facing
  
  if storage.pantographVisible then
    animator.setAnimationState("pantograph", "visible")
  else
	animator.setAnimationState("pantograph", "hidden")
  end
  
  if not storage.specular and storage.reversed then
	animator.scaleTransformationGroup("flip", {-1, 1})
	flip(self.flipTable)
  end
  
  self.timerdt = 0
  self.displayspeedtimer = 0
  
  --if storage.carNumber > 1 then
  if not storage.firstCar then
    vehicle.setPersistent(false)
	sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " not persistent set")
  else
    vehicle.setPersistent(true)
  end
    

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
  
  --tprint(self.trainsetData)
  
  sb.logInfo("car " .. tostring(storage.carNumber) .. " pantographVisibile " .. tostring(storage.pantographVisible))
  sb.logInfo("car " .. tostring(storage.carNumber) .. " pantographVisibile " .. tostring(self.trainsetData[storage.carNumber].pantographVisibile))

  message.setHandler("destroyVehicle", handleDestroyVehicle)
  message.setHandler("childCarDeleted", handleChildCarDeleted)
  message.setHandler("invert", handleInvert)
  sb.logInfo("\nInit() of car " .. tostring(storage.carNumber) .. " ended")
  --message.setHandler("OpenDoors" )
  --message.setHandler("CloseDoors" )
  
end


function update(dt)

  --if storage.firstCar and self.railRider.moving then
    --self.displayspeedtimer = self.displayspeedtimer + dt
	--if self.displayspeedtimer >= 1 then
      --sb.logInfo("\nCAR 1 SPEED " .. tostring(self.railRider.speed))
	  --self.displayspeedtimer = 0
	--end
  --end
  
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
	  if (self.railRider:checkTile(mcontroller.position()) == "metamaterial:railreverse") and storage.firstCar then
       invert()
      end
	  if self.childCar and not storage.lastCar then
	    if world.entityExists(self.childCar) then
          regulateSpeedOfChildcar(self.childCar)
		end
      end
	end
	  storage.railStateData = self.railRider:stateData()
  end
   
    --animator.setFlipped(self.railRider.facing < 0)
	--if self.railRider.facing ~= self.oldfacing then
	  --animator.scaleTransformationGroup("flip", {-1, 1})
	  --flip(self.flipTable)
	--end
	--self.oldfacing = self.railRider.facing
	
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

function flip(flipTable)
  if flipTable[1] then
    animator.scaleTransformationGroup("flip", {-1, 1})
  end
  if flipTable[4] then
    animator.scaleTransformationGroup("decalA", {-1, 1})
  end
  if flipTable[5] then
    animator.scaleTransformationGroup("decalB", {-1, 1})
  end
  if flipTable[6] then
    animator.scaleTransformationGroup("decalC", {-1, 1})
  end
  if flipTable[7] then
    animator.scaleTransformationGroup("decalD", {-1, 1})
  end
  if flipTable[8] then
    animator.scaleTransformationGroup("decalE", {-1, 1})
  end
  if flipTable[9] then
    animator.scaleTransformationGroup("decalF", {-1, 1})
  end
  if flipTable[10] then
    animator.scaleTransformationGroup("decalG", {-1, 1})
  end
  if flipTable[11] then
    animator.scaleTransformationGroup("decalH", {-1, 1})
  end
  if flipTable[12] then
    animator.scaleTransformationGroup("decalI", {-1, 1})
  end
  if flipTable[13] then
    animator.scaleTransformationGroup("decalJ", {-1, 1})
  end
end

function operateDoors()
  if self.railRider:checkTile(mcontroller.position()) == "metamaterial:railstop" and not self.doorOperating then
       --self.doorOperating = true
       OpenDoors()
  elseif self.railRider:checkTile(mcontroller.position()) ~= "metamaterial:railstop" and self.doorOperating then
       --self.doorOperating = false
      CloseDoors()
  end
  
  if storage.firstCar and self.railRider:checkTile(mcontroller.position()) == "metamaterial:railstop" and self.childCar and self.onRailStopNoChildCar then
    if world.entityExists(self.childCar) then
	  world.callScriptedEntity(self.childCar, "OpenDoors")
	  self.onRailStopNoChildCar = false
	end
  end
  
end

function OpenDoors()
  if (not self.doorOperating) then
    if not storage.doorLocked then animator.setAnimationState("rail", "opening") end
	self.doorOperating = true
	if self.childCar then
      if world.entityExists(self.childCar) then
	    world.callScriptedEntity(self.childCar, "OpenDoors") end
	  elseif storage.firstCar then
	    self.onRailStopNoChildCar = true
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
  
  if storage.firstCar and self.onRailStopNoChildCar then
    self.onRailStopNoChildCar = false
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
	
	world.callScriptedEntity(childCarEid, "setChildCarSpeed", self.railRider.speed * (distanceToChildCar / self.targetDistance))
  else
	world.callScriptedEntity(childCarEid, "setChildCarSpeed", 0)
  end

end

function setChildCarSpeed(speed)
  self.railRider.speed = speed
  self.speedWasSet = true
  self.railRider.useGravity = false
end

function uninit()
  animator.stopAllSounds("grind")
  storage.oldTrainSet = true
  sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " uninit() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
  self.railRider:uninit()
  if (not storage.firstCar) then
	destroyVehicle()
  end
end

-- Returns first index of "value" from "array", useful for associative arrays
-- from https://stackoverflow.com/questions/38282234/returning-the-index-of-a-value-in-a-lua-table
function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

-- Print contents of "tbl", with indentation.
-- "indent" sets the initial level of indentation.
-- from https://gist.github.com/ripter/4270799
function tprint(tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      sb.logInfo(tostring(formatting))
      tprint(v, indent+1)
    else
      sb.logInfo(tostring(formatting) .. tostring(v))
    end
  end
end

-- Save copied tables in "copies", indexed by original table.
-- It is important that only one argument is supplied to this version of the deepcopy function.
-- Otherwise, it will attempt to use the second argument as a table, which can have unintended consequences. 
-- taken from http://lua-users.org/wiki/CopyTable
function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function spawnCarNumber(spawnedcarNumber)
  local carParams = {}
  --local vehicleName = config.getParameter("name")
  local vehicleName = self.trainsetData[spawnedcarNumber].name
  
  carParams.carNumber = spawnedcarNumber
  carParams.initialFacing = self.railRider.facing
  carParams.parentCarEid = entity.id()
  carParams.numberOfCars = storage.numberOfCars
  carParams.firstCar = false
  --carParams.carDistance = self.spawnedCarOffsetX
  --carParams.carDistance = self.trainsetData[spawnedcarNumber].carDistance
  --carParams.spawnedCarOffsetX = storage.spawnedCarOffsetX
  --carParams.spawnedCarOffsetY = storage.spawnedCarOffsetY
  
  carParams.color = self.trainsetData[spawnedcarNumber].color
  carParams.cockpitColor = self.trainsetData[spawnedcarNumber].cockpitColor
  carParams.decalNames = self.trainsetData[spawnedcarNumber].decalNames
  carParams.decals = self.trainsetData[spawnedcarNumber].decals
  carParams.pantographVisible = self.trainsetData[spawnedcarNumber].pantographVisibile
  carParams.doorLocked = self.trainsetData[spawnedcarNumber].doorLocked
  carParams.trainsetData = self.trainsetData
  carParams.specular = self.listOfCars[vehicleName].specular
  carParams.reversed = self.trainsetData[spawnedcarNumber].reversed
  
  if spawnedcarNumber == storage.numberOfCars then
	carParams.lastCar = true
  else
    carParams.lastCar = false
  end
  
  local carEid
  local offset = {}
  offset[1] = self.targetDistance - 0.75

  if self.railRider.facing >0 then
    offset[1] = -offset[1]
  end
  
  if self.railRider:onRail() then
    offset[2] = storage.spawnedCarOffsetY
  else
    offset[2] = 0
  end  
  
    carEid = world.spawnVehicle(vehicleName, vec2.add(mcontroller.position(), offset), carParams)

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
  sb.logInfo("\nCar number" .. storage.carNumber .. " received message from parent car: SELF-DESTRUCT")
  destroyVehicle()
end

function handleChildCarDeleted(_, _, carNumber)
  sb.logInfo("\nCar number" .. storage.carNumber .. " received message from child car: CAR " .. tostring(carNumber) .. " DELETED")
  storage.oldTrainSet = true
  storage.childCar = nil
  sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " handleChildDeleted() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
  
  if storage.parentCarEid and (not storage.firstCar) then
    if world.entityExists(storage.parentCarEid) then world.sendEntityMessage(storage.parentCarEid, "childCarDeleted", storage.carNumber) end
  end
  if storage.parentCarEid and (not storage.firstCar) then
	vehicle.destroy()
  end

end

function invert()
  if storage.firstCar then 
    sb.logInfo("\nCar number 1 inverting direction and sending invert message to child car")
    vehicle.setPersistent(false)
    storage.firstCar = false
	storage.lastCar = true
	storage.carNumber = storage.numberOfCars
	--local newTrainSet = {}
	--for i=1,storage.numberOfCars do
	  --newTrainSet[i] = self.trainsetData[storage.numberOfCars-(i-1)]
	--end
	if storage.inverted then
	  self.trainsetData = self.trainsetOriginal
	else
      self.trainsetData = self.trainsetInverted
	end
	storage.inverted = not storage.inverted
	
	self.trainsetData = {}
	self.trainsetData = deepcopy(newTrainSet)
	if self.childCar then
	  if world.entityExists(self.childCar) then
	    --world.sendEntityMessage(self.childCar, "invert", (storage.carNumber - 1), self.railRider.speed)
		world.sendEntityMessage(self.childCar, "invert", (storage.carNumber - 1))
		storage.parentCarEid = self.childCar
		self.childCar = nil
	  end
	end
  end
end

function handleInvert(_, _, carNumber)

   sb.logInfo("\nCar number" .. storage.carNumber .. " received message from parent car: CAR " .. tostring(carNumber) .. " INVERT")
  if storage.inverted then
	self.trainsetData = self.trainsetOriginal
  else
    self.trainsetData = self.trainsetInverted
  end
  storage.inverted = not storage.inverted
  
  if storage.lastCar then
    storage.firstCar = true
	storage.lastCar = false
	storage.carNumber = 1
	vehicle.setPersistent(true)
	self.childCar = storage.parentCarEid
	storage.parentCarEid = nil
	self.railRider.direction = (self.railRider.direction + 3) % 8 + 1
	self.railRider:findNextNode()
	
	local thisVehicle = self.trainsetData[storage.carNumber].name
    local childVehicle = self.trainsetData[storage.carNumber + 1].name
    local thisVehiclePxLen = tonumber(self.listOfCars[thisVehicle].carLenghtPixels)
    local childVehiclePxLen = tonumber(self.listOfCars[childVehicle].carLenghtPixels)
    self.targetDistance = ( ((thisVehiclePxLen/2) + (childVehiclePxLen / 2)) / 8) + 1.75
	
	regulateSpeedOfChildcar(self.childCar)
  else
    storage.carNumber = carNumber
	self.railRider.direction = (self.railRider.direction + 3) % 8 + 1
	self.railRider:findNextNode()
	
	local thisVehicle = self.trainsetData[storage.carNumber].name
    local childVehicle = self.trainsetData[storage.carNumber + 1].name
    local thisVehiclePxLen = tonumber(self.listOfCars[thisVehicle].carLenghtPixels)
    local childVehiclePxLen = tonumber(self.listOfCars[childVehicle].carLenghtPixels)
    self.targetDistance = ( ((thisVehiclePxLen/2) + (childVehiclePxLen / 2)) / 8) + 1.75
	
	if self.childCar then
	  if world.entityExists(self.childCar) then
	    --world.sendEntityMessage(self.childCar, "invert", (carNumber - 1), newSpeed)
		world.sendEntityMessage(self.childCar, "invert", (carNumber - 1))
		local oldChildCar = self.childCar
		local oldParentCar = storage.parentCarEid
		self.childCar = oldParentCar
		storage.parentCarEid = oldChildCar
	  end
	end
  end
  
end

function destroyVehicle()

  local popItem = config.getParameter("popItem")
  if popItem and storage.firstCar then
    local itemParams = {}
	itemParams.numberOfCars = storage.numberOfCars
	itemParams.trainsetData = self.trainsetOriginal

    world.spawnItem(popItem, entity.position(), 1, itemParams)
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