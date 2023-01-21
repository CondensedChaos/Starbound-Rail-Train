require "/scripts/util.lua"

function init()
  if not storage.chunk then
	local pos = entity.position()
	storage.chunk = {}
	storage.chunk[1] = pos[1]-20
	storage.chunk[2] = pos[2]-2
	storage.chunk[3] = pos[1]+20
	storage.chunk[4] = pos[2]+10
  end
  self.resumeSpeed = config.getParameter("resumeSpeed")
  
  local override = object.getInputNodeLevel(0)
  if override == true then
    object.setMaterialSpaces({{{0, 0}, "metamaterial:rail"}})
    animator.setAnimationState("stopState", "off")
  else
    object.setMaterialSpaces({{{0, 0}, "metamaterial:railbooster"}})
    animator.setAnimationState("stopState", "on")
  end
end

function update(dt)
  --if not world.regionActive(storage.chunk) then
	--world.loadRegion(storage.chunk )
  --end
  world.loadRegion(storage.chunk)
end

function nodePosition()
  return util.tileCenter(entity.position())
end

function onInputNodeChange()
  local override = object.getInputNodeLevel(0)
  
  if override == true then
    object.setMaterialSpaces({{{0, 0}, "metamaterial:rail"}})
    animator.setAnimationState("stopState", "off")
  else
    object.setMaterialSpaces({{{0, 0}, "metamaterial:railbooster"}})
    animator.setAnimationState("stopState", "on")
  end
end

function die()
  notifyStoppedEntities()
end

function notifyStoppedEntities()
  local ppos = nodePosition()
  local inStation = world.entityQuery({ppos[1] - 2.5, ppos[2] - 2.5}, {ppos[1] + 2.5, ppos[2] + 2.5}, { includedTypes = { "mobile" }, boundMode = "metaboundbox" })
  for _, id in pairs(inStation) do
    -- sb.logInfo("telling %s to resume", id)
    world.sendEntityMessage(id, "railResume", ppos, self.resumeSpeed)
  end
end
