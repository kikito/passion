local love = love
local Beholder = Beholder
local assert = assert
local print = print
local setmetatable = setmetatable
local ipairs = ipairs

-- This file contains the core methods of the passion lib

------------------------------------
-- LOVE VERSION CONTROL
------------------------------------

loveVersion = 62
loveVersionString = '0.6.2'

assert(loveVersion <= love._version, 'Your love version (' .. love._version_string .. ') is too old. PASSION requires love ' .. loveVersionString .. '.')

if(loveVersion < love._version) then
  print('Warning: Your love version (' .. love._version_string .. ') is newer than the one this PASSION lib was designed for(' .. loveVersionString .. ')')
end

------------------------------------
-- PRIVATE ATTRIBUTES AND METHODS
------------------------------------

-- controls actors so they are not re-drawn. Used in draw callback
local _drawn = nil

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

------------------------------------
-- EXIT
------------------------------------

-- I did this small function because I never remember how to exit in LÖVE :)
function passion.exit()
  love.event.push('q')
end

------------------------------------
-- CALLBACK STUFF
------------------------------------

-- passion.update callback
function passion.update(dt)
  passion.physics.update(dt)
  passion.timer.update(dt)
  passion.Actor:apply('update', dt)
end

-- passion.draw callback
function passion.draw()
  _drawn = setmetatable({}, {__mode = "k"})
  passion.Actor:applySorted( _sortByDrawOrder, _drawIfNotDrawn )
end

-- guess
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
-- LÖVE hooks
------------------------------------

--[[
  This section defines LÖVE functions to their PÄSSION counterparts. For example,
  love.draw and love.update are defined like this:

  function love.draw()
    passion.draw()
  end

  function love.(dt)
    passion.update(dt)
  end
  
  You may redefine love. functions as you want. If you want PÄSSION to work reliably,
  you must include the calls to the passion methods - so if you re-define love.draw, you
  must not forget to call passion.draw inside it.

  function love.draw()
    my_cool_drawing_stuff()
    passion.draw()
  end
  
  
]]

for _,f in ipairs({
  'draw', 'update',
  'joystickpressed', 'joystickreleased',
  'keypressed', 'keyreleased',
  'mousepressed', 'mousereleased',
}) do
  love[f] = function(...)
    passion[f](...)
  end
end


