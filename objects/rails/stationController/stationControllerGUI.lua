local_storage = {}
stopLenSpinner = {}

--callback function when right button is pressed
function stopLenSpinner.up()
  
end

--callback function when left button is pressed
function stopLenSpinner.down()
  
end

function init()

  --When the panel inits we read in the list of slots that need to be emptied on close
  local_storage.slotsToRefund = config.getParameter("refundOnClose",{})

  self.saveFile = world.getProperty("stationController_file")
  self.uuid = config.getParameter("uuid")
  self.slottedItem = config.getParameter("slottedItem")
  
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
  if self.slottedItem then
    sb.logInfo("SLOTTED ITEM ")
    tprint(self.slottedItem)
  else
    sb.logInfo("SLOTTED ITEM " .. tostring(self.slottedItem))
  end
  tprint(self.saveFile)
  
end

function update(dt)

  if self.testRunInProgress then
    --account for left or right start facing direction
  end

  if not self.slottedItem then
    local slottedItem = widget.itemSlotItem("groupsOverlay.itemslot1")
    if slottedItem then
      local itemConfig = root.itemConfig(slottedItem)
	  if (itemConfig.config.category == "railPlatform") and (itemConfig.config.linkedRailTrain == true) then
	    widget.setVisible("groupsOverlay.linkButton", true)
	    widget.setVisible("groupsOverlay.Edit1Label", true)
	    widget.setVisible("groupsOverlay.Edit2Label", true)
		widget.setVisible("groupsOverlay.TestRunButton", false)
	  else
	    widget.setVisible("groupsOverlay.linkButton", false)
	    widget.setVisible("groupsOverlay.ErrorLabel1", true)
	    widget.setVisible("groupsOverlay.Edit1Label", false)
	    widget.setVisible("groupsOverlay.Edit2Label", false)
		widget.setVisible("groupsOverlay.TestRunButton", false)
	  end
    else
	  widget.setVisible("groupsOverlay.linkButton", false)
	  widget.setVisible("groupsOverlay.ErrorLabel1", false)
	  widget.setVisible("groupsOverlay.Edit1Label", true)
	  widget.setVisible("groupsOverlay.Edit2Label", true)
	  widget.setVisible("groupsOverlay.TestRunButton", false)
   end
 else
   widget.setVisible("groupsOverlay.unlinkButton", true)
   widget.setVisible("groupsOverlay.linkButton", false)
   widget.setVisible("groupsOverlay.Edit1Label", false)
   widget.setVisible("groupsOverlay.Edit2Label", false)
   widget.setVisible("groupsOverlay.itemslot1", false)
   widget.setVisible("groupsOverlay.TestRunButton", true)
 end
 
 --if self.saveFile[self.uuid].grouped then
   --widget.setVisible("groupsOverlay.circularCheckBox", true)
   --widget.setVisible("groupsOverlay.circularLabel", true)
  -- widget.setChecked("groupsOverlay.circularCheckBox", self.saveFile.global[self.saveFile[self.uuid].group].data.circular)
 --else
   --widget.setVisible("groupsOverlay.circularCheckBox", false)
   --widget.setVisible("groupsOverlay.circularLabel", false)
 --end
  
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
	
	if self.saveFile.global.numOfGroups > 0 then
	  widget.setVisible("groupsOverlay.addToExistingGroupButton", true)
	else
	  widget.setVisible("groupsOverlay.addToExistingGroupButton", false)
	end
  else
    local groupName = self.saveFile[self.uuid].group
	local numInGroup = self.saveFile[groupName][self.uuid].number
	
	if self.slottedItem then
	  widget.setVisible("groupsOverlay.unlinkButton", true)
	  widget.setVisible("groupsOverlay.linkButton", false)
	  widget.setVisible("groupsOverlay.Edit1Label", false)
	  widget.setVisible("groupsOverlay.Edit2Label", false)
	  widget.setVisible("groupsOverlay.itemslot1", false)
	  widget.setVisible("groupsOverlay.TestRunButton", true)
	else
	  widget.setVisible("groupsOverlay.itemslot1", true)
      widget.setVisible("groupsOverlay.Edit1Label", true)
      widget.setVisible("groupsOverlay.Edit2Label", true)
	  widget.setVisible("groupsOverlay.TestRunButton", false)
	end
	
	if self.saveFile.global[groupName].data.testRunCompleted then
	  widget.setVisible("groupsOverlay.setTimetableButton", true)
	end
	
	self.groupEditing = groupName
	
	widget.setVisible("groupsOverlay.changeNumInGroupButton", true)
	
	widget.setVisible("groupsOverlay.membersInGroupLabel", true)
	widget.setVisible("groupsOverlay.membersInGroupValue", true)
	widget.setText("groupsOverlay.membersInGroupLabel", "Members of group " .. "^green;" .. groupName .. "^reset; (in order):")
	
	widget.setVisible("groupsOverlay.circularCheckBox", true)
	widget.setChecked("groupsOverlay.circularCheckBox", self.saveFile.global[self.groupEditing].data.circular)
	widget.setVisible("groupsOverlay.circularLabel", true)
	
	local members = {}
	local membersString = ""
	
	--sb.logInfo("self.saveFile[groupName] table iteration")
	--sb.logInfo("table ")
	--tprint(self.saveFile[groupName])
	
	for k,v in pairs(self.saveFile[groupName]) do
	   --sb.logInfo("k " .. tostring(k) .. " v " .. tostring(v))
	  local number = self.saveFile[groupName][k].number
	  --sb.logInfo("number " .. tostring(number))
      members[number] = self.saveFile[k].name
	  --sb.logInfo("members[number] " .. tostring(members[number]))
	end
	
	for i=1,#members do
     if i == 1 then
        membersString = members[i]
      else
        membersString = membersString .. " " .. members[i]
      end
	end
	
	if not self.saveFile.global[groupName].data.numOfStationsInGroup then
	  self.saveFile.global[groupName].data.numOfStationsInGroup = #members
	  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
	end
	
	widget.setText("groupsOverlay.membersInGroupValue", "^green;" .. membersString.. "^reset;")
	
	if self.saveFile.global.numOfGroups > 1 then
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
    widget.setVisible("groupsOverlay.addStationToGroupButton", true)
    widget.setVisible("groupsOverlay.removeStationfromGroupButton", true)
	widget.setVisible("groupsOverlay.renameGroupButton", true)
	widget.setVisible("groupsOverlay.manageOtherGroupsButton", true)
  end
