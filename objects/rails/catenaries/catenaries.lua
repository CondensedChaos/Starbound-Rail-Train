function init()
  if not storage.chunk then
	local pos = entity.position()
	storage.chunk = {}
	storage.chunk[1] = pos[1]-20
	storage.chunk[2] = pos[2]-2
	storage.chunk[3] = pos[1]+20
	storage.chunk[4] = pos[2]+10
  end
end

function update(dt)
  --if not world.regionActive(storage.chunk) then
	--world.loadRegion(storage.chun )
  --end
  world.loadRegion(storage.chunk)
end