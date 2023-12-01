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
  self.reSpawnTime = 1
  
  self.playingSound = false
  --self.t1 = world.time()
  self.sfxRampUpTimer = 0.1
  
  self.defaultStopLenght = 6
  
  self.approachingBumperSpeedLimit = 20
  
  self.maxCarDistance = 20

  self.listOfCars = root.assetJson("/objects/crafting/trainConfigurator/listOfCars.json")
  self.railTypes = root.assetJson("/rails.config")
  
  self.settingsConfig = root.assetJson("/interface/linkedTrain/trainConfigurator/settings.json")
  self.logging = self.settingsConfig.logging
  
  storage.numberOfCars = config.getParameter("numberOfCars")
  self.parentCarId = config.getParameter("parentCarId")
  --storage.spawnedCarOffsetX = config.getParameter("spawnedCarOffsetX")
  storage.spawnedCarOffsetY = config.getParameter("spawnedCarOffsetY")
  self.imgPath = config.getParameter("imgPath")
  storage.color = config.getParameter("color")
  storage.cockpitColor = config.getParameter("cockpitColor")
  --storage.livery = config.getParameter("livery")
  --self.decalNames = config.getParameter("decalNames")
  self.decalsTable = config.getParameter("decals")
  storage.reversed = config.getParameter("reversed")
  storage.specular = config.getParameter("specular")
  storage.pantographVisible = config.getParameter("pantographVisible")
  storage.doorLocked = config.getParameter("doorLocked")
  
  self.spawnangle = config.getParameter("spawnangle")
  self.spawnedonstop = config.getParameter("spawnedonstop")

  self.trainsetOriginal = config.getParameter("trainsetData")
  
  self.vehicleName = config.getParameter("name")
  
  self.decalNames = self.listOfCars[self.vehicleName].decalNames
  
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
	  if self.logging then sb.logInfo("\nCar " .. storage.carNumber .. " storage.inverted == TRUE") end
	  self.trainsetData = self.trainsetInverted
	else
	  if self.logging then sb.logInfo("\nCar " .. storage.carNumber .. " storage.inverted == FALSE") end
      self.trainsetData = self.trainsetOriginal
	end
  end
  
  if storage.inverted == nil then
    if self.logging then sb.logInfo("\nstorage.inverted == nil") end
	storage.carNumber = config.getParameter("carNumber")
	storage.lastCar = config.getParameter("lastCar")
    storage.firstCar = config.getParameter("firstCar")
    storage.stationControlled = config.getParameter("stationControlled")
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
	  if self.logging then sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " set persistent, firstCar= " .. tostring(storage.firstCar) .. " lastCar= " .. tostring(storage.lastCar)) end
	else
	  vehicle.setPersistent(false)
	  if self.logging then sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " not persistent set, firstCar= " .. tostring(storage.firstCar) .. " lastCar= " .. tostring(storage.lastCar)) end
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
	  if self.logging then sb.logInfo("\ncar number " .. "One Car set " .. tostring(storage.oneCarSet)) end
    else
      storage.oneCarSet = false
  end
	
  if (storage.firstCar or storage.lastCar) and storage.stationControlled then
	if not storage.stationInit then
      storage.timetable = config.getParameter("timetable")
      
	  ----timetable :
	  ----.trainNum .direction .speeds .stopsLen .times .startTime .startStation
	  storage.stationsTable = config.getParameter("stations")
	  ----stationsTable :
	  ----.circular .pos .uuids .groupName
      storage.originalCar = config.getParameter("originalCar")
      if self.logging then 
        sb.logInfo("==============STATION CONTROLLED TRAIN -------INIT--------- ============")
        sb.logInfo("==============storage.timetable:============")
        tprint(storage.timetable)
        sb.logInfo("==============storage.stationsTable:============")
        tprint(storage.stationsTable)
      end
	  storage.currentStation = storage.timetable.startStation
	  storage.lastStation = #storage.timetable.speeds
      if self.logging then sb.logInfo("========================storage.lastStation = " .. tostring(storage.lastStation)) end
	  if storage.stationsTable.circular then
	    storage.nextStation = storage.currentStation + 1
	  else
        if storage.timetable.direction == "W" then
          if storage.currentStation == 1 then
            storage.loopingbackstations = false
            storage.nextStation = 2
          else
            storage.nextStation = storage.currentStation - 1
            storage.loopingbackstations = true
          end
        else
          if storage.currentStation == storage.lastStation then
		   storage.nextStation = storage.currentStation - 1
		   storage.loopingbackstations = true
		  else
		    storage.nextStation = storage.currentStation + 1
		    storage.loopingbackstations = false
		  end
        end
	  end
      local speedPercent = storage.timetable.speeds[storage.nextStation]
      storage.speedMultiplier = 100 / speedPercent
      storage.StopLenght = storage.timetable.stopsLen[storage.nextStation]
      storage.currentTime = storage.timetable.times[storage.nextStation]
      self.scheduleTimerT0 = world.time()
      storage.scheduleTimer = 0
      if self.logging then sb.logInfo("Station " .. tostring(storage.currentStation) .. "-" .. tostring(storage.nextStation) .. " Speed: " .. tostring(storage.timetable.speeds[storage.nextStation]) .. "percent --> maxSpeed/" .. tostring(storage.speedMultiplier) .. " Station " .. tostring(storage.nextStation) .. " Stop Lenght: " .. tostring(storage.StopLenght) .. "s" .. " projected time = " .. tostring(storage.currentTime)) end
      
      self.saveFile = world.getProperty("stationController_file")
      
      storage.numberOfTrainsE = self.saveFile.global[storage.stationsTable.groupName].data.numberOfTrainsE
      storage.numberOfTrainsW = self.saveFile.global[storage.stationsTable.groupName].data.numberOfTrainsW
      
      storage.stationControlledTrainUninit = false
      storage.stationInit = true
	end
  elseif (storage.firstCar or storage.lastCar) and (not storage.stationControlled) then
    storage.speedMultiplier = 1
  end
  
  
  if not storage.lastCar then 
    if not storage.oneCarSet then calculateTargetDistanceToChild() end
  end
  
  if not storage.oneCarSet then
    if not storage.firstCar then
      calculateTargetDistanceFromParent(self.trainsetData, storage.carNumber)
    else
	  calculateTargetDistanceFromParent(self.trainsetData, storage.numberOfCars)
    end
  end
  
  if storage.firstCar or storage.lastCar then
    storage.trainsetLen = getTrainsetLenght(self.trainsetOriginal)
    storage.trainsetLenInverted = getTrainsetLenght(self.trainsetInverted)
	if self.logging then sb.logInfo("================TRAINSET LENGHT==== " .. tostring(storage.trainsetLen) .. " inverted len " .. tostring(storage.trainsetLenInverted)) end
  end

  local vehicleNameHasDecals = self.listOfCars[self.vehicleName].hasDecals
  self.hasHeadlight = self.listOfCars[self.vehicleName].headlight
  self.hasRevHeadlight = self.listOfCars[self.vehicleName].reverseheadlight
  self.hasTaillight = self.listOfCars[self.vehicleName].taillight
  self.hasRevTaillight = self.listOfCars[self.vehicleName].reversetaillight
  
  animator.setPartTag("bodyColor", "partImage", tostring(self.imgPath) .. tostring(storage.color) .. ".png")
  animator.setPartTag("cockpit", "partImage", tostring(self.imgPath) .. "cockpit" .. tostring(storage.cockpitColor) .. ".png")
  
  animator.setPartTag("doorsBody", "partImage", tostring(self.imgPath) .. "doors/doorbody" .. tostring(storage.color) .. ".png")
  animator.setPartTag("doorsCockpit", "partImage", tostring(self.imgPath) .. "doors/doorcockpit" .. tostring(storage.cockpitColor) .. ".png")
  animator.setAnimationState("doors", "closed")
  
  self.flipTable = {false,false,false,false,false,false,false,false,false,false}
  
  if vehicleNameHasDecals then
    local decalsFlippableTable = self.listOfCars[self.vehicleName].decalsFlippable
	local decalsIndexes = self.listOfCars[self.vehicleName].decals
    local numberOfDecals = #self.decalNames
    for i=1,numberOfDecals do
	  currentDecal = tostring(self.decalNames[i])
	  currentDecalSprite = tostring(self.decalsTable[currentDecal])
      
      if storage.lastCar then 
        sb.logInfo("======i=" .. tostring(i) .. " decalsFlippableTable[" .. tostring(currentDecal) ..  "]")
        tprint(decalsFlippableTable[currentDecal])
        sb.logInfo("======i=" .. tostring(i) .. " currentDecal " .. tostring(currentDecal) .. " currentDecalSprite " .. tostring(currentDecalSprite))
      end
      
      if (currentDecalSprite == nil) or (currentDecalSprite == "nil") then
        currentDecalSprite = "0"
      end
      
	  local currentDecalBaseString = "decal" .. currentDecal
	  
      if storage.lastCar then
	    self.flipTable[i] = decalsFlippableTable[currentDecal][indexOf(decalsIndexes[currentDecal], tonumber(currentDecalSprite), true)]
      else
        self.flipTable[i] = decalsFlippableTable[currentDecal][indexOf(decalsIndexes[currentDecal], tonumber(currentDecalSprite), false)]
      end
	  
      local renderdecal0 = self.listOfCars[self.vehicleName].decal0rendered[currentDecal]
      
	  --if (currentDecalSprite == 0) or (currentDecalSprite == "0") then
      if currentDecalSprite == "0" then
        if renderdecal0 then
          animator.setPartTag(currentDecalBaseString, "partImage", self.imgPath .. "decals/" .. currentDecal .. "/" ..  currentDecalBaseString .. "0.png")
        else
          animator.setPartTag(currentDecalBaseString, "partImage", self.imgPath .. "decalPlaceholder.png")
        end
	  else
        animator.setPartTag(currentDecalBaseString, "partImage", self.imgPath .. "decals/" .. currentDecal .. "/" .. currentDecalBaseString .. currentDecalSprite .. ".png")
	  end
	end
    
    if storage.lastCar then
      sb.logInfo("=============================================FLIPTABLE=")
      tprint(self.flipTable)
    end
    
    animator.setAnimationState("rail", "inMotion")
  
	--for i=numberOfDecals+1,10 do
	  --self.flipTable[1+i] = false
	--end
  --else
    --for i=1,10 do
	  --self.flipTable[1+i] = false
	--end
  end

  self.oldfacing = self.railRider.facing
  
  if storage.pantographVisible then
    animator.setAnimationState("pantograph", "visible")
  else
	animator.setAnimationState("pantograph", "hidden")
  end
  
  if storage.firstCar then   
    if self.railRider.facing > 0 then
      if self.hasHeadlight then
        animator.setLightActive("headlightBeam", true)
        animator.setAnimationState("headlight", "on")
      end
      if self.hasRevHeadlight then 
        animator.setLightActive("reverseheadlightBeam", false)
        animator.setAnimationState("reverseheadlight", "off")
      end
      if self.hasTaillight then 
        animator.setLightActive("taillight", false)
        animator.setAnimationState("taillight", "off")
      end
      if self.hasRevTaillight then
        animator.setLightActive("reversetaillight", false)
        animator.setAnimationState("reversetaillight", "off")
      end
    else
      if self.hasHeadlight then
        animator.setLightActive("headlightBeam", false)
        animator.setAnimationState("headlight", "off")
      end
      if self.hasRevHeadlight then
        animator.setLightActive("reverseheadlightBeam", true)
        animator.setAnimationState("reverseheadlight", "on")
      end
      if self.hasTaillight then
        animator.setLightActive("taillight", false)
        animator.setAnimationState("taillight", "off")
      end
      if self.hasRevTaillight then
        animator.setLightActive("reversetaillight", false)
        animator.setAnimationState("reversetaillight", "off")
      end
    end
  elseif storage.lastCar then
    if self.railRider.facing > 0 then
      if self.hasHeadlight then 
        animator.setLightActive("headlightBeam", false)
        animator.setAnimationState("headlight", "off")
      end
      if self.hasRevHeadlight then
        animator.setLightActive("reverseheadlightBeam", false)
        animator.setAnimationState("reverseheadlight", "off")
      end
      if self.hasTaillight then
        animator.setLightActive("taillight", true)
        animator.setAnimationState("taillight", "on")
      end
      if self.hasRevTaillight then
        animator.setLightActive("reversetaillight", false)
        animator.setAnimationState("reversetaillight", "off")
      end
    else
      if self.hasHeadlight then
        animator.setLightActive("headlightBeam", false)
        animator.setAnimationState("headlight", "off")
      end
      if self.hasRevHeadlight then
        animator.setLightActive("reverseheadlightBeam", false)
        animator.setAnimationState("reverseheadlight", "off")
      end
      if self.hasTaillight then
        animator.setLightActive("taillight", false)
        animator.setAnimationState("taillight", "off")
      end
      if self.hasRevTaillight then
        animator.setLightActive("reversetaillight", true)
        animator.setAnimationState("reversetaillight", "on")
      end
    end
  else
    if self.hasHeadlight then
      animator.setLightActive("headlightBeam", false)
      animator.setAnimationState("headlight", "off")
    end
    if self.hasRevHeadlight then
      animator.setLightActive("reverseheadlightBeam", false)
      animator.setAnimationState("reverseheadlight", "off")
    end
    if self.hasTaillight then
      animator.setLightActive("taillight", false)
      animator.setAnimationState("taillight", "off")
    end
    if self.hasRevTaillight then
      animator.setLightActive("reversetaillight", false)
      animator.setAnimationState("reversetaillight", "off")
    end
  end
  
  --if self.railRider.facing > 0 then
    --animator.setLightPointAngle("headlightBeam",0)
    --animator.setLightPointAngle("reverseheadlightBeam",180)
  --else
    --animator.setLightPointAngle("headlightBeam",180)
    --animator.setLightPointAngle("reverseheadlightBeam",0)
  --end
  
  if storage.reversed and (not storage.specular) then
	--animator.scaleTransformationGroup("flip", {-1, 1})
	--flip(self.flipTable)
    animator.scaleTransformationGroup("flip", {-1, 1})
    for f=1,10 do
      if self.flipTable[f] then
        animator.scaleTransformationGroup("decal" .. string.char(f+64), {-1, 1}) --string.char(f+64): 65 = A in ASCII, 66 = B in ASCII
        sb.logInfo("=======FLIP " .. "decal" .. string.char(f+64), {-1, 1})
      end
    end
  end
  
  if storage.oldTrainSet then
    if (not storage.firstCar) then --and (not storage.lastCar) then
	  if self.logging then sb.logInfo("\nCar number " .. tostring(storage.carNumber) .. " DESTROYED FROM ===INIT=== AS ==OLDTRAINSET=TRUE= firstCar= " .. tostring(storage.firstCar) .. " lastCar= " .. tostring(storage.lastCar) .."LINE 310") end
	  vehicle.destroy()
	end
  end
	
  if not storage.firstCar then
    self.checkDistance = false
    self.checkDistanceTimer = 0
	self.CheckDistanceTimerT0 = world.time() - 3
  end

  if (not storage.lastCar) and (not storage.oneCarSet) then --(not storage.oldTrainSet) and (not storage.lastCar) then
    if self.logging then sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " init() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) ) end
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
  
  message.setHandler("stopGroup", handleStopGroup)
  
  if storage.uninitWhileStopping then
    mcontroller.setVelocity({0, 0})
	self.railRider.moving = false
  end
  
  if self.logging then sb.logInfo("\nInit() of car " .. tostring(storage.carNumber) .. " ended") end
  
  script.setUpdateDelta(5)
  
  if self.logging then sb.logInfo("\nSCRIPT DELTA : " .. tostring(script.updateDt())) end
  
