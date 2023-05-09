function init()
  self.resumeSpeed = config.getParameter("resumeSpeed")
end

function updateActive()

end

function onInputNodeChange()

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
