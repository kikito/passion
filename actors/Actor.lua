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

function passion.Actor:getX() return self.x end
function passion.Actor:getY() return self.y end
function passion.Actor:getPosition() return { self.x, self.y } end

function passion.Actor:getAngle() return self.angle end

function passion.Actor:getCenterX() return self.centerX or 0 end
function passion.Actor:getCenterY() return self.centerY or 0 end
function passion.Actor:getCenter() return {self.centerX or 0, self.centerX or 0} end

function passion.Actor:getScaleX() return self.scaleX or 1 end
function passion.Actor:getScaleY() return self.scaleY or 1 end


function passion.Actor:setX(x) self.x = x end
function passion.Actor:setY(y) self.y = y end
function passion.Actor:setPosition(x, y)
  self.x = x
  self.y = y
end

function passion.Actor:setAngle(angle) self.angle = angle end

function passion.Actor:setCenterX(centerX) self.centerX = centerX end
function passion.Actor:setCenterY(centerY) self.centerY = centerY end
function passion.Actor:setCenter(centerX, centerY)
  self.centerX = centerX
  self.centerY = centerY
end

function passion.Actor:setScaleX(scaleX) self.scaleX = scaleX end
function passion.Actor:setScaleY(scaleY) self.scaleY = scaleY end
function passion.Actor:setScale(scale)
  self.scaleX = scale
  self.scaleY = scale
end