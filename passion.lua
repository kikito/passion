local love = love
local Beholder = Beholder
local assert = assert
local print = print
local setmetatable = setmetatable
local ipairs = ipairs
local table=table
local type=type
local pairs=pairs
local tostring=tostring
local string=string

-- This file contains the core methods of the passion lib
module('passion')

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

-- function used for drawing. Used in draw callback
local _drawWithCameras = function(actor)
  local cameras = actor:getCameras()
  for _,camera in pairs(cameras) do
    camera:set()
    actor:draw()
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
function exit()
  love.event.push('q')
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
end

-- guess
function keypressed(key)
  Beholder.trigger('keypressed_' .. key)
end

function keyreleased(key)
  Beholder.trigger('keyreleased_' .. key)
end

function mousepressed(x, y, button)
  Beholder.trigger('mousepressed_' .. button, x, y)
end

function mousereleased(x, y, button)
  Beholder.trigger('mousereleased_' .. button, x, y)
end

function joystickpressed(joystick, button)
  Beholder.trigger('joystickpressed_' .. joystick .. '_' .. button)
end

function joystickreleased(joystick, button)
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
    _M[f](...)
  end
end


------------------------------------
-- UTILITY METHODS
------------------------------------

--[[ Invokes a function over an object, with parameters.
  MethodOrName can be either a function or a method name. The following lines are equivalent:

    player:moveRight(10)
    passion.invoke(player, function() player:moveRight(10) end)
    passion.invoke(player, 'moveRight', 10)

This is useful for implementing things like passion.apply easily.
]]
function invoke(object, methodOrName, ...)
  local method = methodOrName
  if(type(methodOrName)=='string') then method = object[methodOrName] end

  assert(type(method)=='function', tostring(methodOrName) .. ' must be a function or function name')

  return method(object, ...)
end

--[[ Helper function used to apply methods to collections
  * collection is a table containing a bunch of elements to which the function must be applied
  * sortFunc is a sorting function. It defines the order in which the method will be applied. It can be nil (no sorting)
  * methodOrName is either a function or a string
    - If it is a function, it will be applied to all objects in the collection, in order
    - If it is a string, then each object must have a function named like MethodName.
  * additional parameters can be passed to the methodOrName function. The first parameter will allways be the element
  Example:

    passion.apply({a,b,c}, nil, 'update', dt)

  is equivalent to doing this:
    a:update(dt)
    b:update(dt)
    c:update(dt)
]]
function apply(collection, methodOrName, ... )
  for _,object in pairs(collection) do
    if(invoke(object, methodOrName, ...) == false) then return end
  end
end

-- sorted version of passion.apply
function applySorted(collection, sortFunc, methodOrName, ... )

  -- If sortFunc exists, make a copy of collection and sort it
  if(type(sortFunc)=='function') then
    local collectionCopy = {}
    local i = 1
    for _,object in pairs(collection) do
      collectionCopy[i]=object
      i=i+1
    end
    table.sort(collectionCopy, sortFunc)
    collection = collectionCopy
  end

  apply(collection, methodOrName, ...)
end


--[[ Removes an object from a table.
  Only works reliably with 'array-type' collections (collections indexed with integers)
  Removes only the first appearance of object
]]
function remove(collection, object)
  local index
  for i, v in pairs(collection) do
    if v == object then
      index = i
      break
    end
  end
  if(index~=nil) then table.remove(collection, index) end
end

-- prints a table on the console, recursively. Useful for debugging.
function dumpTable(t, level, depth)
  level = level or 1
  depth = depth or 4
  
  if(level>=depth) then return end

  print(string.rep("   ", level) .. tostring(t) .. ':')

  if(type(t)=='table') then
    for k,object in pairs(t) do
      print(string.rep("   ", level+1) .. tostring(k) .. ' => '.. tostring(object) )
      if(type(object)=='table') then dumpTable(object, level + 1) end
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