end

function lastCarCheck()
  --storage.lastCarID
  if self.lastCarCheckTimer == nil then
    self.lastCarCheckTimer = 0
    --if self.
  end
  
end

function update(dt)

  if storage.uninitWhileStopping then
    if self.logging then 
      sb.logInfo("===================UNINIT WHILE STOPPING=====================")
      sb.logInfo("storage.stopTimer = " .. tostring(storage.stopTimer) .. " world Time = " .. tostring(world.time()) .. " | world.time() - storage.stopTimer = " .. tostring(world.time() - storage.stopTimer))
    end
    storage.stopTimerT0 = world.time() - storage.stopTimer
    storage.uninitWhileStopping = false
    self.resumingStopFromUninit = true
  end
  if storage.uninitWhileTravelling and storage.stationControlled then
    if self.logging then 
      sb.logInfo("===================UNINIT WHILE TRAVELLING=====================")
      sb.logInfo("storage.scheduleTimer = " .. tostring(storage.scheduleTimer) .. " world Time = " .. tostring(world.time()) .. " | world.time() - storage.scheduleTimer = " .. tostring(world.time() - storage.scheduleTimer))
    end
    self.scheduleTimerT0 = world.time() - storage.scheduleTimer
    storage.uninitWhileTravelling = false
  end

  local pos
  if storage.firstCar then
    --if self.railRider:onRail() then
      pos = entity.position()
      if self.railRider:onRail() then
	    railStopsRoutine(dt,storage.stationControlled,pos)
      end
	--end
    if self.testRunMode then
	  if self.testModeCanStart then
	    testRunModeRoutine(util.tileCenter(pos))
	  else
	    self.testModeStartTimer = world.time() - self.testModeStartTimerT0
		if self.logging then sb.logInfo("=========test mode start timer " .. tostring(self.testModeStartTimer)) end
		if self.testModeStartTimer >= 1 then
		  self.testModeCanStart = true
		end
      end
	end
  end
  
  if not storage.oneCarSet then
    if (not storage.lastCar) then    
      if storage.oldTrainSet then
        if self.t0 == nil then self.t0 = world.time() end
        self.reSpawnTimer = world.time() - self.t0
      else
        if self.checkchildcaraliveT0 == nil then self.checkchildcaraliveT0 = world.time() end
        self.checkchildcaraliveTimer = world.time() - self.checkchildcaraliveT0
        if self.checkchildcaraliveTimer >= 5 then
          self.checkchildcaraliveTimer = 0
          self.checkchildcaraliveT0 = nil
          if self.childCarID == nil then
	        storage.oldTrainSet = true
	      else
	        if not world.entityExists(self.childCarID) then
              storage.oldTrainSet = true
              self.reSpawnTimer = 0
	          self.t0 = nil
            end
          end
        end
      end
    end
  end

  if mcontroller.atWorldLimit() then
    destroyVehicle(true)
    return
  end

  if mcontroller.isColliding() then
    if self.logging then sb.logInfo("\nCar number " .. tostring(storage.carNumber) .. " COLLIDED") end
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
        if self.railRider.moving then
          if not (storage.stopping and self.approachingStation and storage.atRailStop) then
            if storage.approachingBumper then
              regulateSpeedFirstCarApproachingBumper(dt, storage.speedMultiplier)
            else
              if not storage.stationControlled then
                checkForBumpers(pos)
              end
              if not storage.departingFromStation then
                regulateSpeedFirstCar(dt, storage.speedMultiplier)
              end
            end
          end
        end
        if storage.invertAtNextCycle then
          invert()
          self.railRider.direction = (self.railRider.direction + 3) % 8 + 1
	      self.railRider:findNextNode()
          storage.invertAfterStop = false
          storage.invertAtNextCycle = false
        end
	  end
    end
  
    self.railRider:update(dt)
	
    if storage.oldTrainSet and (not storage.lastCar) and (self.reSpawnTimer >= self.reSpawnTime) and not storage.oneCarSet then --and (storage.firstCar)  then
      if self.logging then
        sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " update() function checked " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) )
	    sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " update() function trying to spawn car n " .. tostring(storage.carNumber +1) )
      end
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
      if self.logging then sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " update() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) ) end
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
        if not storage.oneCarSet then
          invert()
          --bumpinvert()
        end
        storage.approachingBumper = false
      end
      if self.spawnedonstop then
        spawnedonstophandle()
      end
	  if self.childCarID and not storage.lastCar and not storage.oneCarSet then
	    if world.entityExists(self.childCarID) then
          regulateSpeedOfChildcar(self.childCarID)
	    end
      end
    --else
	  --animator.rotateGroup("cockpit", 0)
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
	operateDoors((self.railRider:checkTile(mcontroller.position()) == "metamaterial:railstop") or storage.atRailStop)
  end
  
  if storage.firstCar and storage.stationControlledTrainUninit then
    if not self.updateidtimert0 then
      self.updateidtimert0 = world.time()
      self.waitingToLoadIDS = true
    end
    self.updateidtimer = world.time() - self.updateidtimert0
    if self.updateidtimer >= 5 then
      updateID()
      self.updateidtimert0 = nil
    end
  end
	
