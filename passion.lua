local _G=_G

-- This file contains the core methods of the passion lib
module('passion')

------------------------------------
-- LOVE VERSION CONTROL
------------------------------------

loveVersion = 62
loveVersionString = '0.6.2'

_G.assert(loveVersion <= _G.love._version, 'Your love version (' .. _G.love._version_string .. ') is too old. PASSION requires love ' .. loveVersionString .. '.')

if(loveVersion < _G.love._version) then
  _G.print('Warning: Your love version (' .. _G.love._version_string .. ') is newer than the one this PASSION lib was designed for(' .. loveVersionString .. ')')
end

------------------------------------
-- PRIVATE ATTRIBUTES AND METHODS
------------------------------------

-- function used for drawing. Used in draw callback
local _drawWithCameras = function(actor)
  --for _,camera in _G.pairs(actor:getCameras()) do
  --  _G.print('drawing with cameras')
  --  camera:set()
    actor:draw()
  --end
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
function exit()
  _G.love.event.push('q')
end

------------------------------------
-- CALLBACK STUFF
------------------------------------

-- passion.update callback
function update(dt)
  physics.update(dt)
  timer.update(dt)
  Actor:apply('update', dt)

  graphics.Camera:apply('update', dt)
end

-- passion.draw callback
function draw()
  Actor:applySorted( _sortByDrawOrder, _drawWithCameras )
  graphics.Camera:clear()
end

-- guess
function keypressed(key)
  _G.Beholder.trigger({'keypressed', key})
end

function keyreleased(key)
  _G.Beholder.trigger({'keyreleased', key})
end

function mousepressed(x, y, button)
  _G.Beholder.trigger({'mousepressed', button}, x, y)
end

function mousereleased(x, y, button)
  _G.Beholder.trigger({'mousereleased', button}, x, y)
end

function joystickpressed(joystick, button)
  _G.Beholder.trigger({'joystickpressed', joystick, button})
end

function joystickreleased(joystick, button)
  _G.Beholder.trigger({'joystickreleased', joystick, button})
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

  function love.update(dt)
    passion.update(dt)
  end
  
  You may redefine love. functions as you want. If you want PÄSSION to work reliably,
  you must include the calls to the passion methods - so if you re-define love.draw, you
  must not forget to call passion.draw inside it.

  function love.draw()
    my_custom_drawing_stuff()
    passion.draw()
  end
  
  
]]

for _,f in _G.ipairs({
  'draw', 'update',
  'joystickpressed', 'joystickreleased',
  'keypressed', 'keyreleased',
  'mousepressed', 'mousereleased',
}) do
  _G.love[f] = function(...)
    _M[f](...)
  end
end


------------------------------------
-- UTILITY METHODS
------------------------------------

-- prints a table on the console, recursively. Useful for debugging.
function dump(t, level, depth)
  level = level or 1
  depth = depth or 4
  
  if(level>=depth) then return end

  _G.print(_G.string.rep("   ", level) .. _G.tostring(t) .. ':')

  if(_G.type(t)=='table') then
    for k,object in _G.pairs(t) do
      _G.print(_G.string.rep("   ", level+1) .. _G.tostring(k) .. ' => '.. _G.tostring(object) )
      if(_G.type(object)=='table') then dump(object, level + 1) end
    end
  end
end

--[[ Aux function used in Resource loading. 
   If the resource is not in collection[key], create it using f(...)
   I need to make it "public" because I use it on the graphics, audio and fonts modules for
   implementing getImage, getSource and getFont.
   Regular users shouldn't be using it (that is why it begins with an underscore)
]]
function _getResource(collection, f, key, ...)
  local resource = collection[key]
  if(resource == nil) then
    resource = f(...)
    collection[key]=resource
  end
  return resource
end



