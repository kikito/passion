local _G=_G
module('passion')

Actor = _G.class('passion.Actor')

-- Include all the modules from middleclass-extras
local middleclass_extras_modules = {
  _G.Invoker, _G.GetterSetter, _G.Callbacks, _G.Apply, _G.Beholder, _G.Stateful, _G.Branchy
}
for _,module in _G.pairs(middleclass_extras_modules) do
  Actor:include(module)
end

-- Also include the passion.timer.Timed interface
Actor:include(_G.passion.timer.Timed)

------------------------------------
-- INSTANCE METHODS
------------------------------------

function Actor:destroy()
  self:gotoState(nil)
  self:applyToChildren('destroy')
  super.destroy(self)
end

function Actor:update(dt) end
function Actor:draw() end

Actor:getterSetter('x') --getX, setX
Actor:getterSetter('y') -- getY, setY
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
  if vis then
    self:popState('Invisible')
  else
    self:pushState('Invisible')
  end
end
