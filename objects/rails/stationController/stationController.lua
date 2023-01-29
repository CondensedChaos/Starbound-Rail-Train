function init()

  object.setInteractive(true)
  
  storage.stopLenght = (config.getParameter("stopLenght", 7))


  self.countdown = 0
  
  --if self.uuidtimer0 == nil then
    --self.uuidtimer0 = world.time()
	--self.uuidtimerBool = true
  --end
  
  self.uuidInit = false
  self.init = true
  
  message.setHandler("forceReloadData", forceReloadData)
  message.setHandler("saveSlottedItems", saveSlottedItems)
  message.setHandler("startTestRun", startTestRun) --message sent from GUI to station nr1 of group to initiate test run
  message.setHandler("testRunMode", testRunMode) --message sent from station 1 to other stations of the group to wait for incoming car
  message.setHandler("endTestRun", endTestRun) --message sent from last station of the group to station 1 to end the test run and calculate times from absolute times stored in save file
  message.setHandler("testRunCarArrivedAt", testRunCarArrivedAt) --message sent from car when arriving at a station
  message.setHandler("testRunGetlastCarID", testRunGetlastCarID) --message recieved from last Car with their ID (in case train set invert)
  message.setHandler("testRunCarInverted", testRunCarInverted) --message received from test run trainset to inform train set has inverted direction (and cars order)
  
end

function forceReloadData(_,_, pane, dontLog, nodepos)

  if nodepos then
  storage.groupNodePos = world.getProperty("stationController_" .. storage.group .. "_nodesPos")
  --sb.logInfo("=====================================FORCING =NODEPOS= DATA RELOAD: ")
  --tprint(storage.groupNodePos)
  else
  storage.saveFile = world.getProperty("stationController_file")
  sb.logInfo("FORCING DATA RELOAD: ")
  local oldnumber = self.stationNum
  self.stationNum = storage.saveFile[storage.uuid].number
  if self.stationNum == oldnumber then
    sb.logInfo("STATION NUMBER " .. tostring(self.stationNum))
  else
    sb.logInfo("STATION NUMBER " .. tostring(oldnumber) .. "IS NOW NUMBER " .. tostring(self.stationNum))
  end
  
  if not dontLog then
    sb.logInfo("SAVE FILE AS FOLLOWS: ")  
  end
  
  if storage.saveFile[storage.uuid].grouped then
    storage.group = storage.saveFile[storage.uuid].group
	storage.grouped = true
	storage.numInGroup = storage.saveFile[storage.group][storage.uuid].number
	self.circularLine = storage.saveFile.global[storage.group].data.circular
	self.numOfStationsInGroup = storage.saveFile.global[storage.group].data.numOfStationsInGroup
  end
  
  if storage.saveFile and not dontLog then
    tprint(storage.saveFile)
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

function saveSlottedItems(_,_, slot, item)
  storage.slottedItem = item
  sb.logInfo("item saved ")
  if storage.slottedItem then tprint(storage.slottedItem) end
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

