require 'passion.gui.Core'
require 'passion.actors.Actor'

passion.gui.Pannel = class('passion.gui.Pannel', passion.Actor)
local Pannel = passion.gui.Pannel

-- instance methods

local VALID_OPTIONS = { 
  'x', 'y', 'width', 'height', 'backgroundColor', 'borderColor', 'borderWidth', 'borderStyle', 'cornerRadius', 
  'padding', 'leftPadding', 'rightPadding', 'topPadding', 'bottomPadding'
}

function Pannel:initialize(options)
  super.initialize(self)
  self:parseOptions(options, VALID_OPTIONS)
end

function Pannel:parseOptions(options, validOptions)
  options = options or {}
  for _,option in pairs(validOptions) do
    if(options[option]~=nil) then
      local setterName = self.class:setterFor(option)
      local setter = self[setterName]
      assert(setter~=nil, "Setter function " .. setterName .. " not found on class " .. self.class.name)
      setter(self, options[option])
    end
  end
end

Pannel:getterSetter('backgroundColor')
Pannel:getterSetter('borderColor', passion.white)
Pannel:getterSetter('borderWidth', 1)
Pannel:getterSetter('borderStyle', 'smooth') -- it can also be 'rough'
Pannel:getterSetter('cornerRadius', 0)
Pannel:setter('width')
Pannel:setter('height')

function Pannel:getWidth()
  self.width = self.width or 0
  local maxWidth = self:getMaxWidth()
  if(maxWidth ~= nil and maxWidth < self.width) then self.width = maxWidth end
  return self.width
end

function Pannel:getHeight()
  self.height = self.height or 0
  local maxHeight = self:getMaxHeight()
  if(maxHeight ~= nil and maxHeight < self.height) then self.height = maxHeight end
  return self.height
end

-- returns the max height that the pannel can have, if it is inside of another pannel (otherwise, nil)
-- FIXME: take local y into account
function Pannel:getMaxHeight()
  local parent = self:getParent()
  if(parent ~= nil) then return parent:getInternalHeight() end
  return nil
end

-- returns the max width that the pannel can have, if it is inside of another pannel (otherwise, nil)
-- FIXME: take local y into account
function Pannel:getMaxWidth()
  local parent = self:getParent()
  if(parent ~= nil) then return parent:getInternalWidth() end
  return nil
end

-- returns the height of the 'Internal' box (the space inside the pannel, with the padding taken out)
function Pannel:getInternalHeight()
  return (self:getHeight() - self:getTopPadding() - self:getBottomPadding())
end

-- returns the width of the 'Internal' box (the space inside the pannel, with the padding taken out)
function Pannel:getInternalWidth()
  return (self:getWidth() - self:getLeftPadding() - self:getRightPadding())
end

-- returns x, y, width and height, with x and y being the top-left corner
function Pannel:getBoundingBox()
  local x, y = self:getPosition()
  return x, y, self:getWidth(), self:getHeight()
end

-- returns the boundingbox minus the padding. It also returns x,y,InternalWidth,InternalHeight
function Pannel:getInternalBox()
  local x, y = self:getPosition()
  return x+self:getLeftPadding(), y+self:getTopPadding(), self:getInternalWidth(), self:getInternalHeight()
end

-- define getters & setters for paddings (i.e. setLeftPadding, getLeftPadding)
for _,paddingName in pairs({'leftPadding', 'rightPadding', 'topPadding', 'bottomPadding'}) do 
  Pannel:setter(paddingName)
  Pannel[Pannel:getterFor(paddingName)] = function(self)
    local cornerRadius = self:getCornerRadius()
    if(self[paddingName]==nil or cornerRadius > self[paddingName]) then
      self[paddingName] = cornerRadius
    end
    return self[paddingName] or 0
  end
end

--[[ Sets the padding in general.
     The default parameter order is left, right, top, bottom.
     Exceptions:
       * If left is a table, the rest of the parameters are ignored. It is assumed that left has the form {left, right, top, bottom}
       * If left is a number, and the rest are nil, then padding is set uniformly (the 4 paddings will have that value, not just left)
     For finer control, use setLeftPadding, setRightPadding, setTopPadding & setBottomPadding
]]
function Pannel:setPadding(left, right, top, bottom)
  if(type(left) == 'table') then
    right = left[2]
    top = left[3]
    bottom = left[4]
    left = left[1]
  elseif(type(left) == 'number' and right==nil and top==nil and bottom==nil) then
    right = left
    top = left
    bottom = left
  end
  
  self:setLeftPadding(left)
  self:setRightPadding(right)
  self:setTopPadding(top)
  self:setBottomPadding(bottom)
end

-- allways returns left, right, top & bottom padding
function Pannel:getPadding()
  return self:getLeftPadding(), self:getRightPadding(), self:getTopPadding(), self:getBottomPadding()
end

-- If you reset the corner Radius, and it is "bigger" than the padding, then adjust the padding.
-- FIXME: cornerRadius incrementing padding?
function Pannel:setCornerRadius(cornerRadius)
  self.cornerRadius = cornerRadius
end

function Pannel:getX()
  local parent = self:getParent()
  return self:getLocalX() + (parent == nil and 0 or (parent:getX() + parent:getLeftPadding()))
end

function Pannel:getY()
  local parent = self:getParent()
  return self:getLocalY() + (parent == nil and 0 or (parent:getY() + parent:getTopPadding()))
end

function Pannel:getPosition()
  local parent = self:getParent()
  if(parent == nil) then
    return self.x, self.y
  else
    return self:getX(), self:getY()
  end
end

function Pannel:getLocalX() return self.x or 0 end
function Pannel:getLocalY() return self.y or 0 end
function Pannel:getLocalPosition() return self.x, self.y end