end

function debug1ButtonPressed()
  self.saveFile.global[self.groupEditing].data.toBeInit = true
  self.saveFile.global[self.groupEditing].data.trainsEast = nil
  self.saveFile.global[self.groupEditing].data.trainsWest = nil
  self.saveFile.global[self.groupEditing].data.timesTidy = nil
  self.saveFile.global[self.groupEditing].data.numberOfTrainsE = nil
  self.saveFile.global[self.groupEditing].data.numberOfTrainsW = nil
  self.saveFile.global[self.groupEditing].data.timesABS[6] = self.saveFile.global[self.groupEditing].data.timesABS[5] + 10.887
  self.saveFile.global[self.groupEditing].data.times[6] = 10.887
  self.saveFile.global[self.groupEditing].data.testRunCompleted = true
  world.setProperty("stationController_file", self.saveFile)
end

function loadBackupFileButtonPressed()
  self.saveFile = world.getProperty("stationController_file_backup")
  world.setProperty("stationController_file", self.saveFile)
end
function saveBackupFileButtonPressed()
  world.setProperty("stationController_file_backup", self.saveFile)
end


function setTimetableButtonPressed(widgetName, widgetData)
  --world.setProperty("stationController_file_backup", self.saveFile)
  
  widget.setVisible("testRunOverlay", false)
  widget.setVisible("groupsOverlay", false)
  widget.setVisible("timetableOverlay", true)
  
  if self.saveFile.global[self.groupEditing].data.toBeInit then
    self.saveFile.global[self.groupEditing].data.trainsEast = {}
    self.saveFile.global[self.groupEditing].data.trainsWest = {}
	
	self.saveFile.global[self.groupEditing].data.trainsEast[1] = {}
	self.saveFile.global[self.groupEditing].data.trainsWest[1] = {}
	self.saveFile.global[self.groupEditing].data.numberOfTrainsE = 1
	self.saveFile.global[self.groupEditing].data.numberOfTrainsW = 1
	
	self.saveFile.global[self.groupEditing].data.trainsEast.vehicles = {}
	self.saveFile.global[self.groupEditing].data.trainsWest.vehicles = {}
	
	self.saveFile.global[self.groupEditing].data.trainsEast.startStations = {}
	self.saveFile.global[self.groupEditing].data.trainsEast.startTimes = {}
	self.saveFile.global[self.groupEditing].data.trainsEast.startStations[1] = 1
	self.saveFile.global[self.groupEditing].data.trainsEast.startTimes[1] = 0
	
	self.saveFile.global[self.groupEditing].data.trainsWest.startStations = {}
	self.saveFile.global[self.groupEditing].data.trainsWest.startTimes = {}
	self.saveFile.global[self.groupEditing].data.trainsWest.startStations[1] = 1
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
	self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[1][1] = 0
	self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[1][1] = 0
	
	for i=2,#self.saveFile.global[self.groupEditing].data.timesTidy do
	  self.saveFile.global[self.groupEditing].data.trainsEast.speeds[1][i] = 100
	  self.saveFile.global[self.groupEditing].data.trainsWest.speeds[1][i] = 100
	  self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[1][i] = self.defaultStopLen
	  self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[1][i] = self.defaultStopLen
	end
	
	self.saveFile.global[self.groupEditing].data.toBeInit = false
	self.saveFile.global[self.groupEditing].data.readyToStart = false
	
	world.setProperty("stationController_file", self.saveFile)
  end
  
  local timesArray = self.saveFile.global[self.groupEditing].data.timesTidy
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