function startTestRun(_,_)
  sb.logInfo("====station nr " .. tostring(storage.numInGroup) .. " group " .. storage.group .. " TEST RUN INIT=====")
  storage.saveFile = world.getProperty("stationController_file")
  self.circularLine = storage.saveFile.global[storage.group].data.circular
  sb.logInfo("CIRCULAR: " .. tostring(self.circularLine))
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
  
  sb.logInfo("ITERATION ==========================================")
  for k,v in pairs(storage.saveFile[storage.group]) do
    --self.numOfStationsInGroup = self.numOfStationsInGroup + 1  
    index = storage.saveFile[storage.group][k].number
	members[index] = k
	sb.logInfo("k " .. tostring(k) .. " index " .. tostring(index))
	if k ~= storage.uuid then
	  local id = world.loadUniqueEntity(k)
	  if (id ~= nil) and (id ~= 0 ) then
		self.stationsData.id[index] = id
		self.stationsData.ready[index] = true
	  end
	end
  end
  sb.logInfo("MEMBERS ==========================================")
  tprint(members)
  self.testRunReady = true
  for i=2,self.numOfStationsInGroup do
    if not self.stationsData.ready[i] then
      --self.nonReadyStations = self.nonReadyStations + 1
	  self.testRunReady = false
	  break
	end
  end
  
  --if self.nonReadyStations > 0 then
    --self.testRunReady = false
  --else
    --self.testRunReady = true
  --end

  sb.logInfo("Stations data printed from station ")
  tprint(self.stationsData)
  sb.logInfo("testRunReady " .. tostring(self.testRunReady))
  --sb.logInfo("nonReadyStations " .. tostring(self.nonReadyStations))
  
  sb.logInfo("NUM OF STATIONS IN GROUP " .. tostring(self.numOfStationsInGroup))
  --storage.saveFile.global[storage.group].data.numOfStations = self.numOfStationsInGroup
  storage.saveFile.global[storage.group].data.times = {}
  storage.saveFile.global[storage.group].data.times[1] = 0
  --storage.saveFile.global[storage.group].data.uuids = {}
  --storage.saveFile.global[storage.group].data.uuids = deepcopy(members)
  
  
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
  
  sb.logInfo("====station nr " .. tostring(storage.numInGroup) .. " group " .. storage.group .. " TEST RUN STARTED=====")
  
  self.testRunMode = true
  sb.logInfo("CIRCULAR: " .. tostring(self.circularLine))
  
  --send message to all stations to enter test run mode
  local vehicleName = storage.slottedItem.parameters.trainsetData[1].name
  local vehicleParameters = {}
  local listOfCars = root.assetJson("/objects/crafting/trainConfigurator/listOfCars.json")
  vehicleParameters.cockpitColor =  storage.slottedItem.parameters.trainsetData[1].cockpitColor
  vehicleParameters.initialFacing = 1 --account for left or right facing direction
  vehicleParameters.numberOfCars = 2 --tonumber(storage.slottedItem.parameters.trainsetData.numberOfCars)
  --vehicleParameters.popItem = self.itemName --account for testrun mode in rail cars and a custom message to destroy chain without popitem
  vehicleParameters.color = storage.slottedItem.parameters.trainsetData[1].color
  vehicleParameters.decalNames = storage.slottedItem.parameters.trainsetData[1].decalNames
  vehicleParameters.decals = storage.slottedItem.parameters.trainsetData[1].decals
  vehicleParameters.pantographVisible = storage.slottedItem.parameters.trainsetData[1].pantographVisibile
  vehicleParameters.doorLocked = storage.slottedItem.parameters.trainsetData[1].doorLocked
  vehicleParameters.trainsetData = storage.slottedItem.parameters.trainsetData
  vehicleParameters.specular = listOfCars[vehicleName].specular
  vehicleParameters.reversed = storage.slottedItem.parameters.trainsetData[1].reversed
  vehicleParameters.firstCar = true
  vehicleParameters.lastcar = false
  vehicleParameters.carNumber = 1
	
  local stopPos = getStopPos()
  
  sb.logInfo("station nr " .. tostring(storage.numInGroup) .. " pos of connected nodes ")
  --stopPos = world.entityPosition(stopID)
  sb.logInfo("pos " .. tostring(stopPos))
  tprint(stopPos)

    --handle error of stop node not connected
  
  --SPANW CAR:
  local spawnoffset = {}
  spawnoffset[1] = stopPos[1]
  spawnoffset[2] = stopPos[2] + 1
  self.testRunCarID0 = world.spawnVehicle(vehicleName, spawnoffset, vehicleParameters)
  if not self.testRunCarID0 then
    --handle car not spawn error
	self.testRunReady = false
    return
  end
  
  self.testrunT0 = world.time()
  
  local numStations = self.numOfStationsInGroup
  
  world.sendEntityMessage(self.testRunCarID0, "testRunModeEnabled", numStations, self.stationsData, storage.groupNodePos, self.circularLine )
  
  sb.logInfo("station " .. tostring(storage.numInGroup) .. " T0 " .. tostring(self.testrunT0) )
  storage.saveFile.global[storage.group].data.timesABS = {}
  storage.saveFile.global[storage.group].data.timesABS[1] = self.testrunT0
  world.setProperty("stationController_file", storage.saveFile)
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

  local testCar = self.testRunCarID0

  for i=2,self.numOfStationsInGroup do
    local id = self.stationsData.id[i]
    world.sendEntityMessage(id, "testRunMode", testCar, numStations)
  end

  self.testRunInit = false
  
end

function testRunMode(_,_, carID, numOfStations)
  self.testRunMode = true
  self.testRunCarID0 = carID
  self.numOfStationsInGroup = numOfStations
  storage.saveFile = world.getProperty("stationController_file")
end

function endTestRun(_,_)
  
  sb.logInfo("station " .. tostring(storage.numInGroup) .. " received message test run ended ")
  
  storage.saveFile = world.getProperty("stationController_file")
  if storage.numInGroup == 1 then
    if self.testRunMode and self.circularLine then
	  self.waitingToCloseLoop = true
	elseif self.testRunMode and not self.circularLine then
      self.testRunMode = false
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

