
carNumberSpinner = {}
carTypeSpinner = {}
craftSpinner = {}
color1Spinner = {}
color2Spinner = {}
decal1Spinner = {}
decal2Spinner = {}
decal3Spinner = {}
decal4Spinner = {}
decal5Spinner = {}
decal6Spinner = {}
decal7Spinner = {}
decal8Spinner = {}
decal9Spinner = {}
decal10Spinner = {}

    --callback function when right button is pressed
function carNumberSpinner.up()
  if self.numberOfCars < 10 then
    local lastCar = deepcopy(self.trainSet[self.numberOfCars])
    table.insert(self.trainSet, (self.numberOfCars + 1), lastCar)
    self.numberOfCars = self.numberOfCars + 1
    widget.setText("valuenumberOfCars", self.numberOfCars)
    for i=1,self.numberOfCars do
      widget.setVisible("scrollArea.car" .. tostring(i) .. "Button", true)
	  widget.setVisible("scrollArea.car" .. tostring(i) .. "Body", true)
      widget.setVisible("scrollArea.car" .. tostring(i) .. "Pantograph", true)
      for j=1,10 do
        widget.setVisible("scrollArea.car" .. tostring(i) .. "Decal" .. tostring(j), true)
      end
    end
	for i=self.numberOfCars+1,10 do
      widget.setVisible("scrollArea.car" .. tostring(i) .. "Button", false)
	  widget.setVisible("scrollArea.car" .. tostring(i) .. "Body", false)
      widget.setVisible("scrollArea.car" .. tostring(i) .. "Pantograph", false)
      for j=1,10 do
        widget.setVisible("scrollArea.car" .. tostring(i) .. "Decal" .. tostring(j), false)
      end
    end
	updatePane()
  end
end

    --called when left button is pressed
function carNumberSpinner.down()
  if self.numberOfCars > 1 then
    self.trainSet[self.numberOfCars] = nil
    self.numberOfCars = self.numberOfCars - 1
    widget.setText("valuenumberOfCars", self.numberOfCars)
	for i=1,self.numberOfCars do
      widget.setVisible("scrollArea.car" .. tostring(i) .. "Button", true)
	  widget.setVisible("scrollArea.car" .. tostring(i) .. "Body", true)
      widget.setVisible("scrollArea.car" .. tostring(i) .. "Pantograph", true)
      for j=1,10 do
        widget.setVisible("scrollArea.car" .. tostring(i) .. "Decal" .. tostring(j), true)
      end
    end
	for i=self.numberOfCars+1,10 do
    end
	for i=self.numberOfCars+1,10 do
      widget.setVisible("scrollArea.car" .. tostring(i) .. "Button", false)
	  widget.setVisible("scrollArea.car" .. tostring(i) .. "Body", false)
      widget.setVisible("scrollArea.car" .. tostring(i) .. "Pantograph", false)
      for j=1,10 do
        widget.setVisible("scrollArea.car" .. tostring(i) .. "Decal" .. tostring(j), false)
      end
    end
	updatePane()
  end
end

    --callback function when right button is pressed
function craftSpinner.up()
  if self.craftAmount < 99 then
    self.craftAmount = self.craftAmount +1
  end
  widget.setText("craftValue",self.craftAmount)
  
  setPrice()
end
    --called when left button is pressed
function craftSpinner.down()
  if self.craftAmount > 1 then
    self.craftAmount = self.craftAmount - 1
  end
  widget.setText("craftValue",self.craftAmount)
  
  setPrice()
end

    --callback function when right button is pressed
function carTypeSpinner.up()
  local currentvehicleIndex = self.IndexesTemp[self.editingCar].vehicleIndex
  local numOfvehicleIndex = self.numberOfVehicleTypes
  
  if currentvehicleIndex < numOfvehicleIndex then
    self.trainsetTemp[self.editingCar].name = self.vehiclesIndexes[currentvehicleIndex+1]
    
    self.trainsetTemp[self.editingCar] = getDefaultValues(self.vehiclesIndexes[currentvehicleIndex+1])
    
	self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	self.editingACar = true
	widget.setVisible("saveCarButton", true)
	widget.setVisible("discardButton", true)
  else
	self.trainsetTemp[self.editingCar].name = self.vehiclesIndexes[1]
	self.trainsetTemp[self.editingCar] = getDefaultValues(self.vehiclesIndexes[1])
	
	self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	self.editingACar = true
	widget.setVisible("saveCarButton", true)
	widget.setVisible("discardButton", true)
  end
  
  setPrice()
end

    --called when left button is pressed
function carTypeSpinner.down()
  local currentvehicleIndex = self.IndexesTemp[self.editingCar].vehicleIndex
  local numOfvehicleIndex = self.numberOfVehicleTypes
  
  if currentvehicleIndex > 1 then
    self.trainsetTemp[self.editingCar].name = self.vehiclesIndexes[currentvehicleIndex-1]    
    self.trainsetTemp[self.editingCar] = getDefaultValues(self.vehiclesIndexes[currentvehicleIndex-1])
    
	self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	self.editingACar = true
	widget.setVisible("saveCarButton", true)
	widget.setVisible("discardButton", true)
  else
	self.trainsetTemp[self.editingCar].name = self.vehiclesIndexes[numOfvehicleIndex]
	self.trainsetTemp[self.editingCar] = getDefaultValues(self.vehiclesIndexes[numOfvehicleIndex])
	
	self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	self.editingACar = true
	widget.setVisible("saveCarButton", true)
	widget.setVisible("discardButton", true)
  end
  
  setPrice()
end

    --callback function when right button is pressed
function color1Spinner.up()

  local currentColorIndex = self.IndexesTemp[self.editingCar].currentColorIndex
  local numOfColorIndexes = self.IndexesTemp[self.editingCar].numOfColorIndexes
  
  if numOfColorIndexes == 1 then
    return
  end
  
  if currentColorIndex < numOfColorIndexes then
    self.trainsetTemp[self.editingCar].color = self.listOfCars[self.IndexesTemp[self.editingCar].vehicleName].colors[currentColorIndex+1]
	self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	self.editingACar = true
	widget.setVisible("saveCarButton", true)
	widget.setVisible("discardButton", true)
  else
	self.trainsetTemp[self.editingCar].color = self.listOfCars[self.IndexesTemp[self.editingCar].vehicleName].colors[1]
	self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	self.editingACar = true
	widget.setVisible("saveCarButton", true)
	widget.setVisible("discardButton", true)
  end
  
end
    --called when left button is pressed
function color1Spinner.down()

  local currentColorIndex = self.IndexesTemp[self.editingCar].currentColorIndex
  local numOfColorIndexes = self.IndexesTemp[self.editingCar].numOfColorIndexes
  
  if numOfColorIndexes == 1 then
    return
  end
  
  if currentColorIndex > 1 then
	self.trainsetTemp[self.editingCar].color = self.listOfCars[self.IndexesTemp[self.editingCar].vehicleName].colors[currentColorIndex-1]
	self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	self.editingACar = true
	widget.setVisible("saveCarButton", true)
	widget.setVisible("discardButton", true)
  else
	self.trainsetTemp[self.editingCar].color = self.listOfCars[self.IndexesTemp[self.editingCar].vehicleName].colors[numOfColorIndexes]
	self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	self.editingACar = true
	widget.setVisible("saveCarButton", true)
	widget.setVisible("discardButton", true)
  end
  
end

    --callback function when right button is pressed
