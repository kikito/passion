require 'passion.MiddleClass'
require 'passion.MindState'
require 'passion.Core'
require 'passion.actors.HasImage'
require 'passion.actors.HasBody'


passion.Actor = class('passion.Actor', StatefulObject)

function passion.Actor:initialize(options) -- options will normally be nil
  super(self, options)
  passion:addActor(self) -- add the actor to the passion system
end

do -- keep the following variable
  local prevSubclass = passion.Actor.subclass

  function passion.Actor:subclass(name, options)
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
end

function passion.Actor:update(dt) end

passion.Actor:getterSetter('x') --getX, setX
passion.Actor:getterSetter('y') -- getY, setY
passion.Actor:getterSetter('angle') -- getAngle, setAngle
passion.Actor:getterSetter('centerX') -- getCenterX, setCenterX
passion.Actor:getterSetter('centerY') -- getCenterY, setCenterY
passion.Actor:getterSetter('scaleX', 1) -- getScaleX, setScaleX, with 1 as default value
passion.Actor:getterSetter('scaleY', 1) --getScaleY, setScaleY, with 1 as defalult value

function passion.Actor:getPosition() return self.x, self.y end
function passion.Actor:setPosition(x, y)
  self.x = x
  self.y = y
end

function passion.Actor:getCenter() return self.centerX, self.centerX end
function passion.Actor:setCenter(centerX, centerY)
  self.centerX = centerX
  self.centerY = centerY
end

function passion.Actor:setScale(scale)
  self.scaleX = scale
  self.scaleY = scale
end