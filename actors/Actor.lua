require 'passion.MiddleClass'
require 'passion.MindState'
require 'passion.Core'
require 'passion.actors.HasImage'
require 'passion.actors.HasBody'


passion.Actor = class('passion.Actor', StatefulObject)

local Actor = passion.Actor

-- PRIVATE METHODS AND ATTRIBUTES

-- The global list of actors
_actors = {}
_actors[Actor] = setmetatable({}, {__mode = "k"})

-- Each actor's children
_children = setmetatable({}, {__mode = "k"})

-- Adds an actor to the "list of actors" of its class
local _registerInstance -- we define the variable first so we can make the function recursive
_registerInstance = function(theClass, actor)
  table.insert(_actors[theClass], actor)
  if(theClass~=Actor) then _registerInstance(theClass.superclass,actor) end
end

-- Removes an actor from the "list of actors" of its class
local _unregisterInstance -- we define the variable first so we can make the function recursive
_unregisterInstance = function(theClass, actor)
  if(theClass~=Actor) then _unregisterInstance(theClass.superclass,actor) end
  local index
  for i, v in ipairs(_actors[theClass]) do
    if v == arg then
      index = i
      break
    end
  end
  table.remove(_actors[theClass], index)
end

-- private helper function used to apply methods to collections of actors
local _applyToActorCollection = function(actors, sortFunc, methodOrName, ... )
  
  if(type(sortFunc)=='function') then
    local actorsCopy = {}
    for k,actor in pairs(actors) do actorsCopy[k]=actor end
    table.sort(actorsCopy, sortFunc)
    actors = actorsCopy
  end

  if(type(methodOrName)=='string') then
    for _,actor in pairs(actors) do
      local method = actor[methodOrName]
      if(type(method)=='function') then
        if(method(actor, ...) == false) then return end
      end
    end

  elseif(type(methodOrName)=='function') then
    for _,actor in pairs(actors) do
      if(methodOrName(actor, ...) == false) then return end
    end

  else
    error('methodOrName must be a function or function name')
  end

end

-- INSTANCE METHODS

function Actor:initialize(options) -- options will normally be nil
  super.initialize(self, options)
  _registerInstance(self.class, self) -- add the actor to the list of actors of its class and superclasses
  _children[self] = {}
end

function Actor:destroy()
  self:gotoState(nil)
  self:applyToAllChildren('destroy')
  _children[self] = nil
  _unregisterInstance(self.class, self)
end

--FIXME add special control case on HasBody
--FIXME add frozen status
function Actor:freeze()
  self._frozen = true
end

function Actor:unFreeze()
  self._frozen = false
end

function Actor:isFrozen()
  return (self._frozen == true)
end

function Actor:update(dt) end
function Actor:draw() end

Actor:getterSetter('x') --getX, setX
Actor:getterSetter('y') -- getY, setY
Actor:getterSetter('parent')
Actor:getterSetter('visible', true)
Actor:getterSetter('angle') -- getAngle, setAngle
Actor:getterSetter('centerX') -- getCenterX, setCenterX
Actor:getterSetter('centerY') -- getCenterY, setCenterY
Actor:getterSetter('scaleX', 1) -- getScaleX, setScaleX, with 1 as default value
Actor:getterSetter('scaleY', 1) --getScaleY, setScaleY, with 1 as defalult value
Actor:getterSetter('drawOrder', 0)

function Actor:getPosition()
  return self.x, self.y
end
function Actor:setPosition(x, y)
  self.x = x
  self.y = y
end

function Actor:getCenter() return self.centerX, self.centerX end
function Actor:setCenter(centerX, centerY)
  self.centerX = centerX
  self.centerY = centerY
end

function Actor:setScale(scale)
  self.scaleX = scale
  self.scaleY = scale
end

--[[
  An actor's chilren are other actors. For example, the weels of a car, or controls inside a form.
  they are also useful for stablishing drawing and updating orders
  setParent is used to define wether we call child:setParent or not(default:yes)
  setParent should be put to false in those rare cases in which a children can have several parents
]]
function Actor:addChild(child, setParent)
  table.insert(_children[self], child)
  if(setParent~=false) then child:setParent(self) end
  return child