function testRunCarArrivedAt(_,_, numStation, absoluteTime)

  sb.logInfo("station " .. tostring(storage.numInGroup) .. " test car arrived at " .. tostring(numStation) .. " T1 " .. tostring(absoluteTime) )

  storage.saveFile = world.getProperty("stationController_file")
  self.testRunMode = false
  --storage.saveFile.global[storage.group].data.times[numStation] = absoluteTime
  storage.saveFile.global[storage.group].data.timesABS[numStation] = absoluteTime
  storage.saveFile.global[storage.group].data.times[numStation] = absoluteTime - storage.saveFile.global[storage.group].data.timesABS[numStation - 1]
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
	
	storage.saveFile.global[storage.group].data.timesABS[numStation] = absoluteTime
    storage.saveFile.global[storage.group].data.times[numStation] = absoluteTime - storage.saveFile.global[storage.group].data.timesABS[numStation - 1]
	world.setProperty("stationController_file", storage.saveFile)
	dontlog = false
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
  interactData.slottedItem = storage.slottedItem
  return {config.getParameter("interactAction"), interactData}
end

function onNodeConnectionChange(args)
  --sb.logInfo("STATION NUMBER " .. tostring(self.stationNum) .. " node connected")
  --local data = object.getInputNodeIds(1)
  --tprint(data)
  
  --initNodePos()
  initNodePos2()
  
end


function onInputNodeChange(args)
  --if args.level then
    --output(args.node == 0)
  --end
  
  if args.node == 0 then --and not storage.state then
    if args.level then
	  storage.state = true
	  object.setOutputNodeLevel(0, false)
	  self.t0 = world.time()
	  self.countdown = 0
	  animator.setAnimationState("switchState", "on")
      if not (config.getParameter("alwaysLit")) then object.setLightColor(config.getParameter("lightColor", {0, 0, 0, 0})) end
      animator.playSound("on");
      --object.setAllOutputNodes(true)
	  --sb.logInfo(self.countdown)
	end
  end
  
  --if storage.state and args.node == 1 then
    --if args.level then
	  --self.countdown = self.countdown + 0.9
	  --if not self.trainInStation then
	    --self.trainInStation = true
	  --end
	--else
	  --self.trainInStation = false
	--end
  --end
  
  sb.logInfo("=====")
  tprint(args)
  if self.t0 then sb.logInfo("=====T0= " .. self.t0) end
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
      if not self.stationsData.ready[index] then
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
	
	sb.logInfo("Stations data printed from station = FURTHER ITERATION")
    tprint(self.stationsData)
    sb.logInfo("testRunReady " .. tostring(self.testRunReady))
    sb.logInfo("nonReadyStations " .. tostring(self.nonReadyStations))
  end
  
  if self.testRunMode then
    if storage.numInGroup > 1 then
      if not self.testrunInit then
	    self.testrunInit = true
	    storage.saveFile = world.getProperty("stationController_file")
	    if storage.numInGroup == 2 then
		  self.testrunT0 = storage.saveFile.global[storage.group].data.times[1]
		end
		sb.logInfo("Station nr " .. tostring(storage.numInGroup) .. " TEST RUN ON, num of stations " .. tostring(storage.numInGroup) )
		if storage.numInGroup == self.numOfStationsInGroup then
		  sb.logInfo("==================Last station received the TEST RUN MSG==============================")
	    end
      end
    end
  end

   if self.init then
     if storage.state == nil then
	   storage.state = false
       object.setOutputNodeLevel(1, true)
     else
       object.setOutputNodeLevel(0, not storage.state)
	   if storage.state then
	     self.t0 = world.time()
	   end
	   object.setOutputNodeLevel(1, true)
     end
     if storage.uuid == nil then
       storage.uuid = sb.makeUuid()
     end
	 if storage.state == nil then
	   storage.state = false
       object.setOutputNodeLevel(1, true)
	   object.setOutputNodeLevel(0, not storage.state)
     else
       object.setOutputNodeLevel(0, not storage.state)
	   self.t0 = world.time()
	   object.setOutputNodeLevel(1, true)
     end
     world.setUniqueId(entity.id(), storage.uuid)
	 local idfromuuid = world.loadUniqueEntity(storage.uuid)
	 sb.logInfo("ATTEMPTING TO GET ENTITY ID FROM UUID : " .. tostring(idfromuuid) .. " it should be " .. tostring(entity.id()) )
	 if idfromuuid then
	   self.uuidInit = false
	 else
	   self.uuidInit = true
	 end
	 storage.saveFile = world.getProperty("stationController_file")
	 if storage.saveFile == nil then
	   sb.logInfo("INITIALIZING SAVE FILE")
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
	   storage.saveFile[storage.uuid].pos = storage.saveFile[tostring(self.stationNum)].pos
	   storage.saveFile[storage.uuid].grouped = false
	   world.setProperty("stationController_file", storage.saveFile)
	   storage.saveFile = world.getProperty("stationController_file")
	   sb.logInfo("SAVE FILE AS FOLLOWS: ")
	   if storage.saveFile then tprint(storage.saveFile) end
	 else
	   sb.logInfo("SAVE FILE FOUND: ")
	   if storage.saveFile[storage.uuid] == nil then
	     sb.logInfo("THIS STATION IS ==NOT== IN SAVE FILE ")
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
	     storage.saveFile[storage.uuid].pos = storage.saveFile[tostring(self.stationNum)].pos
	     storage.saveFile[storage.uuid].grouped = false
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
		 sb.logInfo("STATION NUMBER " .. tostring(self.stationNum))
	     if storage.saveFile[storage.uuid].grouped then
		 end
	   end
	   if storage.saveFile then tprint(storage.saveFile) end
	 end
	 
	 --initNodePos()
	 initNodePos2()
	 
	 self.init = false
   end
   
   if self.noteposInit then
     --initNodePos()
   end
   if self.noteposInit2 then
     initNodePos2()
   end
   
   if self.uuidInit then
     world.setUniqueId(entity.id(), storage.uuid)
	 local idfromuuid = world.loadUniqueEntity(storage.uuid)
	 sb.logInfo("ATTEMPTING TO GET ENTITY ID FROM UUID : " .. tostring(idfromuuid) .. " it should be " .. tostring(entity.id()) )
	 if idfromuuid then
	   self.uuidInit = false
	 else
	   self.uuidInit = true
	 end
   end


  if storage.state then
    
    --self.countdown = self.countdown - dt
	self.countdown = world.time() - self.t0
	--sb.logInfo(tostring("time=" .. world.time()) .. " count=" .. tostring(self.countdown))
  end
  --if self.countdown <= 0 then
  if self.countdown >= storage.stopLenght and storage.state then
    --self.countdown = storage.stopLenght
	storage.state = false
	object.setOutputNodeLevel(0, true)
	self.countdown = 0
	sb.logInfo(tostring("time=" .. world.time()) .. " count=" .. tostring(self.countdown))
	animator.setAnimationState("switchState", "off")
    if not (config.getParameter("alwaysLit")) then object.setLightColor({0, 0, 0, 0}) end
    animator.playSound("off");
    --object.setAllOutputNodes(false)
  end