function color2Spinner.up()
  local currentCockpitColorIndex = self.IndexesTemp[self.editingCar].currentCockpitColorIndex
  local numOfCockpitColorIndexes = self.IndexesTemp[self.editingCar].numOfCockpitColorIndexes
  
  if numOfCockpitColorIndexes == 1 then
    return
  end
  
  if currentCockpitColorIndex < numOfCockpitColorIndexes then
    self.trainsetTemp[self.editingCar].cockpitColor = self.listOfCars[self.IndexesTemp[self.editingCar].vehicleName].cockpitColors[currentCockpitColorIndex+1]
	self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	self.editingACar = true
	widget.setVisible("saveCarButton", true)
	widget.setVisible("discardButton", true)
  else
    self.trainsetTemp[self.editingCar].cockpitColor = self.listOfCars[self.IndexesTemp[self.editingCar].vehicleName].cockpitColors[1]
    self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	self.editingACar = true
	widget.setVisible("saveCarButton", true)
	widget.setVisible("discardButton", true)
  end
end
    --called when left button is pressed
function color2Spinner.down()
  
  local currentCockpitColorIndex = self.IndexesTemp[self.editingCar].currentCockpitColorIndex
  local numOfCockpitColorIndexes = self.IndexesTemp[self.editingCar].numOfCockpitColorIndexes
  
  if numOfCockpitColorIndexes == 1 then
    return
  end
  
  if currentCockpitColorIndex > 1 then
    self.trainsetTemp[self.editingCar].cockpitColor = self.listOfCars[self.IndexesTemp[self.editingCar].vehicleName].cockpitColors[currentCockpitColorIndex-1]
	self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	self.editingACar = true
	widget.setVisible("saveCarButton", true)
	widget.setVisible("discardButton", true)
  else
    self.trainsetTemp[self.editingCar].cockpitColor = self.listOfCars[self.IndexesTemp[self.editingCar].vehicleName].cockpitColors[numOfCockpitColorIndexes]
    self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	self.editingACar = true
	widget.setVisible("saveCarButton", true)
	widget.setVisible("discardButton", true)
  end
end

    --callback function when right button is pressed
function decal1Spinner.up()
  setDecal(1, 1)
  
end
    --called when left button is pressed
function decal1Spinner.down()
  setDecal(1, -1)
end

    --callback function when right button is pressed
function decal2Spinner.up()
  setDecal(2, 1)  
end
    --called when left button is pressed
function decal2Spinner.down()
  setDecal(2, -1)
end

    --callback function when right button is pressed
function decal3Spinner.up()
  setDecal(3, 1)  
end
    --called when left button is pressed
function decal3Spinner.down()
  setDecal(3, -1)
end

    --callback function when right button is pressed
function decal4Spinner.up()
  setDecal(4, 1)  
end
    --called when left button is pressed
function decal4Spinner.down()
  setDecal(4, -1)
end

    --callback function when right button is pressed
function decal5Spinner.up()
  setDecal(5, 1)  
end
    --called when left button is pressed
function decal5Spinner.down()
  setDecal(5, -1)
end

    --callback function when right button is pressed
function decal6Spinner.up()
  setDecal(6, 1)  
end
    --called when left button is pressed
function decal6Spinner.down()
  setDecal(6, -1)
end

    --callback function when right button is pressed
function decal7Spinner.up()
  setDecal(7, 1)  
end
    --called when left button is pressed
function decal7Spinner.down()
  setDecal(7, -1)
end

    --callback function when right button is pressed
function decal8Spinner.up()
  setDecal(8, 1)  
end
    --called when left button is pressed
function decal8Spinner.down()
  setDecal(8, -1)
end

    --callback function when right button is pressed
function decal9Spinner.up()
  setDecal(9, 1)  
end
    --called when left button is pressed
function decal9Spinner.down()
  setDecal(9, -1)
end

    --callback function when right button is pressed
function decal10Spinner.up()
  setDecal(10, 1)  
end
    --called when left button is pressed
function decal10Spinner.down()
  setDecal(10, -1)
end

function setDecal(n, method)
  local decalnName = self.listOfCars[self.IndexesTemp[self.editingCar].vehicleName].decalNames[n]
  local currentDecalIndex = self.IndexesTemp[self.editingCar].currentDecalIndex[decalnName]
  local numOfDecalSpritesIndexes = self.IndexesTemp[self.editingCar].numOfDecalSpritesIndexes[decalnName]
    
  if method >= 1 then
    if currentDecalIndex < numOfDecalSpritesIndexes then
      self.trainsetTemp[self.editingCar].decals[decalnName] = self.listOfCars[self.IndexesTemp[self.editingCar].vehicleName].decals[decalnName][currentDecalIndex+1]
	  self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	  displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	  self.editingACar = true
	  widget.setVisible("saveCarButton", true)
	  widget.setVisible("discardButton", true)
    else
      self.trainsetTemp[self.editingCar].decals[decalnName] = self.listOfCars[self.IndexesTemp[self.editingCar].vehicleName].decals[decalnName][1]
      self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	  displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	  self.editingACar = true
	  widget.setVisible("saveCarButton", true)
	  widget.setVisible("discardButton", true)
    end
  else
    if currentDecalIndex  > 1 then
      self.trainsetTemp[self.editingCar].decals[decalnName] = self.listOfCars[self.IndexesTemp[self.editingCar].vehicleName].decals[decalnName][currentDecalIndex-1]
	  self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	  displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	  self.editingACar = true
	  widget.setVisible("saveCarButton", true)
	  widget.setVisible("discardButton", true)
    else
      self.trainsetTemp[self.editingCar].decals[decalnName] = self.listOfCars[self.IndexesTemp[self.editingCar].vehicleName].decals[decalnName][numOfDecalSpritesIndexes]
      self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
	  displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
	  self.editingACar = true
	  widget.setVisible("saveCarButton", true)
	  widget.setVisible("discardButton", true)
    end
  end
  
end

function init()


  self.listOfCars = root.assetJson("/objects/crafting/trainConfigurator/listOfCars.json")
  self.settingsConfig = root.assetJson("/interface/linkedTrain/trainConfigurator/settings.json")
  self.logging = self.settingsConfig.logging
  
  self.sounds = config.getParameter("sounds")
  
  --sb.logInfo("\nself.listOfCars ")
  --tprint(self.listOfCars)
  
  self.paneImgPath = self.settingsConfig.paneImgPath
  self.vehiclesIndexes = self.settingsConfig.vehiclesList
  
  --sb.logInfo("================================self.settingsConfig.vehiclesList:")
  --tprint(self.vehiclesIndexes)
  --sb.logInfo("===================Taken from list of cars:")
  
  --local vehiclesarray = {}
  --for k,_ in pairs(self.listOfCars) do
    --table.insert(vehiclesarray,k)
  --end
  --tprint(vehiclesarray)
  
  self.numberOfVehicleTypes = #self.vehiclesIndexes
  
  --self.numberOfVehicleTypes = 0
  --for _ in pairs(self.listOfCars) do self.numberOfVehicleTypes = self.numberOfVehicleTypes + 1 end
  if self.logging then sb.logInfo("\nself.numberOfVehicleTypes " .. tostring(self.numberOfVehicleTypes)) end
  
  self.defaultTrainset = self.settingsConfig.defaultTrainset
  self.itemName = self.settingsConfig.itemName
  
  self.editingACar = false
  
  --sb.logInfo("\ndefault Trainset ")
  --tprint(self.defaultTrainset)
      

  if world.containerItemAt(pane.containerEntityId(), 0) then
    local item = world.containerItemAt(pane.containerEntityId(), 0)
	local itemConfig = root.itemConfig(item)
	if (itemConfig.config.category == "railPlatform") and (itemConfig.config.linkedRailTrain == true) then
	  self.itemValid = true
	  self.itemPresent = true
      local item = world.containerItemAt(pane.containerEntityId(), 0)
      self.numberOfCars = item.parameters.numberOfCars
      self.trainSet = deepcopy(item.parameters.trainsetData)
      if not self.numberOfCars then self.numberOfCars = #self.trainSet end
	  self.trainsetIndexed = trainsetToIndexes(self.trainSet)
	  self.editingExistingItem = true
	  self.craftAmount = 1
	  showCraftInteface()
	end
  else
    self.trainSet = deepcopy(self.defaultTrainset)
    self.numberOfCars = #self.trainSet
	self.trainsetIndexed = trainsetToIndexes(self.trainSet)
	self.editingExistingItem = false
	showCraftInteface()
  end
  
  self.numberOfCars = tonumber(self.numberOfCars)
  
  if self.logging then 
    sb.logInfo("\nTrainset ")
    tprint(self.trainSet)
    sb.logInfo("\nTrainset INDEXED ")
    tprint(self.trainsetIndexed)
  end
  
  widget.setText("valuenumberOfCars", self.numberOfCars)
  for i=1,self.numberOfCars do
    widget.setVisible("scrollArea.car" .. tostring(i) .. "Button", true)
  end
  for i=self.numberOfCars+1,10 do
    widget.setVisible("scrollArea.car" .. tostring(i) .. "Button", false)
  end
  
  self.playerMoney = player.currency("money")
  widget.setText("playerPixels", tostring(self.playerMoney))
  
  --self.paneuuid = sb.makeUuid()
  --sb.logInfo(tostring(self.paneuuid))
  --sb.logInfo(tostring(self.paneuuid) .. "TrainSetPane")
  --world.setProperty("TrainSetPane", self.trainSet)
  --local tempworldprop = world.getProperty("TrainSetPane")
  --sb.logInfo(tostring(self.trainSet))
  --sb.logInfo(tostring(tempworldprop))
  --tprint(tempworldprop)
    
  updatePane()

  --self.trainSet = config.getParameter("trainsetData")
  
  --widget.setVisible("welcomeOverlay", true)

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

