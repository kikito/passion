
do

passion = {}

-- actor managing stuff
passion.actors = setmetatable({}, {__mode = "k"})
function passion:addActor(actor)
  table.insert(actor.class._actors, actor)
  table.insert(self.actors, actor)
  actor.actorId = #(self.actors)
end

passion.actorClasses={}
function passion:addActorClass(actorClass)
  table.insert(self.actorClasses,actorClass)
end

-- physical world stuff
function passion:newWorld(w, h)
  self.world = love.physics.newWorld( w, h )
  self.ground = self:newBody(0, 0, 0)
  return world
end
function passion:getWorld()
  assert(self.world ~= nil, "passion.world is nil. You must invoke passion:newWorld")
  return self.world
end
function passion:getGround()
  assert(self.ground ~= nil, "passion.ground is nil. You must invoke passion:createWorld before using passion:getGround")
  return self.ground
end
function passion:newBody(x, y, m )
  local world = self:getWorld()
  return love.physics.newBody( world, x, y, m )
end

function passion:applyToAllActors(methodName, ...)
  for _,actorClass in pairs(self.actorClasses) do
    local method = actorClass[methodName]
    if(type(method)=='function') then
      for _,actor in pairs(actorClass._actors) do
        actor[methodName](actor, ...)
      end
    end
  end
end

-- update callback
function passion:update(dt)
  if self.world ~= nil then self.world:update(dt) end
  passion:applyToAllActors('update', dt)
end

-- Rest of the callbacks
local callbacks = {
  'joystickpressed', 'joystickreleased', 'keypressed', 'keyreleased', 'mousepressed', 'mousereleased', 'reset', 'draw'
}
for _,method in pairs(callbacks) do
  passion[method] = function(self, ...)
    passion:applyToAllActors(method, ...)
  end
end

-- Apply the following methods directly to passion. for example passion:update(dt).
-- Passion will route them to the world object.
local delegatedMethods = {
  'getBodyCount', 'getCallbacks', 'getGravity', 'getJointCount', 'getMeter', 'isAllowSleep', 'setAllowSleep', 'setCallbacks', 'setGravity', 'setMeter'
}
for _,method in pairs(delegatedMethods) do
  passion[method] = function(self, ...)
    local world = passion:getWorld()
    return world[method](world, ...)
  end
end

--[[ Redefined the main loop to use passion functions
function love.run()
  if passion.load then passion:load() end
  -- Main loop.
  while true do

    love.timer.step()

    passion:update(love.timer.getDelta()) --execute the "update" method on all actors, and update the world
    passion:draw()  -- draw all actors
    passion:reset() -- execute the reset method on all actors - this is new

    -- Process events.
    for e,a,b,c in love.event.poll() do
      if e == love.event_quit then return end
      love.handlers[e](a,b,c)
    end

    love.graphics.present()
  end
end
]]

-- resource loading

--TBD

-- this is not used yet
passion.SUPPORTED_FORMATS= {
  image = { bmp=1, gif=1, jpeg=1, jpg=1, lbm=1, pcx=1, png=1, pnm=1, tga=1, xcf=1, xpm=1, xv=1 },
  font =  { ttf=1 },
  sound = { aif=1, aiff=1, ogg=1, rif=1, riff=1, voc=1, wav=1 },
  music = { midi=1, ['mod']=1, mp3=1, ogg=1, xm=1 }
}

end
