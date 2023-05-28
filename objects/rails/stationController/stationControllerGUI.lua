require "/scripts/util.lua"

local_storage = {}
stopLenSpinner = {}
stopLenSpinner1 = {}
testRunNumSpinner = {}
datasetSpinner = {}

--callback function when right button is pressed
function datasetSpinner.up()
  --self.statisticsdataset
  --self.totalTestruns
  
  if self.statisticsdataset < self.totalTestruns then
    self.statisticsdataset = self.statisticsdataset + 1
    buildStatistics(self.statisticsdataset)
  end

end

--callback function when left button is pressed
function datasetSpinner.down()
  --self.statisticsdataset
  
  if self.statisticsdataset > 1 then
    self.statisticsdataset = self.statisticsdataset - 1
    buildStatistics(self.statisticsdataset)
  end
  
end

--callback function when right button is pressed
function testRunNumSpinner.up()
  self.numOfTestRunTodo = self.numOfTestRunTodo + 1
  widget.setText("testRunOverlay.testRunNumValue",self.numOfTestRunTodo)
end

--callback function when left button is pressed
function testRunNumSpinner.down()
  if self.numOfTestRunTodo > 1 then
    self.numOfTestRunTodo = self.numOfTestRunTodo - 1
    widget.setText("testRunOverlay.testRunNumValue",self.numOfTestRunTodo)
  end
end

--callback function when right button is pressed
function stopLenSpinner.up()
  local currentStopLen = self.timetableEditing[9]
  local direction = self.timetableEditing[2]
  
  currentStopLen = currentStopLen + 1
  self.timetableEditing[9] = currentStopLen
  
  if direction == "E" then
    overlayName = "trainSettingsEastOverlay"
  else
    overlayName = "trainSettingsWestOverlay"
  end
  
  widget.setText("timetableOverlay." .. overlayName ..".stopLenValue", "^yellow;" ..  tostring(currentStopLen) .. "^reset;")

  local listName 
  if direction == "E" then
    listName = self.trainsDataListNameE
  else
    listName = self.trainsDataListNameW
  end
  
  local listItem = widget.getListSelected(listName)
  if listItem then
    widget.setText(listName .. "." ..listItem .. ".stopLenghtLabel", "^yellow;" .. tostring(currentStopLen) .. "^reset;" .. " seconds stop" )
  end
end

--callback function when left button is pressed
function stopLenSpinner.down()
  --variable to tell to other functions what stations are we editing and the original data
  --format: self.timetableEditing = {trainNum,direction,station,numOfStations,circular,Originalspeed,OriginalstopLen,newSpeed,newStopLen}
  local currentStopLen = self.timetableEditing[9]
  local direction = self.timetableEditing[2]
  
  if currentStopLen > 0 then
    currentStopLen = currentStopLen -1
	self.timetableEditing[9] = currentStopLen

    if direction == "E" then
      overlayName = "trainSettingsEastOverlay"
    else
      overlayName = "trainSettingsWestOverlay"
    end
  
    widget.setText("timetableOverlay." .. overlayName ..".stopLenValue", "^yellow;" .. tostring(currentStopLen) .. "^reset;")

    local listName 
    if direction == "E" then
      listName = self.trainsDataListNameE
    else
      listName = self.trainsDataListNameW
    end
  
    local listItem = widget.getListSelected(listName)
    if listItem then
      widget.setText(listName .. "." ..listItem .. ".stopLenghtLabel", "^yellow;" .. tostring(currentStopLen) .. "^reset;" .. " seconds stop")
    end
	
  end

end

--callback function when right button is pressed
function stopLenSpinner1.up()
  local currentStopLen = self.timetableEditing[12]
  local direction = self.timetableEditing[2]
  
  currentStopLen = currentStopLen + 1
  self.timetableEditing[12] = currentStopLen
  
  if direction == "E" then
    overlayName = "trainSettingsEastOverlay"
  else
    overlayName = "trainSettingsWestOverlay"
  end
  
  widget.setText("timetableOverlay." .. overlayName ..".stopLenValue1", "^yellow;" ..  tostring(currentStopLen) .. "^reset;")

  local listName 
  if direction == "E" then
    listName = self.trainsDataListNameE
  else
    listName = self.trainsDataListNameW
  end
  
  --local listItem = widget.getListSelected(listName)
  --if listItem then
    --widget.setText(listName .. "." ..listItem .. ".stopLenghtLabel", "^yellow;" .. tostring(currentStopLen) .. "^reset;" .. " seconds stop" )
  --end
end

--callback function when left button is pressed
function stopLenSpinner1.down()
  --variable to tell to other functions what stations are we editing and the original data
  --format: self.timetableEditing = {trainNum,direction,station,numOfStations,circular,Originalspeed,OriginalstopLen,newSpeed,newStopLen}
  local currentStopLen = self.timetableEditing[12]
  local direction = self.timetableEditing[2]
  
  if currentStopLen > 0 then
    currentStopLen = currentStopLen -1
	self.timetableEditing[12] = currentStopLen

    if direction == "E" then
      overlayName = "trainSettingsEastOverlay"
    else
      overlayName = "trainSettingsWestOverlay"
    end
  
    widget.setText("timetableOverlay." .. overlayName ..".stopLenValue1", "^yellow;" .. tostring(currentStopLen) .. "^reset;")

    local listName 
    if direction == "E" then
      listName = self.trainsDataListNameE
    else
      listName = self.trainsDataListNameW
    end
  
    --local listItem = widget.getListSelected(listName)
    --if listItem then
      --widget.setText(listName .. "." ..listItem .. ".stopLenghtLabel", "^yellow;" .. tostring(currentStopLen) .. "^reset;" .. " seconds stop")
    --end
	
  end

end

function init()

  --When the panel inits we read in the list of slots that need to be emptied on close
  local_storage.slotsToRefund = config.getParameter("refundOnClose",{})

  self.saveFile = world.getProperty("stationController_file")
  self.uuid = config.getParameter("uuid")
  self.slottedItem = config.getParameter("slottedItem")
  
  self.groupVehiclesFile = world.getProperty("stationController_vehicles_file")
  if self.groupVehiclesFile == nil then
    self.groupVehiclesFile = {}
	world.setProperty("stationController_vehicles_file", self.groupVehiclesFile)
  end
  
  self.defaultStopLen = config.getParameter("defaultStopLen")
  
  self.widgetListName = "addStationOverlay.stationsScrollArea.stationsList"
  
  widget.setVisible("mainOverlay", true)

  local displayName = self.saveFile[self.uuid].name
  local idNumber = self.saveFile[self.uuid].number
  widget.setVisible("mainOverlay.displayNameLabel", true)
  widget.setVisible("mainOverlay.displayNameValue", true)
  widget.setVisible("mainOverlay.idLabel", true)
  widget.setVisible("mainOverlay.idValue", true)
  widget.setText("mainOverlay.idValue", "^green;" .. idNumber .. "^reset;")
  widget.setText("mainOverlay.displayNameValue", "^green;" .. displayName .. "^reset;")
  
  if not self.saveFile[self.uuid].grouped then
    widget.setVisible("mainOverlay.NoGroupLabel1", true)
  else
    local groupName = self.saveFile[self.uuid].group
	local numInGroup = self.saveFile[groupName][self.uuid].number
    widget.setVisible("mainOverlay.NoGroupLabel1", false)
	widget.setVisible("mainOverlay.groupNameLabel", true)
	widget.setVisible("mainOverlay.groupNameValue", true)
	widget.setText("mainOverlay.groupNameValue", "^green;" .. groupName .. "^reset;")
	widget.setVisible("mainOverlay.numInGroupLabel", true)
	widget.setVisible("mainOverlay.numInGroupValue", true)
	widget.setText("mainOverlay.numInGroupValue", "^green;" .. tostring(numInGroup) .. "^reset;")
  end
  
  sb.logInfo("GUI INTERFACE OPENED")
  sb.logInfo("UUID IS " .. tostring(self.uuid))
  tprint(self.saveFile)
  
end

function update(dt)

  if self.testRunInProgress then
    --account for left or right start facing direction
  end
  
  if self.viewingAtrain then
    --self.editingTrain = {trainNum,direction}
    local overlayname 
    local slotWidget
	local trainPresent
	
	local direction = self.editingTrain[2]
	local trainNum = self.editingTrain[1]
	
	if direction == "E"then
	  overlayname = "timetableOverlay.trainSettingsEastOverlay"
	  slotWidget = overlayname .. ".itemslot2"
	  if self.saveFile.global[self.groupEditing].data.trainsEast.vehiclePresent[trainNum] then
	    trainPresent = true
	  else
	    trainPresent = false
	  end
	else
	  overlayname = "timetableOverlay.trainSettingsWestOverlay"
	  slotWidget = overlayname .. ".itemslot3"
	  if self.saveFile.global[self.groupEditing].data.trainsWest.vehiclePresent[trainNum] then
	    trainPresent = true
	  else
	    trainPresent = false
	  end
	end
	
	if trainPresent then
	  widget.setVisible(overlayname .. ".addVehicleButton", false)
	  widget.setVisible(overlayname .. ".removeVehicleButton", true)
	  widget.setVisible(overlayname .. ".ErrorLabel1", false)
	  widget.setVisible(overlayname .. ".vehiclePresentLabel", true)
	  widget.setVisible(slotWidget, false)
	else
	  widget.setVisible(slotWidget, true)
	  local slottedItem = widget.itemSlotItem(slotWidget)
	  if slottedItem then
	    local itemConfig = root.itemConfig(slottedItem)
	    if (itemConfig.config.category == "railPlatform") and (itemConfig.config.linkedRailTrain == true) then
	      widget.setVisible(overlayname .. ".addVehicleButton", true)
		  widget.setVisible(overlayname .. ".ErrorLabel1", false)
		  widget.setVisible(overlayname .. ".removeVehicleButton", false)
		  widget.setVisible(overlayname .. ".vehiclePresentLabel", false)
	    else
	      widget.setVisible(overlayname .. ".addVehicleButton", false)
		  widget.setVisible(overlayname .. ".ErrorLabel1", true)
		  widget.setVisible(overlayname .. ".removeVehicleButton", false)
		  widget.setVisible(overlayname .. ".vehiclePresentLabel", false)
	    end
	  else
	    widget.setVisible(overlayname .. ".vehiclePresentLabel", false)
	    widget.setVisible(overlayname .. ".addVehicleButton", false)
	    widget.setVisible(overlayname .. ".removeVehicleButton", false)
		widget.setVisible(overlayname .. ".ErrorLabel1", false)
	  end
	end

  end
  
  if self.reloadDataTimerSet then
    self.reloadDataTimer = world.time() - self.reloadDataTimerT0
    sb.logInfo("update dt timer=" .. tostring(self.reloadDataTimer))
    if self.reloadDataTimer >= 4 then
      self.reloadDataTimerSet = false
      --sb.logInfo("RELOAD TIMER ENDED T=" .. tostring(world.time()))
      widget.setVisible("timetableOverlay.loadingOverlay", false)
      trainsListSelected(self.resumewidgedname)
    end
  end
  
  if self.reloadDataTimer1Set then
    self.reloadDataTimer1 = world.time() - self.reloadDataTimer1T0
    sb.logInfo("update dt timer=" .. tostring(self.reloadDataTimer1))
    if self.reloadDataTimer1 >= 4 then
      self.reloadDataTimer1Set = false
      --sb.logInfo("RELOAD TIMER ENDED T=" .. tostring(world.time()))
      widget.setVisible("loadingGroupsOverlay", false)
      widget.setVisible("mainOverlay", true)
    end
  end
  
end

function clearSaveFileButtonPressed(widgetName, widgetData)
  world.setProperty("stationController_file", nil)
end

function groupStationsButtonPressed(widgetName, widgetData)
  
  widget.setVisible("mainOverlay", false)
  widget.setVisible("groupsOverlay", true)

  local displayName = self.saveFile[self.uuid].name
  local idNumber = self.saveFile[self.uuid].number
  widget.setVisible("groupsOverlay.displayNameLabel", true)
  widget.setVisible("groupsOverlay.displayNameValue", true)
  widget.setText("groupsOverlay.displayNameValue", "^green;" .. displayName .. "^reset;")
  widget.setVisible("groupsOverlay.idLabel", true)
  widget.setVisible("groupsOverlay.idValue", true)
  widget.setText("groupsOverlay.idValue", "^green;" .. idNumber .. "^reset;")
  
  if not self.saveFile[self.uuid].grouped then
    widget.setVisible("groupsOverlay.NoGroupLabel", true)
	widget.setVisible("groupsOverlay.createGroupButton", true)
	widget.setVisible("groupsOverlay.circularCheckBox", false)
	widget.setVisible("groupsOverlay.circularLabel", false)
    
    widget.setVisible("groupsOverlay.startTrainsButton", false)
    widget.setVisible("groupsOverlay.stopTrainsButton", false)
	
	if self.saveFile.global.numOfGroups > 0 then
	  widget.setVisible("groupsOverlay.addToExistingGroupButton", true)
	else
	  widget.setVisible("groupsOverlay.addToExistingGroupButton", false)
	end
  else
    local groupName = self.saveFile[self.uuid].group
	local numInGroup = self.saveFile[groupName][self.uuid].number
    
	
	widget.setVisible("groupsOverlay.TestRunButton", true)

	self.groupEditing = groupName
    if self.saveFile.global[self.groupEditing].data.testRunCompleted == nil then
      self.saveFile.global[self.groupEditing].data.testRunCompleted = false
      world.setProperty("stationController_file",self.saveFile)
    end  

    if not self.saveFile.global[self.groupEditing].data.testRunCompleted then
      widget.setVisible("groupsOverlay.setTimetableButton", false)
      widget.setVisible("groupsOverlay.addStationToGroupButton", true)
      widget.setVisible("groupsOverlay.removeStationfromGroupButton", true)
	  widget.setVisible("groupsOverlay.renameGroupButton", true)
      widget.setVisible("groupsOverlay.reorderGroupStationsButton", true)
      widget.setVisible("groupsOverlay.startTrainsButton", false)
      widget.setVisible("groupsOverlay.stopTrainsButton", false)
	else
	  widget.setVisible("groupsOverlay.setTimetableButton", true)
      widget.setVisible("groupsOverlay.addStationToGroupButton", false)
      widget.setVisible("groupsOverlay.removeStationfromGroupButton", false)
	  widget.setVisible("groupsOverlay.renameGroupButton", false)
      widget.setVisible("groupsOverlay.reorderGroupStationsButton", false)
      if self.saveFile.global[self.groupEditing].data.readyToStart then
        widget.setVisible("groupsOverlay.startTrainsButton", true)
      else
        widget.setVisible("groupsOverlay.startTrainsButton", false)
      end
      if self.saveFile.global[self.groupEditing].data.operational then
        widget.setVisible("groupsOverlay.stopTrainsButton", true)
      else
        widget.setVisible("groupsOverlay.stopTrainsButton", false)
      end
	end
	
	widget.setVisible("groupsOverlay.membersInGroupLabel", true)
	widget.setVisible("groupsOverlay.membersInGroupValue", true)
	widget.setText("groupsOverlay.membersInGroupLabel", "Members of group " .. "^green;" .. groupName .. "^reset; (in order):")
	
	widget.setVisible("groupsOverlay.circularCheckBox", true)
	widget.setChecked("groupsOverlay.circularCheckBox", self.saveFile.global[self.groupEditing].data.circular)
	widget.setVisible("groupsOverlay.circularLabel", true)
	
	local members = {}
	local membersString = ""
    
    -------------------
    
    local uuids = deepcopy(self.saveFile.global[self.groupEditing].data.uuids)
    local circular = self.saveFile.global[self.groupEditing].data.circular
  
    if circular then
      local arraylen = #uuids
      uuids[arraylen] = nil
    end
  
    for s=1,#uuids do
      members[s] = self.saveFile[uuids[s]].name
      if s == 1 then
        membersString = members[s]
      else
        membersString = membersString .. ", " .. members[s]
      end
      
    end
    
    tprint(membersString)
    
    ------------------
    
    --for s=1,#self.saveFile[groupName] do
      --members[s] = " "
    --end
	
	----sb.logInfo("self.saveFile[groupName] table iteration")
	----sb.logInfo("table ")
	----tprint(self.saveFile[groupName])
	
	--for k,v in pairs(self.saveFile[groupName]) do
	   --sb.logInfo("k " .. tostring(k) .. " v " .. tostring(v))
	  --local number = tonumber(self.saveFile[groupName][k].number)
	  --sb.logInfo("number " .. tostring(number))
      --members[number] = self.saveFile[k].name
	  --sb.logInfo("name " .. tostring(members[number]))
	--end
    
    ----for s=1,#self.saveFile[groupName] do
      ----local number = tonumber(self.saveFile[groupName][s].number)
      ----local uuid = self.saveFile.global[groupName].data.uuids[number]
      ----members[number] = self.saveFile[uuid].name
      ----sb.logInfo("number " .. tostring(number) .. "name " .. members[number])
    ----end
	
	--for i=1,#members do
     --if i == 1 then
        --membersString = members[i]
      --else
        --membersString = membersString .. ", " .. members[i]
      --end
	--end
    
	if not self.saveFile.global[groupName].data.numOfStationsInGroup then
	  self.saveFile.global[groupName].data.numOfStationsInGroup = #members
	  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
	end
	
	widget.setText("groupsOverlay.membersInGroupValue", "^green;" .. membersString.. "^reset;")
	
	if (self.saveFile.global.numOfGroups > 1) and  (not self.saveFile.global[self.groupEditing].data.testRunCompleted) then
	  widget.setVisible("groupsOverlay.addToExistingGroupButton", true)
	else
	  widget.setVisible("groupsOverlay.addToExistingGroupButton", false)
	end
    widget.setVisible("groupsOverlay.NoGroupLabel", false)
	widget.setVisible("groupsOverlay.createGroupButton", false)
	widget.setVisible("groupsOverlay.groupNameLabel", true)
    widget.setVisible("groupsOverlay.groupNameValue", true)
    widget.setText("groupsOverlay.groupNameValue", "^green;" .. groupName .. "^reset;")
	widget.setVisible("groupsOverlay.numInGroupLabel", true)
	widget.setVisible("groupsOverlay.numInGroupValue", true)
	widget.setText("groupsOverlay.numInGroupValue", "^green;" .. tostring(numInGroup) .. "^reset;")
    
	widget.setVisible("groupsOverlay.manageOtherGroupsButton", true)
    
  end