end

function spawnedonstophandle()
  --self.spawnedonstop
  if not self.spawnedonstopT0 then
    self.spawnedonstopT0 = world.time()
  end
  self.spawnedonstopTimer = world.time() - self.spawnedonstopT0
  if self.spawnedonstopTimer >= 17 then
    self.spawnedonstop = false
  end
end

function updateID()
  if storage.timetable.direction == "E" then
    world.setProperty(storage.stationsTable.groupName .. "trainsidsE_" .. tostring(storage.timetable.trainNum) , entity.id())
  else
    world.setProperty(storage.stationsTable.groupName .. "trainsidsW_" .. tostring(storage.timetable.trainNum) , entity.id())
  end
  storage.stationControlledTrainUninit = false
  self.waitingToLoadIDS = false
end

function railStopsRoutine(dt,stationControlled,pos)
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
    self.stationDetectionSpace = 35
  end
  
  if stationControlled and not storage.atRailStop then
    --self.scheduleTimerT0
    storage.scheduleTimer = world.time() - self.scheduleTimerT0
  end    
  
  if self.railRider.moving and not storage.stopping and not storage.atRailStop and not storage.departingFromStation then
	local stopsNearby
	if storage.inverted then
	  --storage.trainsetLenInverted
	  if self.railRider.facing > 0 then
	    --stopsNearby = world.objectQuery({pos[1], pos[2] - 2.5}, {pos[1] + storage.trainsetLenInverted, pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
		stopsNearby = world.objectQuery({pos[1], pos[2] - 2.5}, {pos[1] + self.stationDetectionSpace, pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
	  else
	    --stopsNearby = world.objectQuery({pos[1] - storage.trainsetLenInverted, pos[2] - 2.5}, {pos[1], pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
		stopsNearby = world.objectQuery({pos[1] - self.stationDetectionSpace, pos[2] - 2.5}, {pos[1], pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
	  end
	else
	  --storage.trainsetLen
	  if self.railRider.facing > 0 then
	    --stopsNearby = world.objectQuery({pos[1], pos[2] - 2.5}, {pos[1] + storage.trainsetLen, pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
		stopsNearby = world.objectQuery({pos[1], pos[2] - 2.5}, {pos[1] + self.stationDetectionSpace, pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
	  else
	    --stopsNearby = world.objectQuery({pos[1] - storage.trainsetLen, pos[2] - 2.5}, {pos[1], pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
		stopsNearby = world.objectQuery({pos[1] - self.stationDetectionSpace, pos[2] - 2.5}, {pos[1], pos[2] + 2.5}, { name = "customrailstop", boundMode = "position", order = "nearest" })
	  end
	end
	if #stopsNearby > 0 then
	  if self.logging then 
        sb.logInfo("\nINCOMING RAIL STOP DETECTED :")
	    tprint(stopsNearby)
	  end

	  storage.stopPosId = stopsNearby[1]
	  storage.railStopPos = util.tileCenter(world.entityPosition(storage.stopPosId))
	  storage.railStopPosReal = world.entityPosition(storage.stopPosId)
	  
	  if stationControlled then
	    storage.nextStationPos = util.tileCenter(storage.stationsTable.pos[storage.nextStation])
		if (storage.nextStationPos[1] == storage.railStopPos[1]) and (storage.nextStationPos[2] == storage.railStopPos[2]) then
          if self.logging then sb.logInfo("Station controlled Train " .. tostring(storage.timetable.trainNum) .. "-" .. tostring(storage.timetable.direction) .. " stopping at station " .. tostring(storage.nextStation)) end
		  storage.stopping = true
	      self.approachingStation = false
	      self.railRider.speed = 30
		end
	  else
	    storage.stopping = true
	    self.approachingStation = false
	    self.railRider.speed = 30
	  end
	  if self.logging then 
        sb.logInfo("\nRail Stop POS ")
	    tprint(storage.railStopPos)
	    sb.logInfo("\nCAR 1 POS ")
	    tprint(util.tileCenter(mcontroller.position()))
      end
	  --sb.logInfo("\nCAR 1 SPEED " .. tostring(self.railRider.speed))
	end
  end
  
  ---------------------------
  if storage.stopping then
    local currentRailMaterial = self.railRider.onRailType
	if self.formerRailMaterial == nil then
	  self.formerRailMaterial = currentRailMaterial
      self.speedLimit = self.railTypes[currentRailMaterial].speedLimit
	  self.currentFriction = self.railTypes[currentRailMaterial].friction
	  if currentRailMaterial == nil then return end
	end
	  if self.formerRailMaterial ~= currentRailMaterial then
        currentRailMaterial = self.railRider.onRailType
	    self.formerRailMaterial = currentRailMaterial
	    self.speedLimit = self.railTypes[currentRailMaterial].speedLimit
	    self.currentFriction = self.railTypes[currentRailMaterial].friction
    end
    if not self.approachingStation then
      ----sb.logInfo("\nstorage.stopping " .. tostring(storage.stopping))
	  if self.logging then 
        sb.logInfo("\nCAR 1 POS ")
	    tprint(util.tileCenter(mcontroller.position()))
      end
	  ----sb.logInfo("\nCAR 1 SPEED " .. tostring(self.railRider.speed))
	  distanceToStop = world.magnitude(world.xwrap(mcontroller.position()), storage.railStopPos)
	  ----sb.logInfo("\ndistance to stop " .. tostring(distanceToStop))
	  
	  self.frictionEffect = (self.stoppingFriction + self.currentFriction) * dt
	  self.railRider.speed = self.railRider.speed - self.frictionEffect
	  local stoppingLimit = self.speedLimit
	  if self.speedLimit > self.stoppingSpeedLimit then
	    stoppingLimit = self.stoppingSpeedLimit
	  end
	  self.railRider.speed = util.clamp(self.railRider.speed, 20, stoppingLimit)
	  
	  if distanceToStop <= 15 then
	    self.railRider.speed = 20
	    self.approachingStation = true
		--sb.logInfo("\nApproaching station " .. tostring(distanceToStop))
	  end
	else
	  ----sb.logInfo("\nstorage.stopping " .. tostring(storage.stopping) .. " self.approaching " .. tostring(self.approaching))
	  
	  --distanceToStop = world.magnitude(world.xwrap(mcontroller.position()), storage.railStopPos)
	  distanceToStop = world.magnitude(world.xwrap(mcontroller.position()), storage.railStopPos)
      if self.logging then sb.logInfo("\nDistance to stop: " .. tostring(distanceToStop)) end
	  
	  --sb.logInfo("\nCAR 1 POS ")
	  --tprint(mcontroller.position())
	  --sb.logInfo("\nCAR 1 SPEED " .. tostring(self.railRider.speed))
	  --sb.logInfo("\ndistance to stop " .. tostring(distanceToStop))
	  self.frictionEffect = (self.approachingFriction + self.currentFriction) * dt
	  self.railRider.speed = self.railRider.speed - self.frictionEffect
	  self.railRider.speed = util.clamp(self.railRider.speed, 15, self.approachingSpeedLimit)
      
      local trainPos = util.tileCenter(world.xwrap(mcontroller.position()))
      
	  if (trainPos[1] == storage.railStopPos[1]) and (trainPos[2] == storage.railStopPos[2]) or (distanceToStop <= 0.8) then
	    storage.atRailStop = true
        storage.stopping = false
	    storage.stopTimerT0 = world.time()
	    storage.stopTimer = 0
	    mcontroller.setVelocity({0, 0})
	    self.railRider.moving = false
  
        local speedPercent
		if stationControlled then
        
          storage.scheduleTimeDiff = storage.currentTime - storage.scheduleTimer
          local projectedTimeDebug = storage.currentTime
          local currentStationDebug = storage.currentStation
          local nextStationDebug = storage.nextStation
		  
		  if storage.stationsTable.circular then
		    if storage.nextStation == storage.lastStation then
              if self.logging then 
                sb.logInfo("=====CIRCULAR====storage.currentStation == storage.lastStation===============")
                sb.logInfo("currentStation was: " .. tostring(storage.currentStation) .. " nextStation was: " .. tostring(storage.nextStation))
              end
			  storage.currentStation = 1
			  storage.nextStation = 2
              if self.logging then sb.logInfo("currentStation is: " .. tostring(storage.currentStation) .. " nextStation is: " .. tostring(storage.nextStation)) end
              speedPercent = storage.timetable.speeds[storage.nextStation]
              storage.speedMultiplier = 100 / speedPercent
              storage.StopLenght = storage.timetable.stopsLen[storage.currentStation]
              storage.currentTime = storage.timetable.times[storage.nextStation]
			else
			  storage.currentStation = storage.nextStation
	          storage.nextStation = storage.currentStation + 1
              speedPercent = storage.timetable.speeds[storage.nextStation]
              storage.speedMultiplier = 100 / speedPercent
              storage.StopLenght = storage.timetable.stopsLen[storage.currentStation]
              storage.currentTime = storage.timetable.times[storage.nextStation]
			end
		  else
		    if storage.loopingbackstations then
			  if storage.nextStation == 1 then
                if self.logging then 
                  sb.logInfo("=======NOT circular===LOOPING BACK=====storage.nextStation == 1==============")
                  sb.logInfo("currentStation was: " .. tostring(storage.currentStation) .. " nextStation was: " .. tostring(storage.nextStation))
                end
			    storage.nextStation = 2
                storage.currentStation = 1
			    storage.loopingbackstations = false
                storage.invertAfterStop = true
                if self.logging then 
                  sb.logInfo("storage.loopingbackstations = false")
                  sb.logInfo("currentStation is: " .. tostring(storage.currentStation) .. " nextStation is: " .. tostring(storage.nextStation))
                end
                speedPercent = storage.timetable.speeds[storage.nextStation]
                storage.speedMultiplier = 100 / speedPercent
                storage.StopLenght = storage.timetable.stopsLen[storage.currentStation]
                storage.currentTime = storage.timetable.times[storage.nextStation]
			  else
			    storage.currentStation = storage.nextStation
				storage.nextStation = storage.currentStation - 1
                speedPercent = storage.timetable.speeds[storage.currentStation]
                storage.speedMultiplier = 100 / speedPercent
                storage.StopLenght = storage.timetable.stopsLen[storage.currentStation]
                storage.currentTime = storage.timetable.times[storage.currentStation]
			  end
			else
			  if storage.nextStation == storage.lastStation then
                if self.logging then 
                  sb.logInfo("=======NOT circular========storage.nextStation == storage.lastStation==============")
                  sb.logInfo("currentStation was: " .. tostring(storage.currentStation) .. " nextStation was: " .. tostring(storage.nextStation))
                end
			    storage.nextStation = storage.nextStation - 1
                storage.currentStation = storage.lastStation
				storage.loopingbackstations = true
                storage.invertAfterStop = true
                if self.logging then 
                  sb.logInfo("storage.loopingbackstations = true")
                  sb.logInfo("currentStation is: " .. tostring(storage.currentStation) .. " nextStation is: " .. tostring(storage.nextStation))
                end
                speedPercent = storage.timetable.speeds[storage.currentStation]
                storage.speedMultiplier = 100 / speedPercent
                storage.StopLenght = storage.timetable.stopsLen[storage.currentStation]
                storage.currentTime = storage.timetable.times[storage.currentStation]
			  else
			    storage.currentStation = storage.nextStation
				storage.nextStation = storage.currentStation + 1
                speedPercent = storage.timetable.speeds[storage.nextStation]
                storage.speedMultiplier = 100 / speedPercent
                storage.StopLenght = storage.timetable.stopsLen[storage.currentStation]
                storage.currentTime = storage.timetable.times[storage.nextStation]
			  end
			end
		  end 
          if self.logging then 
            sb.logInfo("Station " .. tostring(storage.currentStation) .. " reached, Next Station:" .. tostring(storage.nextStation))
            sb.logInfo("Station " .. tostring(storage.currentStation) .. " Stop Lenght " .. tostring(storage.StopLenght) .. "s" )
            sb.logInfo("Station " .. tostring(storage.currentStation) .. "-" .. tostring(storage.nextStation) .. " Speed: " .. tostring(speedPercent) .. "percent --> maxSpeed/" .. tostring(storage.speedMultiplier))
          end
          
          if storage.scheduleTimeDiff >= -0.5 then --it is a positive number or at most bigger than -0.5
            storage.StopLenght = storage.StopLenght + storage.scheduleTimeDiff
             if self.logging then 
               sb.logInfo("==============".. tostring(currentStationDebug) .. "-" .. tostring(nextStationDebug) .." Projected time= " .. tostring(projectedTimeDebug) .. " Time elapsed= " .. tostring(storage.scheduleTimer) .. "=====================Train Arrived Early or on time==")
               sb.logInfo("Time difference= " .. tostring(storage.scheduleTimeDiff) .. " Stopping train for  " .. tostring(storage.StopLenght) .. " s")
             end
          elseif (storage.StopLenght + storage.scheduleTimeDiff) > 2 then --at most 2 seconds more than stop lenght to be considered late --a negative number smaller than 0.5
            storage.StopLenght = storage.StopLenght + storage.scheduleTimeDiff
             if self.logging then 
               sb.logInfo("====================TRAIN ARRIVED LATE================================")
               sb.logInfo("==============".. tostring(currentStationDebug) .. "-" .. tostring(nextStationDebug) .." Projected time= " .. tostring(projectedTimeDebug) .. " Time elapsed= " .. tostring(storage.scheduleTimer) .. "=====================")
               sb.logInfo("Time difference= " .. tostring(storage.scheduleTimeDiff) .. " Stopping train for  " .. tostring(storage.StopLenght) .. " s")
             end
          else --a negative number smaller than 0.5 and smaller than -stoplenght
            if self.logging then 
              sb.logInfo("==========================TRAIN ARRIVED LATE more than stopLen================================")
              sb.logInfo("==============".. tostring(currentStationDebug) .. "-" .. tostring(nextStationDebug) .." Projected time= " .. tostring(projectedTimeDebug) .. " Time elapsed= " .. tostring(storage.scheduleTimer) .. "=====================")
              sb.logInfo("Time difference= " .. tostring(storage.scheduleTimeDiff) .. " Stopping train for  " .. tostring(storage.StopLenght) .. " s")
            end
            storage.StopLenght = 1.5
          end
          storage.scheduleTimer = 0
          storage.scheduleTimeDiff = 0
          
		else
		  storage.StopLenght = self.defaultStopLenght
          storage.speedMultiplier = 1
		end
		
	    if self.childCarID and (not storage.lastCar) then
	      if world.entityExists(self.childCarID) then
		    world.callScriptedEntity(self.childCarID, "stop")
		  end
        end
	    ----sb.logInfo("\nSTOP TIMER T0 " .. tostring(storage.stopTimerT0))
	  end
	end
	
  end
  ----------------------------
  
  if storage.atRailStop then
    
    ----sb.logInfo("\nstorage.atRailStop " .. tostring(storage.atRailStop))
    storage.stopTimer = world.time() - storage.stopTimerT0
	----sb.logInfo("\nSTOP TIMER " .. tostring(storage.stopTimer))
	--OpenDoors()
	--operateDoors(true, storage.atRailStop)
	if storage.stopTimer >= storage.StopLenght then
	  storage.atRailStop = false
	  --CloseDoors()
	  --operateDoors(true, storage.atRailStop)
	  storage.departingFromStation = true
	  --self.railRider.moving = true
	  self.railRider:railResume(mcontroller.position())
	  self.railRider:findNextNode()
	  self.railRider.speed = self.departingSpeed
	  self.departingAccelerating = false
	  storage.stopTimerT0 = world.time()
	  storage.stopTimer = 0
      if stationControlled then
        self.scheduleTimerT0 = world.time()
        if (not storage.stationsTable.circular) and storage.invertAfterStop then
          --invert()
          --storage.invertAfterStop = false
          storage.invertAtNextCycle = true
        end
      end
	  if self.childCarID and (not storage.lastCar) then
	    if world.entityExists(self.childCarID) then
		  world.callScriptedEntity(self.childCarID, "start", self.railRider.speed)
		end
      end
      if self.resumingStopFromUninit then self.resumingStopFromUninit = false end
	  ----sb.logInfo("\nCAR 1 SPEED " .. tostring(self.railRider.speed))
    end
  end
  
  if storage.departingFromStation then
    local railMaterial = self.railRider:checkTile(mcontroller.position())
	if (util.tileCenter(mcontroller.position()) ~= storage.railStopPos) then
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
		----sb.logInfo("\nCAR 1 SPEED " .. tostring(self.railRider.speed))
		if self.railRider.speed >= self.departingSpeedLimit then
		  self.departingAccelerating = false
		  storage.departingFromStation = false
		end
	  else
	    storage.stopTimer = world.time() - storage.stopTimerT0
        if storage.stopTimer >= self.departingAccelerationWaitTime then
		  self.departingAccelerating = true
		end
	  end
	end
  end
  
end

function testRunModeRoutine(currentStopPos)

	--if world.magnitude(mcontroller.position(), stationPos) <= 1 then
	if storage.atRailStop then
	  
	  local posTarget = util.tileCenter(self.nodePos[self.nextStation])
	  --local currentStopPos = util.tileCenter(storage.railStopPosReal)
	  
	  if self.logging then 
        sb.logInfo("=============TEST MODE DETECTED RAIL STOP AT: =========== " .. tostring(currentStopPos[1]) .. "," .. tostring(currentStopPos[2]))
	    sb.logInfo("=============TARGET RAIL STOP (" .. tostring(self.nextStation) .. ") pos:"  .. tostring(posTarget[1]) .. "," .. tostring(posTarget[2]))
	    --sb.logInfo("POS[1][1] == POS[2][1]: " .. tostring((currentStopPos[1] == posTarget[1])))
	    --sb.logInfo("POS[1][2] == POS[2][2]: " .. tostring((currentStopPos[2] == posTarget[2])))
	    sb.logInfo("POS[1][1] == POS[2][1] +-1: " .. tostring( (currentStopPos[1] <= (posTarget[1] + 1)) and (currentStopPos[1] >= (posTarget[1] - 1)) ) )
	    sb.logInfo("POS[1][2] == POS[2][2] +-1: " .. tostring( (currentStopPos[2] <= (posTarget[2] + 1)) and (currentStopPos[2] >= (posTarget[2] - 1)) ) )
	  end
      
	  --if (currentStopPos[1] == posTarget[1]) and (currentStopPos[2] == posTarget[2]) then
	  if ( ( (currentStopPos[1] <= (posTarget[1] + 1)) and (currentStopPos[1] >= (posTarget[1] - 1)) ) and ( (currentStopPos[2] <= (posTarget[2] + 1)) and (currentStopPos[2] >= (posTarget[2] - 1)) ) ) then
	    local arrivedAtStation = self.nextStation
	    local stationEntityId = self.stationsData.id[self.nextStation]
	    world.sendEntityMessage(stationEntityId, "testRunCarArrivedAt", arrivedAtStation, world.time())
	    self.currentStation = self.currentStation + 1
	    if self.logging then sb.logInfo("current station " .. tostring(self.currentStation)) end
	    if self.currentStation == self.numStations then
		  if self.logging then sb.logInfo("Trainset TEST MODE DISABLED, attempting to self destruct") end
		  self.testRunMode = false
		  destroyVehicle(true)
	    else
		  self.nextStation = self.nextStation + 1
		  if self.logging then sb.logInfo(" Next station " .. tostring(self.nextStation)) end
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
  self.spawnedonstop = false
  if self.childCarID and (not storage.lastCar) then
	if world.entityExists(self.childCarID) then world.callScriptedEntity(self.childCarID, "start", resumeSpeed) end
  end
end

--function bumpinvert()
  --mcontroller.setVelocity({0, 0})
  --self.railRider.moving = false
  --if self.childCarID and (not storage.lastCar) then
    --if world.entityExists(self.childCarID) then
	  --world.callScriptedEntity(self.childCarID, "stop")
    --end
  --end
  --invert(true)
--end

function checkForBumpers(pos)
  local bumpersNearby
  if storage.inverted then
	--storage.trainsetLenInverted
	if self.railRider.facing > 0 then
      bumpersNearby = world.objectQuery({pos[1], pos[2] - 2.5}, {pos[1] + self.stationDetectionSpace, pos[2] + 2.5}, { name = "railbumper", boundMode = "position", order = "nearest" })
	else
      bumpersNearby = world.objectQuery({pos[1] - self.stationDetectionSpace, pos[2] - 2.5}, {pos[1], pos[2] + 2.5}, { name = "railbumper", boundMode = "position", order = "nearest" })
	end
  else
	if self.railRider.facing > 0 then
	  bumpersNearby = world.objectQuery({pos[1], pos[2] - 2.5}, {pos[1] + self.stationDetectionSpace, pos[2] + 2.5}, { name = "railbumper", boundMode = "position", order = "nearest" })
	else
	  bumpersNearby = world.objectQuery({pos[1] - self.stationDetectionSpace, pos[2] - 2.5}, {pos[1], pos[2] + 2.5}, { name = "railbumper", boundMode = "position", order = "nearest" })
	end
  end
    
  if #bumpersNearby > 0 then
	if self.logging then
      sb.logInfo("\nINCOMING BUMPER DETECTED :")
	  tprint(bumpersNearby)
    end
    local bumperId = bumpersNearby[1]
	local bumperPos = util.tileCenter(world.entityPosition(bumperId))
    storage.approachingBumper = true
  end
  
end

function regulateSpeedFirstCarApproachingBumper(dt, speedMultiplier)
  local currentRailMaterial = self.railRider.onRailType
  if self.formerRailMaterial == nil then
	self.formerRailMaterial = currentRailMaterial
    self.speedLimit = self.railTypes[currentRailMaterial].speedLimit / speedMultiplier
    self.currentFriction = self.railTypes[currentRailMaterial].friction
    self.frictionEffect = self.currentFriction * dt
  end
  if self.formerRailMaterial ~= currentRailMaterial then
    currentRailMaterial = self.railRider.onRailType
	self.formerRailMaterial = currentRailMaterial
	self.speedLimit = self.railTypes[currentRailMaterial].speedLimit / speedMultiplier
	self.currentFriction = self.railTypes[currentRailMaterial].friction
    self.frictionEffect = self.currentFriction * dt
  end
  local approachingBumperFriction = 50
  --self.approachingBumperSpeedLimit = 20
        
  self.frictionEffect = (approachingBumperFriction + self.currentFriction) * dt
  self.railRider.speed = self.railRider.speed - self.frictionEffect
	    
  local aprroachingBumperLimit = self.speedLimit
  if self.speedLimit > self.approachingBumperSpeedLimit then
	aprroachingBumperLimit = self.approachingBumperSpeedLimit
  end
  self.railRider.speed = util.clamp(self.railRider.speed, 20, aprroachingBumperLimit)
end

function regulateSpeedFirstCar(dt, speedMultiplier)

    local currentRailMaterial = self.railRider.onRailType
	if self.formerRailMaterial == nil then
	  self.formerRailMaterial = currentRailMaterial
      self.speedLimit = self.railTypes[currentRailMaterial].speedLimit / speedMultiplier
      self.currentFriction = self.railTypes[currentRailMaterial].friction
      self.frictionEffect = self.currentFriction * dt
	end
	if self.formerRailMaterial ~= currentRailMaterial then
      currentRailMaterial = self.railRider.onRailType
	  self.formerRailMaterial = currentRailMaterial
	  self.speedLimit = self.railTypes[currentRailMaterial].speedLimit / speedMultiplier
	  self.currentFriction = self.railTypes[currentRailMaterial].friction
      self.frictionEffect = self.currentFriction * dt
    end
    if (self.railRider.speed < self.speedLimit) then
	  self.frictionEffect = self.currentFriction * dt 
	  if self.railRider.speed < 20 then
	    self.railRider.speed = (self.railRider.speed + (self.railRider.speed / 15)) - self.frictionEffect
	  else
		self.railRider.speed = (self.railRider.speed + (self.railRider.speed / 13)) - self.frictionEffect
      end
    elseif self.railRider.speed > self.speedLimit then
      self.railRider.speed = (self.railRider.speed - 4 ) - self.frictionEffect
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
  if self.targetDistance == nil then
	calculateTargetDistanceFromParent(self.trainsetData, storage.carNumber)
  end
  if distanceToChildParent > (self.targetDistance + self.maxCarDistance) then --self.maxCarDistance is the actual distance between the cars, since distances are calculated from the center of the entity we have to add the distance between the center of this car and the center of the parent car
    destroyVehicle(true)
  end
end

function calculateTargetDistanceFromParent(trainsetData, carNumber)
  local thisVehicle = trainsetData[carNumber].name
  local parentVehicle = trainsetData[carNumber - 1].name
  local thisVehiclePxLen = tonumber(self.listOfCars[thisVehicle].carLenghtPixels)
  local ParentVehiclePxLen = tonumber(self.listOfCars[parentVehicle].carLenghtPixels)
  self.targetDistance = ( ((thisVehiclePxLen/2) + (ParentVehiclePxLen / 2)) / 8) + 1.75 --since distance is measured from the center of the entity we have to add the distance from the center of the entity to the center of the parent's car entity + 1.75 blocks circa that is between the cars, we put this value in self.targetDistance
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
    if not storage.doorLocked then
      animator.setAnimationState("doors", "opening")
      animator.setAnimationState("rail", "stopped")
    end
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
    if not storage.doorLocked then
      animator.setAnimationState("doors", "closing")
      animator.setAnimationState("rail", "inMotion")
    end
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
 
 --if self.logging then sb.logInfo("ANGLE: (" .. tostring(vel[1]) .. "," .. tostring(vel[2]) .. ") = " .. tostring(angle) .. " RADs usegravity: " .. tostring(self.railRider.useGravity)) end
 
 --self.spawnangle
 --self.spawnedonstop
 
 if self.spawnedonstop then
   --sb.logInfo("SPAWNED ON STOP")
   animator.rotateGroup("cockpit", self.spawnangle)
   return
 end
 
 if storage.firstCar then
   if (vel[2] == 1) or (vel[2] == -1) then --if (angle == 1.5707963267949) or (angle == -1.5707963267949) then
     destroyVehicle(true)
     if self.logging then sb.logInfo("VERTICAL=TRUE") end
   end
 end
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
  if self.logging then 
    sb.logInfo("Trainset got message TEST RUN MODE ENABLED, num stations " .. tostring(numStations))
    sb.logInfo("Stationsdata as follows ")
    tprint(stationsData)
  end
  self.testRunMode = true
  self.stationsData = stationsData
  --self.nodePos = stationsData.nodePos
  self.currentStation = 1
  self.nextStation = 2
  if self.logging then sb.logInfo("current station " .. tostring(self.currentStation) .. " Next station " .. tostring(self.nextStation)) end
  self.numStations = numStations
  self.testRunCircular = circular
  if self.logging then sb.logInfo("TRAINSET numstations " .. tostring(self.numStations)) end
  
  self.testModeStartTimer = 0
  self.testModeStartTimerT0 = world.time()
  self.testModeCanStart = false
  
  self.nodePos = nodepos
  if self.logging then 
    sb.logInfo("TRAINSET node stations POS as follows: ")
    tprint(self.nodePos)
  end
  
  if self.testRunCircular then
    self.numStations = self.numStations + 1
	self.nodePos[self.numStations] = {}
	self.nodePos[self.numStations][1] = self.nodePos[1][1]
	self.nodePos[self.numStations][2] = self.nodePos[1][2]
	self.stationsData.id[self.numStations] = self.stationsData.id[1]
	if self.logging then 
      sb.logInfo(" TRAINSET circular TESTRUN " .. tostring(self.testRunCircular) .. " num stations " .. tostring(self.numStations) .. " Trainsed node stations POS as follows")
	  tprint(self.nodePos)
	  sb.logInfo(" TRAINSET stations ids as follows ")
	  tprint(self.stationsData.id)
    end
  end
  
  self.debugTimerTestRun = 0
  self.debugTimerTestRunT0 = world.time()
  
end  

function uninit()
  animator.stopAllSounds("grind")
  storage.oldTrainSet = true
  if self.logging then sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " uninit() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) ) end
  self.railRider:uninit()
  if storage.atRailStop and storage.firstCar then
    storage.uninitWhileStopping = true
  elseif storage.stationControlled then
    storage.uninitWhileTravelling = true
  end
  
  if storage.stationControlled and storage.firstCar then
    storage.stationControlledTrainUninit = true
  end
  
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
function indexOf(array, value, debug)
  if debug then
    sb.logInfo("finding indexOf " .. tostring(value) .. " in array:")
    tprint(array)
  end
  for i, v in ipairs(array) do
    if (v == value) then
      if debug then sb.logInfo("found " .. tostring(value) .. "index=" .. tostring(i)) end
      return i
    end
  end
  if debug then sb.logInfo(tostring(value) .. " NOT FOUND") end
  return nil
end

-- Print contents of "tbl", with indentation.
-- "indent" sets the initial level of indentation.
-- from https://gist.github.com/ripter/4270799
function tprint(tbl, indent)
  if type(tbl) == "table" then
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
  else
    sb.logInfo("not a table: " .. tostring(tbl))
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
  parameters.timetable = config.getParameter("timetable")
  parameters.stations = config.getParameter("stations")
  parameters.stationControlled = config.getParameter("stationControlled")
  
  if storage.firstCar then
    if storage.atRailStop then
      local vel = vec2.norm(mcontroller.velocity())
      parameters.spawnangle = math.atan(vel[2], vel[1])
      parameters.spawnedonstop = storage.atRailStop
    else
      parameters.spawnedonstop = false
    end
  else
    parameters.spawnangle = self.spawnangle
    parameters.spawnedonstop = self.spawnedonstop
  end

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
	if self.logging then 
      sb.logInfo("\ncar number " .. tostring(spawnedcarNumber) .. " spawned by car number " .. tostring(storage.carNumber) )
	  sb.logInfo("\nEntity ID of car " .. tostring(spawnedcarNumber) .. " is " .. tostring(carEid) )
    end
    if storage.atRailStop or storage.uninitWhileStopping then
      if world.entityExists(carEid) then world.callScriptedEntity(carEid, "stop") end
    end
	return carEid
  else
	if self.logging then sb.logInfo("\nFAILED to spawn car number " .. tostring(spawnedcarNumber) .. " by car number " .. tostring(storage.carNumber) ) end
	--storage.oldTrainSet = true
	return nil
  end
  
end

function handleDestroyVehicle(_, _, destroyChilds)
  if self.logging then sb.logInfo("\nCar number" .. storage.carNumber .. " received message from parent car: SELF-DESTRUCT") end
  destroyVehicle(destroyChilds)
end

function handleChildCarDeleted(_, _, carNumber)
  if self.logging then sb.logInfo("\nCar number" .. storage.carNumber .. " received message from child car: CAR " .. tostring(carNumber) .. " DELETED") end
  storage.oldTrainSet = true
  storage.childCar = nil
  if self.logging then sb.logInfo("\ncar number " .. tostring(storage.carNumber) .. " handleChildDeleted() function called " .. "storage.oldTrainSet= " .. tostring(storage.oldTrainSet) ) end

end

function handleGetLastCarID(_, _, EntityID)
  storage.lastCarID = EntityID
end

function invert()
  if storage.firstCar then 
    if self.logging then sb.logInfo("\nCar number 1 inverting direction and sending invert message to child car") end
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
      if storage.stationControlled and not (storage.stationControlledTrainUninit or self.waitingToLoadIDS) then
        if not storage.originalCar then
          if storage.timetable.direction == "E" then
            world.setProperty(storage.stationsTable.groupName .. "trainsidsE_" .. tostring(storage.timetable.trainNum) , entity.id())
         else
            world.setProperty(storage.stationsTable.groupName .. "trainsidsW_" .. tostring(storage.timetable.trainNum) , entity.id())
          end
        end
      end
	else
      self.trainsetData = self.trainsetInverted
	end
	storage.inverted = not storage.inverted
        
    if self.railRider.facing > 0 then
      if self.hasHeadlight then
        animator.setLightActive("headlightBeam", false)
        animator.setAnimationState("headlight", "off")
      end
      if self.hasRevHeadlight then
        animator.setLightActive("reverseheadlightBeam", false)
        animator.setAnimationState("reverseheadlight", "off")
      end
      if self.hasTaillight then
        animator.setLightActive("taillight", true)
        animator.setAnimationState("taillight", "on")
      end
      if self.hasRevTaillight then
        animator.setLightActive("reversetaillight", false)
        animator.setAnimationState("reversetaillight", "off")
      end
    else
      if self.hasHeadlight then
        animator.setLightActive("headlightBeam", false)
        animator.setAnimationState("headlight", "off")
      end
      if self.hasRevHeadlight then
        animator.setLightActive("reverseheadlightBeam", false)
        animator.setAnimationState("reverseheadlight", "off")
      end
      if self.hasTaillight then
        animator.setLightActive("taillight", false)
        animator.setAnimationState("taillight", "off")
      end
      if self.hasRevTaillight then
        animator.setLightActive("reversetaillight", true)
        animator.setAnimationState("reversetaillight", "on")
      end
    end
	
	self.trainsetData = {}
	self.trainsetData = deepcopy(newTrainSet)
	if self.childCarID then
	  if world.entityExists(self.childCarID) then
	    --world.sendEntityMessage(self.childCarID, "invert", (storage.carNumber - 1), self.railRider.speed)
        if storage.stationControlled then
          if self.logging then sb.logInfo("first car self.scheduleTimerT0 ="..tostring(self.scheduleTimerT0)) end
          local tempt0 = self.scheduleTimerT0
          world.sendEntityMessage(self.childCarID, "invert", (storage.carNumber - 1), true, storage.currentStation, storage.nextStation, storage.loopingbackstations, storage.speedMultiplier, storage.StopLenght, storage.currentTime, tempt0 )
        else
          world.sendEntityMessage(self.childCarID, "invert", (storage.carNumber - 1), false)
        end
		self.parentCarId = self.childCarID
		self.childCarID = nil
	  end
	end
  end
end

function onRailStopAndInverted(state)
  storage.onRailStopAndInverted = state
  if self.logging then sb.logInfo("\nCar number " .. tostring(storage.carNumber) .. "function onRailStopAndInverted(state) state=" .. tostring(storage.onRailStopAndInverted) ) end
end

function handleInvert(_, _, carNumber, stationControlled, currentStation, nextStation, loopingbackstations, speedMultiplier, StopLenght, currentTime, scheduleTmrT0)

   if self.logging then sb.logInfo("\nCar number" .. storage.carNumber .. " received message from parent car: CAR " .. tostring(carNumber) .. " INVERT") end
   
   if stationControlled and storage.lastCar then
     storage.currentStation = currentStation
     storage.nextStation = nextStation
     storage.loopingbackstations = loopingbackstations
     storage.speedMultiplier = speedMultiplier
     storage.StopLenght = StopLenght
     storage.currentTime = currentTime
     self.scheduleTimerT0 = scheduleTmrT0
     if self.logging then sb.logInfo("last car self.scheduleTimerT0 ="..tostring(self.scheduleTimerT0)) end
     if self.scheduleTimerT0 == nil then
      self.scheduleTimerT0 = world.time()
      if self.logging then sb.logInfo("self.scheduleTimerT0==nil now is " .. tostring(self.scheduleTimerT0)) end
    end
     storage.scheduleTimer = 0
     storage.scheduleTimeDiff = 0
   end
   
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
    
    --if bumperpresent then
      --start(self.approachingBumperSpeedLimit)
    --else
      self.railRider.direction = (self.railRider.direction + 3) % 8 + 1
      self.railRider:findNextNode()
    --end
	
	calculateTargetDistanceToChild()
	
	regulateSpeedOfChildcar(self.childCarID)
    
    if self.railRider.facing > 0 then
      if self.hasHeadlight then
        animator.setLightActive("headlightBeam", false)
        animator.setAnimationState("headlight", "off")
      end

      if self.hasRevHeadlight then
        animator.setLightActive("reverseheadlightBeam", true)
        animator.setAnimationState("reverseheadlight", "on")
      end
      if self.hasTaillight then
        animator.setLightActive("taillight", false)
        animator.setAnimationState("taillight", "off")
      end
      if self.hasRevTaillight then
        animator.setLightActive("reversetaillight", false)
        animator.setAnimationState("reversetaillight", "off")
      end
    else
      if self.hasHeadlight then
        animator.setLightActive("headlightBeam", true)
        animator.setAnimationState("headlight", "on")
      end
      if self.hasRevHeadlight then
        animator.setLightActive("reverseheadlightBeam", false)
        animator.setAnimationState("reverseheadlight", "off")
      end
      if self.hasTaillight then
        animator.setLightActive("taillight", false)
        animator.setAnimationState("taillight", "off")
      end
      if self.hasRevTaillight then
        animator.setLightActive("reversetaillight", false)
        animator.setAnimationState("reversetaillight", "off")
      end
    end
  else
    storage.carNumber = carNumber
	self.railRider.direction = (self.railRider.direction + 3) % 8 + 1
	self.railRider:findNextNode()
	
	calculateTargetDistanceToChild()
	
	if self.childCarID then
	  if world.entityExists(self.childCarID) then
	    --world.sendEntityMessage(self.childCarID, "invert", (carNumber - 1), newSpeed)
		if stationControlled then
          world.sendEntityMessage(self.childCarID, "invert", (storage.carNumber - 1), true, currentStation, nextStation, loopingbackstations, speedMultiplier, StopLenght, currentTime, scheduleTmrT0 )
        else
          world.sendEntityMessage(self.childCarID, "invert", (storage.carNumber - 1), false)
        end
		local oldChildCar = self.childCarID
		local oldParentCar = self.parentCarId
		self.childCarID = oldParentCar
		self.parentCarId = oldChildCar
	  end
	end
  end
  
end

function handleStopGroup(_, _)
  if storage.firstCar then
    if self.logging then sb.logInfo("Car n " .. tostring(storage.carNumber) .. " Received message STOPGROUP as FIRSTCAR") end
    destroyVehicle(true)
  else
    if self.parentCarId then
      if self.logging then sb.logInfo("Car n " .. tostring(storage.carNumber) .. " Received message STOPGROUP") end
      if world.entityExists(self.parentCarId) then world.sendEntityMessage(self.parentCarId, "stopGroup") end
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
  
  if self.logging then sb.logInfo("\nCar number " .. tostring(storage.carNumber) .. " DESTROYED") end
  vehicle.destroy()
  
end