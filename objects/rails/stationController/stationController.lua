require "/scripts/util.lua"

function init()

  object.setInteractive(true)
  
  storage.stopLenght = (config.getParameter("stopLenght", 6))
  
  self.settingsConfig = root.assetJson("/interface/linkedTrain/trainConfigurator/settings.json")
  self.logging = self.settingsConfig.logging
  self.defaultTrainset = self.settingsConfig.defaultTrainset
  self.testVehicleName = self.settingsConfig.itemName

  self.countdown = 0
  
  --if self.uuidtimer0 == nil then
    --self.uuidtimer0 = world.time()
    --self.uuidtimerBool = true
  --end
  
  self.uuidInit = false
  self.init = true
  
  storage.slottedItem = nil
  
  message.setHandler("forceReloadData", forceReloadData)
  message.setHandler("startTestRun", startTestRun) --message sent from GUI to station nr1 of group to initiate test run
  message.setHandler("testRunMode", testRunMode) --message sent from station 1 to other stations of the group to wait for incoming car
  message.setHandler("endTestRun", endTestRun) --message sent from last station of the group to station 1 to end the test run and calculate times from absolute times stored in save file
  message.setHandler("testRunCarArrivedAt", testRunCarArrivedAt) --message sent from car when arriving at a station
  message.setHandler("testRunGetlastCarID", testRunGetlastCarID) --message recieved from last Car with their ID (in case train set invert)
  message.setHandler("testRunCarInverted", testRunCarInverted) --message received from test run trainset to inform train set has inverted direction (and cars order)
  message.setHandler("startTrains", startTrains)
  message.setHandler("stopTrains", stopTrains)
  message.setHandler("startMoreLines", startMoreLines)
  
  message.setHandler("receiveTime", receiveTime)
  
end

function forceReloadData(_,_, pane, dontLog, nodepos)

  if nodepos then
    initNodePos()
  else
    storage.saveFile = world.getProperty("stationController_file")
    if self.logging then sb.logInfo("FORCING DATA RELOAD: ") end
    local oldnumber = self.stationNum
    self.stationNum = storage.saveFile[storage.uuid].number
    if self.stationNum == oldnumber then
      if self.logging then sb.logInfo("STATION NUMBER " .. tostring(self.stationNum)) end
    else
      if self.logging then sb.logInfo("STATION NUMBER " .. tostring(oldnumber) .. "IS NOW NUMBER " .. tostring(self.stationNum)) end
    end
  
    if not dontLog then
      if self.logging then sb.logInfo("SAVE FILE AS FOLLOWS: ") end
    end
  
    if storage.saveFile[storage.uuid].grouped then
      storage.group = storage.saveFile[storage.uuid].group
      storage.grouped = true
      storage.numInGroup = storage.saveFile[storage.group][storage.uuid].number
      self.circularLine = storage.saveFile.global[storage.group].data.circular
      self.numOfStationsInGroup = storage.saveFile.global[storage.group].data.numOfStationsInGroup
    end
  
    if storage.saveFile and not dontLog then
      if self.logging then tprint(storage.saveFile) end
    end
  
    if pane then
      for i=1,storage.saveFile.global.numOfStations do
        if storage.saveFile[tostring(i)].uuid ~= storage.uuid then
          local id = world.loadUniqueEntity(tostring(storage.saveFile[tostring(i)].uuid))
          if id then
            if world.entityExists(id) then
            world.sendEntityMessage(id, "forceReloadData", false)
            end
          end
        end
      end
    end
    
  end
  
end

function startMoreLines(_,_,groupstostart)
  self.spawningmorelinestable = {}
  self.spawningmorelinesallready = true
  self.spawningmorelinesfailednum = 0
  for key, value in pairs(groupstostart) do
    local groupname = key
    local ready = value
    if ready then
      self.spawningmorelinestable[groupname] = {}
      self.spawningmorelinestable[groupname].numberOfTrainsE = storage.saveFile.global[groupname].data.numberOfTrainsE
      self.spawningmorelinestable[groupname].numberOfTrainsW = storage.saveFile.global[groupname].data.numberOfTrainsW
      self.spawningmorelinestable[groupname].uuid = storage.saveFile.global[groupname].data.uuids[1]
      if storage.group == nil then
        storage.group = storage.saveFile[storage.uuid].group
      end
      if groupname == storage.group then
        entityid = entity.id()
        self.spawningmorelinestable[groupname].idvalid = true
      else
        local entityid = world.loadUniqueEntity(storage.saveFile.global[groupname].data.uuids[1])
        self.spawningmorelinestable[groupname].id = entityid
        if entityid then
          if world.entityExists(entityid) then
            self.spawningmorelinestable[groupname].idvalid = true
          else
            self.spawningmorelinestable[groupname].idvalid = false
            self.spawningmorelinesallready = false
            self.spawningmorelinesfailednum = self.spawningmorelinesfailednum + 1
          end
        else
          self.spawningmorelinestable[groupname].idvalid = false
          self.spawningmorelinesallready = false
          self.spawningmorelinesfailednum = self.spawningmorelinesfailednum + 1
        end
      end
    end
    --world.sendEntityMessage(world.loadUniqueEntity(storage.saveFile.global[groupname].data.uuids[1]), "startTrains", groupname, numberOfTrainsE, numberOfTrainsW)
  end
  if self.spawningmorelinesallready then
    for key, value in pairs(self.spawningmorelinestable) do
      if self.logging then tprint(value) end
      local groupname = key
      if self.logging then sb.logInfo("groupname=" .. tostring(groupname)) end
      local numberOfTrainsE = value.numberOfTrainsE
      local numberOfTrainsW = value.numberOfTrainsW
      if self.logging then 
        sb.logInfo("numberOfTrainsE=" .. tostring(numberOfTrainsE))
        sb.logInfo("numberOfTrainsW=" .. tostring(numberOfTrainsW))
      end
      if groupname == storage.group then
        startTrains(_,_, groupname, numberOfTrainsE, numberOfTrainsW)
      else
        local entityid = value.id
        
        world.sendEntityMessage(entityid, "startTrains", groupname, numberOfTrainsE, numberOfTrainsW)
      end
    end
  else
    if self.logging then sb.logInfo("could not get all entity ids of all lines, trying again in 3 seconds") end
    self.spawningmorelinesfailed = true
    self.spawningmorelinesfailedTimer = 0
    self.spawningmorelinesfailedTimerT0 = world.time()
  end
end