end

function debug1ButtonPressed()
  
  
  ----self.saveFile.global[self.groupEditing].data.testRunsTimes = nil
  ----self.saveFile.global[self.groupEditing].data.testRunsTimesAVG = nil
  ----self.saveFile.global[self.groupEditing].data.testRunsTimesMIN = nil
  ----self.saveFile.global[self.groupEditing].data.testRunsTimesMAX = nil
  ----self.saveFile.global[self.groupEditing].data.testRunsTimesMAXWest = nil
  
  ----self.saveFile.global[self.groupEditing].data.testRunCompleted = false
  --self.saveFile.global[self.groupEditing].data.toBeInit = nil
  
  --local newMAX = {}
  
  --for i=1,#self.saveFile.global[self.groupEditing].data.testRunsTimesMAX do
    --newMAX[i] = math.ceil(self.saveFile.global[self.groupEditing].data.testRunsTimesMAX[i])
  --end
  
  --tprint(newMAX)
  
  --self.saveFile.global[self.groupEditing].data.testRunsTimesMAX = newMAX
  
  --self.saveFile.global[self.groupEditing].data.timesABS = nil
  --self.saveFile.global[self.groupEditing].data.times = nil
  --self.saveFile.global[self.groupEditing].data.timesTidyWest = nil
  
  --self.saveFile.global[self.groupEditing].data.toBeInit = true
  --self.saveFile.global[self.groupEditing].data.trainsEast = nil
  --self.saveFile.global[self.groupEditing].data.trainsWest = nil
  --self.saveFile.global[self.groupEditing].data.timesTidy = nil
  --self.saveFile.global[self.groupEditing].data.numberOfTrainsE = nil
  --self.saveFile.global[self.groupEditing].data.numberOfTrainsW = nil
  ----self.saveFile.global[self.groupEditing].data.testRunCompleted = true
  
  ----self.saveFile.global[self.groupEditing].data.nodesPos[6] = nil
  --self.saveFile.global[self.groupEditing].data.nodesPos[6] = self.saveFile.global[self.groupEditing].data.nodesPos[1]
  ----self.saveFile.global[self.groupEditing].data.nodesPos[7] = nil
  --self.saveFile.global[self.groupEditing].data.uuids[5] = self.saveFile.global.stationsList[5]
  --self.saveFile.global[self.groupEditing].data.uuids[6] = nil
  --self.saveFile.global[self.groupEditing].data.uuids[6] = self.saveFile.global[self.groupEditing].data.uuids[1]
  ----self.saveFile.global[self.groupEditing].data.uuids[7] = nil
  
  --sb.logInfo("world time = " .. tostring(world.time()) .. " world.time() -3 =" .. tostring(world.time() - 3))

  world.setProperty("stationController_file", self.saveFile)
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
end

function loadBackupFileButtonPressed()
  self.saveFile = world.getProperty("stationController_file_backup")
  world.setProperty("stationController_file", self.saveFile)
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
end
function saveBackupFileButtonPressed()
  world.setProperty("stationController_file_backup", self.saveFile)
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
end

function addTrainButtonPressed(widgetName, widgetData)

  local stationslistname = "timetableOverlay.addTrainOverlay.stationSelectScrollArea.stationSelectList"
  
  self.saveFile = world.getProperty("stationController_file")
  tprint(self.saveFile.global[self.groupEditing].data)
  
  widget.setVisible("timetableOverlay.addTrainOverlay", true)
  widget.setVisible("timetableOverlay.trainSettingsEastOverlay",false)
  widget.setVisible("timetableOverlay.trainSettingsWestOverlay",false)
  widget.setVisible("timetableOverlay.trainsEastDataScrollArea",false)
  widget.setVisible("timetableOverlay.trainsWestDataScrollArea",false)
  widget.setVisible("timetableOverlay.selectedTrainDataLabel", false)
  widget.clearListItems(self.trainsDataListNameW)
  widget.clearListItems(self.trainsDataListNameE)
  widget.clearListItems(stationslistname)
  
  widget.setText("timetableOverlay.addTrainOverlay.timeTextBox","0")
  widget.setSelectedOption("timetableOverlay.addTrainOverlay.directionRadioGroup", 0)
  
  local numOfStations = #self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
  
  if self.saveFile.global[self.groupEditing].data.circular then
    numOfStations = numOfStations -1
  end
  
  for i=1,numOfStations do
    local listItem = string.format("%s.%s",stationslistname, widget.addListItem(stationslistname))
    widget.setText(listItem .. ".stationLabel", "^green;Station " .. tostring(i) .. "^reset;")
    widget.setData(listItem, i)
  end
  
  self.trainToAdd = {"E",1,0}
  --{direction,startStation,startTime}
  
  if not self.saveFile.global[self.groupEditing].data.circular then
    local lastStation = #self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
    self.trainToAdd[2] = lastStation
	widget.setText("timetableOverlay.addTrainOverlay.startStationLabel","Start Station : ^green;" .. tostring(lastStation).."^reset;")
  end

end

function addTrainButton2Pressed(widgetName, widgetData)
  local direction = self.trainToAdd[1]
  local startStation = self.trainToAdd[2]
  local startTime = self.trainToAdd[3]
  
  self.saveFile = world.getProperty("stationController_file")
  
  local numOfTrainsE = tonumber(self.saveFile.global[self.groupEditing].data.numberOfTrainsE)
  local numOfTrainsW = tonumber(self.saveFile.global[self.groupEditing].data.numberOfTrainsW)
  local trainNum
  local dataName
  
  if direction == "E" then
    numOfTrainsE = numOfTrainsE + 1
	self.saveFile.global[self.groupEditing].data.numberOfTrainsE = numOfTrainsE
	trainNum = numOfTrainsE
	dataName = "trainsEast"
  else
    numOfTrainsW = numOfTrainsW + 1	
	self.saveFile.global[self.groupEditing].data.numberOfTrainsW = numOfTrainsW
	trainNum = numOfTrainsW
	dataName = "trainsWest"
  end
  
  self.saveFile.global[self.groupEditing].data[dataName].vehiclePresent[tonumber(trainNum)] = false
  self.saveFile.global[self.groupEditing].data[dataName].startStations[tonumber(trainNum)] = startStation
  self.saveFile.global[self.groupEditing].data[dataName].startTimes[tonumber(trainNum)] = startTime
  self.saveFile.global[self.groupEditing].data[dataName].speeds[tonumber(trainNum)] = {}
  self.saveFile.global[self.groupEditing].data[dataName].speeds[tonumber(trainNum)][1] = 0
  self.saveFile.global[self.groupEditing].data[dataName].stopsLen[tonumber(trainNum)] = {}
  self.saveFile.global[self.groupEditing].data[dataName].stopsLen[tonumber(trainNum)][1] = self.defaultStopLen
  self.groupVehiclesFile[self.groupEditing][dataName][trainNum] = {}
  
  for i=2,#self.saveFile.global[self.groupEditing].data.testRunsTimesMAX do
	self.saveFile.global[self.groupEditing].data[dataName].speeds[trainNum][i] = 100
	self.saveFile.global[self.groupEditing].data[dataName].stopsLen[trainNum][i] = self.defaultStopLen
  end
  
  world.setProperty("stationController_vehicles_file", self.groupVehiclesFile)
  world.setProperty("stationController_file", self.saveFile)
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  
  widget.setVisible("timetableOverlay.addTrainOverlay", false)
  
  widget.clearListItems(self.trainsDataListNameE)
  widget.clearListItems(self.trainsDataListNameW)
  widget.clearListItems(self.trainsEastListName)
  widget.clearListItems(self.trainsWestListName)
  
  if direction == "E" then 
    makeTrainList("W")
    makeTrainList("E", numOfTrainsE)
  else
    makeTrainList("W", numOfTrainsW)
    makeTrainList("E")
  end
  
end

function stationSelectSelected(widgetName, widgetData)
  local listName = "timetableOverlay.addTrainOverlay.stationSelectScrollArea.stationSelectList"
  local listItem = widget.getListSelected(listName)
  local itemData
  if listItem then
    itemData = widget.getData(string.format("%s.%s", listName, listItem))
	widget.setText("timetableOverlay.addTrainOverlay.startStationLabel","Start Station : ^green;" .. tostring(itemData).."^reset;")
	self.trainToAdd[2] = tonumber(itemData)
	tprint(self.trainToAdd)
  end
end

function directionRadioGroupCallback(id)
  if self.trainToAdd == nil then
    self.trainToAdd = {"E",1,0}
	if not self.saveFile.global[self.groupEditing].data.circular then
      local lastStation = #self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
      self.trainToAdd[2] = lastStation
	  widget.setText("timetableOverlay.addTrainOverlay.startStationLabel","Start Station : ^green;" .. tostring(lastStation).."^reset;")
    end
  end
  if id == "0" then
    self.trainToAdd[1] = "E"
	tprint(self.trainToAdd)
  end
  if id == "1" then
    self.trainToAdd[1] = "W"
	tprint(self.trainToAdd)
  end
end

function timeEnterKey(widgetName, widgetData)
  local startTime = widget.getText("timetableOverlay.addTrainOverlay.timeTextBox")
  if self.trainToAdd == nil then
    self.trainToAdd = {"E",1,0}
	if not self.saveFile.global[self.groupEditing].data.circular then
      local lastStation = #self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
      self.trainToAdd[2] = lastStation
	  widget.setText("timetableOverlay.addTrainOverlay.startStationLabel","Start Station : ^green;" .. tostring(lastStation).."^reset;")
    end
  end
  --if startTime == nil then
    --widget.setText("timetableOverlay.addTrainOverlay.timeTextBox","0")
  --end
  self.trainToAdd[3] = tonumber(startTime) or 0
  tprint(self.trainToAdd)
end

function timecallback(widgetName, widgetData)
  local startTime = widget.getText("timetableOverlay.addTrainOverlay.timeTextBox")
  if self.trainToAdd == nil then
    self.trainToAdd = {"E",1,0}
	if not self.saveFile.global[self.groupEditing].data.circular then
      local lastStation = #self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
      self.trainToAdd[2] = lastStation
	  widget.setText("timetableOverlay.addTrainOverlay.startStationLabel","Start Station : ^green;" .. tostring(lastStation).."^reset;")
    end
  end
  --if startTime == nil then
    --widget.setText("timetableOverlay.addTrainOverlay.timeTextBox","0")
  --end
  self.trainToAdd[3] = tonumber(startTime) or 0
  tprint(self.trainToAdd)
end