function getDefaultValues(vehicleName)
    default = {}
	default.name = vehicleName
    default.color = self.listOfCars[vehicleName].colors[1]
    default.cockpitColor = self.listOfCars[vehicleName].cockpitColors[1]
    default.pantographVisibile = self.listOfCars[vehicleName].hasPantograph
    default.reversed = false
    default.doorLocked = false
    default.carDistance = self.listOfCars[vehicleName].carDistance
    
    local hasDecals = self.listOfCars[vehicleName].hasDecals
    if hasDecals then
      default.decalNames = deepcopy(self.listOfCars[vehicleName].decalNames)
      local numberOfDecals = #default.decalNames
      default.decals = {}
      for i=1,numberOfDecals do
        local currentDecalName = default.decalNames[i]
        default.decals[currentDecalName] = self.listOfCars[vehicleName].decals[currentDecalName][1]
      end
    end
	
    if self.logging then tprint(default) end
	
    return default
  end


function dismissed()
   --world.setProperty(tostring(self.paneuuid) .. "TrainSetPane" , nil)
   --world.setProperty("TrainSetPane", nil)
  --for _, sound in pairs(self.sounds) do pane.stopAllSounds(sound) end
  --local item = widget.itemSlotItem("modifyTrainsetOverlay.inputItemSlot")
  --if item then
  --player.giveItem(item)--pop the item if there is any inside to avoid it being lost
end

function update(dt)

  if world.containerItemAt(pane.containerEntityId(), 0) == nil then
    widget.setVisible("ErrorLabel1", false)
	widget.setVisible("Edit1Label", true)
	widget.setVisible("Edit2Label", true)
  end

  if world.containerItemAt(pane.containerEntityId(), 0) ~= nil then
	local item = world.containerItemAt(pane.containerEntityId(), 0)
	local itemConfig = root.itemConfig(item)
	if (itemConfig.config.category ~= "railPlatform") and (itemConfig.config.linkedRailTrain ~= true) then
	  widget.setVisible("ErrorLabel1", true)
	  widget.setVisible("loadTrainsetButton", false)
	  widget.setVisible("saveTrainsetButton", false)
	  widget.setVisible("Edit1Label", false)
	  widget.setVisible("Edit2Label", false)
	  self.itemValid = false
	  self.itemPresent = true
	else
	  self.itemValid = true
	  self.itemPresent = true
	  widget.setVisible("ErrorLabel1", false)
	  widget.setVisible("Edit1Label", true)
	  widget.setVisible("Edit2Label", true)
	  widget.setVisible("loadTrainsetButton", true)
	  widget.setVisible("saveTrainsetButton", true)
	end
  end
  if world.containerItemAt(pane.containerEntityId(), 0) == nil then
    widget.setVisible("loadTrainsetButton", false)
    widget.setVisible("saveTrainsetButton", false)
	widget.setVisible("ErrorLabel1", false)
	self.itemPresent = false
	self.editingExistingItem = false
  end

  if self.playerMoney ~= player.currency("money") then 
    self.playerMoney = player.currency("money")
    widget.setText("playerPixels", tostring(self.playerMoney))
  end
  
  if self.notEnoughMoneyDialogShown then
    
	if self.flashingTimer == nil then
	  self.flashingTimer = 0
	  self.flashingCycles = 1
	end
	
	self.flashingTimer = self.flashingTimer + dt
	
	if self.flashingCycles == 20 then
	  widget.setVisible("priceTotalLabel", true)
      widget.setVisible("pixelsIcon2", true)
      widget.setVisible("priceTotalValue", true)
      widget.setVisible("notEnoughMoneyLabel", false)
	  widget.setText("notEnoughMoneyLabel", "^red;not enough money^reset;")
      widget.setVisible("craftButton", true)
      self.notEnoughMoneyDialogShown = false
	  self.flashingTimer = 0
	  self.flashingCycles = 1
	  --widget.playSound(self.sounds.error)
	end
	
	if self.flashingTimer >= 0.1 and self.flashingCycles % 2 == 0 then
	  widget.setText("notEnoughMoneyLabel", "^red;not enough money^reset;")
	  self.flashingTimer = 0
	  self.flashingCycles = self.flashingCycles +1
	elseif self.flashingTimer >= 0.1 then
	  widget.setText("notEnoughMoneyLabel", "^yellow;not enough money^reset;")
	  self.flashingTimer = 0
	  self.flashingCycles = self.flashingCycles +1
	end
  end

end

function trainsetToIndexes(indata)
    if self.logging then sb.logInfo("\ntrainsetToIndexes() called") end

  local data = {}
  
  --data.numOfVehicleIndexes = self.numberOfVehicleTypes
  
  for carNumber=1,#indata do
    data[carNumber] = {}
    local vehicleName = indata[carNumber].name
  
    data[carNumber].vehicleName = indata[carNumber].name
    --data[carNumber].vehicleIndex = indexOf(self.listOfCars, vehicleName)
	data[carNumber].vehicleIndex = indexOf(self.vehiclesIndexes, vehicleName)
  
    local colorsTable = self.listOfCars[vehicleName].colors
    data[carNumber].numOfColorIndexes = #self.listOfCars[vehicleName].colors
    data[carNumber].currentColorIndex = indexOf(colorsTable, indata[carNumber].color)
    data[carNumber].currentColor = indata[carNumber].color
  
    local cockpitColorsTable = self.listOfCars[vehicleName].cockpitColors
    data[carNumber].numOfCockpitColorIndexes = #self.listOfCars[vehicleName].cockpitColors
    data[carNumber].currentCockpitColorIndex = indexOf(cockpitColorsTable, indata[carNumber].cockpitColor)
    data[carNumber].currentCockpitColor = indata[carNumber].cockpitColor
  
    if self.listOfCars[vehicleName].hasPantograph then
      data[carNumber].pantographEnabled = indata[carNumber].pantographVisibile
    end
  
    data[carNumber].doorsLocked = indata[carNumber].doorLocked
    data[carNumber].reversed = indata[carNumber].reversed
    data[carNumber].specular = self.listOfCars[vehicleName].specular
  
    local hasDecals = self.listOfCars[vehicleName].hasDecals
  
    if hasDecals then
	  data[carNumber].currentDecalIndex = {}
      data[carNumber].currentDecalSprite = {}
      data[carNumber].numOfDecalSpritesIndexes = {}
      local numberOfDecals = #self.listOfCars[vehicleName].decalNames
  	  local decalsNames = self.listOfCars[vehicleName].decalNames
      local decalsTable = self.listOfCars[vehicleName].decals
	  local CarDecalsTable = indata[carNumber].decals
	  for i=1,tonumber(numberOfDecals) do
	    local currentDecal = decalsNames[i]
        local currentDecalSprite = CarDecalsTable[currentDecal]
	    local decalIndex = indexOf(decalsTable[currentDecal], currentDecalSprite)
	    data[carNumber].currentDecalIndex[currentDecal] = decalIndex
	    data[carNumber].currentDecalSprite[currentDecal] = currentDecalSprite
	    data[carNumber].numOfDecalSpritesIndexes[currentDecal] = #decalsTable[currentDecal]
	  end
    end
 
  end
  
  --tprint(data)
  
  return data
