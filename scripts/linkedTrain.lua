require "/scripts/rails.lua"
require "/scripts/util.lua"

function init()
  message.setHandler("positionTileDamaged", function()
      if not world.isTileProtected(mcontroller.position()) then
        destroyVehicle(true)
      end
    end)

  mcontroller.setRotation(0)

  local railConfig = config.getParameter("railConfig", {})
  railConfig.facing = config.getParameter("initialFacing", 1)

  self.railRider = Rails.createRider(railConfig)
  self.railRider:init(storage.railStateData)
  
  self.reSpawnTimer = 0
  self.reSpawnTime = 2

  self.speedWasSet = false
  
  self.playingSound = false
  --self.t1 = world.time()
  self.sfxRampUpTimer = 0.1
  
  self.listOfCars = root.assetJson("/objects/crafting/trainConfigurator/listOfCars.json")
  
  storage.numberOfCars = config.getParameter("numberOfCars")
  self.parentCarId = config.getParameter("parentCarId")
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
  
  if storage.OnRailStopAndInverted == nil then storage.OnRailStopAndInverted = false end
  if storage.uninitOnRailStop == nil then storage.uninitOnRailStop = false end
  
  
  self.trainsetInverted = {}
  for i=1,storage.numberOfCars do
	self.trainsetInverted[i] = self.trainsetOriginal[storage.numberOfCars-(i-1)]
  end
  
  if storage.inverted ~= nil then
    if storage.inverted then
	  sb.logInfo("\nCar " .. storage.carNumber .. " storage.inverted == TRUE")
	  self.trainsetData = self.trainsetInverted
	else
	  sb.logInfo("\nCar " .. storage.carNumber .. " storage.inverted == FALSE")
      self.trainsetData = self.trainsetOriginal
	end
  end
  
  if storage.inverted == nil then
    sb.logInfo("\nstorage.inverted == nil")
	storage.carNumber = config.getParameter("carNumber")
	storage.lastCar = config.getParameter("lastCar")
    storage.firstCar = config.getParameter("firstCar")
	if storage.firstCar then
	  storage.inverted = false
	else
	  self.firstCarID = config.getParameter("firstCarID")
	  storage.inverted = config.getParameter("inverted")
	end
	if storage.inverted then
	  self.trainsetData = self.trainsetInverted
	else
	  self.trainsetData = self.trainsetOriginal
	end
	if not storage.firstCar then self.firstCarID = config.getParameter("firstCarID") end
	if storage.firstCar then
	  vehicle.setPersistent(true)
	  sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " set persistent, firstCar= " .. tostring(storage.firstCar) .. " lastCar= " .. tostring(storage.lastCar))
	else
	  vehicle.setPersistent(false)
	  sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " not persistent set, firstCar= " .. tostring(storage.firstCar) .. " lastCar= " .. tostring(storage.lastCar))
	end
	if storage.lastCar then
	  if world.entityExists(self.firstCarID) then
	    world.sendEntityMessage(self.firstCarID, "getLastCarID", entity.id())
	  end
	end
  end
  
  if storage.numberOfCars == 1 then
      storage.oneCarSet = true
	  storage.firstCar = true
	  storage.lastCar = false
	  storage.carNumber = 1
	  sb.logInfo("\ncar number " .. "One Car set " .. tostring(storage.oneCarSet))
    else
      storage.oneCarSet = false
    end
	
  
  if not storage.lastCar then 
    if not storage.oneCarSet then calculateTargetDistanceToChild() end
  end
  
  if not storage.firstCar then
    calculateTargetDistanceFromParent()
  end
  
  animator.setPartTag("bodyColor", "partImage", tostring(self.imgPath) .. tostring(storage.color) .. ".png")
  animator.setPartTag("cockpit", "partImage", tostring(self.imgPath) .. "cockpit" .. tostring(storage.cockpitColor) .. ".png")

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
  
  if storage.oldTrainSet then
    if (not storage.firstCar) then --and (not storage.lastCar) then
	  sb.logInfo("\nCar number " .. tostring(storage.carNumber) .. " DESTROYED FROM ===INIT=== AS ==OLDTRAINSET=TRUE= firstCar= " .. tostring(storage.firstCar) .. " lastCar= " .. tostring(storage.lastCar) .."LINE 186")
	  vehicle.destroy()
	end
  end
	
  if not storage.firstCar then
    self.checkDistance = false
    self.checkDistanceTimer = 0
	self.CheckDistanceTimerT0 = world.time()
  end

  if (not storage.lastCar) and (not storage.oneCarSet) then --(not storage.oldTrainSet) and (not storage.lastCar) then
    sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " init() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
    self.childCarID = spawnCarNumber(storage.carNumber + 1)
	if self.childCarID == nil then
	  storage.oldTrainSet = true
	else
	  if world.entityExists(self.childCarID) then
	    storage.oldTrainSet = false
	  else
	    storage.oldTrainSet = true
	  end
	end
  end
  
  local pos = entity.position()
  local playersNearby = world.entityQuery({pos[1] - 47, pos[2] - 47}, {pos[1] + 47, pos[2] + 47}, { includedTypes = { "player" }, boundMode = "metaboundbox" })
  if #playersNearby == 0 then
	self.playersNearby = false
  else
    self.playersNearby = true
  end
  
  --tprint(self.trainsetData)
  
  message.setHandler("destroyVehicle", handleDestroyVehicle)
  message.setHandler("childCarDeleted", handleChildCarDeleted)
  message.setHandler("invert", handleInvert)
  message.setHandler("getLastCarID", handleGetLastCarID)
  
  message.setHandler("testRunModeEnabled", testRunModeEnabled)
  
  sb.logInfo("\nInit() of car " .. tostring(storage.carNumber) .. " ended")
  
  script.setUpdateDelta(5)
  
  sb.logInfo("\nSCRIPT DELTA : " .. tostring(script.updateDt()))
  
