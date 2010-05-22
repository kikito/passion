local _G=_G
module('passion.physics')

Actor = _G.class('passion.physics.Actor', _G.passion.Actor)

------------------------------------
-- PRIVATE METHODS AND ATTRIBUTES
------------------------------------

-- stores the shapes of each actor, and its pre-freezing properties
local _private = _G.setmetatable({}, {__mode = "k"})

-- used for adding shapes to the collection of shapes of the body
local _addShape = function(self, shape)
  _G.table.insert(_private[self].shapes, shape)
  shape:setData(self)
  return shape
end

-- calculates the maximum between two numbers. If the first is nil, just return the second
local _max = function(a,b, ...)
  return _G.math.max(a==nil and b or a, b, ...)
end

-- calculates the minimum between two numbers. If the first is nil, just return the second
local _min = function(a,b, ...)
  return _G.math.min(a==nil and b or a, b, ...)
end

-- Methods from body. They will be handled directly by the Actor
local _delegatedMethods = {
  'applyForce', 'applyImpulse', 'applyTorque', 'getAngle', 'getAngularDamping',
  'getAngularVelocity', 'getFixedRotation', 'getInertia', 'getLinearDamping',
  'getLinearVelocity', 'getLinearVelocityFromLocalPoint', 'getLinearVelocityFromWorldPoint',
  'getLocalCenter', 'getLocalPoint', 'getLocalVector', 'getMass', 'getPosition',
  'getWorldCenter', 'getWorldPoint', 'getWorldVector', 'getX', 'getY', 'isBullet',
  'isDynamic', 'isFrozen', 'isSleeping', 'isStatic', 'putToSleep', 'setAllowSleeping',
  'setAngle', 'setAngularDamping', 'setAngularVelocity', 'setBullet', 'setFixedRotation',
  'setInertia', 'setLinearDamping', 'setMass', 'setMassFromShapes', 
  'setPosition', 'setLinearVelocity', 'setX', 'setY', 'wakeUp'
}

-- Draws a shape. Used internally by Actor.drawShapes
local drawShape = function(shape, style)
  _G.passion.graphics.drawShape(style, shape)
end

------------------------------------
-- INSTANCE METHODS
------------------------------------

-- class constructor. The options can be used to initialize states
function Actor:initialize(options)
  super.initialize(self, options)
  _private[self]={ shapes={} }
end

--[[ class destructor
  If you implement a destructor, it should allways call super.destroy(self) at the end 
  so everything is destroyed properly.
  If you are not implementing a destructor in your subclass, this will be taken care of automatically.
]]
function Actor:destroy()
  if(self.body~=nil) then self.body:destroy() end
  super.destroy(self)
end

function Actor:setBody(body)
  if(self.body~=nil) then self.body:destroy() end
  self.body = body
  return self.body
end

function Actor:setWorld(world)
  self.world = world
end

function Actor:getWorld()
  return self.world or _G.passion.physics.getWorld()
end

--[[ Creates a new body for the current actor
  Signatures: newBody() or newBody(x, y) or newBody(x, y, mass)
]]
function Actor:newBody(x, y, mass)
  world = self:getWorld()
  if(x==nil or y==nil) then
    self.body = _G.love.physics.newBody(world)
  elseif(mass==nil) then
    self.body = _G.love.physics.newBody(world, x, y)
  else
    self.body = _G.love.physics.newBody(world, x, y, mass)
  end
  return self.body
end

--[[ Returns the body actor, or throws an error
  * If raise error is nil or true, it will raise an error if the actor does not have a body
]]
function Actor:getBody(raiseError)
  raiseError = raiseError or false
  if raiseError then
    _G.assert(self.body ~= nil, "self.body is nil. You must invoke newBody or setBody on the Actor's constructor")
  end
  return self.body
end

--[[
Creates a new CircleShape, or a CircleShape with an offset
  Signatures:
    newCircleShape( radius )       Creates a new CircleShape.
    newCircleShape( offsetX, offsetY, radius ) Creates a new CircleShape with an offset
  Parameters:
    * offsetX: The x-component of the offset.
    * offsetY: The y-component of the offset.
    * radius: The radius of the circle
]]
function Actor:newCircleShape(offsetX, offsetY, radius)
  local body = self:getBody()
  local shape
  if(offsetY==nil or radius==nil) then shape= _G.love.physics.newCircleShape(body, offsetX)
  else shape = _G.love.physics.newCircleShape(body, offsetX, offsetY, radius)
  end
  return _addShape(self, shape)
end

