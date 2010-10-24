local _G=_G
module('passion')

Actor = _G.class('passion.Actor')

for _,module in _G.pairs({_G.Invoker, _G.GetterSetter, _G.Callbacks, _G.Apply, _G.Beholder, _G.Stateful})
  Actor:include(module)
end

------------------------------------
-- PRIVATE METHODS AND ATTRIBUTES
------------------------------------

-- Each actor's children
_children = _G.setmetatable({}, {__mode = "k"})

-- If methodOrname is a function, it returns it. If it is a name, it returns the method named.
local _getMethod = function(actor, methodOrName)
  local method = (_G.type(methodOrName)=='string' and actor[methodOrName] or methodOrName)
  _G.assert(_G.type(method)=='function', 'methodOrName(' .. _G.tostring(methodOrName) .. ') must be either a function or a valid method name')
  return method
end

------------------------------------
-- INSTANCE METHODS
------------------------------------

function Actor:initialize(options) -- options will normally be nil
  super.initialize(self, options)
  _children[self] = {}
end

function Actor:destroy()
  self:gotoState(nil)
  self:applyToChildren('destroy')
  _children[self] = nil
  self:removeFromApply()
  super.destroy(self)
end

function Actor:update(dt) end
function Actor:draw() end

Actor:getterSetter('x') --getX, setX
Actor:getterSetter('y') -- getY, setY
Actor:getterSetter('parent')
Actor:getterSetter('angle') -- getAngle, setAngle
Actor:getterSetter('centerX') -- getCenterX, setCenterX
Actor:getterSetter('centerY') -- getCenterY, setCenterY
Actor:getterSetter('scaleX', 1) -- getScaleX, setScaleX, with 1 as default value
Actor:getterSetter('scaleY', 1) --getScaleY, setScaleY, with 1 as defalult value
Actor:getterSetter('drawOrder', 0)
Actor:getterSetter('camera', _G.passion.graphics.defaultCamera)

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
  they are also useful for stablishing drawing and updating order.
  setParent is used to define wether we call child:setParent or not(default:yes)
  setParent should be put to false in those rare cases in which a children can have several parents
]]
function Actor:addChild(child, setParent)
  _G.table.insert(_children[self], child)
  if(setParent~=false) then child:setParent(self) end
  return child
end

-- Removes a child.
-- if resetParent is set to 'true' (default) then the child parent will be set to nil
function Actor:removeChild(child, resetParent)
  _G.passion.remove(_children[self], child)
  if(resetParent~=false) then child:setParent(nil) end
end

-- Applies some method to all the children of an actor
function Actor:applyToChildren(methodOrName, ... )
  _G.assert(self~=nil, 'Please call actor:applyToChildren instead of actor.applyToChildren')
  _G.passion.apply(_children[self], methodOrName, ... )
end

function Actor:applyToChildrenSorted(sortFunc, methodOrName, ... )
  _G.assert(self~=nil, 'Please call actor:applyToChildrenSorted instead of actor.applyToChildrenSorted')
  _G.passion.applySorted(_children[self], sortFunc, methodOrName, ... )
end

-- timer function. Executes one action after some seconds have passed
function Actor:after(seconds, methodOrName, ...)
  local method = _getMethod(self, methodOrName)
  return _G.passion.timer.after(seconds, method, self, ...)
end

-- timer function. Executes an action periodically.
function Actor:every(seconds, methodOrName, ...)
  local method = _getMethod(self, methodOrName)
  return _G.passion.timer.every(seconds, method, self, ...)
end

-- timer function. Changes the properties of the actor gradually over a period of time
function Actor:effect(seconds, properties, easing, callback, ...)
  return _G.passion.timer.effect(self, seconds, properties, easing, callback, ...)
end

-- Override this to change which cameras are used to render an actor (you can also override getCamera)
function Actor:getCameras()
  return {self:getCamera()}
end

------------------------------------
-- STATES (INVISIBLE & FROZEN)
------------------------------------

-- The frozen state just redefines update to do nothing
-- It has to do some more stuff if the PhysicalBody (freeze and unfreeze the body)
local Frozen = Actor:addState('Frozen')

function Frozen:update(dt) end -- do nothing

function Actor:freeze()
  self:pushState('Frozen')
end

function Actor:unFreeze()
  self:popState('Frozen')
end

function Actor:isFrozen()
  return self:isInState('Frozen', true)
end

-- The Invisible state redefines the draw method to do nothing
local Invisible = Actor:addState('Invisible')

function Invisible:draw() end -- do nothing

function Actor:getVisible()
  return not self:isInState('Invisible', true)
end

function Actor:setVisible(vis)
  if(not vis) then
    self:pushState('Invisible')
  else
    self:popState('Invisible')
  end
end
