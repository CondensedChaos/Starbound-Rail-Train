function init()

end

function update(dt)

end


function loadBackupFileButtonPressed()
  self.saveFile = world.getProperty("stationController_file_backup")
  world.setProperty("stationController_file", self.saveFile)
  tprint(selfsavefile)
end
function saveBackupFileButtonPressed()
  world.setProperty("stationController_file_backup", self.saveFile)
end