end

-- Removes a child.
-- if resetParent is set to 'true' (default) then the child parent will be set to nil
function Actor:removeChild(child, resetParent)
  local index
  for i, v in ipairs(_children[self]) do
    if v == arg then
      index = i
      break
    end
  end
  table.remove(_children[self], index)
  if(resetParent~=false) then child:setParent(nil) end
end

-- Applies some method to all the children of an actor
function Actor:applyToAllChildren(methodOrName, ... )
  assert(self~=nil, 'Please call actor:applyToAllChildren instead of actor.applyToAllChildren')
  self:applyToAllChildrenSorted(nil, methodOrName, ... )
end

function Actor:applyToAllChildrenSorted(sortFunc, methodOrName, ... )
  assert(self~=nil, 'Please call actor:applyToAllChildrenSorted instead of actor.applyToAllChildrenSorted')
  _applyToActorCollection(_children[self], sortFunc, methodOrName, ... )
end

-- CLASS METHODS

-- redefine the subclass function so it admits two options: hasImage & hasBody (default to false, both)
-- it also registers the subclass on the list of passion actor classes
-- and creates the _actors array
local _prevSubclass = Actor.subclass -- stores the "default" way of making subclasses
function Actor.subclass(theClass, name, options)
  local theSubclass = _prevSubclass(theClass, name)
  options = options or {}

  local hasImage = options.hasImage==nil and false or options.hasImage -- equivalent to ? : trinary operator
  local hasBody = options.hasBody==nil and false or options.hasBody

  if(hasImage) then theSubclass:includes(passion.HasImage) end
  if(hasBody) then theSubclass:includes(passion.HasBody) end

  passion:addActorClass(theSubclass) -- register the new actor class on the passion system
  _actors[theSubclass] = setmetatable({}, {__mode = "k"}) --this will hold references to all the actors created on this class

  return theSubclass
end

-- Applies some method to all the actors of this class (not subclasses)
function Actor.applyToAllActors(theClass, methodOrName, ...)
  assert(theClass~=nil, 'Please call Class:applyToAllActors instead of Class.applyToAllActors')
  theClass:applyToAllActorsSorted(nil, methodOrName, ...)
end

function Actor.applyToAllActorsSorted(theClass, sortFunc, methodOrName, ...)
  assert(theClass~=nil, 'Please call Class:applyToAllActorsSorted instead of Class.applyToAllActorsSorted')
  if( type(methodOrName)=='function' or 
     (type(methodOrName)=='string' and type(theClass[methodOrName])=='function') ) then
    _applyToActorCollection(_actors[theClass], sortFunc, methodOrName, ... )
  end
end

local resourceTypes = {
  images = 'getImage',
  sources = 'getSource',
  fonts = 'getFont'
}
-- Loads images, fonts, sounds & music onto the actor class itself
function Actor.load(theClass, resourceTypesToLoad)
  assert(theClass~=nil, 'Please call Class:load instead of Class.load')
  local resourceTypeToLoad
  for resourceTypeName,loadingMethod in pairs(resourceTypes) do
    resourceTypeToLoad = resourceTypesToLoad[resourceTypeName]
    if(type(resourceTypeToLoad)=='table') then -- if the parameter table has something called 'images', 'fonts', etc then
      -- create theClass.fonts if it doesn't exist
      if(theClass[resourceTypeName]==nil) then theClass[resourceTypeName] = {} end
      
      -- parse all the resource names, invoking the right loadingMethod with the right parameters
      for resourceName, params in pairs(resourceTypeToLoad) do -- load all those and replace their "params" with loaded objects
        if(type(params) == 'table') then
          theClass[resourceTypeName][resourceName] = passion[loadingMethod](passion, unpack(params))
        else
          theClass[resourceTypeName][resourceName] = passion[loadingMethod](passion, params)
        end
      end
    end
  end
end
