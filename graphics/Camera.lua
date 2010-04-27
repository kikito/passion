local _G = _G

module('passion.graphics')

-- The following code is based *heavily* on pekka (Pekka Karjalainen)'s work.
-- I could not have done it without it.

------------------------------------------
--           MATRIX STUFF               --
------------------------------------------

local Matrix = _G.class('Matrix')

-- create a new matrix and initialize it with the values of the identity matrix
function Matrix:initialize()
  super.initialize(self)
  self:reset()
end

-- transform a matrix on the idendity matrix
function Matrix:reset()
  self.elems = {1.0, 0.0, 0.0, 0.0, 1.0, 0.0}
end

-- multiply the column vector x y 1 with the matrix
function Matrix:multVector(x, y)
  local e = self.elems
  return e[1]*x + e[2]*y + e[3], e[4]*x + e[5]*y + e[6]
end

-- multiply the matrix from the left by a translation with dx dy
-- the translation matrix is
-- 1 0 dx
-- 0 1 dy
-- 0 0  1
-- (the multiplication simplifies to two additions)
function Matrix:leftTranslate(dx, dy)
  local e = self.elems
  e[3] = e[3] + dx
  e[6] = e[6] + dy
end

-- multiply the matrix from the left by a scaling with sx sy
-- the scaling matrix is
-- sx 0 0
-- 0 sy 0
-- 0  0 1
-- (the multiplication simplifies to separate scalar multiplications)
function Matrix:leftScale(sx, sy)
  local e = self.elems
  e[1] = sx * e[1]
  e[2] = sx * e[2]
  e[3] = sx * e[3]
  e[4] = sy * e[4]
  e[5] = sy * e[5]
  e[6] = sy * e[6]
end

-- multiply the matrix from the left by a rotation with ar
-- the rotation matrix is
-- cos ar -sin ar 0
-- sin ar  cos ar 0
--      0       0 1
-- (the multiplication is a little more complex than above...)
function Matrix:leftRotate(ar)
  local cs, sn = _G.math.cos(ar), _G.math.sin(ar)
  local e = self.elems
  -- all six elements updated in one simultaneous assigment
  e[1], e[2], e[3], e[4], e[5], e[6] =
    cs * e[1] - sn * e[4], cs * e[2] - sn * e[5], cs * e[3] - sn * e[6], 
    sn * e[1] + cs * e[4], sn * e[2] + cs * e[5], sn * e[3] + cs * e[6]
end

------------------------------------------
--           CAMERA STUFF               --
------------------------------------------

Camera = _G.class('passion.graphics.Camera', _G.StatefulObject)
Camera:includes(_G.Beholder)

local _cameras = _G.setmetatable({}, {__mode = "k"}) -- list of all available cameras (used for updating)

local _current = nil -- current camera being used

local _recalculate = function(self)

  if(self.dirty==false) then return end
  self.matrix:reset()
  self.matrix:leftTranslate(self.x, self.y)
  self.matrix:leftRotate(self.angle)
  self.matrix:leftScale(self.sx, self.sy)

  self.inverse:reset()
  self.inverse:leftTranslate(-self.x, -self.y)
  self.inverse:leftRotate(-self.angle)
  self.inverse:leftScale(1.0/self.sx, 1.0/self.sy)

  self.dirty = false
end

function Camera:initialize()
  super.initialize(self)
  self.matrix = Matrix:new()
  self.inverse = Matrix:new()
  self:reset()
  _cameras[self]=self
end

function Camera:update(dt)
  -- this method is supposed to be re-defined by users creating new cameras.
  -- ideally they should use reset(), translate, scale and rotate for interesting effects
end

function Camera:reset()
  self.x, self.y, self.sx, self.sy, self.angle = 0.0,0.0,1.0,1.0,0.0
  self.dirty = true
end

function Camera:setPosition(x,y)
  self.x, self.y = x,y
  self.dirty = true
end

function Camera:setScale(sx,sy)
  self.sx, self.sy = sx,sy
  self.dirty = true
end

function Camera:setAngle(angle)
  self.angle = angle
  self.dirty = true
end

function Camera:getPosition()
  return self.x, self.y
end

function Camera:getScale()
  return self.sx, self.sy
end

function Camera:getAngle()
  return self.angle
end

function Camera:translate(dx,dy)
  self:setPosition(self.x + dx, self.y + dy)
end

function Camera:scale(sdx,sdy)
  self:setScale(self.sx * sdx, self.sy * sdy)
end

function Camera:rotate(angle)
  self:setAngle(self.angle + angle)
end

function Camera:set()
  if(_current==self) then return end
  
  if(_current~=nil) then
    _current:unset()
  end
  _recalculate(self)
  _G.love.graphics.push()
  _G.love.graphics.translate(self.x, self.y)
  _G.love.graphics.rotate(self.angle)
  _G.love.graphics.scale(self.sx, self.sy)
  _current = self
end

function Camera:unset()
  _G.love.graphics.pop()
  _current = nil
end

function Camera:draw(actor)
  self:set()
  actor:draw()
  self:unset()
end


function Camera:getMatrix()
  _recalculate(self)
  return self.matrix
end

function Camera:getInverse()
  _recalculate(self)
  return self.inverse
end

function Camera:invert(x,y)
  return self:getInverse():multVector(x,y)
end

function Camera:transform(x,y)
  return self:getMatrix():multVector(x,y)
end

function Camera:destroy()
  _cameras[self]=nil
  super.destroy(self)
end

------------------------------------------
--  DEFAULT CAMERA (does nothing)       --
------------------------------------------

defaultCamera = Camera:new()


------------------------------------------
--         CLASS METHODS                --
------------------------------------------
function Camera.getCurrent(theClass)
  return _current
end

function Camera.apply(theClass, methodName, ...)
  _G.passion.apply(_cameras, methodName, ...)
end

function Camera.clear(theClass)
  if(_current ~= nil) then _current:unset() end
  _current = nil
end

