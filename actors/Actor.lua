require 'passion.MiddleClass'
require 'passion.MindState'
require 'passion.Core'
require 'passion.actors.HasImage'
require 'passion.actors.HasBody'


passion.Actor = class('passion.Actor', StatefulObject)

local Actor = passion.Actor

-- INSTANCE METHODS

function Actor:initialize(options) -- options will normally be nil
  super(self, options)
  self.class:_registerInstance(self) -- add the actor to the list of actors of its class
end

function Actor:destroy()
  self:gotoState(nil)
  self:freeze()
  self:setVisible(false)
  self.class:_unregisterInstance(self)
end

--FIXME add special control case on HasBody
function Actor:freeze()
  self._frozen = true
end

function Actor:unFreeze()
  self._frozen = false
end

function Actor:updateIfNotFrozen()
  if(self._frozen~=true) then self:update() end
end

function Actor:drawIfVisible()
  if(self:getVisible()==true) then self:draw() end
end

function Actor:update(dt) end
function Actor:draw() end

Actor:getterSetter('x') --getX, setX
Actor:getterSetter('y') -- getY, setY
Actor:getterSetter('visible', true)
Actor:getterSetter('angle') -- getAngle, setAngle
Actor:getterSetter('centerX') -- getCenterX, setCenterX
Actor:getterSetter('centerY') -- getCenterY, setCenterY
Actor:getterSetter('scaleX', 1) -- getScaleX, setScaleX, with 1 as default value
Actor:getterSetter('scaleY', 1) --getScaleY, setScaleY, with 1 as defalult value

function Actor:getPosition() return self.x, self.y end
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

-- CLASS METHODS

-- redefine the subclass function so it admits two options: hasImage & hasBody (default to false, both)
-- it also registers the subclass on the list of passion actor classes
-- and creates the _actors array
local prevSubclass = Actor.subclass
function Actor:subclass(name, options)
  local theSubclass = prevSubclass(self, name)
  options = options or {}

  local hasImage = options.hasImage==nil and false or options.hasImage -- equivalent to ? : trinary operator
  local hasBody = options.hasBody==nil and false or options.hasBody

  if(hasImage) then theSubclass:includes(passion.HasImage) end
  if(hasBody) then theSubclass:includes(passion.HasBody) end

  passion:addActorClass(theSubclass) -- register the new actor class on the passion system
  theSubclass._actors = setmetatable({}, {__mode = "k"}) --this will hold references to all the actors created on this class

  return theSubclass
end

-- Adds an actor to the "list of actors" of its class
function Actor:_registerInstance(actor)
  table.insert(self._actors, actor)
end

-- Removes an actor from the "list of actors" of its class
function Actor:_unregisterInstance(actor)
  local index
  for i, v in ipairs(self._actors) do
      if v == arg then
          index = i
          break
      end
  end
  table.remove(self._actors, index)
end

-- Applies some method to all the actors of this class (not subclasses)
function Actor:applyToAllActors(methodName, ...)
  local method = self[methodName]
  if(type(method)=='function') then
    for _,actor in pairs(self._actors) do actor[methodName](actor, ...) end -- do NOT replace with method(actor, ...) ... it is not the same thing
  end
end

local resourceTypes = {
  images = 'getImage',
  sounds = 'getSound',
  musics = 'getMusic',
  fonts = 'getFont'
}
-- Loads images, fonts, sounds & music onto the actor class itself
function Actor:load(resourceTypesToLoad)
  assert(self~=nil, 'Please call Class:load instead of class.load')
  local resourceTypeToLoad
  for resourceTypeName,loadingMethod in pairs(resourceTypes) do
    resourceTypeToLoad = resourceTypesToLoad[resourceTypeName]
    if(type(resourceTypeToLoad)=='table') then -- if the parameter table has something called 'images', 'fonts', etc then
      -- create self.fonts if it doesn't exist
      if(self[resourceTypeName]==nil) then self[resourceTypeName] = {} end
      
      -- parse all the resource names, invoking the right loadingMethod with the right parameters
      for resourceName, params in pairs(resourceTypeToLoad) do -- load all those and replace their "params" with loaded objects
        if(type(params) == 'table') then
          self[resourceTypeName][resourceName] = passion[loadingMethod](passion, unpack(params))
        else
          self[resourceTypeName][resourceName] = passion[loadingMethod](passion, params)
        end
      end
    end
  end
end
