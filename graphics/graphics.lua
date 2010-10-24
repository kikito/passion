local _G=_G

module('passion.graphics')

------------------------------------
-- PRIVATE METHODS AND ATTRIBUTES
------------------------------------

-- stores the images loaded
local _images = {}

-- stores what image was used to create each quad created with newQuad
local _quadImages = _G.setmetatable({}, {__mode = "k"})

-- stores the current camera being used
local _currentCamera = nil

------------------------------------
-- PUBLIC FUNCTIONS
------------------------------------

-- Gets or creates an image from a filepath, a file or data
function getImage(pathOrFileOrData)
  return _G.passion._getResource(_images, _G.love.graphics.newImage, pathOrFileOrData, pathOrFileOrData)
end

-- Draws a given shape, using 'fill' or 'line as the style'. Useful for debugging
function drawShape(style, shape)

  _G.assert(style=='line' or style=='fill', "style must be either 'line' or 'fill'")

  local shapeType = shape:getType()

  if(shapeType=="polygon") then
    _G.love.graphics.polygon(style, shape:getPoints())
  elseif(shapeType=="circle") then
    local r = shape:getRadius()
    local x, y = shape:getWorldCenter()
    _G.love.graphics.circle(style, x,y, r, r*3)
  else
    _G.error("Unkwnown shape type: "..shapeType)
  end
end

--[[ Draws a rounded rectangle (or its borders)
    "borrowed" from http://love2d.org/forum/viewtopic.php?f=5&t=1323
    FIXME: review the sin/cos calls. Maybe optimize without xround, yround.
]] 
function roundedRectangle(mode, x, y, width, height, cornerRadius)
  
  cornerRadius = cornerRadius or 0
  
  if cornerRadius == 0 then
    _G.love.graphics.rectangle(mode, x, y, width, height)
  else
    local xround, yround = cornerRadius, cornerRadius
    
    local points = {}
    local precision = (xround + yround) * .1
    local tI, hP = _G.table.insert, .5*_G.math.pi
      if xround > width*.5 then xround = width*.5 end
      if yround > height*.5 then yround = height*.5 end
    local X1, Y1, X2, Y2 = x + xround, y + yround, x + width - xround, y + height - yround
    local sin, cos = _G.math.sin, _G.math.cos
    for i = 0, precision do
      local a = (i/precision-1)*hP
      tI(points, X2 + xround*cos(a))
      tI(points, Y1 + yround*sin(a))
    end
    for i = 0, precision do
      local a = (i/precision)*hP
      tI(points, X2 + xround*cos(a))
      tI(points, Y2 + yround*sin(a))
    end
    for i = 0, precision do
      local a = (i/precision+1)*hP
      tI(points, X1 + xround*cos(a))
      tI(points, Y2 + yround*sin(a))
    end
    for i = 0, precision do
      local a = (i/precision+2)*hP
      tI(points, X1 + xround*cos(a))
      tI(points, Y1 + yround*sin(a))
    end
    _G.love.graphics.polygon(mode, _G.unpack(points))
  end
end

--[[ Creates a new quad without you having to provide rwidth and rheight. Remembers the image used.
     This means that you don't have to pass the image to drawq - it is stored in PÄSSION.
]]
function newQuad(image, x, y, width, height, rWidth, rHeight)
  rWidth = rWidth or image:getWidth()
  rHeight = rHeight or image:getHeight()
  local quad = _G.love.graphics.newQuad( x, y, width, height, rWidth, rHeight )
  _quadImages[quad] = image
  return quad
end

--[[ Similar to love.graphics.drawq, but you don't have to provide the image 
     In order for it to work, you need to create de quad with newQua, 
     not with love.graphics.newQuad
]]
function drawq(quad, x, y, r, sx, sy, ox, oy)
  local image = _quadImages[quad]
  _G.assert(image~=nil, "Image not found for the quad. Please use newQuad instead of love.graphics.newQuad")
  _G.love.graphics.drawq(image, quad, x, y, r, sx, sy, ox, oy)
end

function setColor(r,g,b,a)
  if(_G.type(r)=="table") then
    a = g or r[4]
    b = r[3]
    g = r[2]
    r = r[1]
  end
  a = a or 255
  _G.love.graphics.setColor(r,g,b,a)
end

function setAlpha(alpha)
  local r,g,b = _G.love.graphics.getColor()
  _G.love.graphics.setColor(r,g,b,alpha)
end

