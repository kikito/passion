

require 'passion.Core'

passion.HasBody = {

  setBody=function(self, body)
    self.body = body
    return self.body
  end,

  --[[ Creates a new body for the current actor
    Signatures: newBody() or newBody(x, y) or newBody(x, y, mass)
  ]]
  newBody = function(self, x, y, mass)
    world = passion:getWorld()
    if(x==nil or y==nil) then
      self.body = love.physics.newBody(world)
    elseif(mass==nil) then
      self.body = love.physics.newBody(world, x, y)
    else
      self.body = love.physics.newBody(world, x, y, mass)
    end
    return self.body
  end,

  getBody = function(self)
    assert(self.body ~= nil, "self.body is nil. You must invoke newBody or setBody on the Actor's constructor")
    return self.body
  end,
  
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
  newCircleShape = function( self, offsetX, offsetY, radius )
    local body = self:getBody()
    local shape
    if(offsetY==nil or radius==nil) then shape= love.physics.newCircleShape(body, offsetX)
    else shape = love.physics.newCircleShape(body, offsetX, offsetY, radius)
    end
    return self:addShape(shape)
  end,

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
  newRectangleShape = function( self, offsetX, offsetY, w, h, angle )
    local body = self:getBody()
    local shape
    if(w==nil or h==nil) then shape = love.physics.newRectangleShape(body, offsetX, offsetY)
    elseif(angle==nil) then shape = love.physics.newRectangleShape(body, offsetX, offsetY, w, h)
    else shape = love.physics.newRectangleShape(body, offsetX, offsetY, w, h, angle)
    end
    return self:addShape(shape)
  end,

  -- Creates a new PolygonShape, using the parameters as an array of points
  newPolygonShape = function( self, ... )
    local body = self:getBody()
    return self:addShape(love.physics.newPolygonShape( body, ... ))
  end,
  
  -- Manage shapes do they don't get garbage-collected
  getShapes = function(self)
    if(self.shapes == nil) then self.shapes = {} end
    return self.shapes
  end,
  
  addShape = function(self, shape)
    table.insert(self:getShapes(), shape)
    shape:setData(self)
    return shape
  end
}

-- TODO: JOINS


--[[
  Define all the following functions so the actor acts as a proxy to the internal body object.
  for example, after this code, there will be a function equivalent to
      function passion.HasBody.getX(...)
        local body=self:getBody()
        return body:getX(body, ...)
      end
  and the same goes for the rest of the functions
]]
do

local delegatedMethods = {
  'applyForce', 'applyImpulse', 'applyTorque', 'getAngle', 'getAngularDamping', 'getAngularVelocity', 'getInertia', 'getLinearDamping',
  'getLinearVelocity', 'getLinearVelocityFromLocalPoint', 'getLinearVelocityFromWorldPoint', 'getLocalCenter',
  'getLocalPoint', 'getLocalVector', 'getMass', 'getPosition', 'getWorldCenter', 'getWorldPoint', 'getWorldVector',
  'getX', 'getY', 'isBullet', 'isDynamic', 'isFrozen', 'isSleeping', 'isStatic', 'putToSleep', 'setAllowSleeping',
  'setAngle', 'setAngularDamping', 'setAngularVelocity', 'setBullet', 'setLinearDamping', 'setLinearVelocity',
  'setMass', 'setMassFromShapes', 'setPosition', 'setX', 'setY', 'wakeUp'
}

for _,method in pairs(delegatedMethods) do
  passion.HasBody[method] = function(self, ...)
    local body = self:getBody()
    return body[method](body, ...)
  end 
end

end