function Pannel:drawOrder()
  if(self.drawOrder~=nil) then return self.drawOrder end
  
  local parent = self:getParent()
  if(parent~=nil) then
    return parent:getDrawOrder() - 1
  end
  
  return 0
end


function Pannel:draw()
  local x, y = self:getPosition()
  local width = self:getWidth()
  local height = self:getHeight()
  
  if(x~=nil and y~=nil and width~=nil and height~=nil) then
    self:drawBackground(x, y, width, height)
    self:drawBorder(x, y, width, height)
  end
end


function Pannel:drawBackground(x, y, width, height)
  local backgroundColor = self:getBackgroundColor()

  if(backgroundColor~=nil) then
    local r, g, b, a = love.graphics.getColor()
    local cornerRadius = self:getCornerRadius()
    local cornerRadius_2 = cornerRadius * 2
    local cornerRadius_3 = cornerRadius * 3

    love.graphics.setColor(unpack(backgroundColor))

    if(cornerRadius > 0) then
      love.graphics.rectangle('fill', x+cornerRadius, y, width-cornerRadius_2, height)
      love.graphics.rectangle('fill', x, y+cornerRadius, width, height-cornerRadius_2)
      love.graphics.circle('fill', x+cornerRadius, y+cornerRadius, cornerRadius, cornerRadius_3)
      love.graphics.circle('fill', x+width-cornerRadius, y+cornerRadius, cornerRadius, cornerRadius_3)
      love.graphics.circle('fill', x+cornerRadius, y+height-cornerRadius, cornerRadius, cornerRadius_3)
      love.graphics.circle('fill', x+width-cornerRadius, y+height-cornerRadius, cornerRadius, cornerRadius_3)
    else
      love.graphics.rectangle('fill', x, y, width, height)
    end

    love.graphics.setColor(r,g,b,a)
  end
end


function Pannel:drawBorder(x, y, width, height)
  local lineColor = self:getBorderColor()

  if(lineColor~=nil) then
    local lineWidth = self:getBorderWidth()
    local lineStyle = self:getBorderStyle()
    local cornerRadius = self:getCornerRadius()
    local cornerRadius_2 = cornerRadius * 2
    local cornerRadius_3 = cornerRadius * 3

    local r, g, b, a = love.graphics.getColor()
    local w = love.graphics.getLineWidth()
    local s = love.graphics.getLineStyle()

    love.graphics.setColor(unpack(lineColor))
    love.graphics.setLineWidth(lineWidth)
    love.graphics.setLineStyle(lineStyle)

    if(cornerRadius > 0) then
      love.graphics.line(x+cornerRadius, y, x+width-cornerRadius, y)
      love.graphics.line(x+width, y+cornerRadius, x+width, y+height-cornerRadius)
      love.graphics.line(x+cornerRadius, y+height, x+width-cornerRadius, y+height)
      love.graphics.line(x, y+cornerRadius, x, y+height-cornerRadius)

      self:_drawCorners(x, y, width, height, cornerRadius, lineWidth)

    else
      love.graphics.rectangle('line', x, y, width, height)
    end

    love.graphics.setColor(r,g,b,a)
    love.graphics.setLineWidth(w)
    love.graphics.setLineStyle(s)
  end
end

local math_round = function (num, idp) local mult = 10^(idp or 0) return math.floor(num * mult + 0.5) / mult end 

function Pannel:_drawCorners(x, y, width, height, r, lineWidth)
    local step = 1.0 / r
    local theta = 0.0
    local c = r + 0.0
    local s = 0.0
    local pc = c
    local ps = s

    while(theta <= math.pi / 4.0) do
      theta = theta + step
      c = math_round(r*math.cos(theta)) -- rounded cosine
      s = math_round(r*math.sin(theta)) -- rounded sine
      
      r_2 = lineWidth / 2.0
      r_23 = r_2*3

      love.graphics.line(x+width-r+pc, y+r-ps, x+width-r+c, y+r-s) -- octant 0
      love.graphics.line(x+width-r+ps, y+r-pc, x+width-r+s, y+r-c) -- octant 1
      love.graphics.line(x+r-pc, y+r-ps, x+r-c, y+r-s) -- octant 2
      love.graphics.line(x+r-ps, y+r-pc, x+r-s, y+r-c) -- octant 3
      love.graphics.line(x+r-pc, y+height-r+ps, x+r-c, y+height-r+s) -- octant 4
      love.graphics.line(x+r-ps, y+height-r+pc, x+r-s, y+height-r+c) -- octant 5
      love.graphics.line(x+width-r+pc, y+height-r+ps, x+width-r+c, y+height-r+s) -- octant 6
      love.graphics.line(x+width-r+ps, y+height-r+pc, x+width-r+s, y+height-r+c) -- octant 8

      if(r_2 > 1) then
        love.graphics.circle('fill', x+width-r+pc, y+r-ps, r_2, r_23)
        love.graphics.circle('fill', x+width-r+ps, y+r-pc, r_2, r_23)
        love.graphics.circle('fill', x+r-pc, y+r-ps, r_2, r_23)
        love.graphics.circle('fill', x+r-ps, y+r-pc, r_2, r_23)
        love.graphics.circle('fill', x+r-pc, y+height-r+ps, r_2, r_23)
        love.graphics.circle('fill', x+r-ps, y+height-r+pc, r_2, r_23)
        love.graphics.circle('fill', x+width-r+pc, y+height-r+ps, r_2, r_23)
        love.graphics.circle('fill', x+width-r+ps, y+height-r+pc, r_2, r_23)
      end

      pc = c
      ps = s
    end

end
