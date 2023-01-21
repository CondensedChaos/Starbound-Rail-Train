function init()

  object.setInteractive(true)
  
  storage.stopLenght = (config.getParameter("stopLenght", 7))


  self.countdown = 0
  
  if storage.state == nil then
	storage.state = false
	object.setOutputNodeLevel(1, true)
  else
    object.setOutputNodeLevel(0, not storage.state)
	self.t0 = world.time()
	object.setOutputNodeLevel(1, true)
  end
  
  
  --if self.uuidtimer0 == nil then
    --self.uuidtimer0 = world.time()
	--self.uuidtimerBool = true
  --end
  
  self.uuidInit = true
  
  message.setHandler("forceReloadData", forceReloadData)
  
  message.setHandler("saveSlottedItems", saveSlottedItems)
  
  --message.setHandler("forceReloadData", function(_, _)
    --storage.saveFile = world.getProperty("stationController_file")
	--sb.logInfo("FORCING DATA RELOAD: ")
	--sb.logInfo("SAVE FILE AS FOLLOWS: ")
	--if storage.saveFile then tprint(storage.saveFile) end
  --end)
  
end

function forceReloadData(_,_)
  storage.saveFile = world.getProperty("stationController_file")
  sb.logInfo("FORCING DATA RELOAD: ")
  local oldnumber = self.stationNum
  self.stationNum = storage.saveFile[storage.uuid].number
  if self.stationNum == oldnumber then
    sb.logInfo("STATION NUMBER " .. tostring(self.stationNum))
  else
    sb.logInfo("STATION NUMBER " .. tostring(oldnumber) .. "IS NOW NUMBER " .. tostring(self.stationNum))
  end
  sb.logInfo("SAVE FILE AS FOLLOWS: ")
  
  if storage.saveFile[storage.uuid].grouped then
    storage.group = storage.saveFile[storage.uuid].group
	storage.grouped = true
	storage.numInGroup = storage.saveFile[storage.group][storage.uuid].number
  end
  if storage.saveFile then tprint(storage.saveFile) end
end

function saveSlottedItems(_,_, slot, item)
  storage.slottedItem = item
  sb.logInfo("item saved ")
  if storage.slottedItem then tprint(storage.slottedItem) end
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

   if self.uuidInit then
     if storage.uuid == nil then
	   storage.uuid = sb.makeUuid()
	   world.setUniqueId(entity.id(), storage.uuid)
	 end
     sb.logInfo("UUID OF STATION (entity ID " .. tostring(entity.id()) .. ") " .. tostring(world.entityUniqueId(entity.id())))
	 sb.logInfo("ATTEMPTING TO GET ENTITY ID FROM UUID : " .. tostring(world.loadUniqueEntity(storage.uuid)))
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
             local id = world.loadUniqueEntity(tostring(storage.saveFile[tostring(i)].uuid))
			 --sb.logInfo("ENTITY ID OF " .. tostring(i) .. " IS " .. tostring(id) .. " UUID IS " .. tostring(storage.saveFile[tostring(i)].uuid))
	         if id then
	           if world.entityExists(id) then
	             world.sendEntityMessage(id, "forceReloadData")
		         --world.callScriptedEntity(id, "forceReloadData")
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
	 self.uuidInit = false
   end

  --if self.uuidtimerBool then
    --self.uuidtimer = world.time() - self.uuidtimer0
  --end
  
  --if (self.uuidtimer >= 10) and self.uuidtimerBool then
    --storage.uuid = sb.makeUuid()
    --world.setUniqueId(entity.id(), storage.uuid)
	--sb.logInfo("UUID OF  STATION" .. tostring(world.entityUniqueId(entity.id())))
	--self.uuidtimerBool = false
  --end

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