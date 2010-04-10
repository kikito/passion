passion.physics = {}
local physics = passion.physics

------------------------------------
-- PRIVATE ATTRIBUTES AND METHODS
------------------------------------

-- Physics update frequency (60 times per second)
local _physicsDt = 1.0/60

-- accumulates time increments in order to be able to "trigger" physics updates on the right instants
local _accumulator = 0

-- stores the world, if it exists
local _world = nil

-- stores a ground body, if it exists
local _ground = nil

-- PÄSSION will route the following to the internal world object (i.e. passion.physics.setGravity(0, 100) )
local _delegatedWorldMethods = {
  'getBodyCount' , 'getCallbacks', 'getGravity', 
  'getJointCount', 'getMeter'    , 'isAllowSleep', 
  'setAllowSleep', 'setCallbacks', 'setGravity', 
  'setMeter'
}

------------------------------------
-- PUBLIC METHODS
------------------------------------

-- creates a new world with a given with and height. It also initializes a "ground" body at 0,0
function physics.newWorld(w, h)
  _world = love.physics.newWorld( w, h )
  _ground = physics.newBody(0, 0, 0)
  return _world
end

-- Returns the world. If inexistant, it fails
function physics.getWorld()
  assert(_world ~= nil, "passion.physics.world is nil. You must invoke passion.newWorld")
  return _world
end

-- Returns the ground body. If inexistant, it fails
function physics.getGround()
  assert(_ground ~= nil, "passion.physics.ground is nil. You must invoke passion.createWorld before using passion.getGround")
  return _ground
end

-- Liberates the world
function physics.destroyWorld()
  _world = nil
  _ground = nil
end

-- Creates a new body using the default world
function physics.newBody(x, y, m )
  return love.physics.newBody( physics.getWorld(), x, y, m )
end

-- Define world methods in passion.physics so it can be used "as a world"
for _,method in pairs(_delegatedWorldMethods) do
  physics[method] = function(...)
    local world = physics.getWorld()
    return world[method](world, ...)
  end
end

-- sets a new physics update frequency
function physics.setDt(newDt)
  _physicsDt = newDt
end

-- gets the physics update frequency
function physics.getDt()
  return _physicsDt
end

-- updates the physics world accoring to the physics fixed dt, more or less independently from
-- the given dt. This code is based on pekka's work here: http://love2d.org/forum/viewtopic.php?f=5&t=1163
-- which in turn is based on this article: http://gafferongames.com/game-physics/physics-in-3d/
function physics.update(dt)

  if(_world ~= nil) then
    _accumulator = _accumulator + dt

    while _accumulator > _physicsDt do
      _accumulator = _accumulator - _physicsDt
      _world:update(_physicsDt)
    end
  end

end


