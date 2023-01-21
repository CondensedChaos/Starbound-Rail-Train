local_storage = {}

function init()

  --When the panel inits we read in the list of slots that need to be emptied on close
  local_storage.slotsToRefund = config.getParameter("refundOnClose",{})

  self.saveFile = world.getProperty("stationController_file")
  self.uuid = config.getParameter("uuid")
  self.slottedItem = config.getParameter("slottedItem")
  
  self.widgetListName = "addStationOverlay.stationsScrollArea.stationsList"
  
  widget.setVisible("mainOverlay", true)
  
  widget.setVisible("mainOverlay.itemslot1", true)
  widget.setVisible("mainOverlay.Edit1Label", true)
  widget.setVisible("mainOverlay.Edit2Label", true)
  
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
	
	if self.slottedItem then
	  widget.setVisible("mainOverlay.unlinkButton", true)
	  widget.setVisible("mainOverlay.linkButton", false)
	  widget.setVisible("mainOverlay.Edit1Label", false)
	  widget.setVisible("mainOverlay.Edit2Label", false)
	  widget.setVisible("mainOverlay.itemslot1", false)
	end
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

  if not self.slottedItem then
    local slottedItem = widget.itemSlotItem("mainOverlay.itemslot1")
    if slottedItem then
      local itemConfig = root.itemConfig(slottedItem)
	  if (itemConfig.config.category == "railPlatform") and (itemConfig.config.linkedRailTrain == true) then
	    widget.setVisible("mainOverlay.linkButton", true)
	    widget.setVisible("mainOverlay.Edit1Label", true)
	    widget.setVisible("mainOverlay.Edit2Label", true)
	  else
	    widget.setVisible("mainOverlay.linkButton", false)
	    widget.setVisible("mainOverlay.ErrorLabel1", true)
	    widget.setVisible("mainOverlay.Edit1Label", false)
	    widget.setVisible("mainOverlay.Edit2Label", false)
	  end
    else
	  widget.setVisible("mainOverlay.linkButton", false)
	  widget.setVisible("mainOverlay.ErrorLabel1", false)
	  widget.setVisible("mainOverlay.Edit1Label", true)
	  widget.setVisible("mainOverlay.Edit2Label", true)
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
	
	if self.saveFile.global.numOfGroups > 0 then
	  widget.setVisible("groupsOverlay.addToExistingGroupButton", true)
	else
	  widget.setVisible("groupsOverlay.addToExistingGroupButton", false)
	end
  else
    local groupName = self.saveFile[self.uuid].group
	local numInGroup = self.saveFile[groupName][self.uuid].number
	
	self.groupEditing = groupName
	
	widget.setVisible("groupsOverlay.changeNumInGroupButton", true)
	
	widget.setVisible("groupsOverlay.membersInGroupLabel", true)
	widget.setVisible("groupsOverlay.membersInGroupValue", true)
	widget.setText("groupsOverlay.membersInGroupLabel", "Members of group " .. "^green;" .. groupName .. "^reset; (in order):")
	
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
  world.setProperty("stationController_file", self.saveFile)
  world.sendEntityMessage(pane.sourceEntity(), "forceReloadData")
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
  
  tprint(self.saveFile)
  
  world.setProperty("stationController_file", self.saveFile)
  self.saveFile = world.getProperty("stationController_file")
  
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

  slot_widget = "mainOverlay.itemslot1"
  
  local slottedItem = widget.itemSlotItem(slot_widget)
  self.saveFile = world.getProperty("stationController_file")
  slottedItem.parameters.stationControlled = true
  slottedItem.parameters.stationGroup = self.saveFile[self.uuid].group
  slottedItem.parameters.stationuuid = self.uuid
  local slotNumber = tonumber(string.sub(slot_widget, string.len(slot_widget), string.len(slot_widget)))
  world.sendEntityMessage(pane.sourceEntity(), "saveSlottedItems", slotNumber, slottedItem)
  self.slottedItem = slottedItem
  widget.setItemSlotItem(slot_widget, nil)
  
end

function unlinkButtonPressed(widgetName, widgetData)
  self.slottedItem.parameters.stationControlled = false
  self.slottedItem.parameters.stationGroup = nil
  self.slottedItem.parameters.stationuuid = nil
  sb.logInfo("SLOTTED ITEM ")
  tprint(self.slottedItem)
  player.setSwapSlotItem(self.slottedItem)
  self.slottedItem = nil
  world.sendEntityMessage(pane.sourceEntity(), "saveSlottedItems", 1, nil)
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
  
end

function renameStationButtonPressed(widgetName, widgetData)
  
end

function manageOtherGroupsButtonPressed(widgetName, widgetData)
  
end

function ExitGroupButtonPressed(widgetName, widgetData)
  
end

function groupNameError(kind)
  
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

   slot_widget = "mainOverlay" .. "." .. slot_widget
    
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

    slot_widget = "mainOverlay" .. "." .. slot_widget
  
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