function stopTrains(_,_)
  if not self.spawnedTrainsIDs then
    self.spawnedTrainsIDs = {}
    self.spawnedTrainsIDs.E = {}
    self.spawnedTrainsIDs.W = {}
  end
  
  if not storage.numberOfTrainsE then
    storage.saveFile = world.getProperty("stationController_file")
    storage.numberOfTrainsE = storage.saveFile.global[storage.group].data.numberOfTrainsE
  end
  if not storage.numberOfTrainsW then
    storage.saveFile = world.getProperty("stationController_file")
    storage.numberOfTrainsW = storage.saveFile.global[storage.group].data.numberOfTrainsW
  end
  
  if self.logging then sb.logInfo(tostring(storage.group) .. " SHUTTING DOWN TRAINS") end
    
  if storage.numberOfTrainsE > 0 then
    
    for t=1,storage.numberOfTrainsE do
      self.spawnedTrainsIDs.E[t] = world.getProperty(storage.group .. "trainsidsE_" .. tostring(t))
    end
    if self.logging then 
      sb.logInfo(tostring(storage.group) .. " Entity IDs East:")
      tprint(self.spawnedTrainsIDs.E)
    end
    
    if self.spawnedTrainsIDs.E then
      for i=1,storage.numberOfTrainsE do
        if self.spawnedTrainsIDs.E[i] then
          if self.logging then sb.logInfo("=================ATTEMPTING TO SHUT DOWN TRAIN ".. tostring(i) .." EAST (" .. tostring(storage.group) .. ")==========") end
          if world.entityExists(self.spawnedTrainsIDs.E[i]) then
            if self.logging then sb.logInfo("Train " .. tostring(i) .. "-E Exist sending message") end
            world.sendEntityMessage(self.spawnedTrainsIDs.E[i], "stopGroup")
          end
        end
      end
    end
  end
  if storage.numberOfTrainsW > 0 then
    
    for t=1,storage.numberOfTrainsW do
      self.spawnedTrainsIDs.W[t] = world.getProperty(storage.group .. "trainsidsW_" .. tostring(t))
    end
    if self.logging then 
      sb.logInfo(tostring(storage.group) .. " Entity IDs West:")
      tprint(self.spawnedTrainsIDs.W)
    end
    
    if self.spawnedTrainsIDs.W then
      for i=1,storage.numberOfTrainsW do
        if self.spawnedTrainsIDs.W[i] then
          if self.logging then sb.logInfo("=================ATTEMPTING TO SHUT DOWN TRAIN ".. tostring(i) .." WEST (" .. tostring(storage.group) .. ")==========") end
          if world.entityExists(self.spawnedTrainsIDs.W[i]) then
            if self.logging then sb.logInfo("Train " .. tostring(i) .. "-W Exist sending message") end
            world.sendEntityMessage(self.spawnedTrainsIDs.W[i], "stopGroup")
          end
        end
      end
    end
  end
  
  storage.saveFile.global[storage.group].data.operational = false
  world.setProperty("stationController_file", storage.saveFile)
end

