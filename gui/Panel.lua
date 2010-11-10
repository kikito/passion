local _G=_G

module('passion.gui')
Panel = _G.class('passion.gui.Panel', _G.passion.Actor)

-- instance methods

local VALID_OPTIONS = { 
  'x', 'y', 'width', 'height', 'backgroundColor', 'borderColor', 'borderWidth', 'borderStyle', 'cornerRadius', 
  'padding', 'leftPadding', 'rightPadding', 'topPadding', 'bottomPadding', 'alpha', 'parent'
}

function Panel:initialize(options)
  super.initialize(self)
  self:setInternalCamera(_G.passion.graphics.Camera:new())
  self:parseOptions(options, VALID_OPTIONS)
end

function Panel:parseOptions(options, validOptions)
  options = options or {}
  for _,option in _G.pairs(validOptions) do
    if(options[option]~=nil) then
      local setterName = self.class:setterFor(option)
      local setter = self[setterName]
      _G.assert(setter~=nil, "Setter function " .. setterName .. " not found on class " .. self.class.name)
      setter(self, options[option])
    end
  end
end

Panel:getterSetter('backgroundColor')
Panel:getterSetter('borderColor', _G.passion.colors.white)
Panel:getterSetter('borderWidth', 1)
Panel:getterSetter('borderStyle', 'smooth') -- it can also be 'rough'
Panel:getterSetter('cornerRadius', 0)
Panel:getterSetter('width', 0)
Panel:getterSetter('height', 0)
Panel:setter('alpha')
Panel:getterSetter('internalCamera')

--------------------------------------------------
--            PADDING METHODS
--------------------------------------------------

-- define getters & setters for paddings (i.e. setLeftPadding, getLeftPadding)
-- paddings must be equal or greater than the corner radius, in all directions
for _,paddingName in _G.pairs({'leftPadding', 'rightPadding', 'topPadding', 'bottomPadding'}) do 
  Panel:setter(paddingName)
  Panel[_G.GetterSetter:getterFor(paddingName)] = function(self)
    local cornerRadius = self:getCornerRadius()
    if(self[paddingName]==nil or cornerRadius > self[paddingName]) then
      return cornerRadius
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
function Panel:setPadding(left, right, top, bottom)
  if(_G.type(left) == 'table') then
    right = left[2]
    top = left[3]
    bottom = left[4]
    left = left[1]
  elseif(_G.type(left) == 'number' and right==nil and top==nil and bottom==nil) then
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
function Panel:getPadding()
  return self:getLeftPadding(), self:getRightPadding(), self:getTopPadding(), self:getBottomPadding()
end

--------------------------------------------------
--     BOUNDING BOX AND INTERNAL BOX
--------------------------------------------------

-- returns x, y, width and height, with x and y being the top-left corner
function Panel:getBoundingBox()
  local x, y = self:getPosition()
  return x, y, self:getWidth(), self:getHeight()
end

-- returns the height of the 'Internal' box (the space inside the Panel, with the padding taken out)
function Panel:getInternalHeight()
  return (self:getHeight() - self:getTopPadding() - self:getBottomPadding())
end

-- returns the width of the 'Internal' box (the space inside the Panel, with the padding taken out)
function Panel:getInternalWidth()
  return (self:getWidth() - self:getLeftPadding() - self:getRightPadding())
end

-- returns the lower-left corner of the internal box
function Panel:getInternalPosition()
  local x, y = self:getPosition()
  return x+self:getLeftPadding(), y+self:getTopPadding()
end

-- returns the boundingbox minus the padding. It also returns x,y,InternalWidth,InternalHeight
function Panel:getInternalBox()
  local ix,iy = self:getInternalPosition()
  return ix,iy, self:getInternalWidth(), self:getInternalHeight()
end


--------------------------------------------------
--     CAMERA & PARENT-RELATED METHODS
--------------------------------------------------

local prevAddChild = Panel.addChild

function Panel:addChild(child)
  _G.print('hello')
  prevAddChild(self, child)
  local camera = self:getInternalCamera()
  child:setCamera(camera)
  camera:addChild(child:getInternalCamera())
  return child
end

function Panel:getAlpha()
  if(self.alpha~=nil) then return self.alpha end
  if(self.parent ~= nil) then return self.parent:getAlpha() end
  return 255
end

function Panel:getDrawOrder()
  if(self.drawOrder~=nil) then return self.drawOrder end
  if(self.parent~=nil) then return self.parent:getDrawOrder() - 1 end
  return 0
end

--------------------------------------------------
--                DRAW METHOD
--------------------------------------------------

function Panel:draw()
  local x, y = self:getPosition()
  local width = self:getWidth()
  local height = self:getHeight()
  
  if(x~=nil and y~=nil and width~=nil and height~=nil) then

    local backgroundColor = self:getBackgroundColor()
    local borderColor = self:getBorderColor()
    local alpha = self:getAlpha()

    local r, g, b, a = _G.love.graphics.getColor()

    if(backgroundColor~=nil and backgroundColor~=false) then
      _G.passion.graphics.setColor(backgroundColor)
      _G.passion.graphics.setAlpha(alpha)
      _G.passion.graphics.roundedRectangle('fill', x, y, width, height, self:getCornerRadius())
    end

    if(borderColor~=nil and borderColor~=false) then
      local prevLineWidth = _G.love.graphics.getLineWidth()
      local prevLineStyle = _G.love.graphics.getLineStyle()

      _G.passion.graphics.setColor(borderColor)
      _G.passion.graphics.setAlpha(alpha)
      _G.love.graphics.setLineStyle(self:getBorderStyle())
      _G.love.graphics.setLineWidth(self:getBorderWidth())

      _G.passion.graphics.roundedRectangle('line', x, y, width, height, self:getCornerRadius())

      _G.love.graphics.setLineWidth(prevLineWidth)
      _G.love.graphics.setLineStyle(prevLineStyle)
    end

    _G.love.graphics.setColor(r,g,b,a)

  end
end

--------------------------------------------------
--             UPDATE METHOD
--------------------------------------------------
function Panel:update(dt)
  local ix,iy = self:getInternalPosition()
  self:getInternalCamera():setPosition(-ix,-iy)
end

--------------------------------------------------
--                EFFECTS
--------------------------------------------------

function Panel:fadeIn(seconds, callback, ...)
  self:effect(seconds, {alpha=255}, 'linear', callback, ...)
end

function Panel:fadeOut(seconds, callback, ...)
  self:effect(seconds, {alpha=0}, 'linear', callback, ...)
end



