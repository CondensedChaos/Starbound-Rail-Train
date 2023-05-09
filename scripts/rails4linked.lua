require "/scripts/util.lua"
require "/scripts/vec2.lua"

Rails = {}

-- fake enum for sensible direction names
Rails.dirs = {
  e = 1,
  ne = 2,
  n = 3,
  nw = 4,
  w = 5,
  sw = 6,
  s = 7,
  se = 8
}

-- vectors corresponding to the above directions
Rails.dirVectors = {
  {1, 0},
  {1, 1},
  {0, 1},
  {-1, 1},
  {-1, 0},
  {-1, -1},
  {0, -1},
  {1, -1}
}

-- directions to search when finding next node on a rail
Rails.standardSearchOrder = { 0, -1, 1, -2, 2 }

-- directions to search when we don't have a reliable direction, e.g. when falling
Rails.fullSearchOrder = { 0, -1, 1, -2, 2, -3, 3, 4 }

-- convert a direction name to a direction index if necessary
function Rails.direction(dir)
  if type(dir) == "string" then
    return Rails.dirs[string.lower(dir)]
  else
    return dir
  end
end

-- distance (if any) by which an entity at the startPos moving at speed will cross the tarPos
-- assumes that we're traveling directly toward the target
function Rails.crossDist(tarPos, startPos, speed)
  local toTarget = world.magnitude(startPos, tarPos)
  if toTarget <= speed then
    return speed - toTarget
  end
end