function makeTrainList(direction)
  if direction == "E" then
    local numOfTrainsE = self.saveFile.global[self.groupEditing].data.numberOfTrainsE
    for i=1,numOfTrainsE do
      local listItem = string.format("%s.%s",self.trainsEastListName, widget.addListItem(self.trainsEastListName))
	  widget.setText(listItem .. ".trainLabel", "Train " .. tostring(i) .. "-E")
	  --data format for widget array : {trainNum,direction}
	  widget.setData(listItem, {i,"E"})
    end
  else
    local numOfTrainsW = self.saveFile.global[self.groupEditing].data.numberOfTrainsW
	for i=1,numOfTrainsW do
      local listItem = string.format("%s.%s",self.trainsWestListName, widget.addListItem(self.trainsWestListName))
	  widget.setText(listItem .. ".trainLabel", "Train " .. tostring(i) .. "-W")
	  --data format for widget array : {trainNum,direction}
	  widget.setData(listItem, {i,"W"})
    end
  end
end

function trainsListSelected(widgetName, widgetData)
  local parentElement
  
  sb.logInfo("widgetName " .. widgetName)
  
  if widgetName == "trainsWestList" then
    parentElement = "timetableOverlay.trainsWestScrollArea"
  else
    parentElement = "timetableOverlay.trainsEastScrollArea"
  end
  
  local listName = parentElement .. "." .. widgetName
  sb.logInfo("listName " .. listName)
  
  local listItem = widget.getListSelected(listName)
  local itemData
  if listItem then
    sb.logInfo("listitem " .. tostring(listItem))
    itemData = widget.getData(string.format("%s.%s", listName, listItem))
	sb.logInfo("widget.getData " .. tostring(itemData))
	tprint(itemData)
	
	self.editingTrain = itemData
	--data format for widget array : {trainNum,direction}
	
	local trainNum = itemData[1]
	local direction = itemData[2]
	local speedsArray
	local stopsLenArray
    if widgetName == "trainsWestList" then
	  speedsArray = self.saveFile.global[self.groupEditing].data.trainsWest.speeds[trainNum]
	  stopsLenArray = self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[trainNum]
	  widget.setVisible("timetableOverlay.trainsEastDataScrollArea", false)
	  widget.setVisible("timetableOverlay.trainsWestDataScrollArea", true)
	  widget.setVisible("timetableOverlay.trainSettingsWestOverlay", false)
	  widget.setVisible("timetableOverlay.trainSettingsEastOverlay", false)
	  --widget.setVisible("timetableOverlay.trainSettingsWestOverlay.selectedTrainLabel", true)
	  widget.setText("timetableOverlay.trainSettingsWestOverlay.selectedTrainLabel","^red;Train " .. itemData[1] .. "-" .. itemData[2] .. ":^reset;")
	  widget.setText("timetableOverlay.trainSettingsWestOverlay.startStationLabel", "Start station: " .. self.saveFile.global[self.groupEditing].data.trainsWest.startStations[trainNum])
	  widget.setText("timetableOverlay.trainSettingsWestOverlay.startTimeLabel", "Start time: " .. self.saveFile.global[self.groupEditing].data.trainsWest.startTimes[trainNum])
	  widget.clearListItems(self.trainsDataListNameW)
	  widget.clearListItems(self.trainsEastListName)
	  makeTrainList("E")
	else
	  speedsArray = self.saveFile.global[self.groupEditing].data.trainsEast.speeds[trainNum]
	  stopsLenArray = self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[trainNum]
	  widget.setVisible("timetableOverlay.trainsWestDataScrollArea", false)
	  widget.setVisible("timetableOverlay.trainsEastDataScrollArea", true)

      widget.setVisible("timetableOverlay.trainSettingsWestOverlay", false)
	  widget.setVisible("timetableOverlay.trainSettingsEastOverlay", false)
	  --widget.setVisible("timetableOverlay.trainSettingsEastOverlay.selectedTrainLabel", true)
	  widget.setText("timetableOverlay.trainSettingsEastOverlay.selectedTrainLabel", "^red;Train " .. itemData[1] .. "-" .. itemData[2] .. ":^reset;")
	  widget.setText("timetableOverlay.trainSettingsEastOverlay.startStationLabel", "Start station: " ..  tostring(self.saveFile.global[self.groupEditing].data.trainsEast.startStations[trainNum]))
	  widget.setText("timetableOverlay.trainSettingsEastOverlay.startTimeLabel", "Start time: " .. tostring(self.saveFile.global[self.groupEditing].data.trainsEast.startTimes[trainNum]))
	  
	  widget.clearListItems(self.trainsDataListNameE)
	  widget.clearListItems(self.trainsWestListName)
      makeTrainList("W")
	end
	displayTrainData(trainNum,direction,speedsArray,stopsLenArray)
  end
  
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
	local numOfStations = #self.saveFile.global[self.groupEditing].data.timesTidy
	local circular = self.saveFile.global[self.groupEditing].data.circular
	self.timetableEditing = {trainNum,direction,station,numOfStations,circular,speed,stopLen,speed,stopLen}
	
	speed = self.saveFile.global[self.groupEditing].data.trainsEast.speeds[trainNum][station]
	stopLen = self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[trainNum][station]
	widget.setSliderValue("timetableOverlay." .. overlayName ..".speedSlider",100)
	widget.setVisible("timetableOverlay." .. overlayName ..".stationLabel",true)
	widget.setVisible("timetableOverlay." .. overlayName ..".speedLabel",true)
	widget.setVisible("timetableOverlay." .. overlayName ..".speedSlider",true)
	widget.setVisible("timetableOverlay." .. overlayName ..".stopLenLabel",true)
	widget.setVisible("timetableOverlay." .. overlayName ..".stopLenValue",true)
	widget.setVisible("timetableOverlay." .. overlayName ..".stopLenSpinner",true)
	widget.setVisible("timetableOverlay." .. overlayName ..".saveButton",true)
	if circular and (station == numOfStations) then
	  widget.setText("timetableOverlay." .. overlayName ..".stationLabel", "^green;Station " .. tostring(station-1) .. " back to 1:^reset;")
	else
	  widget.setText("timetableOverlay." .. overlayName ..".stationLabel", "^green;Station " .. tostring(station-1) .. " to " .. tostring(station) ..":^reset;")
	end
	widget.setText("timetableOverlay." .. overlayName ..".speedLabel", "Speed: " .. tostring(speed) .. "%")
	widget.setText("timetableOverlay." .. overlayName ..".stopLenValue", tostring(stopLen))
    	
	
  end