end

function updatePane()
 
 for i=1,self.numberOfCars do
   
   setListImgs(getImages(i, self.trainSet), i)
   
   setPrice()
 
   --setPreviewImage(i, self.trainSet, true)
 
   --widget.setButtonImage("scrollArea.car" .. tostring(i) .. "Button", self.trainsetIndexed[i].previewImage)
   --widget.setButtonOverlayImage("scrollArea.car" .. tostring(i) .. "Button", updateImage(i))
   --widget.setVisible("scrollArea.car" .. tostring(i) .. "Button", true)
 end
 
 --for j=self.numberOfCars+1,10 do
   --widget.setVisible("scrollArea.car" .. tostring(j) .. "Button", false)
 --end
  
end

function pantographCheckBox(widgetName, widgetData)
  self.trainsetTemp[self.editingCar].pantographVisibile = not self.trainsetTemp[self.editingCar].pantographVisibile
  self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
  displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
  widget.setVisible("saveCarButton", true)
  self.editingACar = true
end

function reversedCheckBox(widgetName, widgetData)
  self.trainsetTemp[self.editingCar].reversed = not self.trainsetTemp[self.editingCar].reversed
  self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
  displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
  widget.setVisible("saveCarButton", true)
  self.editingACar = true
end

function doorslockedCheckBox(widgetName, widgetData)
  self.trainsetTemp[self.editingCar].doorLocked = not self.trainsetTemp[self.editingCar].doorLocked
  self.IndexesTemp = trainsetToIndexes(self.trainsetTemp)
  displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
  widget.setVisible("saveCarButton", true)
  self.editingACar = true
end

