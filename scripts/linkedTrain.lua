require "/scripts/rails4linked.lua"
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
  
  self.playingSound = false
  --self.t1 = world.time()
  self.sfxRampUpTimer = 0.1
  
  self.stopTimer = 0
  self.stopLenght = 6

  self.listOfCars = root.assetJson("/objects/crafting/trainConfigurator/listOfCars.json")
  self.railTypes = root.assetJson("/rails.config")
  
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
  
  --storage.trainsetLen = getTrainsetLenght(self.trainsetOriginal)
  --storage.trainsetLenInverted = getTrainsetLenght(self.trainsetInverted)
  
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
    calculateTargetDistanceFromParent(self.trainsetData, storage.carNumber)
  else
	calculateTargetDistanceFromParent(self.trainsetData, storage.numberOfCars)
  end
  
  if storage.firstCar or storage.lastCar then
    storage.trainsetLen = getTrainsetLenght(self.trainsetOriginal)
    storage.trainsetLenInverted = getTrainsetLenght(self.trainsetInverted)
	sb.logInfo("================TRAINSET LENGHT==== " .. tostring(storage.trainsetLen) .. " inverted len " .. tostring(storage.trainsetLenInverted))
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
	  
	  if (currentDecalSprite == 0) or (currentDecalSprite == "0") then
	    animator.setPartTag(currentDecalBaseString, "partImage", self.imgPath .. "decalPlaceholder.png")
	  else
	    animator.setPartTag(currentDecalBaseString, "partImage", self.imgPath .. currentDecalBaseString .. currentDecalSprite .. ".png")
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
  
  --self.railRider.onRailType
  
  if storage.firstCar then
    --if self.railRider:onRail() then
	  railStopsRoutine(dt)
	--end
    if self.testRunMode then
	  if self.testModeCanStart then
	    testRunModeRoutine()
	  else
	    self.testModeStartTimer = world.time() - self.testModeStartTimerT0
		sb.logInfo("=========test mode start timer " .. tostring(self.testModeStartTimer))
		if self.testModeStartTimer >= 4 then
		  self.testModeCanStart = true
		end
      end
	end
  end
  
  
  
  --if storage.firstCar then
    --if self.debugtimer == nil then self.debugtimer = 0 end
    --self.debugtimer = self.debugtimer + dt
	--if self.debugtimer >= 4 then
	  --local pos = entity.position()
	  --local mpos = mcontroller.position()
	  --sb.logInfo("MCONTROLLER POS")
	  --tprint(mpos)
	  --sb.logInfo("MAGNITUDE to 1 " .. tostring(world.magnitude(mpos, {4914.0, 957.0})))
	  --tprint(world.distance(mpos, {4914.0, 957.0}))
	  --sb.logInfo("MAGNITUDEto 4 " .. tostring(world.magnitude(mpos, {1333.0, 957.0})))
	  --tprint(world.distance(mpos, {1333.0, 957.0}))
      --local playersNearby = world.entityQuery({pos[1] - 47, pos[2] - 47}, {pos[1] + 47, pos[2] + 47}, { includedTypes = { "player" }, boundMode = "metaboundbox" })

	  --sb.logInfo("\nentity query nearby ")
	  --tprint(playersNearby)
	  --sb.logInfo("\nnum of players " .. tostring(#playersNearby))
	--end
	  
  --end
  
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
	  handleUseGravity()
	  if not storage.firstCar then
	    if self.checkDistance then
		  checkDistanceToParentCar()
		else
		  self.CheckDistanceTimer = world.time() - self.CheckDistanceTimerT0
		  if self.CheckDistanceTimer >= 5 then
		    self.checkDistance = true
		  end
		end
      else
	    regulateSpeedFirstCar(dt)
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
    

  if storage.firstCar then 
	--operateDoors()
	--operateDoors(false, false, true, self.railRider:checkTile(mcontroller.position()) )
	operateDoors((self.railRider:checkTile(mcontroller.position()) == "metamaterial:railstop") or self.atRailStop)
  end
	
end

function railStopsRoutine(dt)
  local distanceToStop
  if self.stoppingFriction == nil then
    self.stoppingFriction = 50
	self.stoppingSpeedLimit = 30
	self.approachingFriction = 60
	self.approachingSpeedLimit = 20
	self.departingAcceleration = 1
	self.departingSpeedLimit = 30
	self.departingSpeed = 4
	self.departingAccelerationWaitTime = 2
  end
  
  if self.railRider.moving and not self.stopping and not self.atRailStop and not self.departingFromStation then
    local pos = entity.position()
	local stopsNearby
	if storage.inverted then
	  --storage.trainsetLenInverted
	  if self.railRider.facing > 0 then
	    --stopsNearby = world.objectQuery({pos[1], pos[2] - 2.5}, {pos[1] + storage.trainsetLenInverted, pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
		stopsNearby = world.objectQuery({pos[1], pos[2] - 2.5}, {pos[1] + 35, pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
	  else
	    --stopsNearby = world.objectQuery({pos[1] - storage.trainsetLenInverted, pos[2] - 2.5}, {pos[1], pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
		stopsNearby = world.objectQuery({pos[1] - 35, pos[2] - 2.5}, {pos[1], pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
	  end
	else
	  --storage.trainsetLen
	  if self.railRider.facing > 0 then
	    --stopsNearby = world.objectQuery({pos[1], pos[2] - 2.5}, {pos[1] + storage.trainsetLen, pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
		stopsNearby = world.objectQuery({pos[1], pos[2] - 2.5}, {pos[1] + 35, pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
	  else
	    --stopsNearby = world.objectQuery({pos[1] - storage.trainsetLen, pos[2] - 2.5}, {pos[1], pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
		stopsNearby = world.objectQuery({pos[1] - 35, pos[2] - 2.5}, {pos[1], pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
	  end
	end
	if #stopsNearby > 0 then
	  sb.logInfo("\nINCOMING RAIL STOP DETECTED :")
	  tprint(stopsNearby)
	  self.stopping = true
	  self.approachingStation = false
	  --if self.railRider.speed > 30 then
	    --self.railRider.speed = 30
      --end
	  --if self.railRider.speed > 60 then
	    self.railRider.speed = 30
	  --end
	  self.stopPosId = stopsNearby[1]
	  sb.logInfo("\nSTOP ENTITY ID : " .. tostring(self.stopPosId) .. " POS ")
	  self.railStopPos = util.tileCenter(world.entityPosition(self.stopPosId))
	  self.railStopPosReal = world.entityPosition(self.stopPosId)
	  tprint(self.railStopPos)
	  sb.logInfo("\nCAR 1 POS ")
	  tprint(util.tileCenter(mcontroller.position()))
	  sb.logInfo("\nCAR 1 SPEED " .. tostring(self.railRider.speed))
	end
  end
  
  ---------------------------
  if self.stopping then
    local currentRailMaterial = self.railRider.onRailType
	if self.formerRailMaterial == nil then
	  self.formerRailMaterial = currentRailMaterial
	  if currentRailMaterial == nil then return end
	end
	  if self.formerRailMaterial ~= currentRailMaterial then
        currentRailMaterial = self.railRider.onRailType
	    self.formerRailMaterial = currentRailMaterial
	    self.speedLimit = self.railTypes[currentRailMaterial].speedLimit
	    self.currentFriction = self.railTypes[currentRailMaterial].friction
    end
    if not self.approachingStation then
      --sb.logInfo("\nself.stopping " .. tostring(self.stopping))
	  --sb.logInfo("\nCAR 1 POS ")
	  tprint(mcontroller.position())
	  --sb.logInfo("\nCAR 1 SPEED " .. tostring(self.railRider.speed))
	  distanceToStop = world.magnitude(world.xwrap(mcontroller.position()), self.railStopPos)
	  --sb.logInfo("\ndistance to stop " .. tostring(distanceToStop))
	  
	  self.frictionEffect = (self.stoppingFriction + self.currentFriction) * dt
	  self.railRider.speed = self.railRider.speed - self.frictionEffect
	  local stoppingLimit = self.speedLimit
	  if self.speedLimit > self.stoppingSpeedLimit then
	    stoppingLimit = self.stoppingSpeedLimit
	  end
	  self.railRider.speed = util.clamp(self.railRider.speed, 20, stoppingLimit)
	  
	  if distanceToStop <= 17 then
	    self.railRider.speed = 20
	    self.approachingStation = true
		sb.logInfo("\nApproaching station " .. tostring(distanceToStop))
	  end
	else
	  --sb.logInfo("\nself.stopping " .. tostring(self.stopping) .. " self.approaching " .. tostring(self.approaching))
	  
	  --distanceToStop = world.magnitude(world.xwrap(mcontroller.position()), self.railStopPos)
	  distanceToStop = world.magnitude(world.xwrap(mcontroller.position()), self.railStopPos)
	  
	  --sb.logInfo("\nCAR 1 POS ")
	  --tprint(mcontroller.position())
	  --sb.logInfo("\nCAR 1 SPEED " .. tostring(self.railRider.speed))
	  --sb.logInfo("\ndistance to stop " .. tostring(distanceToStop))
	  self.frictionEffect = (self.approachingFriction + self.currentFriction) * dt
	  self.railRider.speed = self.railRider.speed - self.frictionEffect
	  self.railRider.speed = util.clamp(self.railRider.speed, 15, self.approachingSpeedLimit)
	  if distanceToStop <= 0.6 then
	    self.atRailStop = true
        self.stopping = false
	    self.stopTimerT0 = world.time()
	    self.stopTimer = 0
	    mcontroller.setVelocity({0, 0})
	    self.railRider.moving = false
	    if self.childCarID and (not storage.lastCar) then
	      if world.entityExists(self.childCarID) then
		    world.callScriptedEntity(self.childCarID, "stop")
		  end
        end
	    --sb.logInfo("\nSTOP TIMER T0 " .. tostring(self.stopTimerT0))
	  end
	end
	
  end
  ----------------------------
  
  if self.atRailStop then
    --sb.logInfo("\nself.atRailStop " .. tostring(self.atRailStop))
    self.stopTimer = world.time() - self.stopTimerT0
	--sb.logInfo("\nSTOP TIMER " .. tostring(self.stopTimer))
	--OpenDoors()
	--operateDoors(true, self.atRailStop)
	if self.stopTimer >= self.stopLenght then
	  self.atRailStop = false
	  --CloseDoors()
	  --operateDoors(true, self.atRailStop)
	  self.departingFromStation = true
	  --self.railRider.moving = true
	  self.railRider:railResume(mcontroller.position())
	  self.railRider:findNextNode()
	  self.railRider.speed = self.departingSpeed
	  self.departingAccelerating = false
	  self.stopTimerT0 = world.time()
	  self.stopTimer = 0
	  if self.childCarID and (not storage.lastCar) then
	    if world.entityExists(self.childCarID) then
		  world.callScriptedEntity(self.childCarID, "start", self.railRider.speed)
		end
      end
	  --sb.logInfo("\nCAR 1 SPEED " .. tostring(self.railRider.speed))
    end
  end
  
  if self.departingFromStation then
    local railMaterial = self.railRider:checkTile(mcontroller.position())
	if (util.tileCenter(mcontroller.position()) ~= self.railStopPos) then
	  --local frictionEffect = self.stoppingFriction * self.departingFriction
	  --self.railRider.speed = self.railRider.speed + frictionEffect
	  if self.departingAccelerating then
	    local currentRailMaterial = self.railRider.onRailType
	    if self.formerRailMaterial ~= currentRailMaterial then
          currentRailMaterial = self.railRider.onRailType
	      self.formerRailMaterial = currentRailMaterial
	      self.speedLimit = self.railTypes[currentRailMaterial].speedLimit
	      self.currentFriction = self.railTypes[currentRailMaterial].friction
        end
		local acceleration = self.currentFriction + self.departingAcceleration
		self.frictionEffect = self.currentFriction * dt
	    self.railRider.speed = (self.railRider.speed + acceleration) - self.frictionEffect
	    self.railRider.speed = util.clamp(self.railRider.speed, self.departingSpeed, self.departingSpeedLimit)
		--sb.logInfo("\nCAR 1 SPEED " .. tostring(self.railRider.speed))
		if self.railRider.speed >= self.departingSpeedLimit then
		  self.departingAccelerating = false
		  self.departingFromStation = false
		end
	  else
	    self.stopTimer = world.time() - self.stopTimerT0
        if self.stopTimer >= self.departingAccelerationWaitTime then
		  self.departingAccelerating = true
		end
	  end
	end
  end
  
end

function testRunModeRoutine()

	--if world.magnitude(mcontroller.position(), stationPos) <= 1 then
	if self.atRailStop then
	  
	  local posTarget = util.tileCenter(self.nodePos[self.nextStation])
	  local currentStopPos = util.tileCenter(self.railStopPosReal)
	  
	  sb.logInfo("=============TEST MODE DETECTED RAIL STOP AT: =========== " .. tostring(currentStopPos[1]) .. "," .. tostring(currentStopPos[2]))
	  sb.logInfo("=============TARGET RAIL STOP (" .. tostring(self.nextStation) .. ") pos:"  .. tostring(posTarget[1]) .. "," .. tostring(posTarget[2]))
	  sb.logInfo("POS[1][1] == POS[2][1]: " .. tostring((currentStopPos[1] == posTarget[1])))
	  sb.logInfo("POS[1][2] == POS[2][2]: " .. tostring((currentStopPos[2] == posTarget[2])))
	  
	  if (currentStopPos[1] == posTarget[1]) and (currentStopPos[2] == posTarget[2]) then
	    local arrivedAtStation = self.nextStation
	    local stationEntityId = self.stationsData.id[self.nextStation]
	    world.sendEntityMessage(stationEntityId, "testRunCarArrivedAt", arrivedAtStation, world.time())
	    self.currentStation = self.currentStation + 1
	    sb.logInfo("current station " .. tostring(self.currentStation))
	    if self.currentStation == self.numStations then
		  sb.logInfo("Trainset TEST MODE DISABLED, attempting to self destruct")
		  self.testRunMode = false
		  destroyVehicle(true)
	    else
		  self.nextStation = self.nextStation + 1
		  sb.logInfo(" Next station " .. tostring(self.nextStation))
	    end
	  end
	end
	  
end

function stop()
  mcontroller.setVelocity({0, 0})
  self.railRider.moving = false
  if self.childCarID and (not storage.lastCar) then
	if world.entityExists(self.childCarID) then world.callScriptedEntity(self.childCarID, "stop") end
  end
end
function start(resumeSpeed)
  self.railRider:railResume(mcontroller.position())
  self.railRider:findNextNode()
  self.railRider.speed = resumeSpeed
  if self.childCarID and (not storage.lastCar) then
	if world.entityExists(self.childCarID) then world.callScriptedEntity(self.childCarID, "start", resumeSpeed) end
  end
end

function regulateSpeedFirstCar(dt , speedPercent)

    if speedPercent == nil then
	  speedPercent = 100
	end
	
	speedMultiplier = 100 / speedPercent
	
    if self.railRider.moving and not (self.stopping and self.approachingStation and self.atRailStop and self.departingFromStation) then
	  local currentRailMaterial = self.railRider.onRailType
	  if self.formerRailMaterial == nil then
	    self.formerRailMaterial = currentRailMaterial
		self.speedLimit = self.railTypes[currentRailMaterial].speedLimit / speedMultiplier
	    self.currentFriction = self.railTypes[currentRailMaterial].friction
	  end
	  if self.formerRailMaterial ~= currentRailMaterial then
        currentRailMaterial = self.railRider.onRailType
	    self.formerRailMaterial = currentRailMaterial
	    self.speedLimit = self.railTypes[currentRailMaterial].speedLimit / speedMultiplier
	    self.currentFriction = self.railTypes[currentRailMaterial].friction
      end
      if self.railRider.speed < self.speedLimit  then
	    self.frictionEffect = self.currentFriction * dt 
	    if self.railRider.speed < 20 then
		  --self.railRider.speed = self.railRider.speed + 0.5 
		--elseif self.railRider.speed < 65 then
		  self.railRider.speed = (self.railRider.speed + (self.railRider.speed / 15)) - self.frictionEffect
		else
		  self.railRider.speed = (self.railRider.speed + (self.railRider.speed / 13)) - self.frictionEffect
          --self.frictionEffect = self.currentFriction * dt 
          --self.railRider.speed = (self.railRider.speed + 0.5 ) - self.frictionEffect
		--elseif (self.railRider.speed > 20) and (self.railRider.speed < 50) then
		  --self.frictionEffect = self.currentFriction * dt 
          --self.railRider.speed = (self.railRider.speed + 1.5 ) - self.frictionEffect
		--elseif (self.railRider.speed > 50) then
		  --self.frictionEffect = self.currentFriction * dt 
          --self.railRider.speed = (self.railRider.speed + 3 ) - self.frictionEffect
		--elseif (self.railRider.speed > 60) then
		  --self.frictionEffect = self.currentFriction * dt 
          --self.railRider.speed = (self.railRider.speed + 4 ) - self.frictionEffect
		--elseif (self.railRider.speed > 70) then
		  --self.frictionEffect = self.currentFriction * dt 
          --self.railRider.speed = (self.railRider.speed + 7 ) - self.frictionEffect
        end
        --sb.logInfo("Accelerating, speed: " .. tostring(self.railRider.speed))		
      elseif self.railRider.speed > self.speedLimit then
        --self.frictionEffect = self.currentFriction * dt 
        self.railRider.speed = (self.railRider.speed - 4 ) - self.frictionEffect
	    --sb.logInfo("decelerating, speed: " .. tostring(self.railRider.speed))
      end
	end
  
end

function handleUseGravity()
  local dirVector = self.railRider:dirVector()
  if dirVector[2] >= 0 and self.railRider.useGravity and self.railRider.moving and self.railRider.speed < 3 then
    self.railRider.speed = 5
	self.railRider.useGravity = false
  else
    self.railRider.useGravity = true
  end
end

function isRailTramAt(nodePos)
  if nodePos and vec2.eq(nodePos, self.railRider:position()) then
    return true
  end
end

function checkDistanceToParentCar()
  local distanceToChildParent = world.magnitude(mcontroller.position(), world.entityPosition(self.parentCarId))
  if self.targetDistanceFromParent == nil then
	calculateTargetDistanceFromParent(self.trainsetData, storage.carNumber)
  end
  if distanceToChildParent > (self.targetDistanceFromParent + 5) then
    destroyVehicle(true)
  end
end

function calculateTargetDistanceFromParent(trainsetData, carNumber)
  local thisVehicle = trainsetData[carNumber].name
  local parentVehicle = trainsetData[carNumber - 1].name
  local thisVehiclePxLen = tonumber(self.listOfCars[thisVehicle].carLenghtPixels)
  local ParentVehiclePxLen = tonumber(self.listOfCars[parentVehicle].carLenghtPixels)
  self.targetDistanceFromParent = ( ((thisVehiclePxLen/2) + (ParentVehiclePxLen / 2)) / 8) + 1.75
end

function getTrainsetLenght(trainset)
  local firstVehicle = trainset[1].name
  local firstVehicleLenght = (tonumber(self.listOfCars[firstVehicle].carLenghtPixels) / 2) / 8
  local totalLenght = firstVehicleLenght
  for i=2,storage.numberOfCars do
    local vehicleName = trainset[i].name
    local vehicleLenght = tonumber(self.listOfCars[vehicleName].carLenghtPixels) / 8
	totalLenght = totalLenght + vehicleLenght + 1.75
  end
  
  if math.floor(totalLenght) - totalLenght < 0 then
    totalLenght = math.floor(totalLenght) + 1
  end
  
  return totalLenght
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

function operateDoors(atRailStop)

  if self.doorOperating then
    if not atRailStop then
	  --self.doorOperating = false
      CloseDoors()
	end
  else
    if atRailStop then
	  --self.doorOperating = true
       OpenDoors()
	end
  end
  
  if storage.firstCar and atRailStop and self.childCarID and self.onRailStopNoChildCar then
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
end

function testRunModeEnabled(_, _, numStations, stationsData, nodepos, circular )
  sb.logInfo("Trainset got message TEST RUN MODE ENABLED, num stations " .. tostring(numStations))
  sb.logInfo("Stationsdata as follows ")
  tprint(stationsData)
  self.testRunMode = true
  self.stationsData = stationsData
  --self.nodePos = stationsData.nodePos
  self.currentStation = 1
  self.nextStation = 2
  sb.logInfo("current station " .. tostring(self.currentStation) .. " Next station " .. tostring(self.nextStation))
  self.numStations = numStations
  self.testRunCircular = circular
  sb.logInfo("TRAINSET numstations " .. tostring(self.numStations))
  
  self.testModeStartTimer = 0
  self.testModeStartTimerT0 = world.time()
  self.testModeCanStart = false
  
  --self.testRunStationsPos={}
  --for i=1,self.numStations do
    --self.testRunStationsPos[i] = {}
	--for k,v in pairs(self.stationsData.nodePos) do
	  --sb.logInfo(tostring(k))
	  --sb.logInfo(tostring(v))
      --if k == tostring(i) then
	    --self.testRunStationsPos[i][1] = self.stationsData.nodePos[k][1]
		--self.testRunStationsPos[i][2] = self.stationsData.nodePos[k][2]
	  --end
    --end
  --end
  
  --sb.logInfo("TRAINSET node stations POS refurbished as follows: ")
  --tprint(self.testRunStationsPos)
  
  self.nodePos = nodepos
  sb.logInfo("TRAINSET node stations POS as follows: ")
  tprint(self.nodePos)
  
  if self.testRunCircular then
    self.numStations = self.numStations + 1
	self.nodePos[self.numStations] = {}
	self.nodePos[self.numStations][1] = self.nodePos[1][1]
	self.nodePos[self.numStations][2] = self.nodePos[1][2]
	self.stationsData.id[self.numStations] = self.stationsData.id[1]
	sb.logInfo(" TRAINSET circular TESTRUN " .. tostring(self.testRunCircular) .. " num stations " .. tostring(self.numStations) .. " Trainsed node stations POS as follows")
	tprint(self.nodePos)
	sb.logInfo(" TRAINSET stations ids as follows ")
	tprint(self.stationsData.id)
  end
  
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
	self.checkDistance = false
    self.checkDistanceTimer = 0
	self.CheckDistanceTimerT0 = world.time() - 3
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