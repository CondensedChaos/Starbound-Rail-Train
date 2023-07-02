require "/scripts/rect.lua"

function init()
  self.listOfCars = root.assetJson("/objects/crafting/trainConfigurator/listOfCars.json")
  self.settingsConfig = root.assetJson("/interface/linkedTrain/trainConfigurator/settings.json")
  self.logging = self.settingsConfig.logging
  
  self.placementRange = config.getParameter("placementRange")
  self.placementBounds = config.getParameter("placementBounds")
  --self.platformType = config.getParameter("platformType")
  self.imgPath = config.getParameter("imgPath")
  --self.trainsetData = { { name= "SubwayTram-linked", carNumber= 1, color= "cyan", cockpitColor= "red", pantographVisibile= true,  doorLocked= false, reversed= false, carDistance= 22.75, decalNames= {"A"}, decals= {A= 0} }, { name= "SubwayTram-linked", carNumber= 2, color= "cyan", cockpitColor= "red", pantographVisibile= false,  doorLocked= false, reversed= false, carDistance= 22.75, decalNames= {"A"}, decals= {A= 0} }, { name= "SubwayTram-linked", carNumber= 3, color= "cyan", cockpitColor= "red", pantographVisibile= true,  doorLocked= false, reversed= true, carDistance= 22.75, decalNames= {"A"}, decals= {A= 0} } }
  
  self.defaultTrainset = self.settingsConfig.defaultTrainset
  self.itemName = self.settingsConfig.itemName
  self.numberOfCars = config.getParameter("numberOfCars")
  
  self.trainsetData = config.getParameter("trainsetData", self.defaultTrainset)
  
  if not self.trainsetData then
    self.trainsetData = self.defaultTrainset
  end
  self.numberOfCars = (#self.trainsetData)
  --sb.logInfo(tostring(self.numberOfCars))
  self.platformType = self.trainsetData[1].name
  --sb.logInfo(tostring(self.platformType))
  
  for i=1,self.numberOfCars do
    self.trainsetData[i].fistCar = (i == 1)
	self.trainsetData[i].lastCar = (i == self.numberOfCars)
	self.trainsetData[i].carNumber = i
  end
  
  --tprint(self.trainsetData)
  
  --self.previewImgsArray{ body,cockpit,pantograph,decal1, .. decalN}, {body,cockpit,pantograph,decal1, .. decalN} } ={ {car1data}, {car2data} }
  
  self.previewImgsArray = {}
  offsets = {}
  flipTable = {}
  
  for i=1,self.numberOfCars do
    
    flipTable[i] = {true,true,true}	
	
    self.previewImgsArray[i] = {}
    local vehicleName = self.trainsetData[i].name
	--sb.logInfo(tostring(vehicleName))
    local color = self.trainsetData[i].color
	--sb.logInfo(tostring(color))
	local cockpitColor = self.trainsetData[i].cockpitColor
	--sb.logInfo(tostring(cockpitColor))
	--local StringBaseImage = tostring(self.imgPath) .. tostring(vehicleName) .. tostring(color)
	
	self.previewImgsArray[i][1] = tostring(self.imgPath) .. tostring(vehicleName) .. "/body/" .. tostring(color) .. ".png"
	--sb.logInfo(self.previewImgsArray[i][1])
	self.previewImgsArray[i][2] = tostring(self.imgPath) .. tostring(vehicleName) .. "/cockpit/" .. tostring(cockpitColor) .. ".png"
	--sb.logInfo(self.previewImgsArray[i][2])
	
	local hasPantograph = self.trainsetData[i].pantographVisibile
	if hasPantograph then
	  self.previewImgsArray[i][3] = tostring(self.imgPath) .. tostring(vehicleName) .. "/pantograph/pantograph.png"
	else
      self.previewImgsArray[i][3] = tostring(self.imgPath) .. "empty.png"
	end
	--sb.logInfo(self.previewImgsArray[i][3])
	
	local vehicleNameHasDecals = self.listOfCars[vehicleName].hasDecals
    if vehicleNameHasDecals then
	  local decalnames = self.trainsetData[i].decalNames
	  local numberOfDecals = #decalnames
	  local decalsTable = self.trainsetData[i].decals
	  local decalsFlippableTable = self.listOfCars[vehicleName].decalsFlippable
	  local decalsIndexes = self.listOfCars[vehicleName].decals
	  
	  for j=1,numberOfDecals do
		currentDecal = decalnames[j]
		currentDecalSprite = decalsTable[currentDecal]
        local renderdecal0 = self.listOfCars[vehicleName].decal0rendered[currentDecal]
		if currentDecalSprite == "0" then
          if renderdecal0 then
            self.previewImgsArray[i][3+j] = tostring(self.imgPath) .. tostring(vehicleName) .. "/decal" .. tostring(currentDecal) .. "/0.png"
          else
            self.previewImgsArray[i][3+j] = tostring(self.imgPath) .. "empty.png"
          end
		else
		  self.previewImgsArray[i][3+j] = tostring(self.imgPath) .. tostring(vehicleName) .. "/decal" .. tostring(currentDecal) .. "/" .. tostring(currentDecalSprite) .. ".png"
		end
		--sb.logInfo(self.previewImgsArray[i][3+j])
		flipTable[i][3+j] = decalsFlippableTable[currentDecal][indexOf(decalsIndexes[currentDecal], currentDecalSprite)]
	  end
	  for j=numberOfDecals+1,10 do
	    self.previewImgsArray[i][3+j] = tostring(self.imgPath) .. "empty.png"
		flipTable[i][3+j] = true
		--sb.logInfo(self.previewImgsArray[i][3+j])
	  end
	else
	  for j=1,10 do
	    self.previewImgsArray[i][3+j] = tostring(self.imgPath) .. "empty.png"
		flipTable[i][3+j] = true
	  end
    end
	--sb.logInfo("FLIPTABLE ================")
	--tprint(flipTable)
	
	if i ~= self.numberOfCars then
	  local thisVehicle = self.trainsetData[i].name
      local childVehicle = self.trainsetData[i + 1].name
	  local thisVehiclePxLen = tonumber(self.listOfCars[thisVehicle].carLenghtPixels)
	  local childVehiclePxLen = tonumber(self.listOfCars[childVehicle].carLenghtPixels)
	  offsets[i] = ( ((thisVehiclePxLen/2) + (childVehiclePxLen / 2)) / 8) + 1
	else
	  offsets[i] = 0
	end
	
	--offsets[i] = self.trainsetData[i].carDistance

  end
  
  activeItem.setScriptedAnimationParameter("previewImages", self.previewImgsArray)
  activeItem.setScriptedAnimationParameter("offsets", offsets)
  activeItem.setScriptedAnimationParameter("flipTable", flipTable)
  
  activeItem.setScriptedAnimationParameter("numberOfCars", self.numberOfCars)
  
  --activeItem.setScriptedAnimationParameter("previewImage", config.getParameter("placementPreviewImage"))
  --activeItem.setScriptedAnimationParameter("trainsetData", self.trainsetData
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

function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function activate(fireMode, shiftHeld)
  local placePos = activeItem.ownerAimPosition()
  local parameters = {}
  local vehicleName = self.trainsetData[1].name
  
  parameters.cockpitColor =  self.trainsetData[1].cockpitColor
  
  parameters.initialFacing = mcontroller.facingDirection()

  parameters.numberOfCars = self.numberOfCars
  parameters.popItem = self.itemName

  parameters.color = self.trainsetData[1].color
  parameters.decalNames = self.trainsetData[1].decalNames
  parameters.decals = self.trainsetData[1].decals
  parameters.pantographVisible = self.trainsetData[1].pantographVisibile
  parameters.doorLocked = self.trainsetData[1].doorLocked
  parameters.trainsetData = self.trainsetData
  parameters.specular = self.listOfCars[vehicleName].specular
  parameters.reversed = self.trainsetData[1].reversed
  
  parameters.firstCar = true
  parameters.lastcar = false
  parameters.carNumber = 1
  
  if placementValid(placePos) then
    world.spawnVehicle(vehicleName, placePos, parameters)
    item.consume(1)
  end
end

function update(dt, fireMode, shiftHeld)
  local placePos = activeItem.ownerAimPosition()
  placePos[2] = placePos[2] + (self.listOfCars[self.trainsetData[1].name].carHeightPixels / 16 )
  activeItem.setScriptedAnimationParameter("previewPosition", placePos)
  activeItem.setScriptedAnimationParameter("previewValid", placementValid(placePos))
  activeItem.setScriptedAnimationParameter("numberOfCars", self.numberOfCars)

  local aimAngle, aimDirection = activeItem.aimAngleAndDirection(0, placePos)
  activeItem.setFacingDirection(aimDirection)
  activeItem.setScriptedAnimationParameter("facing", aimDirection)
end

function placementValid(pos)
  if world.isTileProtected(pos) then return false end

  if world.magnitude(mcontroller.position(), pos) > self.placementRange then return false end

  if world.lineCollision(mcontroller.position(), pos, {"Null", "Block", "Dynamic"}) then return false end

  local placementRect = rect.translate(self.placementBounds, pos)
  return not world.rectCollision(placementRect, {"Null", "Block", "Dynamic"})
end