function verifyItem(item)
  if self.logging then 
    sb.logInfo("===========VERIFY ITEM CALLED======")
    sb.logInfo("ITEM AS FOLLOWS:")
  end
  if item then
    if self.logging then  tprint(item) end
    local itemtraindata = deepcopy(item.parameters.trainsetData)
    local itemnumcars = item.parameters.numberOfCars
    
    if self.logging then 
      sb.logInfo("verifyItem(item): trainsed data extracted as follows:")
      tprint(itemtraindata)
    end
    
    local fatalerror = false
    local warning = false
    --local carnumbersmismatch = false
    
    --self.listOfCars[vehicleName].decalNames
    
    local realcarnumbers = {}
    
    if not itemnumcars == #itemtraindata then
      if #itemtraindata > itemnumcars then
        item.parameters.numberOfCars = #itemtraindata
        sb.logInfo("verifyItem(item) WARNING: number of cars mismatch with trainset data array from item, number of cars value=" .. tostring(itemnumcars) .. " array lenght=" .. tostring(#itemtraindata) .. ", fixed")
        warning = true
      else
        sb.logInfo("verifyItem(item) FATAL ERROR: number of cars in array is less than declared in JSON trainset data, number of cars mismatch with trainset data array from item, number of cars value=" .. tostring(itemnumcars) .. " array lenght=" .. tostring(#itemtraindata))
        fatalerror = true
      end
      
    else
      
      for i=1,itemnumcars do
        local vehicleName
        if not itemtraindata[i].name then
          sb.logInfo("verifyItem(item) FATAL ERROR: car number " .. tostring(i) .. " vehicle name not present")
          fatalerror = true
          break
        else
          vehicleName = itemtraindata[i].name
        end
        if not tonumber(itemtraindata[i].carNumber) == i then
          --sb.logInfo("verifyItem(item) ERROR: car number " .. tostring(i) .. " number mismatch in array, number in array=" .. tostring(itemtraindata.carNumber))
          fatalerror = true
          sb.logInfo("verifyItem(item) FATAL ERROR: car number " .. tostring(i) .. " number mismatch in array, number in array=" .. tostring(itemtraindata.carNumber))
          --carnumbersmismatch = true
          --realcarnumbers[i] = itemtraindata[i].carNumber
        --else
          --realcarnumbers[i] = itemtraindata[i].carNumber
        end
        if itemtraindata[i].doorLocked == nil then
          sb.logInfo("verifyItem(item) WARNING: car number " .. tostring(i) .. " doorlocked field not present, setting to false, fixed")
          itemtraindata[i].doorLocked = false
          warning = true
        end
        if itemtraindata[i].pantographVisibile == nil then
          sb.logInfo("verifyItem(item) WARNING: car number " .. tostring(i) .. " pantographVisibile field not present, setting to false, fixed")
          itemtraindata[i].pantographVisibile = false
          warning = true
        end
        if self.logging then 
          sb.logInfo("verifyItem(item): car number " .. tostring(i) .. " vehicle name=" .. tostring(vehicleName) .. " hasdecals=" .. tostring(self.listOfCars[vehicleName].hasDecals))
        end
        if self.listOfCars[vehicleName].hasDecals then
          if not itemtraindata[i].decalNames then
            sb.logInfo("verifyItem(item) FATAL ERROR: car number " .. tostring(i) .. " decalNames array not present")
            fatalerror = true
            break
          else
            if not (#itemtraindata[i].decalNames == #self.listOfCars[vehicleName].decalNames) then
              sb.logInfo("verifyItem(item) WARNING: car number " .. tostring(i) .. " decalNames array lenght mismatch, array lenght=" .. tostring(#itemtraindata[i].decalNames) .. " should be=" .. tostring(#self.listOfCars[vehicleName].decalNames) .. ", fixed")
              sb.logInfo("verifyItem(item) WARNING: decalNames Len=" .. tostring(#itemtraindata[i].decalNames) .. " decalNames Len from JSON car list=" .. tostring(#self.listOfCars[vehicleName].decalNames) .. " Len mismatch=" ..tostring(not (#itemtraindata[i].decalNames == #self.listOfCars[vehicleName].decalNames)))
              sb.logInfo("verifyItem(item) WARNING: car number " .. tostring(i) .. " vehicle name=" .. tostring(vehicleName) .. " decalNames=")
              tprint(itemtraindata[i].decalNames)
              warning = true
              for d=#itemtraindata[i].decalNames+1,#self.listOfCars[vehicleName].decalNames do
                itemtraindata[i].decalNames[d] = self.listOfCars[vehicleName].decalNames[d]
                itemtraindata[i].decals[itemtraindata[i].decalNames[d]] = 0
              end
            end
          end
        end 
      end
      
      if not fatalerror then
        if warning then
          --if carnumbersmismatch then
            --
          --end
          
          sb.logInfo("verifyItem(item): verification ended with warnings, item data before fixes applied:")
          tprint(item)
          
          item.parameters.trainsetData = deepcopy(itemtraindata)
          
          world.containerTakeAt(pane.containerEntityId(), 0)
          world.containerItemApply(pane.containerEntityId(), item, 0)
          sb.logInfo("verifyItem(item): verification ended with warnings, all warnings (should be) fixed, item data after fixes applied as follows:")
          tprint(item)
        else
          if self.logging then sb.logInfo("verifyItem(item): verification ended, no errors or warnings:") end
        end
      end

    end
    
  end
end

function loadTrainsetButtonPressed(widgetName, widgetData)
  local item = world.containerItemAt(pane.containerEntityId(), 0)
  local itemConfig = root.itemConfig(item)
  
  verifyItem(deepcopy(item))
  
  self.numberOfCars = item.parameters.numberOfCars
  self.trainSet = deepcopy(item.parameters.trainsetData)
  if not self.numberOfCars then self.numberOfCars = #self.trainSet end
  self.trainsetIndexed = trainsetToIndexes(self.trainSet)
  
  self.trainsetTemp = deepcopy(self.trainSet)
  self.IndexesTemp =  deepcopy(self.trainsetIndexed)
  
  --reloadCaptions()
  hideEditCar()
  updatePane()
  
  widget.setText("valuenumberOfCars", self.numberOfCars)
  local dump = "\n================stuff got from objects in variables==========="
  dump = dump .. "\nself.numberOfCars " .. tostring(self.numberOfCars)
  if self.logging then 
    sb.logInfo(tostring(dump))
    --sb.logInfo("\nself.trainSet ")
    --sb.logInfo("\n")
    --tprint(self.trainSet)
    sb.logInfo("\nitem descriptor ")
    sb.logInfo("\n")
    tprint(item)
    sb.logInfo("\nitem config ")
    sb.logInfo("\n")
    tprint(itemConfig)
  end
  
  self.editingExistingItem = true
  
end

function saveTrainsetButtonPressed(widgetName, widgetData)

  local item = world.containerItemAt(pane.containerEntityId(), 0)

  if self.logging then
    local dump = "\n================BEFORE stuff got from objects in variables SAVE TRAINSET==========="
    dump = dump .. "\nself.numberOfCars " .. tostring(self.numberOfCars)
    sb.logInfo(tostring(dump))
    --sb.logInfo("\nself.trainSet ")
    --sb.logInfo("\n")
    --tprint(self.trainSet)
    sb.logInfo("\nitem descriptor ")
    sb.logInfo("\n")
  end
  
  item.parameters.numberOfCars = self.numberOfCars
  
  item.parameters.trainsetData = {}
  
  item.parameters.trainsetData = deepcopy(self.trainSet)
  
  if self.logging then
      tprint(item) 
    local dump = "\n================AFTER stuff got from objects in variables SAVE TRAINSET==========="
    dump = dump .. "\nself.numberOfCars " .. tostring(self.numberOfCars)
    sb.logInfo(tostring(dump))
    --sb.logInfo("\nself.trainSet ")
    --sb.logInfo("\n")
    --tprint(self.trainSet)
    sb.logInfo("\nitem descriptor ")
    sb.logInfo("\n")
    tprint(item)
  end

  world.containerTakeAt(pane.containerEntityId(), 0)
  
  --world.containerAddItems(pane.containerEntityId(), item)
  world.containerItemApply(pane.containerEntityId(), item, 0)

  setPrice()

  hideEditCar()
  --updatePane()
  
end

function setPrice()
  local price = 0
  for i=1,self.numberOfCars do
    local vehicleName = self.trainSet[i].name
	price = price + tonumber(self.listOfCars[vehicleName].price)
  end
  
  self.totalPrice = price * self.craftAmount
  self.playerMoney = player.currency("money")
  if self.playerMoney > self.totalPrice then
    widget.setText("priceTotalValue", "^green;" .. tostring(self.totalPrice) .. "^reset;")
	widget.setText("priceTotalLabel", "^green;craft price:^reset;")
  else
    widget.setText("priceTotalValue", "^red;" .. tostring(self.totalPrice) .. "^reset;")
	widget.setText("priceTotalLabel", "^yellow;craft price:^reset;")
  end
  
end

function crafTextbox(widgetName, widgetData)
  local newAmount = tonumber(widget.getText("craftValue"))
  if self.craftAmount == 0 then
    widget.setText("craftValue", tostring(self.craftAmount))
  else
    self.craftAmount = tonumber(newAmount)
  end
end

function craftButton(widgetName, widgetData)

  setPrice()
  
  self.playerMoney = player.currency("money")
  
  if self.playerMoney > self.totalPrice then
    if player.consumeCurrency("money", self.totalPrice) then
	  local itemDescriptor = {}
      itemDescriptor.name = self.itemName
      itemDescriptor.count = self.craftAmount
      itemDescriptor.parameters = {}
      itemDescriptor.parameters.numberOfCars = self.numberOfCars
      itemDescriptor.parameters.trainsetData = {}
      itemDescriptor.parameters.trainsetData = deepcopy(self.trainSet)
	  itemDescriptor.parameters.stationControlled = false
	  --tprint(itemDescriptor)
	  --world.containerItemApply(pane.containerEntityId(), itemDescriptor, 1)
      --world.containerAddItems(pane.containerEntityId(), itemDescriptor)
      player.giveItem(itemDescriptor)
      
      widget.playSound(self.sounds.money)
	  
      hideCraftInteface()
	else
	  showNotEnoughMoneyDialog()
    end
  else
    showNotEnoughMoneyDialog()
  end
  
end

function showNotEnoughMoneyDialog()
  widget.setVisible("priceTotalLabel", false)
  widget.setVisible("pixelsIcon2", false)
  widget.setVisible("priceTotalValue", false)
  widget.setVisible("notEnoughMoneyLabel", true)
  widget.setVisible("craftButton", false)
  self.notEnoughMoneyDialogShown = true
  widget.playSound(self.sounds.error)
end

function displayCarData(TrainSetData, indexedTrainset, carNumber)

  if self.logging then sb.logInfo("\ndisplaycardata() car N " .. tostring(carNumber) .. "called") end

  local vehicleName = indexedTrainset[carNumber].vehicleName
  local hasPantograph = self.listOfCars[vehicleName].hasPantograph
  
  local hasDecals = self.listOfCars[vehicleName].hasDecals
  
  local color1Value = indexedTrainset[carNumber].currentColorIndex
  local color2Value = indexedTrainset[carNumber].currentCockpitColorIndex
  
  --widget.setVisible("saveCarButton", true)
  widget.setText("saveCarButtonPressed", "Save Car " .. tostring(carNumber))
  
  --setPreviewImage(carNumber, TrainSetData, false)
  setPreviewImg(getImages(carNumber, TrainSetData))
  
  widget.setVisible("CurrentCarNumberLabel", true)
  widget.setVisible("CurrentCarNumberValue", true)
  widget.setText("CurrentCarNumberValue", tostring(carNumber))
  
  widget.setVisible("priceLabel", true)
  widget.setVisible("priceValue", true)
  widget.setText("priceValue", tostring(self.listOfCars[vehicleName].price))
  
  widget.setVisible("carTypeSpinner", true)
  widget.setVisible("carTypeLabel", true)
  widget.setVisible("carTypeValue", true)
  widget.setText("carTypeValue", self.listOfCars[vehicleName].description)
  widget.setVisible("carDescLabel", true)
  widget.setVisible("scrollAreaDesc.carDescValue", true)
  widget.setVisible("copyCarButton", true)
  widget.setText("scrollAreaDesc.carDescValue", self.listOfCars[vehicleName].LongDescription)
  widget.setText("saveCarButton", "Save Car " .. tostring(self.editingCar))
  widget.setText("copyCarButton", "Copy Car " .. tostring(self.editingCar))
  
  widget.setVisible("color1Label", true)
  widget.setVisible("color1Spinner", true)
  widget.setVisible("color1Value", true)
  widget.setText("color1Value", tostring(color1Value))
  
  widget.setVisible("color2Label", true)
  widget.setVisible("color2Spinner", true)
  widget.setVisible("color2Value", true)
  widget.setText("color2Value", tostring(color2Value))
  
  showCraftInteface()
  
  if hasPantograph then
    widget.setVisible("pantographLabel", true)
    widget.setVisible("pantographCheckBox", true)
    widget.setChecked("pantographCheckBox", indexedTrainset[carNumber].pantographEnabled)
  end
  
  widget.setVisible("reversedLabel", true)
  widget.setVisible("reversedCheckBox", true)
  widget.setChecked("reversedCheckBox", indexedTrainset[carNumber].reversed)
  
  widget.setVisible("doorslockedLabel", true)
  widget.setVisible("doorslockedCheckBox", true)
  widget.setChecked("doorslockedCheckBox", indexedTrainset[carNumber].doorsLocked)
  
  if self.listOfCars[vehicleName].DisplayNames then
    widget.setText("color1Label", "^green;" .. self.listOfCars[vehicleName].DisplayNames.color .. "^reset;" or "^green;color1^reset;")
	widget.setText("color2Label", "^green;" .. self.listOfCars[vehicleName].DisplayNames.cockpit .. "^reset;" or "^green;color2^reset;")
  end

  if hasDecals then
    local numberOfDecals = #self.listOfCars[vehicleName].decalNames
	local decalsNames = self.listOfCars[vehicleName].decalNames
    local hideDecals = self.listOfCars[vehicleName].hideDecalsInConfigurator
	for i=1,tonumber(numberOfDecals) do
	  widget.setVisible("decal" .. tostring(i) .. "Label", true)
      widget.setVisible("decal" .. tostring(i) .. "Spinner", true)
      widget.setVisible("decal" .. tostring(i) .."Value", true)
	  local currentDecal = decalsNames[i]
      if hideDecals then
        for hd=1,#hideDecals do
          if hideDecals[hd] == currentDecal then
            widget.setVisible("decal" .. tostring(i) .. "Label", false)
            widget.setVisible("decal" .. tostring(i) .. "Spinner", false)
            widget.setVisible("decal" .. tostring(i) .."Value", false)
          end
        end
      end
	  local decalIndex = indexedTrainset[carNumber].currentDecalIndex[currentDecal]
	  widget.setText("decal" .. tostring(i) .."Value", tostring(decalIndex))
	  if self.listOfCars[vehicleName].DisplayNames.decals then
	    widget.setText("decal" .. tostring(i) .."Label", "^green;" .. self.listOfCars[vehicleName].DisplayNames.decals[currentDecal].. "^reset;" or ("^green;Decal" ..tostring(i) .. "^reset;" ))
	  end
	end
	for i=numberOfDecals+1,10 do
	  widget.setVisible("decal" .. tostring(i) .. "Label", false)
      widget.setVisible("decal" .. tostring(i) .. "Spinner", false)
      widget.setVisible("decal" .. tostring(i) .."Value", false)
	  widget.setText("decal" .. tostring(i) .."Value", " ")
	end
  end
  

end

function showCraftInteface()
 
  self.craftAmount = 1
  widget.setText("craftValue",self.craftAmount)
  widget.setVisible("craftButton", true)
  widget.setVisible("craftSpinner", true)
  widget.setVisible("craftValue", true)
  widget.setVisible("howMany", true)
  widget.setVisible("priceTotalLabel", true)
  widget.setVisible("pixelsIcon2", true)
  widget.setVisible("pixelsIcon2", true)
  widget.setVisible("priceTotalValue", true)
  
  setPrice()

end

function hideCraftInteface()

  self.craftAmount = 1
  widget.setText("craftValue",self.craftAmount)
  widget.setVisible("craftButton", false)
  widget.setVisible("craftSpinner", false)
  widget.setVisible("craftValue", false)
  widget.setVisible("howMany", false)

end

function hideEditCar()

  widget.setVisible("currentCarPreviewCockpit", false)
  widget.setVisible("currentCarPreviewBody", false)
  widget.setVisible("currentCarPreviewPantograph", false)
  for i=1,10 do
    widget.setVisible("currentCarPreviewDecal" .. tostring(i), false)
  end
  
  widget.setVisible("CurrentCarNumberLabel", false)
  widget.setVisible("CurrentCarNumberValue", false)
  widget.setVisible("carTypeSpinner", false)
  widget.setVisible("carTypeLabel", false)
  widget.setVisible("carTypeValue", false)
  widget.setVisible("carDescLabel", false)
  widget.setVisible("scrollAreaDesc.carDescValue", false)
  widget.setVisible("copyCarButton", false)
  widget.setVisible("discardButton", false)
  widget.setVisible("scrollAreaDesc.copyCarLabel", false)
  widget.setVisible("scrollAreaDesc.copyCarLabel1", false)
  widget.setVisible("scrollAreaDesc.cancelCopyButton", false)
  
  widget.setVisible("color1Label", false)
  widget.setVisible("color1Spinner", false)
  widget.setVisible("color1Value", false)

  widget.setVisible("color2Label", false)
  widget.setVisible("color2Spinner", false)
  widget.setVisible("color2Value", false)
  
  widget.setVisible("pantographLabel", false)
  widget.setVisible("pantographCheckBox", false)
  
  widget.setVisible("reversedLabel", false)
  widget.setVisible("reversedCheckBox", false)
  
  widget.setVisible("doorslockedLabel", false)
  widget.setVisible("doorslockedCheckBox", false)
  
  for i=1,10 do
    widget.setVisible("decal" .. tostring(i) .. "Label", false)
    widget.setVisible("decal" .. tostring(i) .. "Spinner", false)
    widget.setVisible("decal" .. tostring(i) .."Value", false)
  end
  
  widget.setVisible("saveCarButton", false)
  
  self.editingACar = false
end

function saveCarButtonPressed(widgetName, widgetData)

  self.trainSet = {}
  self.trainSet = deepcopy(self.trainsetTemp)
  self.trainsetIndexed = {}
  self.trainsetIndexed = trainsetToIndexes(self.trainSet)
  self.trainsetTemp = {}
  self.trainsetTemp = deepcopy(self.trainSet)
  self.IndexesTemp = {}
  self.IndexesTemp = trainsetToIndexes(self.trainSet)
  
  self.editingACar = false
  
  --reloadCaptions()
  hideEditCar()
  
  updatePane()
end

function debugButton(widgetName, widgetData)
  if world.containerItemAt(pane.containerEntityId(), 0) ~= nil then
    local item = world.containerItemAt(pane.containerEntityId(), 0)
    local itemConfig = root.itemConfig(item)
	--sb.logInfo("\nitemDescriptor ")
	--tprint(item)
	--sb.logInfo("\nitemConfig ")
	--tprint(itemConfig)
  else
    if self.logging then sb.logInfo(tostring("item slot looks kinda empty")) end
  end
  
  --if self.listOfCars then
    --sb.logInfo("\nself.listOfCars put into ")
    --sb.logInfo("\n/objects/crafting/trainConfigurator/listOfCars.json")
    --tprint(self.listOfCars)
  --else
    --sb.logInfo("\n failed to load /objects/crafting/trainConfigurator/listOfCars.json")
  --end
  if self.logging then
    sb.logInfo("\nself.trainset ")
    tprint(self.trainSet)
  end

  widget.setVisible("CurrentCarNumberLabel", true)
  widget.setVisible("CurrentCarNumberValue", true)
  widget.setVisible("carTypeSpinner", true)
  widget.setVisible("carTypeLabel", true)
  widget.setVisible("carTypeValue", true)
  widget.setVisible("carDescLabel", true)
  widget.setVisible("scrollAreaDesc.carDescValue", true)
  
  widget.setVisible("color1Label", true)
  widget.setVisible("color1Spinner", true)
  widget.setVisible("color1Value", true)

  widget.setVisible("color2Label", true)
  widget.setVisible("color2Spinner", true)
  widget.setVisible("color2Value", true)
  
  widget.setVisible("pantographLabel", true)
  widget.setVisible("pantographCheckBox", true)
  
  widget.setVisible("reversedLabel", true)
  widget.setVisible("reversedCheckBox", true)
  
  widget.setVisible("doorslockedLabel", true)
  widget.setVisible("doorslockedCheckBox", true)
  
  for i=1,10 do
    widget.setVisible("decal" .. tostring(i) .. "Label", true)
    widget.setVisible("decal" .. tostring(i) .. "Spinner", true)
    widget.setVisible("decal" .. tostring(i) .."Value", true)
  end
  
  widget.setVisible("saveCarButton", true)
  
  if self.editingCar then
    local vehicleName = self.trainSet[self.editingCar].name
    if self.logging then sb.logInfo("\nvehicle name " .. tostring(vehicleName)) end
    local previewImage = updateImage(self.editingCar)
    if self.logging then sb.logInfo("\npreview image " .. tostring(previewImage)) end
    local numberOfColors = #self.listOfCars[vehicleName].colors
    if self.logging then sb.logInfo("\nnumber of colors " .. tostring(numberOfColors)) end
    local numberOfCockpitColors = #self.listOfCars[vehicleName].cockpitColors
    if self.logging then sb.logInfo("\nnumber of cock;) pit colors " .. tostring(numberOfCockpitColors)) end
    local numberOfDecals = #self.listOfCars[vehicleName].decalNames
    if self.logging then sb.logInfo("\nnumber of decals " .. tostring(numberOfDecals)) end
    local colorsTable = self.listOfCars[vehicleName].colors
    if self.logging then 
      sb.logInfo("\ncolorstable ")
      tprint(colorsTable)
    end
    local cockpitColorsTable = self.listOfCars[vehicleName].cockpitColors
    if self.logging then 
      sb.logInfo("\ncock pit colors table ")
      tprint(cockpitColorsTable)
    end
    local decalsTable = self.listOfCars[vehicleName].decals
    if self.logging then 
      sb.logInfo("\ndecals table ")
      tprint(decalsTable)
    end
  end
  
end

function setListImgs(previewImgsArray, carNumber)
  widget.setVisible("scrollArea.car" .. tostring(carNumber) .. "Button", true)
  widget.setVisible("scrollArea.car" .. tostring(carNumber) .. "Body", true)
  widget.setVisible("scrollArea.car" .. tostring(carNumber) .. "Pantograph", true)
  widget.setButtonImage("scrollArea.car" .. tostring(carNumber) .. "Button", previewImgsArray.cockpitColor)
  widget.setImage("scrollArea.car" .. tostring(carNumber) .. "Body", previewImgsArray.color )
  widget.setImage("scrollArea.car" .. tostring(carNumber) .. "Pantograph", previewImgsArray.pantograph )
  for i=1,10 do
    widget.setVisible("scrollArea.car" .. tostring(carNumber) .. "Decal" .. tostring(i), true)
    widget.setImage("scrollArea.car" .. tostring(carNumber) .. "Decal" .. tostring(i), previewImgsArray["decal" .. tostring(i)])
  end
end

function setPreviewImg(previewImgsArray)
  widget.setVisible("currentCarPreviewCockpit", true)
  widget.setVisible("currentCarPreviewBody", true)
  widget.setVisible("currentCarPreviewPantograph", true)
  widget.setImage("currentCarPreviewCockpit", previewImgsArray.cockpitColor)
  widget.setImage("currentCarPreviewBody", previewImgsArray.color )
  widget.setImage("currentCarPreviewPantograph", previewImgsArray.pantograph )
  for i=1,10 do
    widget.setVisible("currentCarPreviewDecal" .. tostring(i), true)
    widget.setImage("currentCarPreviewDecal" .. tostring(i), previewImgsArray["decal" .. tostring(i)])
  end
end

function getImages(carNumber, TrainSetData)

  local vehicleName = TrainSetData[carNumber].name
  local color = TrainSetData[carNumber].color
  local cockpitColor = TrainSetData[carNumber].cockpitColor
  local reversed
  if TrainSetData[carNumber].reversed then
    reversed = "?flipx"
  else
    reversed = ""
  end
    
  local previewImgsArray = {}
  previewImgsArray.cockpitColor = self.paneImgPath .. vehicleName .. "/cockpit/" .. cockpitColor .. ".png" .. reversed
  previewImgsArray.color = self.paneImgPath .. vehicleName .. "/body/" .. color .. ".png" .. reversed
  
  local pantographCapable = self.listOfCars[vehicleName].hasPantograph
  if pantographCapable then
    local hasPantograph = TrainSetData[carNumber].pantographVisibile
	if hasPantograph then
	  previewImgsArray.pantograph = self.paneImgPath .. vehicleName .. "/pantograph/pantograph.png" .. reversed
	else
	  previewImgsArray.pantograph = self.paneImgPath .. "empty.png"
    end
  else
	previewImgsArray.pantograph = self.paneImgPath .. "empty.png"
  end
  
  local vehicleNameHasDecals = self.listOfCars[vehicleName].hasDecals
  
  if vehicleNameHasDecals then
    local decalnames = self.listOfCars[vehicleName].decalNames
    local decalsNumber = #decalnames
    local decalsTable = TrainSetData[carNumber].decals
	for k=1,decalsNumber do
	  local currentDecal = tostring(decalnames[k])
	  local currentDecalSprite = decalsTable[currentDecal]
      local renderdecal0 = self.listOfCars[vehicleName].decal0rendered[currentDecal]
	  if currentDecalSprite == 0 then
        if renderdecal0 then
          previewImgsArray["decal" .. tostring(k)] = self.paneImgPath .. vehicleName .. "/decal" .. currentDecal .. "/0.png" .. reversed
        else
          previewImgsArray["decal" .. tostring(k)] = self.paneImgPath .. "empty.png" 
        end
      else
	    previewImgsArray["decal" .. tostring(k)] = self.paneImgPath .. vehicleName .. "/decal" .. currentDecal .. "/" .. tostring(currentDecalSprite) .. ".png" .. reversed
      end	  
	end
	for i=(decalsNumber+1),10 do
	  previewImgsArray["decal" .. tostring(i)] = self.paneImgPath .. "empty.png" 
	end
  else
    for i=1,10 do
      previewImgsArray["decal" .. tostring(i)] = self.paneImgPath .. "empty.png"
	end
  end
  
  return previewImgsArray

end

function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function reloadCaptions()  
  widget.setImage("currentCarPreviewCockpit", self.paneImgPath .. "empty.png")
  widget.setImage("currentCarPreviewBody", self.paneImgPath .. "empty.png")
  widget.setImage("currentCarPreviewPantograph", self.paneImgPath .. "empty.png" )
  for i=1,10 do
    widget.setImage("currentCarPreviewDecal" .. tostring(i), self.paneImgPath .. "empty.png")
  end
  
  widget.setText("color1Value", " ")
  widget.setText("color2Value", " ")
  widget.setText("CurrentCarNumberValue", " ")
  widget.setText("carTypeValue", " ")
  widget.setText("scrollAreaDesc.carDescValue", " ")
  widget.setText("saveCarButtonPressed", "Save Car ")
  widget.setChecked("pantographCheckBox",false)
  widget.setChecked("reversedCheckBox", false)
  widget.setChecked("doorslockedCheckBox", false)
  for i=1,10 do
    widget.setVisible("decal" .. tostring(i) .."Value", false)
  end
 end
 
 function discardButton(widgetName, widgetData)
   discard()
 end
 
 function discard()
   if self.logging then sb.logInfo("\ndiscard function ") end
   --reloadCaptions()
   self.trainsetTemp = {}
   self.trainsetTemp = deepcopy(self.trainSet)
   self.trainsetIndexed = trainsetToIndexes(self.trainSet)
   self.IndexesTemp = {}
   self.IndexesTemp = deepcopy(self.trainsetIndexed)
   widget.setVisible("saveCarButton", false)
   widget.setVisible("discardButton", false)
   --hideEditCar()
   updatePane()
   displayCarData(self.trainSet, self.trainsetIndexed, self.editingCar)
   self.editingACar = false
 end
 
 function copyCarButtonPressed(widgetName, widgetData)

  self.carToCopy = self.editingCar
if not self.editingACar then  
  widget.setVisible("copyCarButton", false)
  widget.setVisible("discardButton", false)
  
  widget.setVisible("scrollAreaDesc.copyCarLabel", true)
  widget.setVisible("scrollAreaDesc.copyCarLabel1", true)
  widget.setVisible("scrollAreaDesc.cancelCopyButton", true)
  
  widget.setText("scrollAreaDesc.copyCarLabel", "^green;Copy car " .. self.carToCopy .." to?^reset;")
  self.carCopying = true
else
  widget.setVisible("copyCarButton", false)
  widget.setVisible("discardButton", false)
  self.carCopying = true
  displaySaveChangesWarning()
end
  
  widget.setVisible("carTypeSpinner", false)
  widget.setVisible("carTypeLabel", false)
  widget.setVisible("carTypeValue", false)
  widget.setVisible("carDescLabel", false)
  widget.setVisible("scrollAreaDesc.carDescValue", false)
  
  widget.setVisible("color1Label", false)
  widget.setVisible("color1Spinner", false)
  widget.setVisible("color1Value", false)

  widget.setVisible("color2Label", false)
  widget.setVisible("color2Spinner", false)
  widget.setVisible("color2Value", false)
  
  widget.setVisible("pantographLabel", false)
  widget.setVisible("pantographCheckBox", false)
  
  widget.setVisible("reversedLabel", false)
  widget.setVisible("reversedCheckBox", false)
  
  widget.setVisible("doorslockedLabel", false)
  widget.setVisible("doorslockedCheckBox", false)
  
  for i=1,10 do
    widget.setVisible("decal" .. tostring(i) .. "Label", false)
    widget.setVisible("decal" .. tostring(i) .. "Spinner", false)
    widget.setVisible("decal" .. tostring(i) .."Value", false)
  end
  
  widget.setVisible("saveCarButton", false)
  
end
 
function copyCar(source, destination)
  self.trainSet[destination] = deepcopy(self.trainSet[source])
  self.trainsetTemp = {}
  self.trainsetTemp = deepcopy(self.trainSet)
  self.trainsetIndexed = trainsetToIndexes(self.trainSet)
  self.IndexesTemp = {}
  self.IndexesTemp = deepcopy(self.trainsetIndexed)
  widget.setVisible("scrollAreaDesc.copyCarLabel", false)
  widget.setVisible("scrollAreaDesc.copyCarLabel1", false)
  widget.setVisible("scrollAreaDesc.cancelCopyButton", false)
  self.carCopying = false
  hideEditCar()
  updatePane()
end

function cancelCopyButton(widgetName, widgetData)
  widget.setVisible("scrollAreaDesc.copyCarLabel", false)
  widget.setVisible("scrollAreaDesc.copyCarLabel1", false)
  widget.setVisible("scrollAreaDesc.cancelCopyButton", false)
  self.carCopying = false
  displayCarData(self.trainSet, self.trainsetIndexed, self.editingCar)
end
 
 function displaySaveChangesWarning()
  widget.setVisible("copyCarButton", false)
  widget.setVisible("discardButton", false)
  
  widget.setVisible("scrollAreaDesc.discardCarLabel", true)
  widget.setVisible("scrollAreaDesc.cancel1Button", true)
  widget.setVisible("scrollAreaDesc.saveAndSwitchButton", true)
  
  if self.carCopying then
    widget.setText("scrollAreaDesc.discardCarLabel", "^red;Save changes to car " .. tostring(self.editingCar) .. " Before copying^reset;")
  else
    widget.setText("scrollAreaDesc.discardCarLabel", "^red;Save changes to car " .. tostring(self.editingCar) .. "?^reset;")
  end
  widget.setText("scrollAreaDesc.saveAndSwitchButton", "Save car " .. tostring(self.editingCar) )
  
  widget.setVisible("carTypeSpinner", false)
  widget.setVisible("carTypeLabel", false)
  widget.setVisible("carTypeValue", false)
  widget.setVisible("carDescLabel", false)
  widget.setVisible("scrollAreaDesc.carDescValue", false)
  
  widget.setVisible("color1Label", false)
  widget.setVisible("color1Spinner", false)
  widget.setVisible("color1Value", false)

  widget.setVisible("color2Label", false)
  widget.setVisible("color2Spinner", false)
  widget.setVisible("color2Value", false)
  
  widget.setVisible("pantographLabel", false)
  widget.setVisible("pantographCheckBox", false)
  
  widget.setVisible("reversedLabel", false)
  widget.setVisible("reversedCheckBox", false)
  
  widget.setVisible("doorslockedLabel", false)
  widget.setVisible("doorslockedCheckBox", false)
  
  for i=1,10 do
    widget.setVisible("decal" .. tostring(i) .. "Label", false)
    widget.setVisible("decal" .. tostring(i) .. "Spinner", false)
    widget.setVisible("decal" .. tostring(i) .."Value", false)
  end
  
  widget.setVisible("saveCarButton", false)
 end
 
 function cancel1Button(widgetName, widgetData)
   widget.setVisible("scrollAreaDesc.discardCarLabel", false)
   widget.setVisible("scrollAreaDesc.cancel1Button", false)
   widget.setVisible("scrollAreaDesc.saveAndSwitchButton", false)
   if self.carCopying then
     displayCarData(self.trainsetTemp, self.IndexesTemp, self.editingCar)
   else
     discard()
     carSelect("car" .. tostring(self.newCar) .. "Button")
   end
   widget.setVisible("saveCarButton", true)
   widget.setVisible("discardButton", true)
 end
 
 function carSelect(widgetName)
   if not self.editingACar then
     self.editingCar = tonumber(string.sub(widgetName, 4, (string.len(widgetName) -6) ) )
     if not self.carCopying then
       discard()
       displayCarData(self.trainSet, self.trainsetIndexed, self.editingCar)
     else
       copyCar(self.carToCopy, self.editingCar)
     end
   else
     self.newCar = tonumber(string.sub(widgetName, 4, (string.len(widgetName) -6) ) )
     displaySaveChangesWarning()
   end
 end
 
 function saveAndSwitchButton(widgetName, widgetData)
   if not self.carCopying then
     self.editingCar = self.newCar
     self.editingACar = false
     widget.setVisible("scrollAreaDesc.discardCarLabel", false)
     widget.setVisible("scrollAreaDesc.cancel1Button", false)
     widget.setVisible("scrollAreaDesc.saveAndSwitchButton", false)
     saveCarButtonPressed()
     carSelect("car" .. self.editingCar .. "Button")
   else
     self.editingACar = false
     widget.setVisible("scrollAreaDesc.discardCarLabel", false)
     widget.setVisible("scrollAreaDesc.cancel1Button", false)
     widget.setVisible("scrollAreaDesc.saveAndSwitchButton", false)
	 saveCarButtonPressed()
	 copyCarButtonPressed()
   end
 end

function car1Button(widgetName, widgetData)
  carSelect(widgetName)
  --widget.setButtonOverlayImage("scrollArea.car1Button", "/interface/linkedTrain/trainConfigurator/SubwayTram-linked/SubwayTram-linkedwhiteA0Ppreview.png")
end

function car2Button(widgetName, widgetData)
  carSelect(widgetName)
end

function car3Button(widgetName, widgetData)
  carSelect(widgetName)
end

function car4Button(widgetName, widgetData)
  carSelect(widgetName)
end

function car5Button(widgetName, widgetData)
  carSelect(widgetName)
end

function car6Button(widgetName, widgetData)
  carSelect(widgetName)
end

function car7Button(widgetName, widgetData)
  carSelect(widgetName)
end

function car8Button(widgetName, widgetData)
  carSelect(widgetName)
end

function car9Button(widgetName, widgetData)
  carSelect(widgetName)
end

function car10Button(widgetName, widgetData)
  carSelect(widgetName)
end

-- Print contents of "tbl", with indentation.
-- "indent" sets the initial level of indentation.
function tprint(tbl, indent) --debug purposes
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    local formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      sb.logInfo(tostring(formatting))
      tprint(v, indent+1)
    else
      sb.logInfo(tostring(formatting) .. tostring(v))
    end
  end
end