end

function speedSlider(widgetName, widgetData)

  local direction = self.timetableEditing[2]
  local station = self.timetableEditing[3]
  local timesArray = self.saveFile.global[self.groupEditing].data.timesTidy
  if direction == "E" then
    overlayName = "trainSettingsEastOverlay"
  else
    overlayName = "trainSettingsWestOverlay"
  end
  
  local newSpeed = widget.getSliderValue("timetableOverlay." .. overlayName ..".speedSlider")
  self.timetableEditing[8] = newSpeed
  widget.setText("timetableOverlay." .. overlayName ..".speedLabel", "Speed: " .. tostring(newSpeed) .. "%")

  local listName 
  
  if direction == "E" then
    listName = self.trainsDataListNameE
  else
    listName = self.trainsDataListNameW
  end
  
  --math.floor((newSpeed * 10) + 0.5)/10
  
  local newTime = timesArray[station] * (100/newSpeed)
  newTime = math.floor((newTime * 10) + 0.5)/10
  
  local listItem = widget.getListSelected(listName)
  sb.logInfo("speedSlider list item name = " .. tostring(listName))
  if listItem then
    widget.setText(listName .. "." .. listItem .. ".timeLabel", tostring(newTime) .. " s")
	widget.setText(listName .. "." .. listItem .. ".speedsLabel", "Speed: " .. tostring(newSpeed) .. "%")
	--sb.logInfo("newTime float = " .. tostring(newTime))
	--sb.logInfo("newTime round1=" .. tostring(math.floor((newTime * 10) + 0.5)/10))
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
  
  if direction == "E" then
    if not (newSpeed == oldSpeed) then
	  self.saveFile.global[self.groupEditing].data.trainsEast.speeds[trainNum][station] = newSpeed
	end
	if not (newStopLen == oldStopLen) then
	  self.saveFile.global[self.groupEditing].data.trainsEast.stopsLen[trainNum][station] = newStopLen
	end
  else
    if not (newSpeed == oldSpeed) then
      self.saveFile.global[self.groupEditing].data.trainsWest.speeds[trainNum][station] = newSpeed
	end
	if not (newStopLen == oldStopLen) then
	  self.saveFile.global[self.groupEditing].data.trainsWest.stopsLen[trainNum][station] = newStopLen
	end
  end
  
  world.setProperty("stationController_file", self.saveFile)
  
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
  
  local timesArray = self.saveFile.global[self.groupEditing].data.timesTidy
  
  widget.setVisible("timetableOverlay.selectedTrainDataLabel", true)
  widget.setText("timetableOverlay.selectedTrainDataLabel","Train " .. trainNum .. "-" .. direction .. " settings:" )
  
  --if direction == "E" then
    --widget.setVisible("timetableOverlay.trainsEastDataScrollArea", true)
	--widget.setVisible("timetableOverlay.trainsWestDataScrollArea", false)

  --elseif direction == "W" then
    --widget.setVisible("timetableOverlay.trainsWestDataScrollArea", true)
    --widget.setVisible("timetableOverlay.trainsEastDataScrollArea", false)
  --end
  
  --widget.clearListItems(self.trainsDataListNameE)
  --widget.clearListItems(self.trainsDataListNameW)
  
  for i=2,#timesArray do
    local listItem
	if direction == "E" then
	  listItem = string.format("%s.%s",self.trainsDataListNameE, widget.addListItem(self.trainsDataListNameE))
	elseif direction == "W" then
	  listItem = string.format("%s.%s",self.trainsDataListNameW, widget.addListItem(self.trainsDataListNameW))
	end
	local stationDisplayName
	if self.saveFile.global[self.groupEditing].data.circular and (i == #timesArray) then
	  stationDisplayName = tostring(i-1) .. " back to 1:"
    else
	  stationDisplayName = tostring(i-1) .. " to " .. tostring(i) .. ":"
	end
	widget.setText(listItem .. ".stationLabel", stationDisplayName)
	if self.saveFile.global[self.groupEditing].data.circular and (i == #timesArray) then
	  widget.setPosition(listItem .. ".stationLabel", {65, 20})
    end
	widget.setText(listItem .. ".timeLabel", tostring(timesArray[i] * (100/speedsArray[i]) ) .. " s")
	widget.setText(listItem .. ".speedsLabel", "Speed:" .. tostring(speedsArray[i]) .. "%")
	widget.setText(listItem .. ".stopLenghtLabel", tostring(stopsLenArray[i]) .. " seconds stop")
	--data format for widget array: {trainNum,direction,station}
	widget.setData(listItem, {trainNum,direction,i})
  end
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
  
  world.setProperty("stationController_file", self.saveFile)
  
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  
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
  widget.setVisible("groupsOverlay.manageOtherGroupsButton", true)
  
  local numInGroup = self.saveFile[groupName][self.uuid].number
	
	
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
  
  tprint(self.saveFile)
  
  world.setProperty("stationController_file", self.saveFile)
  self.saveFile = world.getProperty("stationController_file")
  
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  
  widget.setVisible("addStationOverlay", false)
  widget.setVisible("groupsOverlay", true)
  
  widget.clearListItems(self.widgetListName)
end

function stationsListSelected(widgetName, widgetData)
  local listItem = widget.getListSelected(self.widgetListName)
  local selectedItem = listItem
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

function linkButtonPressed(widgetName, widgetData)

  slot_widget = "groupsOverlay.itemslot1"
  
  local slottedItem = widget.itemSlotItem(slot_widget)
  self.saveFile = world.getProperty("stationController_file")
  slottedItem.parameters.stationControlled = true
  slottedItem.parameters.stationGroup = self.saveFile[self.uuid].group
  slottedItem.parameters.stationuuid = self.uuid
  local slotNumber = tonumber(string.sub(slot_widget, string.len(slot_widget), string.len(slot_widget)))
  world.sendEntityMessage(pane.sourceEntity(), "saveSlottedItems", slotNumber, slottedItem)
  self.slottedItem = slottedItem
  widget.setItemSlotItem(slot_widget, nil)
  self.saveFile.global[self.groupEditing].data.slottedItem = true
  --self.saveFile.global[self.groupEditing].data.item = {}
  --self.saveFile.global[self.groupEditing].data.item = slottedItem
  world.setProperty("stationController_file", self.saveFile)
  
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  
end

function unlinkButtonPressed(widgetName, widgetData)
  self.slottedItem.parameters.stationControlled = false
  self.slottedItem.parameters.stationGroup = nil
  self.slottedItem.parameters.stationuuid = nil
  sb.logInfo("SLOTTED ITEM ")
  tprint(self.slottedItem)
  player.giveItem(self.slottedItem)
  self.slottedItem = nil
  world.sendEntityMessage(pane.sourceEntity(), "saveSlottedItems", 1, nil)
  self.saveFile.global[self.groupEditing].data.slottedItem = false
  self.saveFile.global[self.groupEditing].data.item = nil
  world.setProperty("stationController_file", self.saveFile)
  
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  
end

function circularCheckBox(widgetName, widgetData)
  self.saveFile = world.getProperty("stationController_file")
  self.saveFile.global[self.groupEditing].data.circular = not self.saveFile.global[self.groupEditing].data.circular
  world.setProperty("stationController_file", self.saveFile)
  
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
  
end

function testRunButtonPressed(widgetName, widgetData)
  widget.setVisible("groupsOverlay", false)
  widget.setVisible("testRunOverlay", true)
  widget.setVisible("testRunOverlay.backToMainButton", true)
  if self.saveFile.global[self.groupEditing].data.testRunCompleted then
    widget.setVisible("testRunOverlay.testRunDataScrollArea", true)
	
	local stationTimesRaw = self.saveFile.global[self.groupEditing].data.times
	local timesArray = {}
	timesArray[1] = 0
	timesArray[2] = math.floor((stationTimesRaw[2] * 10) + 0.5)/10
	
    --self.defaultStopLen

    for i=3,#self.saveFile.global[self.groupEditing].data.times do
	  timesArray[i] = (math.floor((stationTimesRaw[i] * 10) + 0.5)/10) - self.defaultStopLen
    end
	tprint(timesArray)
	
	self.testRunDataListName = "testRunOverlay.testRunDataScrollArea.testRunDataList"
	
	--local listItem = string.format("%s.%s",self.widgetListName, widget.addListItem(self.widgetListName))
	--sb.logInfo("listItem " .. tostring(i) .. " " .. listItem .. " ==> " .. listItem .. ".member")
	--sb.logInfo("stationDisplayName " .. stationDisplayName)
	--widget.setText(listItem .. ".member", stationDisplayName)
	--widget.setData(listItem, stationsList[i])
	
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
	
	self.saveFile.global[self.groupEditing].data.timesTidy = {}
	self.saveFile.global[self.groupEditing].data.timesTidy = timesArray
	
	if self.saveFile.global[self.groupEditing].data.toBeInit == nil then
	  self.saveFile.global[self.groupEditing].data.toBeInit = true
	end
	
	world.setProperty("stationController_file", self.saveFile)
	
	widget.setVisible("testRunOverlay.instructionsLabel", true)
	widget.setVisible("testRunOverlay.setTimetableButton", true)
  end
end

function startTestRunButtonPressed(widgetName, widgetData)
  widget.setVisible("testRunOverlay.testRunInProgressLabel", true)
  world.sendEntityMessage(pane.sourceEntity(), "startTestRun")
  --self.testRunInProgress = true
end

function testRunDataListSelected(widgetName, widgetData)
  
end

function clearTestRunDataButtonPressed(widgetName, widgetData)
  self.saveFile.global[self.groupEditing].data.times = nil
  self.saveFile.global[self.groupEditing].data.timesABS = nil
  self.saveFile.global[self.groupEditing].data.uuids = nil
  self.saveFile.global[self.groupEditing].data.nodesPos = nil
  self.saveFile.global[self.groupEditing].data.testRunCompleted = false
  self.saveFile.global[self.groupEditing].data.toBeInit = false
  world.setProperty("stationController_file", self.saveFile)
  
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData", true)
end

function groupNameError(kind)
  
end

function backToMainFromTestRunButtonPressed(widgetName, widgetData)
  
end

function changeNumInGroupButton(widgetName, widgetData)
  
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
sb.logInfo("=NODEPOS= SAVE FILE: ")
self.groupNodePos = world.getProperty("stationController_" .. storage.group .. "_nodesPos")
tprint(self.groupNodePos)
  
end

function renameStationButtonPressed(widgetName, widgetData)
  
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

   slot_widget = "groupsOverlay" .. "." .. slot_widget
    
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