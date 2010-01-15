require 'passion.gui.Core'
require 'passion.actors.Actor'

passion.gui.Pannel = class('passion.gui.Pannel', passion.Actor)
-- instance methods

passion.gui.Pannel.VALID_OPTIONS = { 
  'x', 'y', 'parent', 'width', 'height', 'backgroundColor', 'borderColor', 'borderWidth', 'borderStyle', 'cornerRadius', 'padding'
}

function passion.gui.Pannel:initialize(options)
  super(self)
  self:parseOptions(options, passion.gui.Pannel.VALID_OPTIONS)
end

function passion.gui.Pannel:parseOptions(options, validOptions)
  options = options or {}
  for _,option in pairs(validOptions) do
    local setterName = self.class:setterFor(option)
    local setter = self[setterName]
    assert(setter~=nil, "Setter function " .. setterName .. " not found on class " .. self.class.name)
    setter(self, options[option])
  end
end

passion.gui.Pannel:getterSetter('parent')
passion.gui.Pannel:getterSetter('width')
passion.gui.Pannel:getterSetter('height')
passion.gui.Pannel:getterSetter('backgroundColor')
passion.gui.Pannel:getterSetter('borderColor', passion.white)
passion.gui.Pannel:getterSetter('borderWidth', 1)
passion.gui.Pannel:getterSetter('borderStyle', 'smooth') -- it can also be 'rough'
passion.gui.Pannel:getterSetter('cornerRadius', 0)
passion.gui.Pannel:getterSetter('padding', 0)

-- FIXME: set cornerratius should increase padding

function passion.gui.Pannel:getX()
  local parent = self:getParent()
  return (self.x or 0) + (parent == nil and 0 or (parent:getX() + parent:getPadding()))
end

function passion.gui.Pannel:getY()
  local parent = self:getParent()
  return (self.y or 0) + (parent == nil and 0 or (parent:getY() + parent:getPadding()))
end

function passion.gui.Pannel:getPosition()
  local parent = self:getParent()
  if(parent == nil) then
    return self.x, self.y
  else
    return self:getX(), self:getY()
  end
end

function passion.gui.Pannel:draw()
  local x, y = self:getPosition()
  local width = self:getWidth()
  local height = self:getHeight()
  
  if(x~=nil and y~=nil and width~=nil and height~=nil) then
    self:drawBackground(x, y, width, height)
    self:drawBorder(x, y, width, height)
  end
end

function passion.gui.Pannel:drawBackground(x, y, width, height)
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

do
  local math_round = function (num, idp) local mult = 10^(idp or 0) return math.floor(num * mult + 0.5) / mult end 

  function passion.gui.Pannel:_drawCorners(x, y, width, height, r, lineWidth)
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
end

function passion.gui.Pannel:drawBorder(x, y, width, height)
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