--[[
Creates a new RectangleShape, or a RectangleShape with an offset
  Signatures:
    newRectangleShape( w, h )                           Creates a rectangle.
    newRectangleShape( offsetX, offsetY, w, h )         Creates a new rectangle with an offset.
    newRectangleShape( offsetX, offsetY, w, h, angle )  Creates a new rectangle with offset and orientation.
  Parameters:
  * offsetX: The x-component of the offset.
  * offsetY: The y-component of the offset.
  * w: The width of the rectangle.
  * h: The height of the rectangle.
  * angle: The orientation of the rectangle (degrees).
]]
function Actor:newRectangleShape(offsetX, offsetY, w, h, angle )
  local body = self:getBody()
  local shape
  if(w==nil or h==nil) then shape = _G.love.physics.newRectangleShape(body, offsetX, offsetY)
  elseif(angle==nil) then shape = _G.love.physics.newRectangleShape(body, offsetX, offsetY, w, h)
  else shape = _G.love.physics.newRectangleShape(body, offsetX, offsetY, w, h, angle)
  end
  return _addShape(self, shape)
end

-- Creates a new PolygonShape, using the parameters as an array of points
function Actor:newPolygonShape( ... )
  local body = self:getBody()
  return _addShape(self, _G.love.physics.newPolygonShape( body, ... ))
end

--[[ Gets the body's bounding box.
     Expensive-ish on complex bodies: It gets the bounding box of all shapes
     returns the bounding box like this: x,y,width,height
     x,y are the smallest numbers (upper-left corner by default)
]] 
function Actor:getBoundingBox()
  local shapes = _private[self].shapes

  if(#shapes > 0) then
    local maxX, maxY, minX, minY
    for _,shape in _G.pairs(shapes) do
      local t = shape:getType()
      if(t=='polygon') then
        local points = { shape:getPoints() }
        for i=1,#points,2 do
          local x,y = points[i], points[i+1]
          maxX, maxY = _max(maxX, x), _max(maxY, y)
          minX, minY = _min(minX, x), _min(minY, y)
        end
      elseif(t=='circle') then
        local cx,cy = shape:getWorldCenter()
        local r = shape:getRadius()
        maxX, maxY = _max(maxX, cx+r), _max(maxY, cy+r)
        minX, minY = _min(minX, cx-r), _min(minX, cy-r)
      else
        error('Unknown shape type: ' .. t)
      end
    end
    return minX, minY, maxX-minX, maxY-minY
  else -- this body has no shapes. Return a box with position but no width or height
    local x, y = self:getPosition()
    return x, y, 0, 0
  end
end


function Actor:applyToShapes(methodOrName, ...)
  _G.assert(self~=nil, 'Use actor:applyToShapes instead of actor.applyToShapes')
  _G.passion.apply(_private[self].shapes, methodOrName, ...)
end

function Actor:applyToShapesSorted(sortFunc, methodOrName, ...)
  _G.assert(self~=nil, 'Use actor:applyToShapesSorted instead of actor.applyToShapesSorted')
  _G.passion.applySorted(_private[self].shapes, sortFunc, methodOrName, ... )
end

-- Draws the shapes. Useful for debugging purposes
function Actor:drawShapes(style)
  self:applyToShapes(drawShape, style or 'line')
end

--[[ Implement all the love.Body methods so the actor can be used as a body.
  For example, after this code, there will be a function equivalent to
      function passion.HasBody.getX(...)
        local body=self:getBody()
        return body:getX(body, ...)
      end
  and the same goes for the rest of the functions
]]
for _,method in _G.pairs(_delegatedMethods) do
  Actor[method] = function(self, ...)
    local body = self:getBody()
    return body[method](body, ...)
  end 
end

------------------------------------
-- FROZEN STATE
------------------------------------
local Frozen = Actor.states.Frozen

--[[ Freeze the body, if it exists
  The best way I could find was resetting all important variables (mass, velocity, angularvel) to 0
  I store the previous values on a private variable, that I then use for "unfreezing" the body
]] 
function Frozen:enterState()
  if(self.body~=nil) then
    _private[self].prev = {}

    local p = _private[self].prev

    p.centerX, p.centerY = self:getLocalCenter()
    p.mass = self:getMass()
    p.inertia = self:getInertia()
    p.velX, p.velY = self:getLinearVelocity()
    p.velW = self:getAngularVelocity()

    self:setMass(p.centerX, p.centerY, 0, 0)
    self:setLinearVelocity(0,0)
    self:setAngularVelocity(0)
  end
end

function Frozen:exitState()
  if(self.body~=nil) then
    local p = _private[self].prev

    self:setMass(p.centerX, p.centerY, p.mass, p.inertia)
    self:setLinearVelocity(p.velX,p.velY)
    self:setAngularVelocity(p.velW)
  end
end

