passion.ActorWithBody = class('passion.ActorWithBody', passion.Actor)

local ActorWithBody = passion.ActorWithBody

------------------------------------
-- PRIVATE METHODS AND ATTRIBUTES
------------------------------------

-- stores the shapes of each actor, and its pre-freezing properties
_private = setmetatable({}, {__mode = "k"})

-- used for adding shapes to the collection of shapes of the body
local _addShape = function(self, shape)
  table.insert(_private[self].shapes, shape)
  shape:setData(self)
  return shape
end

-- calculates the maximum between two numbers. If the first is nil, just return the second
local _max = function(a,b,c,d,e)
  return math.max(a==nil and b or a, b,c,d,e)
end

-- calculates the minimum between two numbers. If the first is nil, just return the second
local _min = function(a,b,c,d,e)
  return math.min(a==nil and b or a, b,c,d,e)
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

------------------------------------
-- INSTANCE METHODS
------------------------------------

-- class constructor. The options can be used to initialize states
function ActorWithBody:initialize(options)
  super.initialize(self, options)
  _private[self]={ shapes={} }
end

--[[ class destructor
  If you implement a destructor, it should allways call super.destroy(self) at the end 
  so everything is destroyed properly.
  If you are not implementing a destructor in your subclass, this will be taken care of automatically.
]]
function ActorWithBody:destroy()
  if(self.body~=nil) then self.body:destroy() end
  super.destroy(self)
end

function ActorWithBody:setBody(body)
  if(self.body~=nil) then self.body:destroy() end
  self.body = body
  return self.body
end

function ActorWithBody:setWorld(world)
  self.world = world
end

function ActorWithBody:getWorld()
  return self.world or passion.physics.getWorld()
end

--[[ Creates a new body for the current actor
  Signatures: newBody() or newBody(x, y) or newBody(x, y, mass)
]]
function ActorWithBody:newBody(x, y, mass)
  world = self:getWorld()
  if(x==nil or y==nil) then
    self.body = love.physics.newBody(world)
  elseif(mass==nil) then
    self.body = love.physics.newBody(world, x, y)
  else
    self.body = love.physics.newBody(world, x, y, mass)
  end
  return self.body
end

--[[ Returns the body actor, or throws an error
  * If raise error is nil or true, it will raise an error if the actor does not have a body
]]
function ActorWithBody:getBody(raiseError)
  raiseError = raiseError or false
  if raiseError then
    assert(self.body ~= nil, "self.body is nil. You must invoke newBody or setBody on the Actor's constructor")
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
function ActorWithBody:newCircleShape(offsetX, offsetY, radius)
  local body = self:getBody()
  local shape
  if(offsetY==nil or radius==nil) then shape= love.physics.newCircleShape(body, offsetX)
  else shape = love.physics.newCircleShape(body, offsetX, offsetY, radius)
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
function ActorWithBody:newRectangleShape(offsetX, offsetY, w, h, angle )
  local body = self:getBody()
  local shape
  if(w==nil or h==nil) then shape = love.physics.newRectangleShape(body, offsetX, offsetY)
  elseif(angle==nil) then shape = love.physics.newRectangleShape(body, offsetX, offsetY, w, h)
  else shape = love.physics.newRectangleShape(body, offsetX, offsetY, w, h, angle)
  end
  return _addShape(self, shape)
end

-- Creates a new PolygonShape, using the parameters as an array of points
function ActorWithBody:newPolygonShape( ... )
  local body = self:getBody()
  return _addShape(self, love.physics.newPolygonShape( body, ... ))
end

--[[ Gets the body's bounding box.
     Expensive-ish on complex bodies: It gets the bounding box of all shapes
     returns the bounding box like this: x,y,width,height
     x,y are the smallest numbers (upper-left corner by default)
]] 
function ActorWithBody:getBoundingBox()
  local x1,y1,x2,y2,x3,y3,x4,y4
  local maxX, maxY, minX, minY
  for _,shape in pairs(_private[self].shapes) do
    x1,y1,x2,y2,x3,y3,x4,y4 = shape:getBoundingBox()
    maxX = _max(maxX, x1,x2,x3,x4)
    maxY = _max(maxY, y1,y2,y3,y4)
    minX = _min(minX, x1,x2,x3,x4)
    minY = _min(minY, y1,y2,y3,y4)
  end
  return minX, minY, maxX-minX, maxY-minY
end


function ActorWithBody:applyToShapes(methodOrName, ...)
  assert(self~=nil, 'Use actor:applyToShapes instead of actor.applyToShapes')
  self:applyToShapesSorted(nil, methodOrName, ...)
end

function ActorWithBody:applyToShapesSorted(sortFunc, methodOrName, ...)
  assert(self~=nil, 'Use actor:applyToShapesSorted instead of actor.applyToShapesSorted')
  passion.apply(_private[self].shapes, sortFunc, methodOrName, ... )
end

-- Draws the shapes. Useful for debugging purposes
function ActorWithBody:drawShapes(style)
  self:applyToShapes(passion.graphics.drawShape, style or 'line', shape)
end

--[[ Implement all the love.Body methods so the actor can be used as a body.
  For example, after this code, there will be a function equivalent to
      function passion.HasBody.getX(...)
        local body=self:getBody()
        return body:getX(body, ...)
      end
  and the same goes for the rest of the functions
]]
for _,method in pairs(_delegatedMethods) do
  ActorWithBody[method] = function(self, ...)
    local body = self:getBody()
    return body[method](body, ...)
  end 
end

------------------------------------
-- FROZEN STATE
------------------------------------
local Frozen = ActorWithBody.states.Frozen

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