end


function update(dt)

  --if storage.firstCar and self.railRider.moving then
    --if self.displayspeedtimer == nil then self.displayspeedtimer = 0 end
    --self.displayspeedtimer = self.displayspeedtimer + dt
	--if self.displayspeedtimer >= 1 then
      --sb.logInfo("\nCAR 1 SPEED " .. tostring(self.railRider.speed))
	  --self.displayspeedtimer = 0
	--end
  --end
  
  --if storage.firstCar then
    --if self.debugtimer == nil then self.debugtimer = 0 end
    --self.debugtimer = self.debugtimer + dt
	--if self.debugtimer >= 4 then
	  --local pos = entity.position()
      --local playersNearby = world.entityQuery({pos[1] - 47, pos[2] - 47}, {pos[1] + 47, pos[2] + 47}, { includedTypes = { "player" }, boundMode = "metaboundbox" })

	  --sb.logInfo("\nentity query nearby ")
	  --tprint(playersNearby)
	  --sb.logInfo("\nnum of players " .. tostring(#playersNearby))
	--end
	  
  --end
  
  if self.testRunMode and storage.firstCar then 
  
      self.debugTimerTestRun = world.time() - self.debugTimerTestRunT0
      if self.debugTimerTestRun > 0.5 then
		sb.logInfo("Test car POS (mcontroller): ")
		tprint(mcontroller.position())
		sb.logInfo("Test car distance to next station (" .. tostring(self.currentStation + 1) .. ") " .. tostring(world.magnitude(mcontroller.position(), self.testRunStationsPos[self.currentStation+1])) )
	  end
      
	  if world.magnitude(mcontroller.position(), self.testRunStationsPos[self.currentStation + 1]) < 1 then

		world.sendEntityMessage(self.stationsData.id[self.currentStation+1], "testRunCarArrivedAt", (self.currentStation + 1), world.time())
		self.currentStation = self.currentStation + 1
		sb.logInfo("next station " .. tostring(self.currentStation))
		if self.currentStation == self.numStations then
		  
		  sb.logInfo("Trainset TEST MODE DISABLED, attempting to self destruct")
		  self.testRunMode = false
		  destroyVehicle(true)
		end
	  end
	  
	end
  
  if storage.oldTrainSet and (not storage.oneCarSet) then
    if self.t0 == nil then self.t0 = world.time() end
    self.reSpawnTimer = world.time() - self.t0
  end

  if mcontroller.atWorldLimit() then
    destroyVehicle(true)
    return
  end

  if mcontroller.isColliding() then
    sb.logInfo("\nCar number " .. tostring(storage.carNumber) .. " COLLIDED")
	destroyVehicle(true)
  else --begin  NOT COLLIDING SECTION
    if self.railRider:onRail() then
      checkbooster()
	  if not storage.firstCar then
	    if self.checkDistance then
		  checkDistanceToParentCar()
		else
		  self.CheckDistanceTimer = world.time() - self.CheckDistanceTimerT0
		  if self.CheckDistanceTimer >= 5 then
		    self.checkDistance = true
		  end
		end
	  end
    end
  
    self.railRider:update(dt)
	
    if storage.oldTrainSet and (not storage.lastCar) and (self.reSpawnTimer >= self.reSpawnTime) and not storage.oneCarSet then --and (storage.firstCar)  then
      sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " update() function checked " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
	  sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " update() function trying to spawn car n " .. tostring(storage.carNumber +1) )
      self.childCarID = spawnCarNumber(storage.carNumber + 1)
	  if self.childCarID == nil then
	    storage.oldTrainSet = true
	  else
	    if world.entityExists(self.childCarID) then
	      storage.oldTrainSet = false
		  self.reSpawnTimer = 0
	      self.t0 = nil
	    else
	      storage.oldTrainSet = true
	    end
      end
      sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " update() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
      self.reSpawnTimer = 0
	  self.t0 = world.time()
    --elseif (self.reSpawnTimer >= self.respawnTime) and not storage.oneCarSet then
      --self.reSpawnTimer = 0
	  --self.t0 = nil
    end
	
    if self.railRider:onRail() then
	  checkrotation()
	  sfxVolumeAdjust(dt)
	  if (self.railRider:checkTile(mcontroller.position()) == "metamaterial:railreverse") and storage.firstCar then
        if not storage.oneCarSet then invert() end
      end
	  if self.childCarID and not storage.lastCar and not storage.oneCarSet then
	    if world.entityExists(self.childCarID) then
          regulateSpeedOfChildcar(self.childCarID)
	    end
      end
    end
	storage.railStateData = self.railRider:stateData()
  end --end NOT COLLIDING SECTION
   
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

  if storage.firstCar then 
	operateDoors()
  end
	
end

function isRailTramAt(nodePos, id)
  if nodePos and vec2.eq(nodePos, self.railRider:position()) then
    if id == nil then
      return true
    elseif id == entity.id() then
      return true
    end
  end
end

function checkDistanceToParentCar()
  local distanceToChildParent = world.magnitude(mcontroller.position(), world.entityPosition(self.parentCarId))
  if self.targetDistanceFromParent == nil then calculateTargetDistanceFromParent() end
  if distanceToChildParent > (self.targetDistanceFromParent + 5) then
    destroyVehicle(true)
  end
end

function calculateTargetDistanceFromParent()
  local thisVehicle = self.trainsetData[storage.carNumber].name
  local parentVehicle = self.trainsetData[storage.carNumber - 1].name
  local thisVehiclePxLen = tonumber(self.listOfCars[thisVehicle].carLenghtPixels)
  local ParentVehiclePxLen = tonumber(self.listOfCars[parentVehicle].carLenghtPixels)
  self.targetDistanceFromParent = ( ((thisVehiclePxLen/2) + (ParentVehiclePxLen / 2)) / 8) + 1.75
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
  
  if storage.firstCar and self.railRider:checkTile(mcontroller.position()) == "metamaterial:railstop" and self.childCarID and self.onRailStopNoChildCar then
    if world.entityExists(self.childCarID) then
	  world.callScriptedEntity(self.childCarID, "OpenDoors")
	  self.onRailStopNoChildCar = false
	end
  end
  
end

function OpenDoors()
  if (not self.doorOperating) then
    if not storage.doorLocked then animator.setAnimationState("rail", "opening") end
	self.doorOperating = true
	if self.childCarID and (not storage.oneCarSet) then
      if world.entityExists(self.childCarID) then
	    world.callScriptedEntity(self.childCarID, "OpenDoors") end
	  elseif storage.firstCar then
	    self.onRailStopNoChildCar = true
    end
  end

end

function CloseDoors()
  if self.doorOperating then
    if not storage.doorLocked then animator.setAnimationState("rail", "closing") end
	self.doorOperating = false
	if self.childCarID and (not storage.oneCarSet) then
	  if world.entityExists(self.childCarID) then world.callScriptedEntity(self.childCarID, "CloseDoors") end
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

  if self.railRider.moving and self.railRider.speed > 0.01 and self.railRider:onRail() and self.sfxOnNoPlayers and self.playingSound then
    local pos = entity.position()
    local playersNearby = world.entityQuery({pos[1] - 47, pos[2] - 47}, {pos[1] + 47, pos[2] + 47}, { includedTypes = { "player" }, boundMode = "metaboundbox" })
	
	if #playersNearby == 0 then
	  self.playingSound = true
	  self.sfxOnNoPlayers = true
	else
	  
	  local volume = self.railRider.speed / 20
	  if volume < 0.5 then volume = 0.5 end
	  if volume > 1 then volume = 1 end	  
	  animator.playSound("grind", -1)
	  animator.setSoundVolume("grind", volume, 0)
	  --self.t1 = world.time()
	  self.sfxRampUpTimer = 0
	  self.playingSound = true
	  self.sfxOnNoPlayers = false
	end
	
  end

  if self.railRider.moving and self.railRider.speed > 0.01 and self.railRider:onRail() then
    if self.playingSound and not self.sfxOnNoPlayers then
	
	  local pos = entity.position()
      local playersNearby = world.entityQuery({pos[1] - 47, pos[2] - 47}, {pos[1] + 47, pos[2] + 47}, { includedTypes = { "player" }, boundMode = "metaboundbox" })
	
	  if #playersNearby == 0 then
	    self.sfxOnNoPlayers = true
		return
	  end
	
	  --self.sfxRampUpTimer = world.time() - self.t1
	  self.sfxRampUpTimer = self.sfxRampUpTimer + dt
	  if self.sfxRampUpTimer >= 0.1 then
		local volume = self.railRider.speed / 20
		if volume < 0.5 then volume = 0.5 end
		if volume > 1 then volume = 1 end
        animator.setSoundVolume("grind", volume, 0.1)
		--self.t1 = world.time()
        self.sfxRampUpTimer = 0
	  end
	end
  else
	animator.stopAllSounds("grind")
	self.playingSound = false
	--self.t1 = world.time()
	self.sfxRampUpTimer = 0
  end
  
  if self.railRider.moving and self.railRider.speed > 0.01 and self.railRider:onRail() and not self.playingSound then
  
    self.playingSound = true
	local pos = entity.position()
    local playersNearby = world.entityQuery({pos[1] - 47, pos[2] - 47}, {pos[1] + 47, pos[2] + 47}, { includedTypes = { "player" }, boundMode = "metaboundbox" })
	
	if #playersNearby == 0 then
	  self.sfxOnNoPlayers = true
	else
	  animator.playSound("grind", -1)
	  local volume = self.railRider.speed / 2
	  if volume < 0.5 then volume = 0.5 end
	  if volume > 1 then volume = 1 end
	  animator.setSoundVolume("grind", volume, 0)
	  self.sfxRampUpTimer = 0
	  self.sfxOnNoPlayers = false
	end
	
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

function testRunModeEnabled(_, _, stationsData, numStations)
  sb.logInfo("Trainset got message TEST RUN MODE ENABLED, num stations " .. tostring(numStations))
  sb.logInfo("Stationsdata as follows ")
  tprint(stationsData)
  self.testRunMode = true
  self.stationsData = stationsData
  if self.currentStation == nil then self.currentStation = 1 end
  sb.logInfo("current station " .. tostring(self.currentStation))
  self.numStations = numStations
  sb.logInfo("TRAINSET numstations " .. tostring(self.numStations))
  
  self.testRunStationsPos={}
  for i=1,self.numStations do
    self.testRunStationsPos[i] = {}
	for k,v in pairs(self.stationsData.nodePos) do
      if k == tostring(i) then
	    self.testRunStationsPos[i][1] = self.stationsData.nodePos[k][1]
		self.testRunStationsPos[i][2] = self.stationsData.nodePos[k][2]
	  end
    end
  end
  
  sb.logInfo("TRAINSET node stations POS refurbished as follows: ")
  tprint(self.testRunStationsPos)
  
  
  self.debugTimerTestRun = 0
  self.debugTimerTestRunT0 = world.time()
  
end  

function uninit()
  animator.stopAllSounds("grind")
  storage.oldTrainSet = true
  sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " uninit() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
  self.railRider:uninit()
end

function calculateTargetDistanceToChild()
  local thisVehicle = self.trainsetData[storage.carNumber].name
  local childVehicle = self.trainsetData[storage.carNumber + 1].name
  local thisVehiclePxLen = tonumber(self.listOfCars[thisVehicle].carLenghtPixels)
  local childVehiclePxLen = tonumber(self.listOfCars[childVehicle].carLenghtPixels)
  self.targetDistance = ( ((thisVehiclePxLen/2) + (childVehiclePxLen / 2)) / 8) + 1.75
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
  local parameters = {}
  --local vehicleName = config.getParameter("name")
  local vehicleName = self.trainsetData[spawnedcarNumber].name
  
  parameters.carNumber = spawnedcarNumber
  parameters.initialFacing = self.railRider.facing
  parameters.parentCarId = entity.id()
  parameters.numberOfCars = storage.numberOfCars
  parameters.firstCar = false  
  parameters.color = self.trainsetData[spawnedcarNumber].color
  parameters.cockpitColor = self.trainsetData[spawnedcarNumber].cockpitColor
  parameters.decalNames = self.trainsetData[spawnedcarNumber].decalNames
  parameters.decals = self.trainsetData[spawnedcarNumber].decals
  parameters.pantographVisible = self.trainsetData[spawnedcarNumber].pantographVisibile
  parameters.doorLocked = self.trainsetData[spawnedcarNumber].doorLocked
  parameters.trainsetData = self.trainsetOriginal
  parameters.specular = self.listOfCars[vehicleName].specular
  parameters.reversed = self.trainsetData[spawnedcarNumber].reversed
  parameters.inverted = storage.inverted
  
  
  if storage.firstCar then
    parameters.firstCarID = entity.id()
  else
    parameters.firstCarID = self.firstCarID
  end
  
  if spawnedcarNumber == storage.numberOfCars then
	parameters.lastCar = true
  else
    parameters.lastCar = false
  end
  
  local carEid
  local offset = {}
  
  if (not storage.oneCarSet) then calculateTargetDistanceToChild() end
  
  offset[1] = self.targetDistance - 0.75

  if self.railRider.facing >0 then
    offset[1] = -offset[1]
  end
  
  if self.railRider:onRail() then
    offset[2] = storage.spawnedCarOffsetY
  else
    offset[2] = 0
  end  
  
    carEid = world.spawnVehicle(vehicleName, vec2.add(mcontroller.position(), offset), parameters)

  if carEid then
	sb.logInfo("\ncar number " .. tostring(spawnedcarNumber) .. " spawned by car number " .. tostring(storage.carNumber) )
	sb.logInfo("\nEntity ID of car " .. tostring(spawnedcarNumber) .. " is " .. tostring(carEid) )
	return carEid
  else
	sb.logInfo("\nFAILED to spawn car number " .. tostring(spawnedcarNumber) .. " by car number " .. tostring(storage.carNumber) )
	--storage.oldTrainSet = true
	return nil
  end
  
end

function handleDestroyVehicle(_, _, destroyChilds)
  sb.logInfo("\nCar number" .. storage.carNumber .. " received message from parent car: SELF-DESTRUCT")
  destroyVehicle(destroyChilds)
end

function handleChildCarDeleted(_, _, carNumber)
  sb.logInfo("\nCar number" .. storage.carNumber .. " received message from child car: CAR " .. tostring(carNumber) .. " DELETED")
  storage.oldTrainSet = true
  storage.childCar = nil
  sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " handleChildDeleted() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
  
  --if self.parentCarId and (not storage.firstCar) then
    --if world.entityExists(self.parentCarId) then world.sendEntityMessage(self.parentCarId, "childCarDeleted", storage.carNumber) end
  --end
  --if self.parentCarId and (not storage.firstCar) then
	--vehicle.destroy()
  --end

end

function handleGetLastCarID(_, _, EntityID)
  storage.lastCarID = EntityID
end

function invert()
  if storage.firstCar then 
    sb.logInfo("\nCar number 1 inverting direction and sending invert message to child car")
    --vehicle.setPersistent(false)
	vehicle.setPersistent(true)
    storage.firstCar = false
	storage.lastCar = true
	storage.carNumber = storage.numberOfCars
	if storage.inverted then
	  self.trainsetData = self.trainsetOriginal
	else
      self.trainsetData = self.trainsetInverted
	end
	storage.inverted = not storage.inverted
	
	self.trainsetData = {}
	self.trainsetData = deepcopy(newTrainSet)
	if self.childCarID then
	  if world.entityExists(self.childCarID) then
	    --world.sendEntityMessage(self.childCarID, "invert", (storage.carNumber - 1), self.railRider.speed)
		world.sendEntityMessage(self.childCarID, "invert", (storage.carNumber - 1))
		self.parentCarId = self.childCarID
		self.childCarID = nil
	  end
	end
  end
end

function onRailStopAndInverted(state)
  storage.onRailStopAndInverted = state
  sb.logInfo("\nCar number " .. tostring(storage.carNumber) .. "function onRailStopAndInverted(state) state=" .. tostring(storage.onRailStopAndInverted) )
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
	self.childCarID = self.parentCarId
	self.parentCarId = nil
	self.railRider.direction = (self.railRider.direction + 3) % 8 + 1
	self.railRider:findNextNode()
	
	calculateTargetDistanceToChild()
	
	regulateSpeedOfChildcar(self.childCarID)
  else
    storage.carNumber = carNumber
	self.railRider.direction = (self.railRider.direction + 3) % 8 + 1
	self.railRider:findNextNode()
	
	calculateTargetDistanceToChild()
	
	if self.childCarID then
	  if world.entityExists(self.childCarID) then
	    --world.sendEntityMessage(self.childCarID, "invert", (carNumber - 1), newSpeed)
		world.sendEntityMessage(self.childCarID, "invert", (carNumber - 1))
		local oldChildCar = self.childCarID
		local oldParentCar = self.parentCarId
		self.childCarID = oldParentCar
		self.parentCarId = oldChildCar
	  end
	end
  end
  
end

function destroyVehicle(destroyChilds)

  local popItem = config.getParameter("popItem")
  if popItem and storage.firstCar then
    local itemParams = {}
	itemParams.numberOfCars = storage.numberOfCars
	itemParams.trainsetData = self.trainsetOriginal

    world.spawnItem(popItem, entity.position(), 1, itemParams)
  end
  
 if self.childCarID and (not storage.lastCar) and destroyChilds then
   if world.entityExists(self.childCarID) then world.sendEntityMessage(self.childCarID, "destroyVehicle") end
 end

  if self.parentCarId and (not storage.firstCar) then
    if world.entityExists(self.parentCarId) then world.sendEntityMessage(self.parentCarId, "childCarDeleted", storage.carNumber) end
  end
  
  sb.logInfo("\nCar number " .. tostring(storage.carNumber) .. " DESTROYED")
  vehicle.destroy()
  
end