function startTrains(_,_, group,ntrainE,ntrainW)
  self.vehicleFile = world.getProperty("stationController_vehicles_file")
  ----tprint(self.vehicleFile)
  ----tprint(self.vehicleFile[group].trainsEast)
  
  if self.logging then sb.logInfo("==============STARTING TRAINS FOR GROUP=" .. tostring(group) .. " ntrainE=" .. tostring(ntrainE) .. " ntrainW=" .. tostring(ntrainW)) end
  
  storage.saveFile = world.getProperty("stationController_file")
  
  storage.numberOfTrainsE = ntrainE
  storage.numberOfTrainsW = ntrainW
  
  local starttimesE
  local starttimesW
  local startStationE
  local startStationW
  local timesMerged = {}
  local timesraw={}
  
  if ntrainE > 0 then
    starttimesE = storage.saveFile.global[group].data.trainsEast.startTimes
    startStationE = storage.saveFile.global[group].data.trainsEast.startStations
    for i, v in ipairs(starttimesE) do
      local vehicleItem = self.vehicleFile[group].trainsEast[i]
      --if vehicleItem then tprint(vehicleItem) end
        table.insert(timesMerged, {train=i,direction="E",startTime=tonumber(v),startStation=startStationE[i],vehicle=vehicleItem})
    end
  end
  
  if ntrainW > 0 then
    starttimesW = storage.saveFile.global[group].data.trainsWest.startTimes
    startStationW = storage.saveFile.global[group].data.trainsWest.startStations
    for i, v in ipairs(starttimesW) do
      local vehicleItem = self.vehicleFile[group].trainsWest[i]
      table.insert(timesMerged, {train=i,direction="W",startTime=tonumber(v),startStation=startStationW[i],vehicle=vehicleItem})
    end
  end

  --sb.logInfo("============timesMerged===============================")
  --tprint(timesMerged)
  --sb.logInfo("============")
  
  
  if ntrainE > 0 then
    for _, v in ipairs(starttimesE) do
      table.insert(timesraw, tonumber(v))
    end
  end
  if ntrainW > 0 then
    for _, v in ipairs(starttimesW) do
      table.insert(timesraw, tonumber(v))
    end
  end

  table.sort(timesraw)
  
  self.numberOfSpawnTimes = 0
  
  self.spawnTimes = {}
  flags={}
  for _,v in ipairs(timesraw) do
    if (not flags[v]) then
      self.spawnTimes[#self.spawnTimes+1] = v
      flags[v] = true
      self.numberOfSpawnTimes = self.numberOfSpawnTimes + 1
    end
  end
  if self.logging then 
    sb.logInfo("=========self.spawnTimes:")
    tprint(self.spawnTimes)
    sb.logInfo("========")
    sb.logInfo("self.numberOfSpawnTimes " .. tostring(self.numberOfSpawnTimes))
  end
  timetabletemp = {}
  self.trainstostart = {}
  
  self.numOfTrainsToSpawn = 0
  
  for i,v in ipairs(timesMerged) do
    if not timetabletemp[v.startTime] then
      timetabletemp[v.startTime] = {}
    end
    --if not self.trainstostart[i] then
      --self.trainstostart[i] = {}
    --end
    table.insert(timetabletemp[v.startTime], v)
    self.numOfTrainsToSpawn = self.numOfTrainsToSpawn + 1
    
  end
  
  
  --tprint(timetabletemp)
  
  self.timetable = {}
  for i,v in ipairs(self.spawnTimes) do
    self.timetable[i] = timetabletemp[v]
    table.insert(self.trainstostart,i,#self.timetable[i])
  end
  --sb.logInfo("=========self.self.timetable:")
  --tprint(self.timetable)
  
  if self.logging then 
    sb.logInfo("Trains to start per each time:")
    tprint(self.trainstostart)
    sb.logInfo("Total num of trains to spawn: " .. tostring(self.numOfTrainsToSpawn))
  end
  
  storage.saveFile.global[group].data.spawningTrains = true
  self.spawningTrains = true
  self.spawningTrainsInit = true
  world.setProperty("stationController_file", storage.saveFile)
  standardReload()
  
  self.spawnTrainInGroup = group
  self.stationSpawnTimer = 0
  
end

function spawnTrains(group)
  --storage.saveFile.global[group].data.operational = true
  --storage.saveFile.global[group].data.spawningTrains = true
  --self.spawningTrains = true
  --self.spawnTimes = {time1,time2,...timeN}
  --self.spawnTimes = times
  --self.trainstostart = trainstostart
  --self.trainstostart = {XTrainsForTime1,YTrainsForTime2,...ZTrainsForTimeN}
  --self.timetable = timetable
  --self.numOfTrainsToSpawn
  --self.timetable = { Time1:{{Train1Data},{Train2Data}},...TimeN:{TrainNData} }
  --self.timetable = { {{direction,startTime,train,vehicle,startStation},{direction,startTime,train,vehicle,startStation}}...{{direction,startTime,train,vehicle,startStation}} }
 
  if self.spawningTrainsInit then
    if self.logging then sb.logInfo("=================spawnTrains() init") end
    --self.numberOfSpawnTimes = #self.spawnTimes
    self.currentSpawnTimeSection = 1
    if self.logging then tprint(self.spawnTimes) end
    self.currentSpawnTime = self.spawnTimes[1]
    if self.logging then sb.logInfo("self.currentSpawnTime: " .. tostring(self.currentSpawnTime)) end
    self.trainsToSpawnForCurrentTime = self.trainstostart[1]
    self.currentTrainToSpawn = 1
    --self.currentTrainToSpawnThisTime = 1
    --self.spawnStopPos = getStopPos()
    
    self.spawnedTrainsIDs = {}
    self.spawnedTrainsIDs.E = {}
    self.spawnedTrainsIDs.W = {}
    self.listOfCars = root.assetJson("/objects/crafting/trainConfigurator/listOfCars.json")
    self.stationSpawnTimer = 0
    self.spawntime0 = world.time()
    self.spawningTrainsInit = false
    
    --storage.numberOfTrainsE = storage.saveFile.global[group].data.numberOfTrainsE
    --storage.numberOfTrainsW = storage.saveFile.global[group].data.numberOfTrainsW
    
  else
    self.stationSpawnTimer = world.time() - self.spawntime0
    --sb.logInfo("===========SpawnTimer " .. tostring(self.stationSpawnTimer) .. " next spawn at " .. tostring(self.currentSpawnTime) .. " self.currentSpawnTimeSection " .. tostring(self.currentSpawnTimeSection) .. "self.currentTrainToSpawn " .. tostring(self.currentTrainToSpawn))
  end
  
  if (self.stationSpawnTimer >= self.currentSpawnTime) then --or self.spawningTrainsInit then
    --sb.logInfo("==========================initiating next spawn sequence as per timer or init")
    if self.logging then sb.logInfo("==========================initiating next spawn sequence as per timer") end
    for t=1,self.trainsToSpawnForCurrentTime do
      local spawnOffset = {}
      local direction
      local startStation = self.timetable[self.currentSpawnTimeSection][t].startStation
      local startStationPos = storage.saveFile.global[group].data.nodesPos[startStation]
      if self.timetable[self.currentSpawnTimeSection][t].direction == "E" then
        direction = 1
        --spawnOffset[1] = self.spawnStopPos[1] + 1.5
        --spawnOffset[2] = self.spawnStopPos[2] + 1
        spawnOffset[1] = startStationPos[1] + 1.5
        --spawnOffset[2] = startStationPos[2] + 1
      else
        direction = -1
        --spawnOffset[1] = self.spawnStopPos[1] - 1.5
        --spawnOffset[2] = self.spawnStopPos[2] + 1
        spawnOffset[1] = startStationPos[1] - 1.5
        --spawnOffset[2] = startStationPos[2] + 1
      end
      spawnOffset[2] = startStationPos[2] + 1
      if self.logging then sb.logInfo("============================t is " .. tostring(t) .. " self.currentTrainToSpawn: " .. tostring(self.currentTrainToSpawn) .. " self.trainsToSpawnForCurrentTime: " .. tostring(self.trainsToSpawnForCurrentTime) ) end
      local currentTrainVehicle = self.timetable[self.currentSpawnTimeSection][t].vehicle
      local vehicleParameters = currentTrainVehicle.parameters
      vehicleParameters.initialFacing = direction
      local trainsetData = vehicleParameters.trainsetData
      local vehicleName = trainsetData[1].name
      vehicleParameters.cockpitColor =  trainsetData[1].cockpitColor
      vehicleParameters.numberOfCars = vehicleParameters.numberOfCars
      --vehicleParameters.popItem = self.itemName
      vehicleParameters.color = trainsetData[1].color
      vehicleParameters.decalNames = trainsetData[1].decalNames
      vehicleParameters.decals = trainsetData[1].decals
      vehicleParameters.pantographVisible = trainsetData[1].pantographVisibile
      vehicleParameters.doorLocked = trainsetData[1].doorLocked
      vehicleParameters.trainsetData = trainsetData
      vehicleParameters.specular = self.listOfCars[vehicleName].specular
      vehicleParameters.reversed = trainsetData[1].reversed
      vehicleParameters.firstCar = true
      vehicleParameters.lastcar = false
      vehicleParameters.carNumber = 1
      vehicleParameters.originalCar = true
      
      --vehicleParameters.nospeeddebug = true
      --sb.logInfo("======================================VEHICLE PARAMETERS========================")
      --tprint(vehicleParameters)
      --sb.logInfo("================================================================================")
      
      --self.spawnedTrainsIDs[t] = world.spawnVehicle(vehicleName, spawnOffset, vehicleParameters)
      
      if direction == 1 then
        local trainNum = self.timetable[self.currentSpawnTimeSection][t].train
        if self.logging then 
          sb.logInfo("=================self.timetable[self.currentSpawnTimeSection][t]")
          tprint(self.timetable[self.currentSpawnTimeSection][t])
          sb.logInfo("Direction E, trainNum =" .. tostring(trainNum))
        end
        --self.spawnedTrainsIDs.E[trainNum] = world.spawnVehicle(vehicleName, spawnOffset, vehicleParameters)
        local trainEntity = world.spawnVehicle(vehicleName, spawnOffset, vehicleParameters)
        if trainEntity then
           if not world.entityExists(trainEntity) then
             sb.logInfo("================Train Spawn Failed, Entity don't exist=================")--handle how to start over
           else
             if self.logging then sb.logInfo("===========================Train spawned succesfull self.currentTrainToSpawn: " .. tostring(self.currentTrainToSpawn) .. " t is ".. tostring(t) .. " entity ID: " .. tostring(trainEntity)) end
             self.currentTrainToSpawn = self.currentTrainToSpawn + 1
             self.spawnedTrainsIDs.E[trainNum] = trainEntity
             world.setProperty(group .. "trainsidsE_" .. tostring(trainNum) , trainEntity)
           end
        else
          sb.logInfo("================Train Spawn Failed, entity is " .. tostring(trainEntity) .. "=================") --nil=handle how to start over
        end
      else
        local trainNum = self.timetable[self.currentSpawnTimeSection][t].train
        if self.logging then 
          sb.logInfo("=================self.timetable[self.currentSpawnTimeSection][t]")
          tprint(self.timetable[self.currentSpawnTimeSection][t])
          sb.logInfo("Direction W, trainNum =" .. tostring(trainNum))
        end
        --self.spawnedTrainsIDs.W[trainNum] = world.spawnVehicle(vehicleName, spawnOffset, vehicleParameters)
        local trainEntity = world.spawnVehicle(vehicleName, spawnOffset, vehicleParameters)
        if trainEntity then
          if not world.entityExists(trainEntity) then
            sb.logInfo("================Train Spawn Failed, Entity don't exist=================") --handle how to start over
          else
            if self.logging then sb.logInfo("===========================Train spawned succesfull self.currentTrainToSpawn: " .. tostring(self.currentTrainToSpawn) .. " t is ".. tostring(t) .. " entity ID: " .. tostring(trainEntity)) end
            self.currentTrainToSpawn = self.currentTrainToSpawn + 1
            self.spawnedTrainsIDs.W[trainNum] = trainEntity
            world.setProperty(group .. "trainsidsW_" .. tostring(trainNum) , trainEntity)
          end
        else
          sb.logInfo("================Train Spawn Failed, entity is " .. tostring(trainEntity) .. "=================") --nil=handle how to start over
        end
      end
      
      --if self.spawningTrainsInit and (t == 1) then
        --self.spawntime0 = world.time()
        --self.stationSpawnTimer = world.time() - self.spawntime0
        --self.spawningTrainsInit = false
        --sb.logInfo("====================first spawn sequence, initiating T0:" .. tostring(self.spawntime0) .. " Spawntimer: " .. tostring(self.stationSpawnTimer))
      --end
      
    end
    self.currentSpawnTimeSection = self.currentSpawnTimeSection + 1
    if self.currentSpawnTimeSection <= self.numberOfSpawnTimes then
      if self.logging then 
        sb.logInfo("==========================self.currentSpawnTimeSection <= self.numberOfSpawnTimes======================")
        sb.logInfo("self.currentSpawnTime before: " .. tostring(self.currentSpawnTime) .. " self.currentSpawnTimeSection: " .. tostring(self.currentSpawnTimeSection))
      end
      self.currentSpawnTime = self.spawnTimes[self.currentSpawnTimeSection]
      if self.logging then 
        sb.logInfo("self.currentSpawnTime after: " .. tostring(self.currentSpawnTime) .. " self.currentSpawnTimeSection: " .. tostring(self.currentSpawnTimeSection))
      end
      self.trainsToSpawnForCurrentTime = self.trainstostart[self.currentSpawnTimeSection]
    else
      self.spawningTrains = false
      storage.saveFile.global[group].data.operational = true
      storage.groupOperational = true
      storage.operational = true
      storage.saveFile.global[group].data.spawningTrains = false
      storage.trainsUninit = false
      world.setProperty("stationController_file", storage.saveFile)
      standardReload()
            
      if self.logging then 
        sb.logInfo("=======================Train Spawn Ended============================")
        sb.logInfo("Entity IDs of trains")
      end
      if self.spawnedTrainsIDs.E then
        if self.logging then 
          sb.logInfo("East:")
          tprint(self.spawnedTrainsIDs.E)
        end
      end
      if self.spawnedTrainsIDs.W then
        if self.logging then 
          sb.logInfo("West:")
          tprint(self.spawnedTrainsIDs.W)
        end
      end
      if self.logging then sb.logInfo("Nr. of trains East= " .. tostring(storage.numberOfTrainsE) .. " Nr. of trains West= " .. tostring(storage.numberOfTrainsW)) end
    end
  end
  
end

function standardReload()
  for i=1,storage.saveFile.global.numOfStations do
    if storage.saveFile[tostring(i)].uuid ~= storage.uuid then
      local id = world.loadUniqueEntity(tostring(storage.saveFile[tostring(i)].uuid))
      if id then
        if world.entityExists(id) then
          world.sendEntityMessage(id, "forceReloadData", false, true)
        end
      end
    end
  end
end

function getOrderedGroupList(groupName)

  local members = {}
    
  for k,v in pairs(storage.saveFile[groupName]) do
    --sb.logInfo("k " .. tostring(k) .. " v " .. tostring(v))
    local number = storage.saveFile[groupName][k].number
    --sb.logInfo("number " .. tostring(number))
    members[number] = k
    --sb.logInfo("members[number] " .. tostring(members[number]))
  end

  return members
 
end

function startTestRun(_,_,numOfTestRuns,totalTestRuns,addtestruns)
  
  self.addTestRuns = addtestruns
  
  self.numOfTestRunTodo = numOfTestRuns
  self.testrunStartFrom = totalTestRuns
  self.currentTestRun = 1
  
  if self.logging then 
    sb.logInfo("====station nr " .. tostring(storage.numInGroup) .. " group " .. storage.group .. " TEST RUN INIT=====")
    sb.logInfo("==========TEST RUN INIT======= self.numOfTestRunTodo = " ..tostring(self.numOfTestRunTodo) .. " self.testrunStartFrom = " .. tostring(self.testrunStartFrom))
  end
  storage.saveFile = world.getProperty("stationController_file")
  self.circularLine = storage.saveFile.global[storage.group].data.circular
  if self.logging then 
    sb.logInfo("CIRCULAR: " .. tostring(self.circularLine))
  end
  self.waitingToCloseLoop = false
  self.testRunInit = true
  self.stationsData = {}
  local members = {}
  local index = 0
  --self.nonReadyStations = 0
  if not self.numOfStationsInGroup then
    self.numOfStationsInGroup = storage.saveFile.global[storage.group].data.numOfStationsInGroup
  end
  
  self.stationsData = {}
  self.stationsData.nodePos = {}
  self.stationsData.id = {}
  self.stationsData.ready = {}
  self.stationsData.ready[1] = true
  self.stationsData.id[1] = entity.id()
  self.stationsData.nodePos = storage.saveFile.global[storage.group].data.nodesPos
  for i=2,self.numOfStationsInGroup do
    self.stationsData.ready[i] = false
  end
  
  if self.logging then sb.logInfo("ITERATION ==========================================") end
  for k,v in pairs(storage.saveFile[storage.group]) do
    --self.numOfStationsInGroup = self.numOfStationsInGroup + 1  
    index = storage.saveFile[storage.group][k].number
    members[index] = k
    if self.logging then sb.logInfo("k " .. tostring(k) .. " index " .. tostring(index)) end
    if k ~= storage.uuid then
      local id = world.loadUniqueEntity(k)
      if (id ~= nil) and (id ~= 0 ) then
        self.stationsData.id[index] = id
        self.stationsData.ready[index] = true
      end
    end
  end
  if self.logging then 
    sb.logInfo("MEMBERS ==========================================")
    tprint(members)
  end
  self.testRunReady = true
  for i=2,self.numOfStationsInGroup do
    if not self.stationsData.ready[i] then
      --self.nonReadyStations = self.nonReadyStations + 1
      self.testRunReady = false
      break
    end
  end

  if self.logging then sb.logInfo("Stations data printed from station ")
    tprint(self.stationsData)
    sb.logInfo("testRunReady " .. tostring(self.testRunReady))
    sb.logInfo("NUM OF STATIONS IN GROUP " .. tostring(self.numOfStationsInGroup))
  end
  
  world.setProperty("stationController_file", storage.saveFile)
  
  if self.testRunReady then
    testRunInit()
  end
  
end

function getStopPos()
  local stopPos = {}
  local stopID = 0
  if object.isOutputNodeConnected(0) then
    local stopNodeIDs = object.getOutputNodeIds(0)
    for k,v in pairs(stopNodeIDs) do
        stopID = k
    end
    stopPos = world.entityPosition(stopID)
  end
  
  return stopPos
end

function testRunInit()
  
  storage.saveFile = world.getProperty("stationController_file")
  
  if self.logging then sb.logInfo("====station nr " .. tostring(storage.numInGroup) .. " group " .. storage.group .. " TEST RUN STARTED=====") end
  
  self.testRunMode = true
  if self.logging then sb.logInfo("CIRCULAR: " .. tostring(self.circularLine)) end
  
  --self.defaultTrainset = self.settingsConfig.defaultTrainset
  --self.testVehicleName = self.settingsConfig.itemName
  
  --send message to all stations to enter test run mode
  
  self.testRunvehicleName = self.defaultTrainset[1].name
  self.testRunvehicleParameters = {}
  local listOfCars = root.assetJson("/objects/crafting/trainConfigurator/listOfCars.json")
  self.testRunvehicleParameters.cockpitColor = self.defaultTrainset[1].cockpitColor
  self.testRunvehicleParameters.initialFacing = 1 --account for left or right facing direction
  self.testRunvehicleParameters.numberOfCars = 3 --tonumber(storage.slottedItem.parameters.trainsetData.numberOfCars)
  ----self.testRunvehicleParameters.popItem = self.itemName --account for testrun mode in rail cars and a custom message to destroy chain without popitem
  self.testRunvehicleParameters.color = self.defaultTrainset[1].color
  self.testRunvehicleParameters.decalNames = self.defaultTrainset[1].decalNames
  self.testRunvehicleParameters.decals = self.defaultTrainset[1].decals
  self.testRunvehicleParameters.pantographVisible = self.defaultTrainset[1].pantographVisibile
  self.testRunvehicleParameters.doorLocked = self.defaultTrainset[1].doorLocked
  self.testRunvehicleParameters.trainsetData = self.defaultTrainset
  self.testRunvehicleParameters.specular = listOfCars[self.testRunvehicleName].specular
  self.testRunvehicleParameters.reversed = self.defaultTrainset[1].reversed
  self.testRunvehicleParameters.firstCar = true
  self.testRunvehicleParameters.lastcar = false
  self.testRunvehicleParameters.carNumber = 1
    
  local stopPos = getStopPos()
  
  if self.logging then sb.logInfo("station nr " .. tostring(storage.numInGroup) .. " pos of connected nodes ")
    --stopPos = world.entityPosition(stopID)
    sb.logInfo("pos " .. tostring(stopPos))
    tprint(stopPos)
  end
    --handle error of stop node not connected

  --SPANW CAR:
  self.testRunspawnoffset = {}
  self.testRunspawnoffset[1] = stopPos[1] + 1
  self.testRunspawnoffset[2] = stopPos[2] + 1
  self.testRunCarID0 = world.spawnVehicle(self.testRunvehicleName, self.testRunspawnoffset, self.testRunvehicleParameters)
  if not self.testRunCarID0 then
    --handle car not spawn error
    self.testRunReady = false
    return
  end
  
  self.testrunT0 = world.time()
  
  self.timesABS = {}
  self.timesABS[1] = self.testrunT0
  
  if self.logging then 
    sb.logInfo("self.timesABS for testrun nr. " .. tostring(self.currentTestRun) .. " total testruns to do " .. tostring(self.numOfTestRunTodo))
    tprint(self.timesABS)
  end
  
  self.testRuns = {}
  
  local numStations = self.numOfStationsInGroup
  
  world.sendEntityMessage(self.testRunCarID0, "testRunModeEnabled", numStations, self.stationsData, self.stationsData.nodePos, self.circularLine)
  
  if self.logging then sb.logInfo("station " .. tostring(storage.numInGroup) .. " T0 " .. tostring(self.testrunT0) ) end
    
  world.setProperty("stationController_file", storage.saveFile)

  local testCar = self.testRunCarID0

  for i=2,self.numOfStationsInGroup do
    local id = self.stationsData.id[i]
    world.sendEntityMessage(id, "testRunMode", testCar, numStations, self.testrunT0, self.numOfTestRunTodo, self.testrunStartFrom, self.currentTestRun, entity.id()) 
  end
  
  self.testRunInit = false
  
end

function testRunMode(_,_, carID, numOfStations, T0, numOfTestRuns, totalTestRuns, currentTestRun, firstStationId)
  storage.saveFile = world.getProperty("stationController_file")
  
  self.firstStationId = firstStationId
  
  self.numOfTestRunTodo = numOfTestRuns
  self.testrunStartFrom = totalTestRuns
  self.currentTestRun = currentTestRun
  self.testRunMode = true
  self.testRunCarID0 = carID
  self.numOfStationsInGroup = numOfStations
  self.testrunT0 = T0
  if self.logging then
    sb.logInfo("Station nr " .. tostring(storage.numInGroup) .. " TEST RUN ON, num of stations " .. tostring(self.numOfStationsInGroup) .. " self.numOfTestRunTodo = " .. tostring(self.numOfTestRunTodo) .. " self.testrunStartFrom = " .. tostring(self.testrunStartFrom) .. " currentTestRun = " .. tostring(self.currentTestRun))
    if (storage.numInGroup == self.numOfStationsInGroup) then
      sb.logInfo("==================Last station received the TEST RUN MSG==============================")
    end
  end
  
end

function endTestRun(_,_)
  
  if self.logging then sb.logInfo("station " .. tostring(storage.numInGroup) .. " received message test run ended ") end
  
  storage.saveFile = world.getProperty("stationController_file")
  
  self.grouptestrunfile = world.getProperty(storage.group .. "_testrun_file")
  
  if storage.numInGroup == 1 then
    if self.testRunMode and self.circularLine then
      self.waitingToCloseLoop = true
    elseif self.testRunMode and not self.circularLine then
      self.currentTestRun = self.currentTestRun + 1
      if self.currentTestRun > self.numOfTestRunTodo then
        
        --self.testRuns[self.currentTestRun - 1] = deepcopy(self.timesABS)
        table.insert(self.testRuns, self.timesABS)
        self.timesABS = nil
        
        if self.logging then 
          sb.logInfo("===========Test run nr. " .. tostring(self.currentTestRun - 1) .. " completed. TestRuns table as follows:")
          tprint(self.testRuns)
        end
        
        storage.saveFile.global[storage.group].data.testrunsnum = storage.saveFile.global[storage.group].data.testrunsnum + self.numOfTestRunTodo
        storage.saveFile.global[storage.group].data.testRunsABS = self.testRuns
        
        storage.saveFile.global[storage.group].data.testRunCompleted = true
        storage.saveFile.global[storage.group].data.operational = false
        --self.grouptestrunfile.testrunsnum = self.grouptestrunfile.testrunsnum + self.numOfTestRunTodo
        self.testRunMode = false
        world.setProperty("stationController_file", storage.saveFile)
        
        calculateTimes()
        
      else
        --do the next test run
        
        self.testRuns[self.currentTestRun - 1] = deepcopy(self.timesABS)
        self.timesABS = nil
        if self.logging then 
          sb.logInfo("===========Test run nr. " .. tostring(self.currentTestRun - 1) .. " completed. TestRuns table as follows:")
          tprint(self.testRuns)
        end
        
        self.testRunMode = true
        self.testRunCarID0 = world.spawnVehicle(self.testRunvehicleName, self.testRunspawnoffset, self.testRunvehicleParameters)
        self.testrunT0 = world.time()
        
        self.timesABS = {}
        self.timesABS[1] = self.testrunT0
        
        local numStations = self.numOfStationsInGroup
        world.sendEntityMessage(self.testRunCarID0, "testRunModeEnabled", numStations, self.stationsData, self.stationsData.nodePos, self.circularLine )
        
        --self.grouptestrunfile.times[testRunIndex] = {}
        --self.grouptestrunfile.times[testRunIndex][1] = 0
        --self.grouptestrunfile.timesABS[testRunIndex] = {}
        --self.grouptestrunfile.timesABS[testRunIndex][1] = self.testrunT0
        world.setProperty("stationController_file", storage.saveFile)
        
        standardReload()
        local testCar = self.testRunCarID0
        for i=2,self.numOfStationsInGroup do
          local id = self.stationsData.id[i]
          world.sendEntityMessage(id, "testRunMode", testCar, numStations, self.testrunT0, self.numOfTestRunTodo, self.testrunStartFrom, self.currentTestRun, entity.id())
        end
      end
      
      --calculate times not circular line
      --for i=2,self.numOfStationsInGroup do
        --local t1 = storage.saveFile.global[storage.group].data.times[i] - storage.saveFile.global[storage.group].data.times[i-1]
        --storage.saveFile.global[storage.group].data.times[i] = t1
      --end
      --storage.saveFile.global[storage.group].data.times[1] = 0
      --world.setProperty("stationController_file", storage.saveFile)
      
      --for i=1,storage.saveFile.global.numOfStations do
        --if storage.saveFile[tostring(i)].uuid ~= storage.uuid then
          --local id = world.loadUniqueEntity(tostring(storage.saveFile[tostring(i)].uuid))
          --if id then
            --if world.entityExists(id) then
              --world.sendEntityMessage(id, "forceReloadData", false)
            --end
          --end
        --end
      --end
      
    end
  end
  
end

function calculateTimes()
  
  storage.saveFile = world.getProperty("stationController_file")
  
  local testrunsnum = storage.saveFile.global[storage.group].data.testrunsnum
  local timesABS = storage.saveFile.global[storage.group].data.testRunsABS
  --default stop lenght = storage.stopLenght
  --self.numOfStationsInGroup
  --self.circularLine
  
  --self.numOfTestRunTodo
  
  local totalTestRunsSoFar = storage.saveFile.global[storage.group].data.testrunsnum - self.numOfTestRunTodo
  
  local numStations = self.numOfStationsInGroup
  
  if self.circularLine then
    numStations = numStations +1
  end
  
  local times = {}
  local timesTidy = {}
  local timesAVG = {}
  local timesMIN = {}
  local timesMAX = {}
  
  for t=1,self.numOfTestRunTodo do
    for s=1,numStations do
      local T0
      if s == 1 then
        times[t] = {}
        times[t][1] = 0
      else
        local T0 = timesABS[t][s-1]
        times[t][s] = timesABS[t][s] - T0
      end
    end    
  end
  if self.logging then 
    sb.logInfo("times relative:")
    tprint(times)
  end
  
  for t=1,self.numOfTestRunTodo do
    for s=1,numStations do
      if s == 1 then
        timesTidy[t] = {}
        timesTidy[t][1] = 0
      else
        if s > 2 then
          --timesTidy[t][s] = times[t][s] - storage.stopLenght
          --timesTidy[t][s] = (math.floor((times[t][s] * 10) + 0.5)/10) - storage.stopLenght
          timesTidy[t][s] = (math.floor(((times[t][s] - storage.stopLenght) * 10) + 0.5) / 10)
        else
          --timesTidy[t][s] = times[t][s]
          timesTidy[t][s] = (math.floor((times[t][s] * 10) + 0.5) / 10)
        end
      end
    end    
  end
  
  if self.addTestRuns then
    if self.logging then 
      sb.logInfo("Adding testruns to dataset")
      sb.logInfo("current DataSet=")
      tprint(storage.saveFile.global[storage.group].data.testRunsTimes)
    end
        
    local toappend = storage.saveFile.global[storage.group].data.testRunsTimes
    
    local arrayLen = #timesTidy
    
    for i=1,totalTestRunsSoFar do
      timesTidy[arrayLen+i] = {}
      timesTidy[arrayLen+i] = toappend[i]
    end
    
    storage.saveFile.global[storage.group].data.testRunsTimesAVG = nil
    storage.saveFile.global[storage.group].data.testRunsTimesMIN = nil
    storage.saveFile.global[storage.group].data.testRunsTimesMAX = nil
  end
  
  if self.logging then 
    sb.logInfo("times relative(tidy):")
    tprint(timesTidy)
  end
  
  local timesByStation = {}
  timesByStation[1] = {}
  for s=2,numStations do
    timesByStation[s] = {}
    for t=1,testrunsnum do
      if t==1 then
        timesByStation[s][t] = {}
      end
      timesByStation[s][t] = timesTidy[t][s]
    end
  end
  if self.logging then
    sb.logInfo("times by station:")
    tprint(timesByStation)
  end
  
  local timesSorted = {}
  timesSorted[1] = {}
  for s=2,numStations do
    timesSorted[s] = {}
    local dataSorted = deepcopy(timesByStation[s])
    table.sort(dataSorted)
    timesSorted[s] = dataSorted
  end
  
  if self.logging then
    sb.logInfo("times by Station (sorted):")
    tprint(timesSorted)
  end
  
  timesMIN[1] = 0
  for s=2,numStations do
    timesMIN[s] = timesSorted[s][1]
  end
  
  if self.logging then
    sb.logInfo("times MIN:")
    tprint(timesMIN)
  end
  
  timesMAX[1] = 0
  for s=2,numStations do
    --timesMAX[s] = timesSorted[s][testrunsnum]
    timesMAX[s] = math.ceil(timesSorted[s][testrunsnum])
  end
  if self.logging then
    sb.logInfo("times MAX:")
    tprint(timesMAX)
  end
  
  timesAVG[1] = 0
  for s=2,numStations do
    local timeSum = 0
    for t=1,testrunsnum do
      timeSum = timeSum + timesByStation[s][t]
    end
    timesAVG[s] = timeSum / testrunsnum
  end
  
  if self.logging then
    sb.logInfo("times AVERAGE:")
    tprint(timesAVG)
  end
  
  storage.saveFile.global[storage.group].data.testRunsTimesMAXWest = {}
  
  storage.saveFile.global[storage.group].data.testRunsTimesMAXWest[1] = 0
	
  local arrayLen = #timesMAX
	
  for i=2,arrayLen do
	storage.saveFile.global[storage.group].data.testRunsTimesMAXWest[i] = timesMAX[arrayLen-(i-2)]
  end
  
  if self.logging then tprint(storage.saveFile.global[storage.group].data.testRunsTimesMAXWest) end
  
  storage.saveFile.global[storage.group].data.testRunsTimes = timesTidy
  storage.saveFile.global[storage.group].data.testRunsTimesAVG = timesAVG
  storage.saveFile.global[storage.group].data.testRunsTimesMIN = timesMIN
  storage.saveFile.global[storage.group].data.testRunsTimesMAX = timesMAX
  storage.saveFile.global[storage.group].data.testRunsABS = nil
  
  storage.saveFile.global[storage.group].data.toBeInit = true
  
  world.setProperty("stationController_file", storage.saveFile)
  standardReload()
end

function receiveTime(_,_, numStation, absoluteTime)
  self.timesABS[numStation] = absoluteTime
  if self.logging then
    sb.logInfo("===========station " .. tostring(storage.numInGroup) .. " receiveTime from Station " .. tostring(numStation) .. " Time is " .. tostring(absoluteTime))
    sb.logInfo("self.timesABS for testrun nr. " .. tostring(self.currentTestRun) .. " total testruns to do " .. tostring(self.numOfTestRunTodo))
    tprint(self.timesABS)
  end
end

function testRunCarArrivedAt(_,_, numStation, absoluteTime)

  if self.logging then sb.logInfo("station " .. tostring(storage.numInGroup) .. " test car arrived at " .. tostring(numStation) .. " T1 " .. tostring(absoluteTime) ) end

  storage.saveFile = world.getProperty("stationController_file")
  
  if (numStation > 1) and (numStation ~= self.numOfStationsInGroup + 1) then
    world.sendEntityMessage(self.firstStationId, "receiveTime", numStation, absoluteTime)
  elseif numStation == self.numOfStationsInGroup + 1 then
    self.timesABS[numStation] = absoluteTime
    if self.logging then
      sb.logInfo("===========station " .. tostring(storage.numInGroup) .. " receiveTime from Station " .. tostring(numStation) .. " Time is " .. tostring(absoluteTime))
      sb.logInfo("self.timesABS for testrun nr. " .. tostring(self.currentTestRun) .. " total testruns to do " .. tostring(self.numOfTestRunTodo))
      tprint(self.timesABS)
    end
  end
  
  self.testRunMode = false
  --storage.saveFile.global[storage.group].data.times[numStation] = absoluteTime
  --local testRunIndex = self.testrunStartFrom + self.currentTestRun
  --sb.logInfo("==========================testRunIndex = " .. tostring(self.testrunStartFrom + self.currentTestRun) .. " numStation = " .. tostring(numStation))
  --local timesABS = self.grouptestrunfile.timesABS
  --local times = self.grouptestrunfile.times
  --sb.logInfo("=============TIMESABS + TIMES:")
  --tprint(timesABS)
  --tprint(times)
  --timesABS[testRunIndex][numStation] = absoluteTime
  --local prevTimeABS = timesABS[testRunIndex][numStation - 1]
  --sb.logInfo("PREV TIME= " .. tostring(prevTimeABS) .. " testRunIndex=" .. tostring(testRunIndex) .. " numStation - 1=" .. tostring(numStation - 1))
  --times[testRunIndex][numStation] = absoluteTime - prevTimeABS
  --self.grouptestrunfile.timesABS = timesABS
  --self.grouptestrunfile.times = times
  --tprint(self.grouptestrunfile)
  world.setProperty("stationController_file", storage.saveFile)
  
  local dontlog = true
  if numStation == self.numOfStationsInGroup then
    world.sendEntityMessage(storage.saveFile.global[storage.group].data.uuids[1], "endTestRun") --last station to receive the message notifies station 1 test Run is over
    dontlog = false
  elseif numStation == self.numOfStationsInGroup + 1 then
    self.waitingToCloseLoop = false
    --calculate times --loop closed
    
    --for i=2,self.numOfStationsInGroup + 1 do
      --local t1 = storage.saveFile.global[storage.group].data.times[i] - storage.saveFile.global[storage.group].data.times[i-1]
      --storage.saveFile.global[storage.group].data.times[i] = t1
    --end
    --storage.saveFile.global[storage.group].data.times[1] = t1
    self.currentTestRun = self.currentTestRun + 1
    dontlog = false
    if self.currentTestRun > self.numOfTestRunTodo then
      
      --self.testRuns[self.currentTestRun - 1] = deepcopy(self.timesABS)
      table.insert(self.testRuns, self.timesABS)
      self.timesABS = nil
      if self.logging then 
        sb.logInfo("===========Test run nr. " .. tostring(self.currentTestRun - 1) .. " completed. TestRuns table as follows:")
        tprint(self.testRuns)
      end
      storage.saveFile.global[storage.group].data.testrunsnum = storage.saveFile.global[storage.group].data.testrunsnum + self.numOfTestRunTodo
      storage.saveFile.global[storage.group].data.testRunsABS = self.testRuns
      
      storage.saveFile.global[storage.group].data.testRunCompleted = true
      storage.saveFile.global[storage.group].data.operational = false
      --self.grouptestrunfile.testrunsnum = self.grouptestrunfile.testrunsnum + self.numOfTestRunTodo
      
      world.setProperty("stationController_file", storage.saveFile)
      
      calculateTimes()
      
    else
      --do the next test run
      
      self.testRuns[self.currentTestRun - 1] = deepcopy(self.timesABS)
      self.timesABS = nil
      if self.logging then 
        sb.logInfo("===========Test run nr. " .. tostring(self.currentTestRun - 1) .. " completed. TestRuns table as follows:")
        tprint(self.testRuns)
      end
      self.testRunMode = true
      self.testRunCarID0 = world.spawnVehicle(self.testRunvehicleName, self.testRunspawnoffset, self.testRunvehicleParameters)
      self.testrunT0 = world.time()
      
      self.timesABS = {}
      self.timesABS[1] = self.testrunT0
              
      local numStations = self.numOfStationsInGroup
      world.sendEntityMessage(self.testRunCarID0, "testRunModeEnabled", numStations, self.stationsData, self.stationsData.nodePos, self.circularLine )
      --testRunIndex = self.testrunStartFrom + self.currentTestRun
      --self.grouptestrunfile.times[testRunIndex] = {}
      --self.grouptestrunfile.times[testRunIndex][1] = 0
      --self.grouptestrunfile.timesABS[testRunIndex] = {}
      --self.grouptestrunfile.timesABS[testRunIndex][1] = self.testrunT0
      world.setProperty("stationController_file", storage.saveFile)
      
      standardReload()
      local testCar = self.testRunCarID0
      for i=2,self.numOfStationsInGroup do
        local id = self.stationsData.id[i]
        world.sendEntityMessage(id, "testRunMode", testCar, numStations, self.testrunT0, self.numOfTestRunTodo, self.testrunStartFrom, self.currentTestRun, entity.id())
      end
    end
  end
  
  for i=1,storage.saveFile.global.numOfStations do
    if storage.saveFile[tostring(i)].uuid ~= storage.uuid then
      local id = world.loadUniqueEntity(tostring(storage.saveFile[tostring(i)].uuid))
      if id then
        if world.entityExists(id) then
          world.sendEntityMessage(id, "forceReloadData", false, dontlog)
        end
      end
    end
  end
  
end

function testRunGetlastCarID(_,_, lastCarID) --shouldn't be necessary(see below)
  
end

function onInteraction(args)
  --world.setProperty("stationController_file", nil)
  local interactData = root.assetJson(config.getParameter("interactData"))
  interactData.uuid = storage.uuid
  interactData.defaultStopLen = storage.stopLenght
  return {config.getParameter("interactAction"), interactData}
end

function onNodeConnectionChange(args)
  --sb.logInfo("STATION NUMBER " .. tostring(self.stationNum) .. " node connected")
  --local data = object.getInputNodeIds(1)
  --tprint(data)
  
  initNodePos()
  
end

function uninit()
  --storage.saveFile.global[group].data.operational = true
  --storage.operational = true
  --storage.trainsUninit = false
  --self.spawnedTrainsIDs.E[trainNum]
  --self.spawnedTrainsIDs.W[trainNum]
  storage.trainsUninit = true
end

function update(dt)

  if (storage.numInGroup == 1) and self.testRunInit and (not self.testRunReady) then
    for i=2,self.numOfStationsInGroup do
      if not self.stationsData.ready[i] then
        local id = world.loadUniqueEntity(tostring(storage.saveFile.global[storage.group].data.uuids[i]))
        if (id ~= nil) and (id ~= 0 ) then
          self.stationsData.id[i] = id
          self.stationsData.ready[i] = true
        end
      end
    end
    
    world.setProperty("stationController_file", storage.saveFile)
    self.testRunReady = true
    for i=2,self.numOfStationsInGroup do
      if not self.stationsData.ready[i] then
        --self.nonReadyStations = self.nonReadyStations + 1
        self.testRunReady = false
        break
      end
    end
    
    if self.testRunReady then
    --if self.nonReadyStations > 0 then
      --self.testRunReady = false
    else
      for i=1,storage.saveFile.global.numOfStations do
        if storage.saveFile[tostring(i)].uuid ~= storage.uuid then
          local id = world.loadUniqueEntity(tostring(storage.saveFile.global[storage.group].data.uuids[i]))
          if id then
            if world.entityExists(id) then
              world.sendEntityMessage(id, "forceReloadData", false)
            end
          end
        end
      end
      self.testRunReady = true
      self.testRunInit = false
      testRunInit()
    end
    if self.logging then 
      sb.logInfo("Stations data printed from station = FURTHER ITERATION")
      tprint(self.stationsData)
      sb.logInfo("testRunReady " .. tostring(self.testRunReady))
      sb.logInfo("nonReadyStations " .. tostring(self.nonReadyStations))
    end
  end
  
   if self.init then
     if storage.uuid == nil then
       storage.uuid = sb.makeUuid()
     end
     world.setUniqueId(entity.id(), storage.uuid)
     local idfromuuid = world.loadUniqueEntity(storage.uuid)
     if self.logging then  sb.logInfo("ATTEMPTING TO GET ENTITY ID FROM UUID : " .. tostring(idfromuuid) .. " it should be " .. tostring(entity.id()) ) end
     if idfromuuid then
       self.uuidInit = false
     else
       self.uuidInit = true
     end
     storage.saveFile = world.getProperty("stationController_file")
     if storage.saveFile == nil then
       if self.logging then sb.logInfo("INITIALIZING SAVE FILE") end
       self.stationNum = 1
       storage.saveFile = {}
       storage.saveFile.global = {}
       storage.saveFile.global.numOfStations = 1
       storage.saveFile.global.numOfGroups = 0
       storage.saveFile.global.stationsList = {}
       storage.saveFile.global.stationsList[1] = storage.uuid
       storage.saveFile[tostring(self.stationNum)] = {}
       storage.saveFile[tostring(self.stationNum)].uuid = storage.uuid
       --storage.saveFile[tostring(self.stationNum)].pos = world.entityPosition(entity.id())
       --storage.saveFile[tostring(self.stationNum)].grouped = false
       storage.grouped = false
       storage.saveFile[storage.uuid] = {}
       storage.saveFile[storage.uuid].number = self.stationNum
       storage.saveFile[storage.uuid].name = tostring(self.stationNum)
       storage.saveFile[storage.uuid].grouped = false
       --storage.saveFile[storage.uuid].nodepos = {}
       world.setProperty("stationController_file", storage.saveFile)
       storage.saveFile = world.getProperty("stationController_file")
       if self.logging then sb.logInfo("SAVE FILE AS FOLLOWS: ") end
       if storage.saveFile then tprint(storage.saveFile) end
     else
       if self.logging then sb.logInfo("SAVE FILE FOUND: ") end
       if storage.saveFile[storage.uuid] == nil then
         if self.logging then sb.logInfo("THIS STATION IS ==NOT== IN SAVE FILE ") end
         storage.saveFile.global.numOfStations = storage.saveFile.global.numOfStations +1
         self.stationNum = storage.saveFile.global.numOfStations
         storage.saveFile.global.stationsList[storage.saveFile.global.numOfStations] = storage.uuid
         storage.saveFile[tostring(self.stationNum)] = {}
         storage.saveFile[tostring(self.stationNum)].uuid = storage.uuid
         --storage.saveFile[tostring(self.stationNum)].pos = world.entityPosition(entity.id())
         --storage.saveFile[tostring(self.stationNum)].grouped = false
         storage.saveFile[storage.uuid] = {}
         storage.saveFile[storage.uuid].number = self.stationNum
         storage.saveFile[storage.uuid].name = tostring(self.stationNum)
         storage.saveFile[storage.uuid].grouped = false
         --storage.saveFile[storage.uuid].nodepos = {}
         storage.grouped = false
         world.setProperty("stationController_file", storage.saveFile)
         if storage.saveFile.global.numOfStations > 1 then
           for i=1,storage.saveFile.global.numOfStations do
              if storage.saveFile[tostring(i)].uuid ~= storage.uuid then
                local id = world.loadUniqueEntity(tostring(storage.saveFile[tostring(i)].uuid))
                if id then
                  if world.entityExists(id) then
                    world.sendEntityMessage(id, "forceReloadData", false)
                  end
                end
              end
            end
         end
       else
         self.stationNum = storage.saveFile[storage.uuid].number
         if self.logging then sb.logInfo("STATION NUMBER " .. tostring(self.stationNum)) end
         if storage.saveFile[storage.uuid].grouped then
         end
       end
       if storage.saveFile then tprint(storage.saveFile) end
     end
     
     initNodePos()
     
     if storage.saveFile[storage.uuid].grouped then
       initGroupNodePos()
     end
     
     self.init = false
   end
   
   if self.noteposInit then
     initNodePos()
   end
   if self.groupnoteposInit then
     initGroupNodePos()  
   end
   
   if self.uuidInit then
     world.setUniqueId(entity.id(), storage.uuid)
     local idfromuuid = world.loadUniqueEntity(storage.uuid)
     if self.logging then sb.logInfo("ATTEMPTING TO GET ENTITY ID FROM UUID : " .. tostring(idfromuuid) .. " it should be " .. tostring(entity.id()) ) end
     if idfromuuid then
       self.uuidInit = false
     else
       self.uuidInit = true
     end
   end
   
   if self.spawningTrains then
     spawnTrains(self.spawnTrainInGroup)
   end
   
   if self.spawningmorelinesfailed then
     self.spawningmorelinesfailedTimer = world.time() - self.spawningmorelinesfailedTimerT0
     if (self.spawningmorelinesfailedTimer >= 3) then
       for key, value in pairs(self.spawningmorelinestable) do
         local groupname = key
         local idvalid = value.idvalid
         if not idvalid then
           local entityid = world.loadUniqueEntity(storage.saveFile.global[groupname].data.uuids[1])
           self.spawningmorelinestable[groupname].id = entityid
           if entityid then
             if world.entityExists(entityid) then
               self.spawningmorelinestable[groupname].idvalid = true
             else
               self.spawningmorelinestable[groupname].idvalid = false
             end
           else
             self.spawningmorelinestable[groupname].idvalid = false
           end
         end
       end
       self.spawningmorelinesallready = true
       self.spawningmorelinesfailed = false
       for key, value in pairs(self.spawningmorelinestable) do
         local groupname = key
         local idvalid = value.idvalid
         if not idvalid then
           self.spawningmorelinesallready = false
           self.spawningmorelinesfailed = true
         end
       end
     end
   end
   
end

function onNodeConnectionChange(args)
  initNodePos()
  if storage.saveFile[storage.uuid].grouped then
    initGroupNodePos()    
  end
end

function initGroupNodePos()
  if storage.saveFile[storage.uuid].grouped then
    if not storage.group then
      storage.group = storage.saveFile[storage.uuid].group
    end
    if not storage.numInGroup then
      storage.numInGroup = storage.saveFile[storage.group][storage.uuid].number
    end
    if self.numOfStationsInGroup == nil then
      self.numOfStationsInGroup = storage.saveFile.global[storage.group].data.numOfStationsInGroup
    end
    
    if object.isOutputNodeConnected(0) then
      --self.groupNodePos = world.getProperty("stationController_" .. storage.group .. "_nodesPos")
      self.groupNodePos = storage.saveFile.global[storage.group].data.nodesPos
      if not self.groupNodePos then
        self.groupNodePos = {}
        storage.saveFile.global[storage.group].data.nodesPos = {}
        for i=1,self.numOfStationsInGroup do
          self.groupNodePos[i] = {}
          storage.saveFile.global[storage.group].data.nodesPos[i] = {}
        end
      end
      local nodepos = storage.saveFile[storage.uuid].nodepos --getStopPos()
      if nodepos then
        self.groupNodePos[storage.numInGroup] = nodepos
        storage.saveFile.global[storage.group].data.nodesPos[storage.numInGroup] = nodepos
        
        if (storage.numInGroup == 1) and (storage.saveFile.global[storage.group].data.circular) then
          storage.saveFile.global[storage.group].data.nodesPos[self.numOfStationsInGroup + 1] = nodepos
          storage.saveFile.global[storage.group].data.uuids[self.numOfStationsInGroup + 1] = storage.saveFile.global[storage.group].data.uuids[1]
        end
        
        --world.setProperty("stationController_" .. storage.group .. "_nodesPos", self.groupNodePos)
        world.setProperty("stationController_file", storage.saveFile)
        self.groupnoteposInit = false
        for i=1,storage.saveFile.global.numOfStations do
          if storage.saveFile[tostring(i)].uuid ~= storage.uuid then
            local id = world.loadUniqueEntity(tostring(storage.saveFile[tostring(i)].uuid))
            if id then
              if world.entityExists(id) then
               world.sendEntityMessage(id, "forceReloadData", false, false, true)
              end
            end
          end
        end
      else
        self.groupnoteposInit = true
        self.noteposInit = true
      end     
    end
  end
  
end

function initNodePos()
  storage.saveFile = world.getProperty("stationController_file")
  
  if object.isOutputNodeConnected(0) then
    local nodepos = storage.saveFile[storage.uuid].nodepos
    if not nodepos then
      nodepos = getStopPos()
      if nodepos then
        storage.saveFile[storage.uuid].nodepos = nodepos
        world.setProperty("stationController_file", storage.saveFile)
        self.noteposInit = false
        standardReload()
      else
        self.noteposInit = true
      end
    else
      local nodepos = getStopPos()
      if nodepos then
        if storage.saveFile[storage.uuid].nodepos == nodepos then
          self.noteposInit = false
        else
          storage.saveFile[storage.uuid].nodepos = nodepos
          world.setProperty("stationController_file", storage.saveFile)
          self.noteposInit = false
          standardReload()
        end
      else
        self.noteposInit = true
      end
    end
  else
    storage.saveFile[storage.uuid].nodepos = nil
    world.setProperty("stationController_file", storage.saveFile)
    self.noteposInit = false
    standardReload()
  end
end

function die(smash)
 
  --world.setProperty("stationController_file", nil)
  
  storage.saveFile = world.getProperty("stationController_file")
  if storage.saveFile == nil then
    return
  else
    storage.saveFile[tostring(self.stationNum)] = nil
    storage.saveFile[storage.uuid] = nil
    table.remove(storage.saveFile.global.stationsList,self.stationNum)
    
    if storage.saveFile.global.numOfStations >1 then
      for i=self.stationNum+1,storage.saveFile.global.numOfStations do
        local uuid = storage.saveFile[tostring(i)].uuid
        storage.saveFile[uuid].number = i-1
        storage.saveFile[tostring(i-1)] = {}
        storage.saveFile[tostring(i-1)].uuid = uuid
        storage.saveFile[tostring(i)] = nil
      end
    end
    
    storage.saveFile.global.numOfStations = storage.saveFile.global.numOfStations - 1
    if storage.saveFile.global.numOfStations <= 0 then
      world.setProperty("stationController_file", nil)
    else
      world.setProperty("stationController_file", storage.saveFile)
    end 
    
  end
  
end

-- Print contents of "tbl", with indentation.
-- "indent" sets the initial level of indentation.
function tprint(tbl, indent) --debug purposes
  if not indent then indent = 0 end
  if type(tbl) == "table" then
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
    sb.logInfo("not a table:" .. tostring(tbl))
  end
end

-- Save copied tables in "copies", indexed by original table.
-- It is important that only one argument is supplied to this version of the deepcopy function. Otherwise, it will attempt to use the second argument as a table, which can have unintended consequences. 
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