end

function initNodePos2()
  storage.saveFile = world.getProperty("stationController_file")
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
	  --storage.groupNodePos = world.getProperty("stationController_" .. storage.group .. "_nodesPos")
	  storage.groupNodePos = storage.saveFile.global[storage.group].data.nodesPos
	  if not storage.groupNodePos then
	    storage.groupNodePos = {}
		storage.saveFile.global[storage.group].data.nodesPos = {}
		for i=1,self.numOfStationsInGroup do
		  storage.groupNodePos[i] = {}
		  storage.saveFile.global[storage.group].data.nodesPos[i] = {}
		end
	  end
	  local nodepos = getStopPos()
	  if nodepos then
	    storage.groupNodePos[storage.numInGroup] = nodepos
		storage.saveFile.global[storage.group].data.nodesPos[storage.numInGroup] = nodepos
	   --world.setProperty("stationController_" .. storage.group .. "_nodesPos", storage.groupNodePos)
	   world.setProperty("stationController_file", storage.saveFile)
	   self.noteposInit2 = false
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
	    self.noteposInit2 = true
      end	  
	end
	
  end
  
  
end

function initNodePos()
     if storage.saveFile[storage.uuid].grouped then
       if not storage.group then
	     storage.group = storage.saveFile[storage.uuid].group
	   end
	   if not storage.numInGroup then
	     storage.numInGroup = storage.saveFile[storage.group][storage.uuid].number
	   end
	   if object.isOutputNodeConnected(0) then
	     if not storage.saveFile.global[storage.group].data.nodesPos then
	       storage.saveFile.global[storage.group].data.nodesPos = {}
	     end
		 local nodepos = getStopPos()
		 if nodepos then
		   storage.saveFile.global[storage.group].data.nodesPos[storage.numInGroup] = nodepos
	       world.setProperty("stationController_file", storage.saveFile)
		   self.noteposInit = false
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
		 else
		   self.noteposInit = true
		 end
	   end
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