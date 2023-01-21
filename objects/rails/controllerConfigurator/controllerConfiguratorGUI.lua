function init()
  
end

function update(dt)

  if world.containerItemAt(pane.containerEntityId(), 0) == nil then
    widget.setVisible("ErrorLabel1", false)
	widget.setVisible("Edit1Label", true)
	widget.setVisible("Edit2Label", true)
	widget.setVisible("linkButton", false)
	widget.setVisible("groupStationsButton", true)
	self.itemPresent = false
  end

  if world.containerItemAt(pane.containerEntityId(), 0) then
  local item = world.containerItemAt(pane.containerEntityId(), 0)
  local itemConfig = root.itemConfig(item)
    if (itemConfig.config.category == "railPlatform") and (itemConfig.config.linkedRailTrain == true) then
	  self.itemValid = true
	  self.itemPresent = true
	  widget.setVisible("ErrorLabel1", false)
	  widget.setVisible("Edit1Label", true)
	  widget.setVisible("Edit2Label", true)
	  widget.setVisible("linkButton", true)
	  widget.setVisible("groupStationsButton", false)
      --local item = world.containerItemAt(pane.containerEntityId(), 0)
    else
	   widget.setVisible("ErrorLabel1", true)
	   widget.setVisible("linkButton", false)
	   widget.setVisible("Edit1Label", false)
	   widget.setVisible("Edit2Label", false)
	   widget.setVisible("groupStationsButton", false)
	   self.itemValid = false
	   self.itemPresent = true
    end
  end
  
end

function linkButtonPressed(widgetName, widgetData)
  local item = world.containerItemAt(pane.containerEntityId(), 0)
  
  item.parameters.stationControlled = true
  item.parameters.stationGroupUUID = ""
  
  world.containerTakeAt(pane.containerEntityId(), 0)
  world.containerItemApply(pane.containerEntityId(), item, 0)
  
end

function unlinkButtonPressed(widgetName, widgetData)
  
end

function groupStationsButtonPresse(widgetName, widgetData)
  
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