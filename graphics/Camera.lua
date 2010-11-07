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

function Matrix:copy(other)
  for k,v in _G.pairs(other.elems) do self.elems[k] = v end
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

-- self:      other:
-- e1 e2 e3   f1 f2 f3
-- e4 e5 e6   f4 f5 f6
--  0  0  1    0  0  1
function Matrix:mult(other)
  local e = self.elems
  local e1,e2,e3,e4,e5,e6 = _G.unpack(self.elems)
  local f1,f2,f3,f4,f5,f6 = _G.unpack(other.elems)
  e[1], e[2], e[3], e[4], e[5], e[6] =
    e1*f1 + e2*f4, e1*f2 + e2*f5, e1*f3+e2*f6+e3,
    e4*f1 + e5*f4, e4*f2 + e5*f5, e4*f3+e5*f6+e6
end

------------------------------------------
--           CAMERA STUFF               --
------------------------------------------

Camera = _G.class('passion.graphics.Camera')
Camera:include(_G.Stateful)
Camera:include(_G.Apply)

local _current = nil -- current camera being used

local _recalculate
_recalculate = function(self)

  if(self.parent ~= nil) then
    self.dirty = _recalculate(self.parent) or self.dirty
  end

  if(self.dirty == false) then return false end

  if(self.parent~=nil) then
    self.matrix:copy(self.parent.matrix)
  else
    self.matrix:reset()
  end
  self.matrix:leftRotate(-self.angle)
  self.matrix:leftScale(1.0/self.sx, 1.0/self.sy)
  self.matrix:leftTranslate(-self.x, -self.y)

  self.inverse:reset()
  self.inverse:leftRotate(self.angle)
  self.inverse:leftScale(self.sx, self.sy)
  self.inverse:leftTranslate(self.x, self.y)

  if(self.parent~=nil) then
    self.inverse:mult(self.parent.inverse)
  end

  self.dirty = false

  return true
end

function Camera:initialize(parent)
  super.initialize(self)
  self.parent = parent
  self.matrix = Matrix:new()
  self.inverse = Matrix:new()
  self:reset()
end

function Camera:update(dt)
  -- this method is supposed to be re-defined by users creating new cameras.
  -- ideally they should use reset(), translate, scale and rotate for interesting effects
end

function Camera:reset()
  self.x, self.y, self.sx, self.sy, self.angle = 0.0,0.0,1.0,1.0,0.0
  self.dirty = true
end

function Camera:setParent(parent)
  if(parent == self.parent) then return end
  self.parent = parent
  self.dirty = true
end

function Camera:setPosition(x,y)
  if(x == self.x and y == self.y) then return end
  self.x, self.y = x,y
  self.dirty = true
end

function Camera:setScale(sx,sy)
  if(sx == self.sx and sy == self.sy) then return end
  self.sx, self.sy = sx,sy
  self.dirty = true
end

function Camera:setAngle(angle)
  if(angle == self.angle) then return end
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

function Camera:getParent()
  return self.parent
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
  
  if(self.parent~=nil) then
    self.parent:set()
  elseif(_current~= nil and _current:unset(self)~=nil) then
    return
  end
  self:push()
  _current = self
  _recalculate(self)
end

function Camera:push()
  _G.love.graphics.push()
  _G.love.graphics.rotate(-self.angle)
  _G.love.graphics.scale(1.0/self.sx, 1.0/self.sy)
  _G.love.graphics.translate(-self.x, -self.y)
end

function Camera:unset(target)
  if(_current==nil) then return nil end
  if(target==self) then
    _current=target
  else
    _G.love.graphics.pop()
    if(self.parent~=nil) then self.parent:unset(target) end
    _current=nil
  end
  return _current
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

function Camera.clear(theClass)
  if(_current ~= nil) then _current:unset() end
  _current = nil
end


