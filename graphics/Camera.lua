local _G = _G

module('passion.graphics')

-- The following code is based *heavily* on Pekka Karjalainen's work.
-- I could not have done it without it.


------------------------------------------
--           MATRIX STUFF               --
------------------------------------------

local Matrix = _G.class('Matrix')

-- create a new matrix and initialize it with the values of the identity matrix
function Matrix:new()
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

-- private method used for adding operations to the camera's queue
local _addOperation= function(self, f, ...)
  _G.table.insert(self.operations, {f=f, params={...}})
end

function Camera:initialize()
  super.initialize(self)
  self.inversionMatrix = Matrix:new()
  self.transformMatrix = Matrix:new()
  self.operations = {}
  _cameras[self]=self
end

function Camera:update(dt)
  -- this method is supposed to be re-defined by users creating new cameras.
  -- ideally they should use reset(), translate, scale and rotate for interesting effects
end

function Camera:reset()
  self.operations = {}
  self.inversionMatrix:reset()
  self.transformMatrix:reset()
end

function Camera:translate(dx,dy)
  _addOperation(self, _G.love.graphics.translate, dx, dy)
  self.transformMatrix:leftTranslate(dx, dy)
  self.inversionMatrix:leftTranslate(-dx, -dy)
end

function Camera:scale(dsx, dsy)
  _addOperation(self, _G.love.graphics.scale, dsx, dsy)
  _G.passion.dumpTable(self)
  self.transformMatrix:leftScale(dsx, dsy)
  self.inversionMatrix:leftScale(1.0/dsx, 1.0/dsy)
end

function Camera:rotate(rotation)
  _addOperation(self, _G.love.graphics.rotate, rotation)
  self.transformMatrix:leftRotate(rotation)
  self.inversionMatrix:leftRotate(-rotation)
end

function Camera:invert(x,y)
  return self.inversionMatrix:multVector(x,y)
end

function Camera:transform(x,y)
  return self.transformMatrix:multVector(x,y)
end

function Camera:set()
  if(_current==self) then return end
  if(_current~=nil) then
    _current:unset()
  end
  _current = self
  _G.love.graphics.push()
  for _,ops in _G.ipairs(self.operations) do
    ops.f(_G.unpack(ops.params))
  end
end

function Camera:unset()
  _G.love.graphics.pop()
  _current = nil
end

function Camera:destroy()
  _cameras[self]=nil
  super.destroy(self)
end

-- Class methods

function Camera.apply(theClass, methodOrName, ...)
  _G.assert(theClass~=nil, 'Please invoke Class:apply instead of Class.apply')
  _G.passion.apply(_cameras, methodOrName, ...)
end

function Camera.getCurrent(theClass)
  return _current
end

------------------------------------------
--  DEFAULT CAMERA (does nothing)       --
------------------------------------------

defaultCamera = Camera:new()