function setTimetableButtonPressed(widgetName, widgetData)
  --world.setProperty("stationController_file_backup", self.saveFile)
  --world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  
  widget.setVisible("testRunOverlay", false)
  widget.setVisible("groupsOverlay", false)
  widget.setVisible("timetableOverlay", true)
  
  
  local timesArray = self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
  
  if self.saveFile.global[self.groupEditing].data.toBeInit then
    
    --local lenght = #self.saveFile.global[self.groupEditing].data.nodesPos
    
    --self.saveFile.global[self.groupEditing].data.nodesPos[#timesArray] = self.saveFile.global[self.groupEditing].data.nodesPos[1]
    --self.saveFile.global[self.groupEditing].data.uuids[#timesArray] = self.saveFile.global[self.groupEditing].data.uuids[1]
    
    self.saveFile.global[self.groupEditing].data.trainsEast = {}
    self.saveFile.global[self.groupEditing].data.trainsWest = {}
	
	self.saveFile.global[self.groupEditing].data.numberOfTrainsE = 1
	self.saveFile.global[self.groupEditing].data.numberOfTrainsW = 1
	
	self.saveFile.global[self.groupEditing].data.trainsEast.vehiclePresent = {}
	self.saveFile.global[self.groupEditing].data.trainsWest.vehiclePresent = {}
	self.saveFile.global[self.groupEditing].data.trainsEast.vehiclePresent[1] = false
	self.saveFile.global[self.groupEditing].data.trainsWest.vehiclePresent[1] = false
	
	self.groupVehiclesFile[self.groupEditing] = {}
	self.groupVehiclesFile[self.groupEditing].trainsEast = {}
	self.groupVehiclesFile[self.groupEditing].trainsEast[1] = {}
	self.groupVehiclesFile[self.groupEditing].trainsWest = {}
	self.groupVehiclesFile[self.groupEditing].trainsWest[1] = {}
	
	world.setProperty("stationController_vehicles_file", self.groupVehiclesFile)
	
	self.saveFile.global[self.groupEditing].data.trainsEast.startStations = {}
	self.saveFile.global[self.groupEditing].data.trainsEast.startTimes = {}
	self.saveFile.global[self.groupEditing].data.trainsEast.startStations[1] = 1
	self.saveFile.global[self.groupEditing].data.trainsEast.startTimes[1] = 0
	
	self.saveFile.global[self.groupEditing].data.trainsWest.startStations = {}
	self.saveFile.global[self.groupEditing].data.trainsWest.startTimes = {}
	if self.saveFile.global[self.groupEditing].data.circular then
	  self.saveFile.global[self.groupEditing].data.trainsWest.startStations[1] = 1
	else
	  self.saveFile.global[self.groupEditing].data.trainsWest.startStations[1] = #timesArray
	end  
	self.saveFile.global[self.groupEditing].data.trainsWest.startTimes[1] = 0
	
	self.saveFile.global[self.groupEditing].data.trainsEast.speeds = {}
	self.saveFile.global[self.groupEditing].data.trainsWest.speeds = {}
	self.saveFile.global[self.groupEditing].data.trainsEast.speeds[1] = {}
	self.saveFile.global[self.groupEditing].data.trainsWest.speeds[1] = {}
	self.saveFile.global[self.groupEditing].data.trainsEast.speeds[1][1] = 0
	self.saveFile.global[self.groupEditing].data.trainsWest.speeds[1][1] = 0
	
	self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen = {}
	self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen = {}
	self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[1] = {}
	self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[1] = {}
	self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[1][1] = self.defaultStopLen
	self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[1][1] = self.defaultStopLen
	
	for i=2,#self.saveFile.global[self.groupEditing].data.testRunsTimesMAX do
	  self.saveFile.global[self.groupEditing].data.trainsEast.speeds[1][i] = 100
	  self.saveFile.global[self.groupEditing].data.trainsWest.speeds[1][i] = 100
	  self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[1][i] = self.defaultStopLen
	  self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[1][i] = self.defaultStopLen
	end
	
	--self.saveFile.global[self.groupEditing].data.testRunsTimesMAXWest = {}
	
	--self.saveFile.global[self.groupEditing].data.testRunsTimesMAXWest[1] = 0
	
	--local arrayLen = #self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
	
	--for i=2,arrayLen do
	  --self.saveFile.global[self.groupEditing].data.testRunsTimesMAXWest[i] = self.saveFile.global[self.groupEditing].data.testRunsTimesMAX[arrayLen-(i-2)]
    --end
	--tprint(self.saveFile.global[self.groupEditing].data.testRunsTimesMAXWest)
	
	--for trains going to east timeArray is : (if not circular: {null,station1-2,station2-3,...,station X-Last} ) (if circular : {null,station1-2,station2-3,...,station Last-1} )
	--for trains going to west timeArray is : (if not circular: {null,station Last-X,...station3-2,station2-1} ) (if circular: {null,station 1-Last,...station3-2,station2-1} )
	
	self.saveFile.global[self.groupEditing].data.toBeInit = false
	self.saveFile.global[self.groupEditing].data.readyToStart = false
	
	world.setProperty("stationController_file", self.saveFile)
	world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  end
  
  local numOfTrainsE = self.saveFile.global[self.groupEditing].data.numberOfTrainsE
  local numOfTrainsW = self.saveFile.global[self.groupEditing].data.numberOfTrainsW
  
  --displayTrainData(1,"E",self.saveFile.global[self.groupEditing].data.trainsEast.speeds[1],self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[1])
  
  widget.setVisible("timetableOverlay.trainsEastScrollArea", true)
  widget.setVisible("timetableOverlay.trainsWestScrollArea", true)
  widget.setVisible("timetableOverlay.trainsELabel", true)
  widget.setVisible("timetableOverlay.trainsWLabel", true)
  
  widget.setVisible("timetableOverlay.addTrainButton", true)
  
  self.trainsEastListName = "timetableOverlay.trainsEastScrollArea.trainsEastList"
  self.trainsWestListName = "timetableOverlay.trainsWestScrollArea.trainsWestList"
  
  self.trainsDataListNameE = "timetableOverlay.trainsEastDataScrollArea.trainsEastDataList"
  self.trainsDataListNameW = "timetableOverlay.trainsWestDataScrollArea.trainsWestDataList"
 
  widget.clearListItems(self.trainsEastListName)
  widget.clearListItems(self.trainsWestListName)
  
  --for i=1,numOfTrainsE do
    --local listItem = string.format("%s.%s",self.trainsEastListName, widget.addListItem(self.trainsEastListName))
	--widget.setText(listItem .. ".trainLabel", "Train " .. tostring(i) .. "-E")
	--data format for widget array : {trainNum,direction}
	--widget.setData(listItem, {i,"E"})
  --end
  --for i=1,numOfTrainsW do
    --local listItem = string.format("%s.%s",self.trainsWestListName, widget.addListItem(self.trainsWestListName))
	--widget.setText(listItem .. ".trainLabel", "Train " .. tostring(i) .. "-W")
	----data format for widget array : {trainNum,direction}
	--widget.setData(listItem, {i,"W"})
  --end
  
  makeTrainList("E")
  makeTrainList("W")
  
end

function makeTrainList(direction, numoftrains)
  local numtrains
  local listname
  
  self.saveFile = world.getProperty("stationController_file")
  
  if direction == "E" then
    numtrains = numoftrains or self.saveFile.global[self.groupEditing].data.numberOfTrainsE
    listname = self.trainsEastListName
  else
    numtrains = numoftrains or self.saveFile.global[self.groupEditing].data.numberOfTrainsW
    listname = self.trainsWestListName
  end
  
  sb.logInfo("Make train list " .. direction .. " numtrains=" .. tostring(numtrains))
  
  for t=1,numtrains do
    local listItem = string.format("%s.%s",listname, widget.addListItem(listname))
	widget.setText(listItem .. ".trainLabel", "Train ^red;" .. tostring(t) .. "-" .. direction .."^reset;")
	--data format for widget array : {trainNum,direction}
	widget.setData(listItem, {t,direction})
  end
end

function trainsListSelected(widgetName, widgetData)
  
  self.saveFile = nil
  self.saveFile = world.getProperty("stationController_file")
  
  local parentElement
  
  --sb.logInfo("widgetName " .. widgetName)
  
  if widgetName == "trainsWestList" then
    parentElement = "timetableOverlay.trainsWestScrollArea"
  else
    parentElement = "timetableOverlay.trainsEastScrollArea"
  end
  
  local listName = parentElement .. "." .. widgetName
  --sb.logInfo("listName " .. listName)
  
  local listItem = widget.getListSelected(listName)
  local itemData
  if listItem then
    --sb.logInfo("listitem " .. tostring(listItem))
    itemData = widget.getData(string.format("%s.%s", listName, listItem))
	--sb.logInfo("widget.getData " .. tostring(itemData))
	--tprint(itemData)
	
	self.editingTrain = itemData
	--data format for widget array : {trainNum,direction}
    sb.logInfo("==============self.editingTrain:")
    tprint(self.editingTrain)
	
	self.viewingAtrain = true
	
	widget.setVisible("timetableOverlay.addTrainOverlay", false)
	
	local trainNum = itemData[1]
	local direction = itemData[2]
	local speedsArray
	local stopsLenArray
    sb.logInfo("widgetName")
    sb.logInfo(tostring(widgetName))
    
    if widgetName == "trainsWestList" then
	  speedsArray = self.saveFile.global[self.groupEditing].data.trainsWest.speeds[trainNum]
	  stopsLenArray = self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[trainNum]
      if (not speedsArray) or (not stopsLenArray) then
        --speedsArray = self.saveFile.global[self.groupEditing].data.trainsEast.speeds[tostring(trainNum)]
        sb.logInfo("=========ARRAYS MALFORMED=======")
        rebuildDataArrays("E")
        self.resumewidgedname = widgetName
        widget.setVisible("timetableOverlay.loadingOverlay", true)
        widget.setVisible("timetableOverlay.trainsEastDataScrollArea", false)
        widget.setVisible("timetableOverlay.trainsWestDataScrollArea", false)
        widget.setVisible("timetableOverlay.trainSettingsEastOverlay", false)
        widget.setVisible("timetableOverlay.trainSettingsWestOverlay", false)
        widget.setVisible("timetableOverlay.selectedTrainDataLabel", false)
        widget.setText("timetableOverlay.loadingOverlay.selectedTrainLabel","Train ^red;" .. itemData[1] .. "-" .. itemData[2] .. "^reset;:")
        return
      end
      sb.logInfo("=======================----------W------===================")
      sb.logInfo(tostring(speedsArray))
      sb.logInfo(tostring(stopsLenArray))
      sb.logInfo("self.groupEditing")
      sb.logInfo(tostring(self.groupEditing))
      sb.logInfo("trainNum")
      sb.logInfo(tostring(trainNum))
      tprint(self.saveFile.global[self.groupEditing].data.trainsWest.speeds[trainNum])
      tprint(self.saveFile.global[self.groupEditing].data.trainsWest.speeds[tostring(trainNum)])
	  widget.setVisible("timetableOverlay.trainsEastDataScrollArea", false)
	  widget.setVisible("timetableOverlay.trainsWestDataScrollArea", true)
	  widget.setVisible("timetableOverlay.trainSettingsWestOverlay", true)
	  widget.setVisible("timetableOverlay.trainSettingsEastOverlay", false)
	  --widget.setVisible("timetableOverlay.trainSettingsWestOverlay.selectedTrainLabel", true)
	  widget.setText("timetableOverlay.trainSettingsWestOverlay.selectedTrainLabel","Train ^red;" .. itemData[1] .. "-" .. itemData[2] .. "^reset;:")
	  widget.setText("timetableOverlay.trainSettingsWestOverlay.startStationLabel", "Start station: ^yellow;" .. tostring(self.saveFile.global[self.groupEditing].data.trainsWest.startStations[trainNum]) .."^reset;")
	  widget.setText("timetableOverlay.trainSettingsWestOverlay.startTimeLabel", "Start time: ^yellow;" .. tostring(self.saveFile.global[self.groupEditing].data.trainsWest.startTimes[trainNum]) .."^reset;")
	  widget.clearListItems(self.trainsDataListNameW)
	  widget.clearListItems(self.trainsEastListName)	  
	  makeTrainList("E")
	else
	  speedsArray = self.saveFile.global[self.groupEditing].data.trainsEast.speeds[trainNum]
      stopsLenArray = self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[trainNum]
      if (not speedsArray) or (not stopsLenArray) then
        --speedsArray = self.saveFile.global[self.groupEditing].data.trainsEast.speeds[tostring(trainNum)]
        sb.logInfo("=========ARRAYS MALFORMED=======")
        rebuildDataArrays("E")
        self.resumewidgedname = widgetName
        widget.setVisible("timetableOverlay.loadingOverlay", true)
        widget.setVisible("timetableOverlay.trainsEastDataScrollArea", false)
        widget.setVisible("timetableOverlay.trainsWestDataScrollArea", false)
        widget.setVisible("timetableOverlay.trainSettingsEastOverlay", false)
        widget.setVisible("timetableOverlay.trainSettingsWestOverlay", false)
        widget.setVisible("timetableOverlay.selectedTrainDataLabel", false)
        widget.setText("timetableOverlay.loadingOverlay.selectedTrainLabel","Train ^red;" .. itemData[1] .. "-" .. itemData[2] .. "^reset;:")
        return
      end
      sb.logInfo("=======================-------E---------===================")
      sb.logInfo(tostring(speedsArray))
      sb.logInfo(tostring(stopsLenArray))
      sb.logInfo("self.groupEditing")
      sb.logInfo(tostring(self.groupEditing))
      sb.logInfo("trainNum")
      sb.logInfo(tostring(trainNum))
      tprint(self.saveFile.global[self.groupEditing].data.trainsEast.speeds[trainNum])
      tprint(self.saveFile.global[self.groupEditing].data.trainsEast.speeds[tostring(trainNum)])
	  widget.setVisible("timetableOverlay.trainsWestDataScrollArea", false)
	  widget.setVisible("timetableOverlay.trainsEastDataScrollArea", true)

      widget.setVisible("timetableOverlay.trainSettingsWestOverlay", false)
	  widget.setVisible("timetableOverlay.trainSettingsEastOverlay", true)
	  --widget.setVisible("timetableOverlay.trainSettingsEastOverlay.selectedTrainLabel", true)
	  widget.setText("timetableOverlay.trainSettingsEastOverlay.selectedTrainLabel", "Train ^red;" .. itemData[1] .. "-" .. itemData[2] .. "^reset;:")
	  widget.setText("timetableOverlay.trainSettingsEastOverlay.startStationLabel", "Start station: ^yellow;" ..  tostring(self.saveFile.global[self.groupEditing].data.trainsEast.startStations[trainNum]).."^reset;")
	  widget.setText("timetableOverlay.trainSettingsEastOverlay.startTimeLabel", "Start time: ^yellow;" .. tostring(self.saveFile.global[self.groupEditing].data.trainsEast.startTimes[trainNum]).."^reset;")
	  
	  widget.clearListItems(self.trainsDataListNameE)
	  widget.clearListItems(self.trainsWestListName)
      makeTrainList("W")
	end
	displayTrainData(trainNum,direction,speedsArray,stopsLenArray)
  end
  
end

function rebuildDataArrays(direction)
  sb.logInfo("rebuildDataArrays called direction=",direction)
  local dataname
  local numtrains
  local rebuildspeed
  local rebuiltops
  if direction =="E" then
    dataname = "trainsEast"
    numtrains = tonumber(self.saveFile.global[self.groupEditing].data.numberOfTrainsE)
  else
    dataname = "trainsWest"
    numtrains = tonumber(self.saveFile.global[self.groupEditing].data.numberOfTrainsW)
  end
  
  self.saveFile = world.getProperty("stationController_file")
  
  local speedsArray = self.saveFile.global[self.groupEditing].data[dataname].speeds
  local stopsArray = self.saveFile.global[self.groupEditing].data[dataname].stopsLen
  if numtrains>=1 then
    if not speedsArray[1] then
      rebuildspeed = true
      sb.logInfo("rebuildspeeds")
    end
    if not stopsArray[1] then
      rebuiltops = true
      sb.logInfo("rebuildstops")
    end
  end
  local newspeedsarray
  local newstopsarray
  for t=1,numtrains do
    if rebuildspeed then
      newspeedsarray = {}
      newspeedsarray[t] = self.saveFile.global[self.groupEditing].data[dataname].speeds[tostring(t)]
      tprint(newspeedsarray[t])
    end
    if rebuiltops then
      newstopsarray = {}
      newstopsarray[t] = self.saveFile.global[self.groupEditing].data[dataname].stopsLen[tostring(t)]
      tprint(newstopsarray[t])
    end
  end
  
  self.saveFile.global[self.groupEditing].data[dataname].speeds = newspeedsarray
  self.saveFile.global[self.groupEditing].data[dataname].stopsLen = newstopsarray
  
  world.setProperty("stationController_file", self.saveFile)
  
  self.reloadDataTimer = 0
  self.reloadDataTimerT0 = world.time()
  self.reloadDataTimerSet = true
  sb.logInfo("RELOAD TIMER ENGAGED T0=" .. tostring(self.reloadDataTimerT0))
  --while self.reloadDataTimer < 15 do
    --self.reloadDataTimer = world.time() - self.reloadDataTimerT0
    --sb.logInfo("RELOAD TIMER=".. tostring(self.reloadDataTimer) .. " world.time()=" .. tostring(world.time()))
  --end
  --self.waiting = coroutine.create(waiting)
  --local s, result = coroutine.resume(self.waiting)
  --if not s then
    --error(result)
  --end
  --sb.logInfo("RELOAD TIMER ENDED T=" .. tostring(world.time()))
  --self.reloadDataTimerSet = false
end

function waiting()
  while true do
    util.run(60,sb.logInfo("WAITING"))
    coroutine.yield()
  end
end

function deleteTrainStartButtonPressed(widgetName, widgetData)
  local trainNum = self.editingTrain[1]
  local direction = self.editingTrain[2]
  self.deleteAtrainActive = true
  widget.setVisible("timetableOverlay.deleteTrainOverlay",true)
  widget.setText("timetableOverlay.deleteTrainOverlay.deleteTrainComfirmLabel","^red;Delete^reset; ^yellow; Train " .. tostring(trainNum) .. "-" .. tostring(direction) .."^reset;")
  widget.setVisible("timetableOverlay.trainSettingsEastOverlay",false)
  widget.setVisible("timetableOverlay.trainSettingsWestOverlay",false)
  widget.setVisible("timetableOverlay.trainsEastDataScrollArea",false)
  widget.setVisible("timetableOverlay.trainsWestDataScrollArea",false)
  widget.setVisible("timetableOverlay.selectedTrainDataLabel", false)
end

function deleteTrainComfirmButtonPressed(widgetName, widgetData)
 
  sb.logInfo("delete button pressed")
  
  self.groupVehiclesFile = world.getProperty("stationController_vehicles_file")
  self.saveFile = world.getProperty("stationController_file")

  local trainNum = self.editingTrain[1]
  local direction = self.editingTrain[2]
  local dataName
  
  sb.logInfo("numberOfTrainsE=" .. tostring(self.saveFile.global[self.groupEditing].data.numberOfTrainsE) .. " numberOfTrainsW=" .. tostring(self.saveFile.global[self.groupEditing].data.numberOfTrainsW))
  
  local numtrains
  if direction == "E" then 
    dataName = "trainsEast"
    numtrains = self.saveFile.global[self.groupEditing].data.numberOfTrainsE
    numtrains = numtrains - 1
    self.saveFile.global[self.groupEditing].data.numberOfTrainsE = numtrains
  else
    dataName = "trainsWest"
    numtrains = self.saveFile.global[self.groupEditing].data.numberOfTrainsW
    numtrains = numtrains - 1
    self.saveFile.global[self.groupEditing].data.numberOfTrainsW = numtrains
  end
  
  sb.logInfo("numberOfTrainsE after=" .. tostring(self.saveFile.global[self.groupEditing].data.numberOfTrainsE) .."numberOfTrainsW after=" .. tostring(self.saveFile.global[self.groupEditing].data.numberOfTrainsW))
  
  tprint(self.saveFile.global[self.groupEditing].data[dataName])
  sb.logInfo("===================")
  
  table.remove(self.saveFile.global[self.groupEditing].data[dataName].speeds, trainNum)
  table.remove(self.saveFile.global[self.groupEditing].data[dataName].stopsLen, trainNum)
  table.remove(self.saveFile.global[self.groupEditing].data[dataName].startTimes, trainNum)
  table.remove(self.saveFile.global[self.groupEditing].data[dataName].startStations, trainNum)
  if self.saveFile.global[self.groupEditing].data[dataName].vehiclePresent[trainNum] == true then
	--local vehicle = self.groupVehiclesFile[self.groupEditing][dataName][trainNum]
	--player.giveItem(vehicle)
    --self.saveFile.global[self.groupEditing].data[dataName].vehiclePresent[trainNum] = false
	--table.remove(self.groupVehiclesFile[self.groupEditing][dataName], trainNum)
	--world.setProperty("stationController_vehicles_file", self.groupVehiclesFile)
    
   removeSpawnerItemButtonPressed()
    
  end
  table.remove(self.saveFile.global[self.groupEditing].data[dataName].vehiclePresent, trainNum)
  tprint(self.saveFile.global[self.groupEditing].data[dataName])
  
  world.setProperty("stationController_file", self.saveFile)
  
  self.deleteAtrainActive = false 
  widget.setVisible("timetableOverlay.deleteTrainOverlay",false) 
  widget.clearListItems(self.trainsEastListName)
  widget.clearListItems(self.trainsWestListName)
  widget.clearListItems(self.trainsDataListNameW)
  widget.clearListItems(self.trainsDataListNameE)
  
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  
  if direction == "E" then 
    makeTrainList("W")
    makeTrainList("E", numtrains)
  else
    makeTrainList("W", numtrains)
    makeTrainList("E")
  end
end

function deleteTrainDontButtonPressed(widgetName, widgetData)
  widget.setVisible("timetableOverlay.deleteTrainOverlay",false) 
  widget.clearListItems(self.trainsEastListName)
  widget.clearListItems(self.trainsWestListName)
  widget.clearListItems(self.trainsDataListNameW)
  widget.clearListItems(self.trainsDataListNameE)
  makeTrainList("W")
  makeTrainList("E") 
end

function trainsDataListSelected(widgetName, widgetData)

  if widgetName == "trainsWestDataList" then
    parentElement = "timetableOverlay.trainsWestDataScrollArea"
	widget.setVisible("timetableOverlay.trainSettingsWestOverlay",true)
	widget.setVisible("timetableOverlay.trainSettingsEastOverlay",false)
	widget.setVisible("timetableOverlay.trainSettingsWestOverlay.selectedTrainLabel", true)
  else
    parentElement = "timetableOverlay.trainsEastDataScrollArea"
	widget.setVisible("timetableOverlay.trainSettingsEastOverlay",true)
	widget.setVisible("timetableOverlay.trainSettingsWestOverlay",false)
	widget.setVisible("timetableOverlay.trainSettingsEastOverlay.selectedTrainLabel", true)
  end
  local listName = parentElement .. "." .. widgetName
  local listItem = widget.getListSelected(listName)
  local itemData
  local trainNum
  local direction
  local station
  local speed
  local stopLen
  if listItem then
    itemData = widget.getData(string.format("%s.%s", listName, listItem))
	--data format for widget array: {trainNum,direction,station}
	
	trainNum = itemData[1]
	direction = itemData[2]
	station = itemData[3]
	
	local overlayName
	if direction == "E" then
	  speed = self.saveFile.global[self.groupEditing].data.trainsEast.speeds[trainNum][station]
	  stopLen = self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[trainNum][station]
	  overlayName = "trainSettingsEastOverlay"
	else
	  speed = self.saveFile.global[self.groupEditing].data.trainsWest.speeds[trainNum][station]
	  stopLen = self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[trainNum][station]
	  overlayName = "trainSettingsWestOverlay"
	end
	
	sb.logInfo("speed " .. tostring(speed) .. " stopLen " .. tostring(stopLen) .. " station " .. tostring(station) .. " direction " .. tostring(direction))
	
    --variable to tell to other functions what stations are we editing and the original data
	--format: self.timetableEditing = {trainNum,direction,station,numOfStations,circular,Originalspeed,OriginalstopLen,newSpeed,newStopLen}
	local numOfStations = #self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
	local circular = self.saveFile.global[self.groupEditing].data.circular
	self.timetableEditing = {trainNum,direction,station,numOfStations,circular,speed,stopLen,speed,stopLen}
	
	widget.setSliderValue("timetableOverlay." .. overlayName ..".speedSlider",speed)
	widget.setVisible("timetableOverlay." .. overlayName ..".stationLabel",true)
	widget.setVisible("timetableOverlay." .. overlayName ..".speedLabel",true)
	widget.setVisible("timetableOverlay." .. overlayName ..".speedSlider",true)
	widget.setVisible("timetableOverlay." .. overlayName ..".stopLenLabel",true)
	widget.setVisible("timetableOverlay." .. overlayName ..".stopLenValue",true)
	widget.setVisible("timetableOverlay." .. overlayName ..".stopLenSpinner",true)
	widget.setVisible("timetableOverlay." .. overlayName ..".saveButton",true)
	
	if (not self.saveFile.global[self.groupEditing].data.circular) and (station == 2) then
	  widget.setVisible("timetableOverlay." .. overlayName ..".stopLenLabel1",true)
	  widget.setVisible("timetableOverlay." .. overlayName ..".stopLenValue1",true)
	  widget.setVisible("timetableOverlay." .. overlayName ..".stopLenSpinner1",true)
	  widget.setPosition("timetableOverlay." .. overlayName ..".saveButton",{51,0})
	  self.timetableEditing[10] = true
	  if direction == "E" then
	    stopLenSt1 = self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[trainNum][1]
	  else
	    stopLenSt1 = self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[trainNum][1]
	  end
	  self.timetableEditing[11] = stopLenSt1
	  self.timetableEditing[12] = stopLenSt1
	  widget.setText("timetableOverlay." .. overlayName ..".stopLenValue1", "^yellow;" .. tostring(stopLenSt1) .. "^reset;")
	else
      widget.setVisible("timetableOverlay." .. overlayName ..".stopLenLabel1",false)
	  widget.setVisible("timetableOverlay." .. overlayName ..".stopLenValue1",false)
	  widget.setVisible("timetableOverlay." .. overlayName ..".stopLenSpinner1",false)
	  widget.setPosition("timetableOverlay." .. overlayName ..".saveButton",{27,10})
	  self.timetableEditing[10] = false
	end
	
	if direction == "E" then
	  if self.saveFile.global[self.groupEditing].data.circular then
	    if station == numOfStations then
		  widget.setText("timetableOverlay." .. overlayName ..".stationLabel", "^green;Station " .. tostring(station - 1) .. " back to 1:^reset;")
		  widget.setText("timetableOverlay." .. overlayName ..".stopLenLabel","Stop Lenght (St.1):")
		else
		  widget.setText("timetableOverlay." .. overlayName ..".stationLabel", "^green;Station " .. tostring(station - 1) .. " to " .. tostring(station) ..":^reset;")
		  widget.setText("timetableOverlay." .. overlayName ..".stopLenLabel","Stop Lenght (St." .. tostring(station) .. "):")
		end
	  else
	    widget.setText("timetableOverlay." .. overlayName ..".stationLabel", "^green;Station " .. tostring(station - 1) .. " to " .. tostring(station) ..":^reset;")
		widget.setText("timetableOverlay." .. overlayName ..".stopLenLabel","Stop Lenght (St." .. tostring(station) .. "):")
	  end
	elseif direction == "W" then
	  if self.saveFile.global[self.groupEditing].data.circular then
	    if station==2 then
		  widget.setText("timetableOverlay." .. overlayName ..".stationLabel", "^green;Station 1 to " .. tostring(numOfStations-1) ..":^reset;")
		  widget.setText("timetableOverlay." .. overlayName ..".stopLenLabel","Stop Lenght (St." .. tostring(numOfStations-1) .. "):")
		elseif station == numOfStations then
		  widget.setText("timetableOverlay." .. overlayName ..".stationLabel", "^green;Station 2 back to 1:^reset;")
		  widget.setText("timetableOverlay." .. overlayName ..".stopLenLabel","Stop Lenght (St.1):")
		else
		  widget.setText("timetableOverlay." .. overlayName ..".stationLabel", "^green;Station " .. tostring(numOfStations-(station-2)) .. " to " .. tostring(numOfStations-(station-1)) ..":^reset;")
		  widget.setText("timetableOverlay." .. overlayName ..".stopLenLabel","Stop Lenght (St." .. tostring(numOfStations-(station-1)) .. "):")
		end
	  else
	    widget.setText("timetableOverlay." .. overlayName ..".stationLabel", "^green;Station " .. tostring(numOfStations-(station-2)) .. " to " .. tostring(numOfStations-(station-1)) ..":^reset;")
		widget.setText("timetableOverlay." .. overlayName ..".stopLenLabel","Stop Lenght (St." .. tostring(numOfStations-(station-1)) .. "):")
	  end
	end
	
	widget.setText("timetableOverlay." .. overlayName ..".speedLabel", "Speed: ^yellow;" .. tostring(speed) .. "%^reset;")
	widget.setText("timetableOverlay." .. overlayName ..".stopLenValue", "^yellow;" .. tostring(stopLen) .. "^reset;")
    	
	
  end
end

function speedSlider(widgetName, widgetData)
  --variable to tell to other functions what stations are we editing and the original data
  --format: self.timetableEditing = {trainNum,direction,station,numOfStations,circular,Originalspeed,OriginalstopLen,newSpeed,newStopLen}
  local direction = self.timetableEditing[2]
  local station = self.timetableEditing[3]
  local Originalspeed = self.timetableEditing[6]
  
  local timesArray
  if direction == "E" then
    timesArray = self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
  else
    timesArray = self.saveFile.global[self.groupEditing].data.testRunsTimesMAXWest
  end
  
  local listName 
  
  if direction == "E" then
    overlayName = "trainSettingsEastOverlay"
	listName = self.trainsDataListNameE
  else
    overlayName = "trainSettingsWestOverlay"
	listName = self.trainsDataListNameW
  end
  
  local listItem = widget.getListSelected(listName)
  
  if not(newSpeed == Originalspeed) then
    local newSpeed = widget.getSliderValue("timetableOverlay." .. overlayName ..".speedSlider")
	if newSpeed > 100 then
	  widget.setSliderValue("timetableOverlay." .. overlayName ..".speedSlider", 100)
	  newSpeed = 100
	end
    self.timetableEditing[8] = newSpeed
    widget.setText("timetableOverlay." .. overlayName ..".speedLabel", "Speed: ^yellow;" .. tostring(newSpeed) .. "%^reset;")
    --math.floor((newSpeed * 10) + 0.5)/10
  
    local newTime = timesArray[station] * (100/newSpeed)
    newTime = math.floor((newTime * 10) + 0.5)/10

    --sb.logInfo("speedSlider list item name = " .. tostring(listName))
    if listItem then
      widget.setText(listName .. "." .. listItem .. ".timeLabel", "^yellow;" .. tostring(newTime) .. "^reset; s")
	  widget.setText(listName .. "." .. listItem .. ".speedsLabel", "Speed: ^yellow;" .. tostring(newSpeed) .. "%^reset;")
    end
    
  else
    widget.setText("timetableOverlay." .. overlayName ..".speedLabel", "Speed: ^yellow;" .. tostring(Originalspeed) .. "%^reset;")
	if listItem then
	  local originalTime = math.floor((Originalspeed * 10) + 0.5)/10
      widget.setText(listName .. "." .. listItem .. ".timeLabel", "^yellow;" ..  tostring(originalTime) .. "^reset; s")
	  widget.setText(listName .. "." .. listItem .. ".speedsLabel", "Speed: ^yellow;" .. tostring(Originalspeed) .. "%^reset;")
    end
  end
  
end

function timetableStationSaveButtonPressed(widgetName, widgetData)
  --variable to tell to other functions what stations are we editing and the original data
  --format: self.timetableEditing = {trainNum,direction,station,numOfStations,circular,Originalspeed,OriginalstopLen,newSpeed,newStopLen}
  local trainNum = self.timetableEditing[1]
  local direction = self.timetableEditing[2]
  local station = self.timetableEditing[3]
  --local numstation = self.timetableEditing[4]
  --local circular = self.timetableEditing[5]
  local newSpeed = self.timetableEditing[8]
  local oldSpeed = self.timetableEditing[6]
  local newStopLen = self.timetableEditing[9]
  local oldStopLen = self.timetableEditing[7]
  
  local numOfStations = #self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
  
  self.viewingAtrain = false
  
  if direction == "E" then
  
    --sb.logInfo("Saved East Train num " .. tostring(trainNum))
	--sb.logInfo("east speeds table before " .. tostring(trainNum))
	--tprint(self.saveFile.global[self.groupEditing].data.trainsEast.speeds[trainNum])
	--sb.logInfo("west speeds table before " .. tostring(trainNum))
	--tprint(self.saveFile.global[self.groupEditing].data.trainsWest.speeds[trainNum])
	
    if not (newSpeed == oldSpeed) then
	  self.saveFile.global[self.groupEditing].data.trainsEast.speeds[trainNum][station] = newSpeed
	  
	  --sb.logInfo("east speeds table after " .. tostring(trainNum))
	  --tprint(self.saveFile.global[self.groupEditing].data.trainsEast.speeds[trainNum])
	  --sb.logInfo("west speeds table after " .. tostring(trainNum))
	  --tprint(self.saveFile.global[self.groupEditing].data.trainsWest.speeds[trainNum])
	end
	if not (newStopLen == oldStopLen) then
	  self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[trainNum][station] = newStopLen
	  if self.saveFile.global[self.groupEditing].data.circular and station == numOfStations then
	    self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[trainNum][1] = self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[trainNum][station]
	  end
	end
	
	if self.timetableEditing[10] then
	  if not(self.timetableEditing[11] == self.timetableEditing[12]) then
	    self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[trainNum][1] = self.timetableEditing[12]
	  end
	end
	
  else
  
    --sb.logInfo("Saved West Train num " .. tostring(trainNum))
	--sb.logInfo("east speeds table before " .. tostring(trainNum))
	--tprint(self.saveFile.global[self.groupEditing].data.trainsEast.speeds[trainNum])
	--sb.logInfo("west speeds table before " .. tostring(trainNum))
	--tprint(self.saveFile.global[self.groupEditing].data.trainsWest.speeds[trainNum])
	
    if not (newSpeed == oldSpeed) then
      self.saveFile.global[self.groupEditing].data.trainsWest.speeds[trainNum][station] = newSpeed
	  
	  --sb.logInfo("east speeds table after " .. tostring(trainNum))
	  --tprint(self.saveFile.global[self.groupEditing].data.trainsEast.speeds[trainNum])
	  --sb.logInfo("west speeds table after " .. tostring(trainNum))
	  --tprint(self.saveFile.global[self.groupEditing].data.trainsWest.speeds[trainNum])
	end
	if not (newStopLen == oldStopLen) then
	  self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[trainNum][station] = newStopLen
	  if self.saveFile.global[self.groupEditing].data.circular and station == numOfStations then
	    self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[trainNum][1] = self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[trainNum][station]
	  end
	end
	
	if self.timetableEditing[10] then
	  if not(self.timetableEditing[11] == self.timetableEditing[12]) then
	    self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[trainNum][1] = self.timetableEditing[12]
	  end
	end
	
  end
  
  world.setProperty("stationController_file", self.saveFile)
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  
    if direction == "E" then
      widget.clearListItems(self.trainsDataListNameE)
      widget.clearListItems(self.trainsEastListName)
      widget.setVisible("timetableOverlay.trainSettingsEastOverlay",false)
      widget.setVisible("timetableOverlay.trainsEastDataScrollArea", false)
	  makeTrainList("E")
    else
      widget.clearListItems(self.trainsWestListName)
      widget.clearListItems(self.trainsDataListNameW)
      widget.setVisible("timetableOverlay.trainSettingsWestOverlay",false)
      widget.setVisible("timetableOverlay.trainsWestDataScrollArea", false)
	  makeTrainList("W")
    end
end

function displayTrainData(trainNum,direction,speedsArray,stopsLenArray)

  local timesArray
  if direction == "E" then
    timesArray = self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
  else
    timesArray = self.saveFile.global[self.groupEditing].data.testRunsTimesMAXWest
  end
  widget.setVisible("timetableOverlay.selectedTrainDataLabel", true)
  widget.setText("timetableOverlay.selectedTrainDataLabel","Train ^red;" .. trainNum .. "-" .. direction .. " ^yellow;settings:^reset;" )
  
  --if direction == "E" then
    --widget.setVisible("timetableOverlay.trainsEastDataScrollArea", true)
	--widget.setVisible("timetableOverlay.trainsWestDataScrollArea", false)

  --elseif direction == "W" then
    --widget.setVisible("timetableOverlay.trainsWestDataScrollArea", true)
    --widget.setVisible("timetableOverlay.trainsEastDataScrollArea", false)
  --end
  
  --widget.clearListItems(self.trainsDataListNameE)
  --widget.clearListItems(self.trainsDataListNameW)
  
  local numStations = #timesArray
  
  for i=2,numStations do
    local listItem
	if direction == "E" then
	  listItem = string.format("%s.%s",self.trainsDataListNameE, widget.addListItem(self.trainsDataListNameE))
	elseif direction == "W" then
	  listItem = string.format("%s.%s",self.trainsDataListNameW, widget.addListItem(self.trainsDataListNameW))
	end
	local stationDisplayName
	

	if direction == "E" then
	  if self.saveFile.global[self.groupEditing].data.circular then
	    if i == numStations then
		  stationDisplayName = "^green;" .. tostring(i-1) .. " back to 1^reset;:"
		else
		  stationDisplayName = "^green;" ..  tostring(i-1) .. " to " .. tostring(i) .. "^reset;:"
		end
	  else
	    stationDisplayName = "^green;" ..  tostring(i-1) .. " to " .. tostring(i) .. "^reset;:"
	  end
	elseif direction == "W" then
	  if self.saveFile.global[self.groupEditing].data.circular then
	    if i==2 then
		  stationDisplayName = "^green;1 to " .. tostring(numStations-1) .. "^reset;:"
		elseif i == numStations then
		  stationDisplayName = "^green;" .. tostring(numStations-(i-2)) .. " back to 1^reset;:"
		else
		  stationDisplayName = "^green;" ..  tostring(numStations-(i-2)) .. " to " .. tostring(numStations-(i-1)) .. "^reset;:"
		end
	  else
	    stationDisplayName = "^green;" ..  tostring(numStations - (i-2)) .. " to " .. tostring(numStations-(i-1)) .. "^reset;:"
	  end
	end

	widget.setText(listItem .. ".stationLabel", stationDisplayName)
	if self.saveFile.global[self.groupEditing].data.circular and (i == #timesArray) then
	  widget.setPosition(listItem .. ".stationLabel", {65, 20})
    end
	local newTime = timesArray[i] * (100/speedsArray[i])
	newTime = math.floor((newTime * 10) + 0.5)/10
	widget.setText(listItem .. ".timeLabel", "^yellow;" .. tostring(newTime) .. "^reset; s")
	widget.setText(listItem .. ".speedsLabel", "Speed: ^yellow;" .. tostring(speedsArray[i]) .. "%^reset;")
	widget.setText(listItem .. ".stopLenghtLabel", "^yellow;" .. tostring(stopsLenArray[i]) .. "^reset; seconds stop")
	--data format for widget array: {trainNum,direction,station}
	widget.setData(listItem, {trainNum,direction,i})
  end
end

function addSpawnerToTrainButtonPressed(widgetName, widgetData)
  local trainNum = self.editingTrain[1]
  local direction = self.editingTrain[2]
  local overlayname
  local slotname
  
  local slot_widget
  
  if direction == "E" then
    overlayname = "timetableOverlay.trainSettingsEastOverlay"
	slotName = "itemslot2"
  else
    overlayname = "timetableOverlay.trainSettingsWestOverlay"
	slotName = "itemslot3"
  end
  
  slot_widget = overlayname .. "." .. slotName
  
  local slottedItem = widget.itemSlotItem(slot_widget)
  
if slottedItem then
  if slottedItem.count > 1 then
    local count = slottedItem.count - 1
    local superfluosItems = slottedItem
    superfluosItems.count = count
	player.giveItem(superfluosItems)
	slottedItem.count = 1
  end

  slottedItem.parameters.stationControlled = true
  slottedItem.parameters.stations = {}
  slottedItem.parameters.stations.circular = self.saveFile.global[self.groupEditing].data.circular
  
  --if slottedItem.parameters.stations.circular then
    --local numStations = #slottedItem.parameters.stations.pos
	--slottedItem.parameters.stations.pos[numStations+1] = slottedItem.parameters.stations.pos[numStations]
  --end
  slottedItem.parameters.stations.groupName = self.saveFile[self.uuid].group
  
  --if slottedItem.parameters.stations.circular then
    --local arrayLen = #self.saveFile.global[self.groupEditing].data.uuids
	--slottedItem.parameters.stations.pos[arrayLen] = slottedItem.parameters.stations.pos[1]
	--slottedItem.parameters.stations.uuids[arrayLen] = slottedItem.parameters.stations.uuids[1]
  --end
  
  slottedItem.parameters.timetable = {}
  slottedItem.parameters.timetable.trainNum = trainNum
  slottedItem.parameters.timetable.direction = direction
  
  slottedItem.parameters.timetable.speeds = {}
  slottedItem.parameters.timetable.stopsLen = {}
  slottedItem.parameters.timetable.times = {}
  
  
  if direction == "E" then
    slottedItem.parameters.timetable.speeds = self.saveFile.global[self.groupEditing].data.trainsEast.speeds[trainNum]
	slottedItem.parameters.timetable.stopsLen = self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[trainNum]
	slottedItem.parameters.timetable.times = self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
	slottedItem.parameters.timetable.startTime = self.saveFile.global[self.groupEditing].data.trainsEast.startTimes[trainNum]
	slottedItem.parameters.timetable.startStation = self.saveFile.global[self.groupEditing].data.trainsEast.startStations[trainNum]
    slottedItem.parameters.stations.pos = self.saveFile.global[self.groupEditing].data.nodesPos
    slottedItem.parameters.stations.uuids = self.saveFile.global[self.groupEditing].data.uuids
    
	self.groupVehiclesFile[self.groupEditing].trainsEast[trainNum] = slottedItem
	self.saveFile.global[self.groupEditing].data.trainsEast.vehiclePresent[trainNum] = true
  else
    slottedItem.parameters.timetable.speeds = self.saveFile.global[self.groupEditing].data.trainsWest.speeds[trainNum]
	slottedItem.parameters.timetable.stopsLen = self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[trainNum]
	slottedItem.parameters.timetable.times = self.saveFile.global[self.groupEditing].data.testRunsTimesMAXWest
	slottedItem.parameters.timetable.startTime = self.saveFile.global[self.groupEditing].data.trainsWest.startTimes[trainNum]
	slottedItem.parameters.timetable.startStation = self.saveFile.global[self.groupEditing].data.trainsWest.startStations[trainNum]
    
    if slottedItem.parameters.stations.circular then
      local nodesPos = self.saveFile.global[self.groupEditing].data.nodesPos
      local nodesPosW = {}
      for i=#nodesPos, 1, -1 do
        table.insert(nodesPosW,nodesPos[i])
      end
      local uuids = self.saveFile.global[self.groupEditing].data.uuids
      local uuidsW = {}
      for i=#uuids, 1, -1 do
        table.insert(uuidsW,uuids[i])
      end
      slottedItem.parameters.stations.pos = nodesPosW
      slottedItem.parameters.stations.uuids = uuidsW
    else
      slottedItem.parameters.stations.pos = self.saveFile.global[self.groupEditing].data.nodesPos
      slottedItem.parameters.stations.uuids = self.saveFile.global[self.groupEditing].data.uuids
    end
    
    self.groupVehiclesFile[self.groupEditing].trainsWest[trainNum] = slottedItem
    self.saveFile.global[self.groupEditing].data.trainsWest.vehiclePresent[trainNum] = true
  end
  
  
  sb.logInfo("Train num " .. tostring(trainNum) .. "-" .. tostring(direction) .. " vehicle spawner item descriptor:")
  tprint(slottedItem)
  
  widget.setVisible(slot_widget, false)
  widget.setVisible(overlayname .. ".ErrorLabel1",false)
  widget.setVisible(overlayname .. ".vehiclePresentLabel",true)
  widget.setVisible(overlayname .. ".removeVehicleButton",true)
  widget.setVisible(overlayname .. ".addVehicleButton",false)
  
  local numberOfTrainsE = self.saveFile.global[self.groupEditing].data.numberOfTrainsE
  local numberOfTrainsW = self.saveFile.global[self.groupEditing].data.numberOfTrainsW
  
  local readyToStart = true
  
  if numberOfTrainsE >= 1 and numberOfTrainsW == 0 then
    for t=1,numberOfTrainsE do
      if self.saveFile.global[self.groupEditing].data.trainsEast.vehiclePresent[t] == false then
        readyToStart = false
        break
      end
    end
  elseif numberOfTrainsE == 0 and numberOfTrainsW >= 1 then
    for t=1,numberOfTrainsW do
      if self.saveFile.global[self.groupEditing].data.trainsWest.vehiclePresent[t] == false then
        readyToStart = false
        break
      end
    end
  elseif numberOfTrainsE >= 1 and numberOfTrainsW >= 1 then
    for t=1,numberOfTrainsE do
      if self.saveFile.global[self.groupEditing].data.trainsEast.vehiclePresent[t] == false then
        readyToStart = false
        break
      end
    end
    for t=1,numberOfTrainsW do
      if self.saveFile.global[self.groupEditing].data.trainsWest.vehiclePresent[t] == false then
        readyToStart = false
        break
      end
    end
  else
    readyToStart = false
  end
  
  if readyToStart == true then
    widget.setVisible("groupsOverlay.startTrainsButton", true)
  else
    widget.setVisible("groupsOverlay.startTrainsButton", false)
  end
  
  self.saveFile.global[self.groupEditing].data.readyToStart = readyToStart
  
  world.setProperty("stationController_vehicles_file", self.groupVehiclesFile)
  world.setProperty("stationController_file", self.saveFile)
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  
  widget.setItemSlotItem(slot_widget, nil)
end
  

end

function changeTrainStartButtonPressed(widgetName, widgetData)
  local trainNum = self.editingTrain[1]
  local direction = self.editingTrain[2]
  widget.setVisible("timetableOverlay.changeStartingParamsOverlay", true)
  widget.setVisible("timetableOverlay.trainSettingsEastOverlay",false)
  widget.setVisible("timetableOverlay.trainSettingsWestOverlay",false)
  widget.setVisible("timetableOverlay.trainsEastDataScrollArea",false)
  widget.setVisible("timetableOverlay.trainsWestDataScrollArea",false)
  widget.setVisible("timetableOverlay.selectedTrainDataLabel", false)
  widget.setText("timetableOverlay.changeStartingParamsOverlay.addTrainLabel", "^yellow;Train ^red;" .. tostring(trainNum) .. "-" .. direction .. "^yellow; Starting params:^reset;")
  
  if direction == "E" then
	dataName = "trainsEast"
    self.resumewidgedname = "trainsEastList"
  else
	dataName = "trainsWest"
    self.resumewidgedname = "trainsWestList"
  end
  
  local startStation = self.saveFile.global[self.groupEditing].data[dataName].startStations[tonumber(trainNum)]
  local startTime = self.saveFile.global[self.groupEditing].data[dataName].startTimes[tonumber(trainNum)]
  
  self.startingParams = {startStation,startTime}
  
  local stationslistname = "timetableOverlay.changeStartingParamsOverlay.stationEditScrollArea.stationEditList"
  
  self.saveFile = world.getProperty("stationController_file")
  
  widget.clearListItems(stationslistname)
  
  widget.setText("timetableOverlay.changeStartingParamsOverlay.timeTextBox","0")
  
  local numOfStations = #self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
  
  if self.saveFile.global[self.groupEditing].data.circular then
    numOfStations = numOfStations -1
  end
  
  for s=1,numOfStations do
    local listItem = string.format("%s.%s",stationslistname, widget.addListItem(stationslistname))
    widget.setText(listItem .. ".stationLabel", "^green;Station " .. tostring(s) .. "^reset;")
    widget.setData(listItem, s)
  end
  
end

function timeEditEnterKey(widgetName, widgetData)
  local startTime = widget.getText("timetableOverlay.changeStartingParamsOverlay.timeTextBox")
  self.startingParams[2] = startTime or self.startingParams[2]
  tprint(self.startingParams)
end

function timeEditcallback(widgetName, widgetData)
  local startTime = widget.getText("timetableOverlay.changeStartingParamsOverlay.timeTextBox")
  self.startingParams[2] = startTime or self.startingParams[2]
  tprint(self.startingParams)
end

function stationEditSelected(widgetName, widgetData)
  local listName = "timetableOverlay.changeStartingParamsOverlay.stationEditScrollArea.stationEditList"
  local listItem = widget.getListSelected(listName)
  local itemData
  if listItem then
    itemData = widget.getData(string.format("%s.%s", listName, listItem))
	widget.setText("timetableOverlay.changeStartingParamsOverlay.startStationLabel","Start Station : ^green;" .. tostring(itemData).."^reset;")
	self.startingParams[1] = tonumber(itemData)
	tprint(self.startingParams)
  end
end

function saveStartingParamsButtonPressed(widgetName, widgetData)
  self.saveFile = world.getProperty("stationController_file")
  local trainNum = self.editingTrain[1]
  local direction = self.editingTrain[2]
  self.saveFile.global[self.groupEditing].data[dataName].startStations[tonumber(trainNum)] = self.startingParams[1]
  self.saveFile.global[self.groupEditing].data[dataName].startTimes[tonumber(trainNum)] = self.startingParams[2]
  widget.setVisible("timetableOverlay.changeStartingParamsOverlay", false)
  world.setProperty("stationController_file", self.saveFile)
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  --trainsListSelected(self.resumewidgedname)
  self.reloadDataTimer = 0
  self.reloadDataTimerT0 = world.time()
  self.reloadDataTimerSet = true
  widget.setVisible("timetableOverlay.loadingOverlay", true)
  widget.setText("timetableOverlay.loadingOverlay.selectedTrainLabel","Train ^red;" .. trainNum .. "-" .. direction .. "^reset;:")
end

function discardtartingParamsButtonPressed(widgetName, widgetData)
  widget.setVisible("timetableOverlay.changeStartingParamsOverlay", false)
  self.startingParams = nil
  trainsListSelected(self.resumewidgedname)
end

function startTrainsButtonPressed(widgetName, widgetData)
  self.saveFile = world.getProperty("stationController_file")
  local numberOfTrainsE = self.saveFile.global[self.groupEditing].data.numberOfTrainsE
  local numberOfTrainsW = self.saveFile.global[self.groupEditing].data.numberOfTrainsW
  world.sendEntityMessage(pane.sourceEntity(), "startTrains", self.groupEditing, numberOfTrainsE, numberOfTrainsW)
end

function stopTrainsButtonPressed(widgetName, widgetData)
  world.sendEntityMessage(pane.sourceEntity(), "stopTrains")
end

function removeSpawnerItemButtonPressed(widgetName, widgetData)
  local trainNum = self.editingTrain[1]
  local direction = self.editingTrain[2]
  local overlayname
  local slotname
  
  local item
  
  if direction == "E" then
    item = self.groupVehiclesFile[self.groupEditing].trainsEast[trainNum]
	overlayname = "timetableOverlay.trainSettingsEastOverlay"
	slotName = "itemslot2"
  else
    item = self.groupVehiclesFile[self.groupEditing].trainsWest[trainNum]
	overlayname = "timetableOverlay.trainSettingsWestOverlay"
	slotName = "itemslot3"
  end
  
  local slot_widget = overlayname .. "." .. slotName
  
  item.parameters.stationControlled = false
  item.parameters.stations = nil
  item.parameters.timetable = nil
  
  player.giveItem(item)
  
  if direction == "E" then
    self.groupVehiclesFile[self.groupEditing].trainsEast[trainNum] = {}
	self.saveFile.global[self.groupEditing].data.trainsEast.vehiclePresent[trainNum] = false
  else
    self.groupVehiclesFile[self.groupEditing].trainsWest[trainNum] = {}
	self.saveFile.global[self.groupEditing].data.trainsWest.vehiclePresent[trainNum] = false
  end
  
  self.saveFile.global[self.groupEditing].data.readyToStart = false
  
  widget.setVisible("groupsOverlay.startTrainsButton", false)
  
  world.setProperty("stationController_vehicles_file", self.groupVehiclesFile)
  world.setProperty("stationController_file", self.saveFile)
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  widget.setVisible(slot_widget, true)
  widget.setVisible(overlayname .. ".addVehicleButton",true)
  widget.setVisible(overlayname .. ".vehiclePresentLabel",false)
  widget.setVisible(overlayname .. ".removeVehicleButton",false)
  widget.setVisible(overlayname .. ".ErrorLabel1",false)
  
end

function createGroupButtonPressed(widgetName, widgetData)
  widget.setVisible("groupsOverlay.NoGroupLabel", false)
  widget.setVisible("groupsOverlay.createGroupButton", false)
  widget.setVisible("groupsOverlay.groupNameLabel", true)
  widget.setVisible("groupsOverlay.groupNameTextBox", true)
  widget.setVisible("groupsOverlay.nameGroupButton", true)
end

function nameGroupButtonPressed(widgetName, widgetData)
  local groupName = widget.getText("groupsOverlay.groupNameTextBox")
  if (groupName == "") or (groupName == nil) then
    groupNameError("empty")
	return
  end
  if self.saveFile.global.numOfGroups >= 1 then
    local groupsNames = self.saveFile.global.groups
	for k,v in pairs(groupsNames) do
	  if v == groupName then
	    groupNameError("taken")
		return
	  end
	end
  end
  widget.setText("mainOverlay.groupNameValue", "^green;" .. groupName .. "^reset;")
    widget.setText("mainOverlay.numInGroupValue", "^green;" .. tostring(1) .. "^reset;")
  if self.saveFile.global.numOfGroups == 0 then self.saveFile.global.groups = {} end
  self.saveFile.global.numOfGroups = self.saveFile.global.numOfGroups +1
  self.saveFile.global.groups[self.saveFile.global.numOfGroups] = groupName
  self.saveFile[self.uuid].grouped = true
  self.saveFile[self.uuid].group = groupName
  self.saveFile[self.uuid].numInGroup = 1
  self.saveFile[groupName] = {}
  self.saveFile[groupName][self.uuid] = {}
  self.saveFile[groupName][self.uuid].number = 1
  self.saveFile.global[groupName] = {}
  self.saveFile.global[groupName].data = {}
  self.saveFile.global[groupName].data.slottedItem = false
  self.saveFile.global[groupName].data.circular = false
  self.saveFile.global[groupName].data.numOfStationsInGroup = 1
  self.saveFile.global[groupName].data.uuids = {}
  self.saveFile.global[groupName].data.uuids[1] = self.uuid
  self.saveFile.global[groupName].data.nodesPos = {}
  self.saveFile.global[groupName].data.nodesPos[1] = self.saveFile[self.uuid].nodepos
  self.saveFile.global[groupName].data.testRunCompleted = false
  self.saveFile.global[groupName].data.readyToStart = false
  self.saveFile.global[groupName].data.operational = false

  world.setProperty("stationController_file", self.saveFile)
  
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  --world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", false, false, true)
  
  local numInGroup = self.saveFile[groupName][self.uuid].number
  
  widget.setVisible("groupsOverlay.groupNameTextBox", false)
  widget.setVisible("groupsOverlay.nameGroupButton", false)
  widget.setVisible("groupsOverlay.groupNameLabel", true)
  widget.setVisible("groupsOverlay.groupNameValue", true)
  widget.setText("groupsOverlay.groupNameValue", "^green;" .. groupName .. "^reset;")
  widget.setVisible("groupsOverlay.numInGroupLabel", true)
  widget.setVisible("groupsOverlay.numInGroupValue", true)
  widget.setText("groupsOverlay.numInGroupValue", "^green;" .. tostring(numInGroup) .. "^reset;")
  widget.setVisible("groupsOverlay.addStationToGroupButton", true)
  widget.setVisible("groupsOverlay.removeStationfromGroupButton", true)
  widget.setVisible("groupsOverlay.renameGroupButton", true)
  widget.setVisible("groupsOverlay.reorderGroupStationsButton", true)
  widget.setVisible("groupsOverlay.manageOtherGroupsButton", true)
  
  widget.setVisible("groupsOverlay.membersInGroupLabel", true)
  widget.setVisible("groupsOverlay.membersInGroupValue", true)
  widget.setText("groupsOverlay.membersInGroupLabel", "Members of group " .. "^green;" .. groupName .. "^reset; (in order):")
	
  local members = {}
  local membersString = ""
	
  for k,v in pairs(self.saveFile[groupName]) do
    local number = self.saveFile[groupName][k].number
    members[number] = self.saveFile[k].name
  end
	
  for i=1,#members do
    if i == 1 then
      membersString = members[i]
    else
      membersString = membersString .. " , " .. members[i]
    end
  end
	
  widget.setText("groupsOverlay.membersInGroupValue", "^green;" .. membersString.. "^reset;")
    
  widget.setVisible("groupsOverlay", false)
  widget.setVisible("mainOverlay.NoGroupLabel1", false)
  widget.setVisible("mainOverlay.groupNameLabel", true)
  widget.setVisible("mainOverlay.groupNameValue", true)
  
  widget.setVisible("mainOverlay.numInGroupLabel", true)
  widget.setVisible("mainOverlay.numInGroupValue", true)
  
  widget.setVisible("loadingGroupsOverlay", true)
  self.reloadDataTimer1 = 0
  self.reloadDataTimer1T0 = world.time()
  self.reloadDataTimer1Set = true
end

function addStationToGroupButtonPressed(widgetName, widgetData)
  self.saveFile = world.getProperty("stationController_file")
  widget.setVisible("groupsOverlay", false)
  widget.setVisible("addStationOverlay", true)
  --from /interface/scripted/vehiclerepair/vehiclerepairgui.lua for reference
  --for i,item in pairs(self.vehicleItems) do
    --local listItem = string.format("%s.%s", "widgetname", widget.addListItem("widgetname"))
	--[...]
  --end
  
  local stationsList = {}
  local groupMembers = {}
  local tempList = deepcopy(stationsList)
  groupMembers = self.saveFile[self.groupEditing]
  stationsList = self.saveFile.global.stationsList
  
  --for k,v in pairs(groupMembers) do
    --for i=1,#stationsList do
	  --if k == stationsList[i] then
	    --table.remove(tempList,i)
	  --end
	--end
  --end
  --stationsList = templist
  
  widget.clearListItems(self.widgetListName)
  
  for i=1,#stationsList do
    
   if (not self.saveFile[stationsList[i]].grouped)  then
     if self.saveFile[stationsList[i]].group ~= self.groupEditing then
       local stationDisplayName = self.saveFile[stationsList[i]].name
       local listItem = string.format("%s.%s",self.widgetListName, widget.addListItem(self.widgetListName))
	   sb.logInfo("listItem " .. tostring(i) .. " " .. listItem .. " ==> " .. listItem .. ".member")
	   sb.logInfo("stationDisplayName " .. stationDisplayName)
	   widget.setText(listItem .. ".member", stationDisplayName)
	   widget.setData(listItem, stationsList[i])
	 end
   end
   
  end
  
end

function addSTationToExistingButtonPressed(widgetName, widgetData)
  addToGroup(self.groupEditing)
end

function addToGroup(group)
  local numInGroup = 0
  for _ in pairs(self.saveFile[group]) do numInGroup = numInGroup + 1 end
  sb.logInfo("self.groupEditing " .. group)
  sb.logInfo("self.addStationToGroup " .. self.addStationToGroup)
  self.saveFile[group][self.addStationToGroup] = {}
  numInGroup = numInGroup + 1
  self.saveFile[group][self.addStationToGroup].number = numInGroup 
  self.saveFile[self.addStationToGroup].grouped = true
  self.saveFile[self.addStationToGroup].group = group
  self.saveFile[self.addStationToGroup].numInGroup = numInGroup
  self.saveFile.global[group].data.numOfStationsInGroup = self.saveFile.global[group].data.numOfStationsInGroup + 1
  self.saveFile.global[group].data.uuids[numInGroup] = self.addStationToGroup
  self.saveFile.global[group].data.nodesPos[numInGroup] = self.saveFile[self.addStationToGroup].nodepos
  if self.saveFile.global[self.groupEditing].data.circular then
    self.saveFile.global[group].data.nodesPos[numInGroup + 1] = self.saveFile.global[group].data.nodesPos[1]
  end
  
  tprint(self.saveFile)
  
  world.setProperty("stationController_file", self.saveFile)
  self.saveFile = world.getProperty("stationController_file")
  
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  widget.setVisible("addStationOverlay.addStationLabel", false)
  widget.setVisible("addStationOverlay.addStationvalue", false)
  widget.setVisible("addStationOverlay.addSTationToExistingButton", false)
  widget.setVisible("addStationOverlay", false)
  widget.setVisible("mainOverlay", true)
  widget.clearListItems(self.widgetListName)
end

function stationsListSelected(widgetName, widgetData)
  local listItem = widget.getListSelected(self.widgetListName)
  if listItem then
    sb.logInfo("listitem " .. tostring(listItem))
    local itemData = widget.getData(string.format("%s.%s", self.widgetListName, listItem))
	sb.logInfo("widget.getData " .. tostring(itemData))
	--if type(itemData) == "table" then tprint(itemData) end
	self.addStationToGroup = itemData
	widget.setVisible("addStationOverlay.addStationLabel", true)
	widget.setVisible("addStationOverlay.addStationvalue", true)
	widget.setVisible("addStationOverlay.addSTationToExistingButton", true)
    widget.setText("addStationOverlay.addStationvalue", self.saveFile[itemData].name)
  end
  
end

function backToMainFromGroupsButtonPressed(widgetName, widgetData)
  widget.setVisible("groupsOverlay", false)
  widget.setVisible("mainOverlay", true)
end

function backToMainFromAddStationButtonPressed(widgetName, widgetData)
  widget.setVisible("addStationOverlay", false)
  widget.setVisible("groupsOverlay", true)
  widget.clearListItems(self.widgetListName)
end

function circularCheckBox(widgetName, widgetData)
  self.saveFile = world.getProperty("stationController_file")
  
  if not self.saveFile.global[self.groupEditing].data.testRunCompleted then
    self.saveFile.global[self.groupEditing].data.circular = not self.saveFile.global[self.groupEditing].data.circular
    if self.saveFile.global[self.groupEditing].data.circular then
      self.saveFile.global[self.groupEditing].data.nodesPos[self.saveFile.global[self.groupEditing].data.numOfStationsInGroup + 1] = self.saveFile.global[self.groupEditing].data.nodesPos[1]
    else
      self.saveFile.global[self.groupEditing].data.nodesPos[self.saveFile.global[self.groupEditing].data.numOfStationsInGroup + 1] = nil
    end
    world.setProperty("stationController_file", self.saveFile)
    world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  else
    widget.setChecked("groupsOverlay.circularCheckBox", self.saveFile.global[self.groupEditing].data.circular)
  end
  
end

function distanceMathMagick(x1, x2, y1, y2, planetsize)
  
  local distance
  if y1==y2 then
    if x1 < x2 then
      distance =  math.floor(x2 - x1)
    else
      distance =  math.floor( (planetsize[1] - x1) + x2 )
    end
  else
    if x1 < x2 then
      distance =  math.floor(math.sqrt( math.pow((x2-x1),2) + math.pow((y2-y1),2) ) )
    else
      local median = {}
      median[1] = planetsize[1]
      if y1 < y2 then
        median[2] = ((y2 - y1) / 2) + y1
      else
        median[2] = ((y1 - y2) / 2) + y2
      end
     distance =  math.floor(math.sqrt( math.pow((median[1]-x1),2) + math.pow((median[2]-y1),2) ) ) + math.floor(math.sqrt( math.pow((x2),2) + math.pow((y2-median[2]),2) ) )
    end
  end
  
  return distance
  
end

function calculatedist()
  local numOfStations = self.saveFile.global[self.groupEditing].data.numOfStationsInGroup --self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
  local circular = self.saveFile.global[self.groupEditing].data.circular
  
  if circular then
    numOfStations = numOfStations + 1
  end
  
  local distarray = {}
  for i=2,numOfStations do
    local dist1 = self.saveFile.global[self.groupEditing].data.nodesPos[i-1]
    local dist2 = self.saveFile.global[self.groupEditing].data.nodesPos[i]
    --distarray[i-1] =  math.floor(world.magnitude(dist1,dist2))
    
    local x1 = dist1[1]
    local x2 = dist2[1]
    local y1 = dist1[2]
    local y2 = dist2[2]
    
    local planetsize = world.size()
    
    distarray[i-1] = distanceMathMagick(x1,x2,y1,y2,planetsize)
    
  end
  
  sb.logInfo("distance array=")
  tprint(distarray)
  
  self.saveFile.global[self.groupEditing].data.distances = distarray
  
  world.setProperty("stationController_file", self.saveFile)
  
end

function additionalDistancesButtonPressed(widgetName, widgetData)
  widget.setVisible("testRunOverlay", false)
  widget.setVisible("additionalDistancesOverlay", true)
  
  local line1listname = "additionalDistancesOverlay.Lines1ScrollArea.linesList"
  local line2listname = "additionalDistancesOverlay.Lines2ScrollArea.linesList"
  local stations1listname = "additionalDistancesOverlay.stations1ScrollArea.stationsList"
  local stations2listname = "additionalDistancesOverlay.stations2ScrollArea.stationsList"
  widget.clearListItems(line1listname)
  widget.clearListItems(line2listname)
  widget.clearListItems(stations1listname)
  widget.clearListItems(stations2listname)
  
  local groupname
  tprint(self.saveFile.global.groups)
  
  for g=1,self.saveFile.global.numOfGroups do
    groupname = self.saveFile.global.groups[g]
    local listItem = string.format("%s.%s",line1listname, widget.addListItem(line1listname))
    widget.setText(listItem .. ".linename", groupname)
    widget.setData(listItem, groupname)
  end
  
  local groupname
  
  for g=1,self.saveFile.global.numOfGroups do
    groupname = self.saveFile.global.groups[g]
    local listItem = string.format("%s.%s",line2listname, widget.addListItem(line2listname))
    widget.setText(listItem .. ".linename", groupname)
    widget.setData(listItem, groupname)
  end
  
end

function additionalDistancesLine1Selected(widgetName, widgetData)
  --sb.logInfo("1-------------------")
  additionalDistancesLineSelected(1) 
end
function additionalDistancesLine2Selected(widgetName, widgetData)
  --sb.logInfo("2-------------------")
  additionalDistancesLineSelected(2)
end

function additionalDistancesLineSelected(numlist)
  
  local listName = "additionalDistancesOverlay.Lines" .. tostring(numlist) .. "ScrollArea.linesList"
  local listItem = widget.getListSelected(listName)
  if listItem then
    --sb.logInfo("-----------------" .. listItem .. "-------------------")
    local groupname = widget.getData(string.format("%s.%s", listName, listItem))
    if self.additionalDistanceData == nil then
      self.additionalDistanceData = {}
      self.additionalDistanceData[1] = {}
      self.additionalDistanceData[2] = {}
    end
    self.additionalDistanceData[1][numlist] = groupname
    sb.logInfo(" SELECTED:")
    tprint(self.additionalDistanceData)
    
    local stationslistname = "additionalDistancesOverlay.stations" .. tostring(numlist) .. "ScrollArea.stationsList"
    widget.clearListItems(stationslistname)
      
    local numOfStations = self.saveFile.global[groupname].data.numOfStationsInGroup
    for s=1,numOfStations do
      local listItem = string.format("%s.%s",stationslistname, widget.addListItem(stationslistname))
      widget.setText(listItem .. ".stationName", "Station " .. tostring(s))
      widget.setData(listItem, s)
    end
    
  end
  
end

function additionalDistancesStation1Selected(widgetName, widgetData)
  additionalDistancesStationSelected(1)
end

function additionalDistancesStation2Selected(widgetName, widgetData)
  additionalDistancesStationSelected(2)
end

function additionalDistancesStationSelected(numlist)
  local listName = "additionalDistancesOverlay.stations" .. tostring(numlist) .. "ScrollArea.stationsList"
  local listItem = widget.getListSelected(listName)
  if listItem then
    local numstation = widget.getData(string.format("%s.%s", listName, listItem))
    self.additionalDistanceData[2][numlist] = numstation
    sb.logInfo(" SELECTED:")
    tprint(self.additionalDistanceData)
    
    if self.additionalDistanceData[1][1] and self.additionalDistanceData[1][2] and self.additionalDistanceData[2][1] and self.additionalDistanceData[2][2] then
      sb.logInfo("show distance")
      widget.setVisible("additionalDistancesOverlay.distance1Label", true)
      local group1 = self.additionalDistanceData[1][1]
      local group2 = self.additionalDistanceData[1][2]
      local station1 = self.additionalDistanceData[2][1]
      local station2 = self.additionalDistanceData[2][2]
      widget.setText("additionalDistancesOverlay.distance1Label", ("Distance between ^green;" .. group1 .."^reset;^yellow; Station " .. tostring(station1) .. "^reset; and ^green;" .. group2 .. "^reset;^yellow; Station " .. tostring(station2) .. "^reset;:") )
      widget.setVisible("additionalDistancesOverlay.distance2Label", true)
      
      station1pos = self.saveFile.global[group1].data.nodesPos[station1]
      station2pos = self.saveFile.global[group2].data.nodesPos[station2]
      
      tprint(station1pos)
      tprint(station2pos)
      
      local planetsize = world.size()
      local distance = distanceMathMagick(tonumber(station1pos[1]),tonumber(station2pos[1]),tonumber(station1pos[2]),tonumber(station2pos[2]),planetsize)
      sb.logInfo("distance " .. tostring(distance))
      
      widget.setText("additionalDistancesOverlay.distance2Label", "^red;" .. tostring(distance) .. "^reset; blocks")
    end
  end
end

function testRunButtonPressed(widgetName, widgetData)
  widget.setVisible("groupsOverlay", false)
  widget.setVisible("testRunOverlay", true)
  widget.setVisible("testRunOverlay.backToMainButton", true)
  self.numOfTestRunTodo = 10
  widget.setText("testRunOverlay.testRunNumValue",self.numOfTestRunTodo)
  
  local nodepos = self.saveFile.global[self.groupEditing].data.nodesPos
  sb.logInfo("NODEPOS==============")
  tprint(nodepos)
  
  local nodeposconnected = true
  if nodepos == nil then
    nodeposconnected = false
    self.saveFile.global[self.groupEditing].data.nodeposconnected = false
    world.setProperty("stationController_file", self.saveFile)
    sb.logInfo("=====NIL=======nodeposconnected = " .. tostring(nodeposconnected))
  else
    for s=1,#nodepos do
      tprint(nodepos[s])
      if not nodepos[s] then
        nodeposconnected = false
      end
    end
    self.saveFile.global[self.groupEditing].data.nodeposconnected = nodeposconnected
    world.setProperty("stationController_file", self.saveFile)
    sb.logInfo("======1=======nodeposconnected = " .. tostring(nodeposconnected))
  end
  
  if nodeposconnected then
    calculatedist()
    self.distanceListName = "testRunOverlay.distancesScrollArea.distancesList"
    widget.clearListItems(self.distanceListName)
    local distArray = self.saveFile.global[self.groupEditing].data.distances
    for i=1,#distArray do
      local listItem = string.format("%s.%s",self.distanceListName, widget.addListItem(self.distanceListName))
      local stationDisplayName
	  if self.saveFile.global[self.groupEditing].data.circular and (i == #distArray) then
	    stationDisplayName = tostring(i) .. " back to 1:"
      else
	    stationDisplayName = tostring(i) .. " to " .. tostring(i+1) .. ":"
	  end
      widget.setText(listItem .. ".stationLabel", stationDisplayName)
      if self.saveFile.global[self.groupEditing].data.circular and (i == #distArray) then
	    widget.setPosition(listItem .. ".stationLabel", {60, 1})
	  end
      widget.setText(listItem .. ".distanceLabel", tostring(distArray[i]) .. " blocks")
    end
    
	world.setProperty("stationController_file", self.saveFile)
    
    widget.setVisible("testRunOverlay.distanceslabel", true)
    widget.setVisible("testRunOverlay.distancesScrollArea", true)
    if self.saveFile.global.numOfGroups > 1 then
      widget.setVisible("testRunOverlay.additionalDistancesButton", true)
    else
      widget.setVisible("testRunOverlay.additionalDistancesButton", false)
    end
  else
    widget.setVisible("testRunOverlay.distanceslabel", false)
    widget.setVisible("testRunOverlay.distancesScrollArea", false)
    widget.setVisible("testRunOverlay.additionalDistancesButton", false)
  end
  
    widget.setText("testRunOverlay.errorScrollArea.errorLabel","Error: ensure all rail station markers are wired to all the station controllers of ^green;" .. self.groupEditing .. "^reset; and try again, you can craft rail stations marker in the rail crafting table, only use 'rail station marker' DO NOT use vanilla(regular) tram stops")
    widget.setVisible("testRunOverlay.testRunNumLabel",nodeposconnected)
    widget.setVisible("testRunOverlay.testRunNumValue",nodeposconnected)
    widget.setVisible("testRunOverlay.testRunNumSpinner",nodeposconnected)
  
  if self.saveFile.global[self.groupEditing].data.testRunCompleted then
    
    self.totalTestruns = self.saveFile.global[self.groupEditing].data.testrunsnum
    
    self.addTestRuns = true

    ---- = self.saveFile.global[self.groupEditing].data.testruns.timesMax
    ---- = self.saveFile.global[self.groupEditing].data.testruns.timesMin
    ---- = self.saveFile.global[self.groupEditing].data.testruns.timesAvg
    sb.logInfo("==========TEST RUN menu opened testrun completed = " ..tostring(self.saveFile.global[self.groupEditing].data.testRunCompleted))
    
    widget.setVisible("testRunOverlay.testRunDataScrollArea", true)
    widget.setVisible("testRunOverlay.seeStatisticsButton",true)
    --widget.setVisible("testRunOverlay.instructionsScrollArea",true)
	widget.setVisible("testRunOverlay.setTimetableButton", true)
    ----widget.setVisible("testRunOverlay.moreTestsButton",true)
    --widget.setVisible("testRunOverlay.testRunNumLabel",true)
    --widget.setVisible("testRunOverlay.testRunNumValue",true)
    --widget.setVisible("testRunOverlay.testRunNumSpinner",true)
    
    
    
    if not nodeposconnected then
      widget.setVisible("testRunOverlay.instructionsScrollArea",false)
      widget.setVisible("testRunOverlay.errorScrollArea",true)
    else
      widget.setVisible("testRunOverlay.instructionsScrollArea",true)
      widget.setVisible("testRunOverlay.errorScrollArea",false)
    end

	--local stationTimesRaw = self.saveFile.global[self.groupEditing].data.times
	--local timesArray = {}
	--timesArray[1] = 0
	--timesArray[2] = math.floor((stationTimesRaw[2] * 10) + 0.5)/10
	
    --self.defaultStopLen

    --for i=3,#self.saveFile.global[self.groupEditing].data.times do
	  --timesArray[i] = (math.floor((stationTimesRaw[i] * 10) + 0.5)/10) - self.defaultStopLen
    --end
	--tprint(timesArray)
	
	self.testRunDataListName = "testRunOverlay.testRunDataScrollArea.testRunDataList"
	
	----local listItem = string.format("%s.%s",self.widgetListName, widget.addListItem(self.widgetListName))
	----sb.logInfo("listItem " .. tostring(i) .. " " .. listItem .. " ==> " .. listItem .. ".member")
	----sb.logInfo("stationDisplayName " .. stationDisplayName)
	----widget.setText(listItem .. ".member", stationDisplayName)
	----widget.setData(listItem, stationsList[i])
    
    local timesArray = self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
	
	for i=2,#timesArray do
	  local listItem = string.format("%s.%s",self.testRunDataListName, widget.addListItem(self.testRunDataListName))
	  local stationDisplayName
	  if self.saveFile.global[self.groupEditing].data.circular and (i == #timesArray) then
	    stationDisplayName = tostring(i-1) .. " back to 1:"
      else
	    stationDisplayName = tostring(i-1) .. " to " .. tostring(i) .. ":"
	  end
	  sb.logInfo("listItem " .. tostring(i) .. " " .. listItem .. " ==> " .. listItem .. ".stationLabel")
	  sb.logInfo("stationDisplayName " .. stationDisplayName)
      widget.setText(listItem .. ".stationLabel", stationDisplayName)
	  
	  if self.saveFile.global[self.groupEditing].data.circular and (i == #timesArray) then
	    widget.setPosition(listItem .. ".stationLabel", {75, 10})
	  end
	  
	  sb.logInfo("listItem " .. tostring(i) .. " " .. listItem .. " ==> " .. listItem .. ".timeLabel")
	  widget.setText(listItem .. ".timeLabel", tostring(timesArray[i]) .. " s")
	  sb.logInfo("listItem " .. tostring(i) .. " " .. listItem .. " ==> " .. listItem .. ".stopLenghtLabel")
	  widget.setText(listItem .. ".stopLenghtLabel", tostring(self.defaultStopLen) .. " seconds stop")
	end
	
	--self.saveFile.global[self.groupEditing].data.timesTidy = {}
	--self.saveFile.global[self.groupEditing].data.timesTidy = timesArray
	
	if self.saveFile.global[self.groupEditing].data.toBeInit == nil then
	  self.saveFile.global[self.groupEditing].data.toBeInit = true
      sb.logInfo("=============self.saveFile.global[self.groupEditing].data.toBeInit" .. tostring(self.saveFile.global[self.groupEditing].data.toBeInit))
	end
	
    --calculatedist()
    
    
	
	
  else
    sb.logInfo("==========TEST RUN menu opened testrun completed = " ..tostring(self.saveFile.global[self.groupEditing].data.testRunCompleted))
    
    widget.setVisible("testRunOverlay.seeStatisticsButton",false)
    widget.setVisible("testRunOverlay.testRunDataScrollArea", false)
    --widget.setVisible("testRunOverlay.instructionsScrollArea",false)
	widget.setVisible("testRunOverlay.setTimetableButton", false)
    --widget.setVisible("testRunOverlay.moreTestsButton",false)

    if not nodeposconnected then
      widget.setVisible("testRunOverlay.instructionsScrollArea",false)
      widget.setVisible("testRunOverlay.errorScrollArea",true)
    else
      widget.setVisible("testRunOverlay.instructionsScrollArea",false)
      widget.setVisible("testRunOverlay.errorScrollArea",false)
    end
    
    self.saveFile.global[self.groupEditing].data.testrunsnum = 0
    self.saveFile.global[self.groupEditing].data.testRunsABS = {}
    
    self.addTestRuns = false
    
    world.setProperty("stationController_file", self.saveFile)
    
  end

end

function reorderGroupStationsButtonPressed(widgetName, widgetData)
  widget.setVisible("groupsOverlay", false)
  widget.setVisible("reorderGroupStationsOverlay", true)
  widget.setText("reorderGroupStationsOverlay.title", "Reorder stations for ^green;" .. self.groupEditing .. "^reset;")
  
  local groupMembers = {}
  local groupMembers = deepcopy(self.saveFile.global[self.groupEditing].data.uuids)
  local stationsList = {}
  
  local circular = self.saveFile.global[self.groupEditing].data.circular
  
  if circular then
    local arraylen = #groupMembers
    groupMembers[arraylen] = nil
  end
  
  local listName = "reorderGroupStationsOverlay.stationsScrollArea.stationsList"
  widget.clearListItems(listName)
  
  for s=1,#groupMembers do
    stationsList[s] = {}
    stationsList[s].number = s
    stationsList[s].uuid = groupMembers[s]
    stationsList[s].name = self.saveFile[stationsList[s].uuid].name    
    local listItem = string.format("%s.%s",listName, widget.addListItem(listName))
    widget.setText(listItem .. ".member", stationsList[s].name)
	widget.setData(listItem, stationsList[s])
  end
  
end

function reorderStationsListSelected(widgetName, widgetData)
  local listName = "reorderGroupStationsOverlay.stationsScrollArea.stationsList"
  local listItem = widget.getListSelected(listName)
  if listItem then
    sb.logInfo("listitem " .. tostring(listItem))
    local itemData = widget.getData(string.format("%s.%s", listName, listItem))
    widget.setVisible("reorderGroupStationsOverlay.reorderStationname", true)
    widget.setVisible("reorderGroupStationsOverlay.stationNumvalue", true)
    widget.setText("reorderGroupStationsOverlay.reorderStationname", itemData.name)
    widget.setText("reorderGroupStationsOverlay.stationNumvalue", itemData.number)

    local numStations = #self.saveFile.global[self.groupEditing].data.uuids
    local circular = self.saveFile.global[self.groupEditing].data.circular
    
    if circular then
      numStations = numStations - 1
    end

    if itemData.number == 1 then
      widget.setVisible("reorderGroupStationsOverlay.reorderstationadd", true)
      widget.setVisible("reorderGroupStationsOverlay.reorderstationsubstract", false)
    elseif itemData.number == numStations then
      widget.setVisible("reorderGroupStationsOverlay.reorderstationadd", false)
      widget.setVisible("reorderGroupStationsOverlay.reorderstationsubstract", true)
    else
      widget.setVisible("reorderGroupStationsOverlay.reorderstationadd", true)
      widget.setVisible("reorderGroupStationsOverlay.reorderstationsubstract", true)
    end
    self.reorderData = itemData
  end
end

function reorderstationaddButtonPressed(widgetName, widgetData)

  local number = self.reorderData.number
  local circular = self.saveFile.global[self.groupEditing].data.circular
  
  local uuids = reorderGroupArrays(self.saveFile.global[self.groupEditing].data.uuids, circular, number, "+")
  self.saveFile.global[self.groupEditing].data.uuids = deepcopy(uuids)
 
  if self.saveFile.global[self.groupEditing].data.nodesPos then
    local nodepos = reorderGroupArrays(self.saveFile.global[self.groupEditing].data.nodesPos, circular, number, "+")
    self.saveFile.global[self.groupEditing].data.nodesPos = nodepos
  end  
  --calculatedist()
  
  if circular then
    local arraylen = #uuids
    uuids[arraylen] = nil
  end
  
  for s=1,#uuids do
    self.saveFile[uuids[s]].numInGroup = s
  end
  
  world.setProperty("stationController_file", self.saveFile)
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  --widget.setVisible("groupsOverlay", true)
  groupStationsButtonPressed()
  widget.setVisible("reorderGroupStationsOverlay", false)
end

function reorderstationsubstractButtonPressed(widgetName, widgetData)

  local number = self.reorderData.number
  local circular = self.saveFile.global[self.groupEditing].data.circular
  
  local uuids = reorderGroupArrays(self.saveFile.global[self.groupEditing].data.uuids, circular, number, "-")
  self.saveFile.global[self.groupEditing].data.uuids = deepcopy(uuids)
 
  if self.saveFile.global[self.groupEditing].data.nodesPos then
    local nodepos = reorderGroupArrays(self.saveFile.global[self.groupEditing].data.nodesPos, circular, number, "-")
    self.saveFile.global[self.groupEditing].data.nodesPos = nodepos
  end
  --if self.saveFile.global[self.groupEditing].data.testRunsTimesAVG then
    --self.saveFile.global[self.groupEditing].data.testRunsTimesAVG = reorderGroupArrays(self.saveFile.global[self.groupEditing].data.testRunsTimesAVG, circular, number, "-")
  --end
  --if self.saveFile.global[self.groupEditing].data.testRunsTimesMIN then
   -- self.saveFile.global[self.groupEditing].data.testRunsTimesMIN = reorderGroupArrays(self.saveFile.global[self.groupEditing].data.testRunsTimesMIN, circular, number, "-")
  --end
  --if self.saveFile.global[self.groupEditing].data.testRunsTimesMAX then
    --self.saveFile.global[self.groupEditing].data.testRunsTimesMAX = reorderGroupArrays(self.saveFile.global[self.groupEditing].data.testRunsTimesMAX, circular, number, "-")
  --end
  --if self.saveFile.global[self.groupEditing].data.testRunsTimesMAXWest then
    --self.saveFile.global[self.groupEditing].data.testRunsTimesMAXWest = reorderGroupArrays(self.saveFile.global[self.groupEditing].data.testRunsTimesMAXWest, circular, number, "-")
  --end
  --if self.saveFile.global[self.groupEditing].data.distances then
    --self.saveFile.global[self.groupEditing].data.distances = reorderGroupArrays(self.saveFile.global[self.groupEditing].data.distances, circular, number, "-")
 -- end
  --if self.saveFile.global[self.groupEditing].data.testRunsTimes then
    --local arrayLen = #self.saveFile.global[self.groupEditing].data.testRunsTimes
    --for t=1,arrayLen do
      --self.saveFile.global[self.groupEditing].data.testRunsTimes[t] = reorderGroupArrays(self.saveFile.global[self.groupEditing].data.testRunsTimes[t], circular, number, "-")
    --end
  --end
  
  --calculatedist()
  
  if circular then
    local arraylen = #uuids
    uuids[arraylen] = nil
  end
  
  for s=1,#uuids do
    self.saveFile[uuids[s]].numInGroup = s
  end
  
  world.setProperty("stationController_file", self.saveFile)
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  --widget.setVisible("groupsOverlay", true)
  groupStationsButtonPressed()
  widget.setVisible("reorderGroupStationsOverlay", false)
  
end

function reorderGroupArrays(array, circular, number, method)

  local oldgroupMembers = deepcopy(array)
  local newgroupMembers = {}
  
  sb.logInfo("before:")
  tprint(oldgroupMembers)
  
  local arraylen
  if circular then
    arraylen = #oldgroupMembers
    oldgroupMembers[arraylen] = nil
  end

  if method == "-" then
    if number >= 3 then
      for s=1,(number - 2) do
        newgroupMembers[s] = oldgroupMembers[s]
      end
    end
    newgroupMembers[number - 1] = oldgroupMembers[number]
    newgroupMembers[number] = oldgroupMembers[number - 1]
    local numstations = #oldgroupMembers
    if numstations > number then
      for s=(number +1),numstations do
        newgroupMembers[s] = oldgroupMembers[s]
      end
    end
  else
    if number >= 2 then
      for s=1,(number - 1) do
        newgroupMembers[s] = oldgroupMembers[s]
      end
    end
    newgroupMembers[number] = oldgroupMembers[number + 1]
    newgroupMembers[number + 1] = oldgroupMembers[number]
    local numstations = #oldgroupMembers
    if numstations > number then
      for s=(number +2),numstations do
        newgroupMembers[s] = oldgroupMembers[s]
      end
    end
  end

  if circular then
    newgroupMembers[arraylen] = newgroupMembers[1]
  end
  
  sb.logInfo("after:")
  tprint(newgroupMembers)
  return newgroupMembers
  
end

function startTestRunButtonPressed(widgetName, widgetData)
  widget.setVisible("testRunOverlay.testRunInProgressLabel", true)
  world.sendEntityMessage(pane.sourceEntity(), "startTestRun", self.numOfTestRunTodo, self.totalTestruns, self.addTestRuns)
    
  --self.testRunInProgress = true
end

function testRunDataListSelected(widgetName, widgetData)
  
end

function backToMainFromStatisticsButtonPressed(widgetName, widgetData)
  widget.setVisible("testRunOverlay", true)
  widget.setVisible("statisticsOverlay", false)
end

function backToMainFromReorderStationButtonPressed(widgetName, widgetData)
  widget.setVisible("reorderGroupStationsOverlay", false)
  widget.setVisible("reorderGroupStationsOverlay.reorderStationname", false)
  widget.setVisible("reorderGroupStationsOverlay.reorderstationsubstract", false)
  widget.setVisible("reorderGroupStationsOverlay.stationNumvalue", false)
  widget.setVisible("reorderGroupStationsOverlay.reorderstationadd", false)
  widget.setVisible("groupsOverlay", true)
end

function clearTestRunDataButtonPressed(widgetName, widgetData)
  
  self.saveFile.global[self.groupEditing].data.testRunsTimes = nil
  self.saveFile.global[self.groupEditing].data.testRunsTimesAVG = nil
  self.saveFile.global[self.groupEditing].data.testRunsTimesMIN = nil
  self.saveFile.global[self.groupEditing].data.testRunsTimesMAX = nil
  self.saveFile.global[self.groupEditing].data.testRunsTimesMAXWest = nil
  
  --self.saveFile.global[self.groupEditing].data.uuids = nil
  --self.saveFile.global[self.groupEditing].data.nodesPos = nil
  self.saveFile.global[self.groupEditing].data.testRunCompleted = false
  self.saveFile.global[self.groupEditing].data.toBeInit = nil
  world.setProperty("stationController_file", self.saveFile)
  
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
end

function seeStatisticsButtonPressed(widgetName, widgetData)
  widget.setVisible("testRunOverlay", false)
  widget.setVisible("statisticsOverlay", true)
  widget.setVisible("statisticsOverlay.StatisticsScrollArea", true)
  
  self.statisticsdataset = 1
  buildStatistics(self.statisticsdataset)
  
  local minListName = "statisticsOverlay.StatisticsMINScrollArea.statisticsMINDataList"
  local avgListName = "statisticsOverlay.StatisticsAVGScrollArea.statisticsAVGDataList"
  local maxListName = "statisticsOverlay.StatisticsMAXScrollArea.statisticsMAXDataList"
  
  local minArray = self.saveFile.global[self.groupEditing].data.testRunsTimesMIN
  local avgArray = self.saveFile.global[self.groupEditing].data.testRunsTimesAVG
  local maxArray = self.saveFile.global[self.groupEditing].data.testRunsTimesMAX
  
  widget.clearListItems(minListName)
  widget.clearListItems(avgListName)
  widget.clearListItems(maxListName)
  
  for i=2,#minArray do --they all have same lenght
    
	local stationDisplayName
	if self.saveFile.global[self.groupEditing].data.circular and (i == #minArray) then
	  stationDisplayName = tostring(i-1) .. " back to 1:"
    else
	  stationDisplayName = tostring(i-1) .. " to " .. tostring(i) .. ":"
	end
	
    local minlistItem = string.format("%s.%s",minListName, widget.addListItem(minListName))
    local avglistItem = string.format("%s.%s",avgListName, widget.addListItem(avgListName))
    local maxlistItem = string.format("%s.%s",maxListName, widget.addListItem(maxListName))
    widget.setText(minlistItem .. ".stationLabel", stationDisplayName)
    widget.setText(avglistItem .. ".stationLabel", stationDisplayName)
    widget.setText(maxlistItem .. ".stationLabel", stationDisplayName)
	if self.saveFile.global[self.groupEditing].data.circular and (i == #minArray) then
	  widget.setPosition(minlistItem .. ".stationLabel", {75, 10})
      widget.setPosition(avglistItem .. ".stationLabel", {75, 10})
      widget.setPosition(maxlistItem .. ".stationLabel", {75, 10})
	end
	widget.setText(minlistItem .. ".timeLabel", tostring(minArray[i]) .. " s")
    widget.setText(avglistItem .. ".timeLabel", tostring(avgArray[i]) .. " s")
    widget.setText(maxlistItem .. ".timeLabel", tostring(maxArray[i]) .. " s")
  end
  
end

function buildStatistics(number)

  widget.setText("statisticsOverlay.datasetValue", number)
  
  local statisticsListName = "statisticsOverlay.StatisticsScrollArea.statisticsDataList"
  widget.clearListItems(statisticsListName)
  local timesArray = self.saveFile.global[self.groupEditing].data.testRunsTimes[number]
  for i=2,#timesArray do
    local listItem = string.format("%s.%s",statisticsListName, widget.addListItem(statisticsListName))
	local stationDisplayName
	if self.saveFile.global[self.groupEditing].data.circular and (i == #timesArray) then
	  stationDisplayName = tostring(i-1) .. " back to 1:"
    else
	  stationDisplayName = tostring(i-1) .. " to " .. tostring(i) .. ":"
	end
	--sb.logInfo("stationDisplayName " .. stationDisplayName)
    widget.setText(listItem .. ".stationLabel", stationDisplayName)
	
	if self.saveFile.global[self.groupEditing].data.circular and (i == #timesArray) then
	  widget.setPosition(listItem .. ".stationLabel", {75, 10})
	end
	widget.setText(listItem .. ".timeLabel", tostring(timesArray[i]) .. " s")
  end
  
end

function groupNameError(kind)
  
end

function stationNameError(kind)
  
end

function backToMainFromTestRunButtonPressed(widgetName, widgetData)
  widget.setVisible("testRunOverlay", false)
  widget.setVisible("groupsOverlay", true)
end

function backToMainFromTimeTableButtonPressed(widgetName, widgetData)
  widget.setVisible("timetableOverlay", false)
  widget.setVisible("groupsOverlay", true)
end


function groupNameEntered(widgetName, widgetData)
  
end

function manageAnotherStationPressed(widgetName, widgetData)
  
end

function addToExistingGroupButtonPressed(widgetName, widgetData)
  
end

function removeStationFromGroupButtonPressed(widgetName, widgetData)
  
end

function renameGroupButtonPressed(widgetName, widgetData)
    
end

function renameStationButtonPressed(widgetName, widgetData)
  widget.setVisible("renameStationOverlay", true)
  widget.setVisible("mainOverlay", false)
  local formername = self.saveFile[self.uuid].name
  widget.setText("renameStationOverlay.stationNameLabel", "Current station name: ^green;" .. formername .. "^reset;")
end

function changeStationNameButtonPressed(widgetName, widgetData)
  local stationName = widget.getText("renameStationOverlay.stationNameTextBox")
  if (stationName == "") or (stationName == nil) then
    stationNameError("empty")
	return
  end

  local statuionUUIDS = self.saveFile.global.stationsList
  tprint(statuionUUIDS)
  
  for i=1,#statuionUUIDS do
    local namechk = self.saveFile[statuionUUIDS[i]].name
    sb.logInfo(namechk)
    if stationName == namechk then
      stationNameError("taken")
	  return
    end
  end
  widget.setVisible("renameStationOverlay",false)
  widget.setVisible("mainOverlay", true)
  widget.setText("mainOverlay.displayNameValue", "^green;" .. stationName .. "^reset;")
  self.saveFile[self.uuid].name = stationName
  world.setProperty("stationController_file", self.saveFile)
  
end

function discardStationNameButton(widgetName, widgetData)
  widget.setVisible("renameStationOverlay",false)
  widget.setVisible("mainOverlay", true)
end

function manageOtherGroupsButtonPressed(widgetName, widgetData)
  
end

function ExitGroupButtonPressed(widgetName, widgetData)
  
end

function uninit()
    --When the panel closes we want to give the player back any items they left in the slot(s)
    --For each slot we have configured
	--Thanks to Whit3_rabbit at ChuckeFish Forum for the itemgrid handle routines!
    --https://community.playstarbound.com/threads/how-to-stack-items-in-an-itemslot.156207/
    for _,widget_name in pairs(local_storage.slotsToRefund or {}) do
        --Get the slotted item
        local slottedItem = widget.itemSlotItem(widget_name)
        --If it wasn't empty
        if slottedItem then
            --Give the player the item
            player.giveItem(slottedItem)			
        end
    end
end

--Callback for left click on a slot
--Thanks to Whit3_rabbit at ChuckeFish Forum for the itemgrid handle routines!
--https://community.playstarbound.com/threads/how-to-stack-items-in-an-itemslot.156207/
function slotleftclick(slot_widget)
    
	if slot_widget == "itemslot1" then
      slot_widget = "groupsOverlay" .. "." .. slot_widget
	elseif slot_widget == "itemslot2" then
	  slot_widget = "timetableOverlay.trainSettingsEastOverlay" .. "." .. slot_widget
	elseif slot_widget == "itemslot3" then
	  slot_widget = "timetableOverlay.trainSettingsWestOverlay" .. "." .. slot_widget
    end
	
	sb.logInfo("slot_widget " .. tostring(slot_widget))

    --Get (a copy of) the item descriptor the player was holding
    local heldItem = player.swapSlotItem()
    --Get (a copy of) the current slotted item
    local slottedItem = widget.itemSlotItem(slot_widget)
  
    --If the current slotted item is blank we just drop in the held item
    if not slottedItem then
  
        --If we aren't dropping anything in then we just end now
        if not heldItem then
            return
        end
		
        --Update the slotted item
        widget.setItemSlotItem(slot_widget,heldItem)
        --Empty what the player was holding
        player.setSwapSlotItem(nil)
        		
		--we are done and can stop here
        return
    end

    --If we reach here then we have an item already in the slot
  
    --If the heldItem is empty then we want to pick up what was in the slot
    if not heldItem then
        --Update the held item
        player.setSwapSlotItem(slottedItem)
        --Empty the slot
        widget.setItemSlotItem(slot_widget,nil)
        --we are done and can stop here
        return
    end
  
    --If we reach here then we are dropping an item onto the slotted item
  
    --Does the item being dropped match the slotted item?
    local itemsMatch = root.itemDescriptorsMatch(heldItem,slottedItem,true) --third arg is true to prevent stacking two weapons with the same name but different secondary attacks
  
    --If they don't match then we just swap them around
    if not itemsMatch then
        --Give the player the slotted item
        player.setSwapSlotItem(slottedItem)
        --Give the slot the players item
        widget.setItemSlotItem(slot_widget,heldItem)
        --Done
        return
    end
  
    --If we reach here the items do match, we need to check the max stack size and handle what happens if we try to go over the max stack
  
    --Get max stack size either from the item or the default max stack
    local itemConfig = root.itemConfig(slottedItem).config
    local rootConfig = root.assetJson("/items/defaultParameters.config")
    local maxStack = itemConfig.maxStack and itemConfig.maxStack or rootConfig.defaultMaxStack
  
    --Combine the quantities
    local slotQty = slottedItem.count
    local heldQty = heldItem.count
    local combinedQty = slotQty+heldQty
  
    --If we are below max stack size we are good to go
    if combinedQty <= maxStack then
        --Adjust quantity of slotted item
        slottedItem.count = combinedQty
        widget.setItemSlotItem(slot_widget,slottedItem)
		
        --Clear held item
        player.setSwapSlotItem(nil)
        --Done
        return
    end
  
    --If we reach here we would go over the max stack size
  
    --Adjust quantity of slotted item to max size
    slottedItem.count = maxStack
    widget.setItemSlotItem(slot_widget,slottedItem)
    --Find how many didn't fit in the stack, these will remain in hand
    local remaining = combinedQty-maxStack
    --Adjust quantity of held item
    heldItem.count = remaining
    player.setSwapSlotItem(heldItem)
  
end

--Callback for right click on a slot
--Thanks to Whit3_rabbit at ChuckeFish Forum for the itemgrid handle routines!
--https://community.playstarbound.com/threads/how-to-stack-items-in-an-itemslot.156207/
function slotrightclick(slot_widget)

    slot_widget = "groupsOverlay" .. "." .. slot_widget
  
    --Get (a copy of) the item descriptor the player was holding
    local heldItem = player.swapSlotItem()
    --Get (a copy of) the current slotted item
    local slottedItem = widget.itemSlotItem(slot_widget)
  
    --If the current slotted item is blank we drop in one of the held item
    if not slottedItem then
  
        --If we aren't dropping anything in then we just end now
        if not heldItem then
            return
        end
      
        local heldQty = heldItem.count
      
        --If we are only holding one item then drop it in and empty our hand
        if heldQty==1 then
            --Put the item in the slot
            widget.setItemSlotItem(slot_widget,heldItem)
            --Empty the players hand
            player.setSwapSlotItem(nil)
            --Done
            return
        end
  
        --If we reach here we are holding more than 1, we need to drop 1 and decrease held by 1
      
        --Adjust quantity of item and put in slot
        heldItem.count = 1
        widget.setItemSlotItem(slot_widget,heldItem)
        --Adjust quantity of item and update held
        heldItem.count = heldQty-1
        player.setSwapSlotItem(heldItem)
        --we are done and can stop here
        return
      
    end
  
    --If we reach here there is currently a slotted item
  
    local slotQty = slottedItem.count
  
    --If we are aren't holding anything we want to pick up 1 quantity
    if not heldItem then
      
        --If there is only 1 in the slot we just pick it up
        if slotQty==1 then
            --Give player the item
            player.setSwapSlotItem(slottedItem)
            --Empty the slot
            widget.setItemSlotItem(slot_widget,nil)
            --Done
            return
        end
      
        --If we reach here there is more than 1 slotted, we want to pick up only 1
      
        --Adjust quantity of item and put in hand
        slottedItem.count =1
        player.setSwapSlotItem(slottedItem)
        --Adjust quantity of item and update slot
        slottedItem.count = slotQty-1
        widget.setItemSlotItem(slot_widget,slottedItem)
        --we are done and can stop here
        return
      
    end
  
    --If we reach here we right clicked a slotted item while carrying an item
    --Are we trying to pick 1 up, or put 1 down?
    --I am going to assume if the items are different, we want to swap them
    --If the items are the same, we are trying to pick 1 up
  
    local heldQty = heldItem.count
  
    --Do the items match
    local itemsMatch = root.itemDescriptorsMatch(heldItem,slottedItem,true) --third arg is true to prevent stacking two weapons with the same name but different secondary attacks
  
    --If they don't match then we just swap them around
    if not itemsMatch then
        --Give the player the slotted item
        player.setSwapSlotItem(slottedItem)
        --Give the slot the players item
        widget.setItemSlotItem(slot_widget,heldItem)
        --Done
        return
    end
  
    --If we reach here the items do match, we need to check the max stack size and handle what happens if we try to go over the max stack
  
    --Calculate new quantities
    local newHeldQty = heldQty+1
    local newSlotQty = slotQty-1
  
    --Get max stack size either from the item or the default max stack
    local itemConfig = root.itemConfig(slottedItem).config
    local rootConfig = root.assetJson("/items/defaultParameters.config")
    local maxStack = itemConfig.maxStack and itemConfig.maxStack or rootConfig.defaultMaxStack
  
    --If we are below max stack size we are good to go
    if newHeldQty <= maxStack then
        --Adjust quantity of held item
        heldItem.count = newHeldQty
        player.setSwapSlotItem(heldItem)
        --If slot qty dropped to zero then empty slot
        if newSlotQty==0 then
            widget.setItemSlotItem(slot_widget,nil)
        else
            --Still have some quantity, update item in slot
            slottedItem.count = newSlotQty
            widget.setItemSlotItem(slot_widget,slottedItem)
        end
        --Done
        return
    end
  
    --If we reach here we would go over the max stack size
    --Since we are only trying to pick 1 up, there is nothing more we can do
    return
  
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