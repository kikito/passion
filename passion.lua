passion = {} -- like everything big, it starts so small...

-- This file contains the core methods of the passion lib

------------------------------------
-- LOVE VERSION CONTROL
------------------------------------

passion.loveVersion = 62
passion.loveVersionString = '0.6.2'

assert(passion.loveVersion <= love._version, 'Your love version (' .. love._version_string .. ') is too old. PASSION requires love ' .. passion.loveVersionString .. '.')

if(passion.loveVersion < love._version) then
  print('Warning: Your love version (' .. love._version_string .. ') is newer than the one this PASSION lib was designed for(' .. passion.loveVersionString .. ')')
end

------------------------------------
-- PRIVATE ATTRIBUTES AND METHODS
------------------------------------

-- table that controls that actors are not re-drawn. Used in draw callback
local _drawn = setmetatable({}, {__mode = "k"})

-- function used for drawing. Used in draw callback
local _drawIfNotDrawn = function(actor)
  if(_drawn[actor]==nil) then
    actor:draw()
    _drawn[actor] = 1
  end
end

-- function for drawing actors in the right order. Used in draw callback
local _sortByDrawOrder = function(actor1, actor2) -- sorting function
  if(actor1==nil or actor2==nil) then return true end

  return actor1:getDrawOrder() > actor2:getDrawOrder()
end

-- PÄSSION will route the following to its internal world object (i.e. passion.setGravity(0, 100) )
local _delegatedWorldMethods = {
  'getBodyCount' , 'getCallbacks', 'getGravity', 
  'getJointCount', 'getMeter'    , 'isAllowSleep', 
  'setAllowSleep', 'setCallbacks', 'setGravity', 
  'setMeter'
}

------------------------------------
-- EXIT
------------------------------------

-- I did this small function because I never remember how to exit in LÖVE :)
function passion.exit()
  love.event.push('q')
end

------------------------------------
-- PHYSICAL WORLD STUFF
------------------------------------

function passion.newWorld(w, h)
  passion.world = love.physics.newWorld( w, h )
  passion.ground = passion.newBody(0, 0, 0)
  return world
end
function passion.getWorld()
  assert(passion.world ~= nil, "passion.world is nil. You must invoke passion.newWorld")
  return passion.world
end
function passion.getGround()
  assert(passion.ground ~= nil, "passion.ground is nil. You must invoke passion.createWorld before using passion.getGround")
  return passion.ground
end
function passion.newBody(x, y, m )
  local world = passion.getWorld()
  return love.physics.newBody( world, x, y, m )
end

-- Define world methods in PÄSSION so it can be used "as a world"
for _,method in pairs(_delegatedWorldMethods) do
  passion[method] = function(self, ...)
    local world = passion.getWorld()
    return world[method](world, ...)
  end
end

------------------------------------
-- CALLBACK STUFF
------------------------------------

-- update callback
function passion.update(dt)
  if passion.world ~= nil then passion.world:update(dt) end
  passion.timer.update(dt)
  passion.Actor:applyToAllActors('update', dt)
end

-- draw callback
function passion.draw()
  _drawn = setmetatable({}, {__mode = "k"})
  passion.Actor:applyToAllActorsSorted( _sortByDrawOrder, _drawIfNotDrawn )
end

function passion.keypressed(key)
  Beholder.trigger('keypressed_' .. key)
end

function passion.keyreleased(key)
  Beholder.trigger('keyreleased_' .. key)
end

function passion.mousepressed(x, y, button)
  Beholder.trigger('mousepressed_' .. button, x, y)
end

function passion.mousereleased(x, y, button)
  Beholder.trigger('mousereleased_' .. button, x, y)
end

function passion.joystickpressed(joystick, button)
  Beholder.trigger('joystickpressed_' .. joystick .. '_' .. button)
end

function passion.joystickreleased(joystick, button)
  Beholder.trigger('joystickreleased_' .. joystick .. '_' .. button)
end

------------------------------------
-- MAIN LOOP
------------------------------------

--[[ passion.run. Can be used to "replace" love.run. Use it like this:

    function love.run()
      return passion.run()
    end

    We cannot simply attach the events and draw functions and use the default love callback because we need reset
    FIXME: review the need of passion.reset()
]]
function passion.run()

  -- registers the love events on passion
  for _,f in ipairs({'joystickpressed', 'joystickreleased', 'keypressed', 'keyreleased', 'mousepressed', 'mousereleased'}) do
    love[f] = function(...)
      passion[f](...)
    end
  end

  if(type(love.load)=='function') then love.load() end
  if(type(passion.load)=='function') then passion.load() end

  local dt = 0

  -- Main loop time.
  while true do
    if love.timer then
      love.timer.step()
      dt = love.timer.getDelta()
    end
    passion.update(dt) -- will pass 0 if love.timer is disabled

    if love.graphics then
      love.graphics.clear()
      passion.draw()
    end

    -- Process events.
    if love.event then
      for e,a,b,c in love.event.poll() do
        if e == "q" then
          if love.audio then love.audio.stop() end
          return
        end
        love.handlers[e](a,b,c)
      end
    end
    
    if love.timer then love.timer.sleep(1) end
    if love.graphics then love.graphics.present() end
  end
end