-- instantiate a moving entity that follows rails. this should work for any entity with either
-- a movement controller or an actor movement controller and access to root and world bindings
function Rails.createRider(riderConfig)
  local defaults = {
    railTypes = root.assetJson("/rails.config"),
    connectionOffset = {0, 0},
    speed = 10,
    direction = Rails.dirs.e,
    useGravity = false,
    gravity = 100,
    gravityMultiplier = 0.75,
    moving = true,
    facing = 1,
    crossedObjects = {},
    -- callbacks
    onEngage = nil,
    onDisengage = nil
  }

  local Rider = util.mergeTable(defaults, riderConfig)

  function Rider:init(restoreStateData)
    -- listen for resume messages e.g. from rail stop objects
    message.setHandler("railResume", function(_, _, pos, vel, dir)
      return self:railResume(pos, vel, dir)
    end)

    -- store this because if the rider uses gravity, the speed will be mutated
    self.baseSpeed = self.speed

    -- optionally restore the data exported by stateData()
    if restoreStateData then
      self.speed = restoreStateData.speed
      self.direction = restoreStateData.direction
      self.facing = restoreStateData.facing
      self.moving = restoreStateData.moving
      self.nextNode = restoreStateData.nextNode
      self.lastNode = restoreStateData.lastNode
      self.onRailType = restoreStateData.onRailType

      -- make sure we don't fall during the first frame if stopped
      self:applyGravity()
    else
      self.direction = Rails.direction(self.direction)
    end

    self.lastFallCheck = vec2.floor(self:position())
    self:updateGravity()
  end

  -- export data used to restore state when the entity is reinstantiated
  function Rider:stateData()
    return {
      speed = self.speed,
      direction = self.direction,
      facing = self.facing,
      moving = self.moving,
      nextNode = self.nextNode,
      lastNode = self.lastNode,
      onRailType = self.onRailType
    }
  end

  function Rider:reset()
    self:setNextNode(nil)
    self.lastNode = nil
    self.lastFallCheck = vec2.floor(self:position())
    self:updateGravity()
  end

  function Rider:update(dt)
    if self.moving then
      -- if we don't have any active nodes, we're falling
      if not self.nextNode and not self.lastNode then
        -- choose the nearest appropriate rail direction based on our falling velocity
        local vel = mcontroller.velocity()
        local angle = math.atan(vel[2], vel[1])
        local dir = math.floor(((4 * angle) / math.pi) + 0.5) % 8 + 1
        if dir == 7 then
          -- never face straight down since we need to bias direction when falling onto horizontal rails
          if vel[1] == 0 then
            dir = self.facing < 0 and 6 or 8
          else
            dir = vel[1] < 0 and 6 or 8
          end
        end
        self.direction = dir

        -- check for rails at any tiles we cross and attempt to snap onto them
        local pos = vec2.floor(self:position())
        if not vec2.eq(pos, self.lastFallCheck) then
          -- if we might cross multiple tiles, use a more thorough search
          if vec2.mag(vel) >= 1.0 / dt then
            local searchSet = world.collisionBlocksAlongLine(self.lastFallCheck, pos, {"None"})
            if #searchSet >= 2 then
              for i = 2, #searchSet do
                -- search inclusively to avoid passing through diagonal rails
                if searchSet[i][1] ~= searchSet[i - 1][1] and searchSet[i][2] ~= searchSet[i - 1][2] then
                  if self:findInitialNode({searchSet[i - 1][1], searchSet[i][2]}) then
                    break
                  end
                end

                if self:findInitialNode(searchSet[i]) then
                  break
                end
              end
            end
          else
            if not self:findInitialNode(pos) then
              -- search inclusively to avoid passing through diagonal rails
              if pos[1] ~= self.lastFallCheck[1] and pos[2] ~= self.lastFallCheck[2] then
                self:findInitialNode({self.lastFallCheck[1], pos[2]})
              end
            end
          end
          self.lastFallCheck = pos
        end
      end

      -- complete previous node if necessary
      if self.lastNode then
        if self.lastNode.type == "end" then
          self.onRailType = nil
          self.lastFallCheck = vec2.floor(self:position())

          -- trigger disengage callback
          if self.onDisengage then self:onDisengage() end
        elseif self.lastNode.type == "stop" then
          -- double check to make sure there's still a rail stop here (and that it's still stopped)
          if self:checkTile(self.lastNode.position) == "metamaterial:railstop" then
            mcontroller.setVelocity({0, 0})
            self.moving = false
          else
            self:railResume(self.lastNode.position)
          end
        elseif self.lastNode.type == "reverse" then
          self.direction = (self.direction + 3) % 8 + 1
          self:findNextNode(vec2.add(self.lastNode.position, Rails.dirVectors[self.direction]), self.lastNode.direction, self.direction)
        end

        self.lastNode = nil
      end

      -- notify any objects we crossed this tick
      for _, objectId in pairs(self.crossedObjects) do
        world.sendEntityMessage(objectId, "railRiderPresent")
      end
      self.crossedObjects = {}

      -- determine which nodes we'll cross next tick
      if self.nextNode then
        if self.nextNode.type ~= "stop" then
          world.debugLine(self.nextNode.position, vec2.add(self.nextNode.position, Rails.dirVectors[self.nextNode.direction]), "cyan")
        end
        world.debugPoint(self.nextNode.position, "blue")

        -- calculate speed change due to gravity and friction if applicable
        if self.useGravity and self.onRailType then
          -- apply gravity
          local gravityEffect = vec2.dot({0, -self.gravity}, self:dirVector()) / vec2.mag(self:dirVector()) * dt
          self.speed = self.speed + gravityEffect

          -- reverse direction if needed
          if self.speed < 0 then
            self.direction = (((self.direction - 1) + 4) % 8) + 1
            self.speed = -self.speed
            self:findNextNode(vec2.add(self.nextNode.position, self:dirVector()))
          end

          -- apply friction
          --local frictionEffect = self.railTypes[self.onRailType].friction * dt
          --self.speed = self.speed - frictionEffect

          -- respect speed limits for the type of rail we're on
          --self.speed = util.clamp(self.speed, 0, self.railTypes[self.onRailType].speedLimit)
        end

        -- position to move toward if we need to cut a corner or stop at a given point
        local targetPosition

        -- check whether we will cross the node next tick
        local toTravel = self.speed * dt
        local crossDist = Rails.crossDist(self.nextNode.position, self:position(), toTravel)
        while crossDist do
          if self.nextNode.type == "turn" then
            self.direction = self.nextNode.direction
            targetPosition = vec2.add(self.nextNode.position, vec2.mul(vec2.norm(self:dirVector()), crossDist))
          elseif self.nextNode.type == "stop" or self.nextNode.type == "reverse" then
            targetPosition = self.nextNode.position
          end

          self.lastNode = self.nextNode
          if self.lastNode.objectId then
            table.insert(self.crossedObjects, self.lastNode.objectId)
          end

          if self.lastNode.material then
            self.onRailType = self.lastNode.material
          end

          if self.lastNode.type == "reverse" then
            -- riders must stop for at least one tick on a reverse node
            break
          elseif self.lastNode.type ~= "stop" and self.lastNode.type ~= "end" then
            self:findNextNode(vec2.add(self.lastNode.position, Rails.dirVectors[self.lastNode.direction]), self.lastNode.direction)

            toTravel = crossDist
            crossDist = Rails.crossDist(self.nextNode.position, self.lastNode.position, toTravel)
          else
            self:setNextNode(nil)
            break
          end
        end

        if targetPosition then
          mcontroller.setVelocity(vec2.mul(world.distance(targetPosition, self:position()), 1 / dt))
        else
          mcontroller.setVelocity(self:onRailVelocity())
        end
      end

      -- update 'facing' which is used to bias search order
      if self:dirVector()[1] ~= 0 then
        self.facing = self:dirVector()[1]
      end
    else
      -- stopped; wait for signal
    end

    self:applyGravity()
  end

  function Rider:uninit()

  end

  -- change the connection offset. if we're on a rail, this requires translating the
  -- movement controller
  function Rider:updateConnectionOffset(newOffset)
    if not vec2.eq(newOffset, self.connectionOffset) then
      if self:onRail() then
        local currentPos = mcontroller.position()
        local posDiff = vec2.sub(self.connectionOffset, newOffset)
        mcontroller.setPosition(vec2.add(currentPos, posDiff))
      end
      self.connectionOffset = newOffset
    end
  end

  function Rider:position()
    return vec2.add(mcontroller.position(), self.connectionOffset)
  end

  function Rider:setPosition(pos)
    mcontroller.setPosition(vec2.sub(pos, self.connectionOffset))
  end

  function Rider:dirVector()
    return Rails.dirVectors[self.direction]
  end

  -- normalized velocity in the current rail direction with current speed
  function Rider:onRailVelocity()
    return vec2.mul(vec2.norm(self:dirVector()), self.speed)
  end

  function Rider:onRail()
    return self.nextNode ~= nil or self.lastNode ~= nil or not self.moving
  end

  -- determine whether there's a connectable rail material at a given position
  function Rider:checkTile(pos)
    local materialAt = world.material(pos, "foreground")
    if self.railTypes[materialAt] then
      return materialAt
    end

    return false
  end

  function Rider:setNextNode(node)
    self.moving = true
    self.nextNode = node
    if self.nextNode then
      self.nextNode.direction = Rails.direction(self.nextNode.direction) or self.direction
    end

    self:updateGravity()
  end

  -- resume movement after having been stopped
  function Rider:railResume(pos, vel, dir)
    -- TODO: resume while stopping?
    if not self.moving and vec2.eq(vec2.floor(pos), vec2.floor(self:position())) then
      if self.useGravity then self.speed = vel or self.speed end
      self.direction = dir or self.direction
      self.moving = true
      self:findInitialNode(pos)
      mcontroller.setVelocity(self:onRailVelocity())
    end
  end

  -- use maximally inclusive search to find any rail segment at the given position
  -- and then attach to it
  function Rider:findInitialNode(pos)
    local pos = util.tileCenter(pos)

    -- first, determine whether there is a rail material at the position we're checking
    local searchMaterial = self:checkTile(pos)
    if searchMaterial then
      -- now look for a connected rail material in ANY direction (but respecting direction and facing biases)
      for _, searchOffset in ipairs(Rails.fullSearchOrder) do
        local searchDir = (((self.direction - 1) + (self.facing * searchOffset)) % 8) + 1
        local searchPos = vec2.add(pos, Rails.dirVectors[searchDir])

        local railMaterial = self:checkTile(searchPos)
        if railMaterial then
          -- now that we've found a connecting rail, snap onto the rail at the initial search position,
          -- but use this connection to determine the direction and speed of travel
          self.onRailType = searchMaterial
          self.direction = searchDir
          self:setPosition(pos)
          if self.useGravity then
            self.speed = vec2.dot(mcontroller.velocity(), self:dirVector()) / vec2.mag(self:dirVector())
            self.speed = util.clamp(self.speed, 0, self.railTypes[self.onRailType].speedLimit)
          end
          mcontroller.setVelocity(self:onRailVelocity())

          -- now that we're properly 'on the rails' we can find the next node
          -- (which should generate a node for the connecting rail we just detected)
          self:findNextNode()

          -- call engage hook if specified
          if self.onEngage then self:onEngage() end

          return true
        end
      end
    end

    self.onRailType = nil
    return false
  end

  -- use a (generall) reduced search to find the next node from the rail we're currently on
  -- and then attach to it. if this search fails, the next node will be and endpoint where
  -- the rider will disconnect from the rail and enter freefall
  function Rider:findNextNode(pos, dir, fullSearch)
    dir = dir or self.direction
    pos = pos or util.tileCenter(vec2.add(self:position(), Rails.dirVectors[dir]))

    -- check the material at the given position to see if it has special behavior or indicates
    -- an object that will need to be notified. it's possible that this isn't a rail material
    -- (it could have changed since we last checked) but we will assume that it once was and
    -- continue traveling past it
    local nodeMaterial = self:checkTile(pos)

    local objectId
    if nodeMaterial and string.find(nodeMaterial, "metamaterial:") then
      -- rail objects use metamaterials rather than real materials and the materialSpace we're detecting
      -- had damn well better be within the object's spaces or else I'm going to get mad
      objectId = world.objectAt(pos)
    end

    if nodeMaterial == "metamaterial:railstop" then
      -- if the next node is a stop, connecting direction doesn't matter as we'll be performing
      -- a full search on resume anyway
      self:setNextNode({type = "stop", position = pos, objectId = objectId, material = nodeMaterial})
      return
    elseif nodeMaterial == "metamaterial:railreverse" then
      -- similarly, a reverse node won't need to check for connectivity
      self:setNextNode({type = "reverse", position = pos, objectId = objectId, material = nodeMaterial})
      return
    else
      -- if rail stops or tram stops are places as endpoints, riders shouldn't fall off of them
      if nodeMaterial == "metamaterial:railsafe" then fullSearch = true end

      -- search for rails around this position to determine the direction for the node
      for _, searchOffset in ipairs(fullSearch and Rails.fullSearchOrder or Rails.standardSearchOrder) do
        local searchDir = (((dir - 1) + (self.facing * searchOffset)) % 8) + 1
        local searchPos = vec2.add(pos, Rails.dirVectors[searchDir])

        if self:checkTile(searchPos) then
          if searchOffset == 0 then
            -- traveling in a straight line is simpler so it has a special node type
            self:setNextNode({type = "continue", position = pos, objectId = objectId, material = nodeMaterial})
          else
            self:setNextNode({type = "turn", position = pos, direction = searchDir, objectId = objectId, material = nodeMaterial})
          end

          return
        end
      end
    end

    -- failed to find a connecting rail; going off the rails
    self:setNextNode({type = "end", position = pos})
  end

  function Rider:updateGravity()
    self.gravity = world.gravity(self:position()) * self.gravityMultiplier
  end

  function Rider:applyGravity()
    -- handle using a base movement controller or an actor movement controller
    if mcontroller.applyParameters then
      mcontroller.applyParameters({gravityEnabled = not self:onRail()})
    elseif mcontroller.controlParameters then
      mcontroller.controlParameters({gravityEnabled = not self:onRail()})
    end
  end

  return Rider
end
