require 'passion.gui.Pannel'

passion.gui.Label = class('passion.gui.Label', passion.gui.Pannel)
local Label = passion.gui.Label

--obtain the default font
love.graphics.setFont(12)
local defaultFont = love.graphics.getFont()

local VALID_OPTIONS = {'text', 'font', 'fontColor', 'align'}

function Label:initialize(options)
  super(self, options)
  self:parseOptions(options, VALID_OPTIONS)
end

Label:getterSetter('text',       '')
Label:getterSetter('font',       defaultFont)
Label:getterSetter('fontColor',  passion.white)
Label:getterSetter('align',      'left')   -- or right or center
Label:getterSetter('valign',     'center') -- or top or bottom
Label:getterSetter('borderColor', nil)

function Label:getHeight()
  return math.max(super(self),
                  self:getTopPadding() + self:getBottomPadding() + self:getFontSize())
end

function Label:getWidth()
  return math.max(super(self),
                  self:getLeftPadding() + self:getRightPadding() + self:getTextWidth())
end

function Label:getTextWidth()
  return self:getFont():getWidth(self:getText())
end

function Label:getFontSize()
  return self:getFont():getHeight()
end

function Label:draw()

  local align = self:getAlign()
  local valign = self:getValign()
  local font = self:getFont()
  local fontColor = self:getFontColor()
  local fontSize = self:getFontSize()
  local text = self:getText()
  local x, y, width, height = self:getInternalBox()


  local prevFont = love.graphics.getFont()
  local pr,pg,pb,pa = love.graphics.getColor() -- previous font color

  super(self) -- draws background and borders using the Pannel implementation

  love.graphics.setFont(font)

  if(fontColor~=nil) then love.graphics.setColor(unpack(fontColor)) end

  if(valign=='top') then y = y+fontSize-1
  elseif(valign=='center') then y = (y + height/2.0 + fontSize/2.0) -1
  else y = y + height -1
  end

  love.graphics.printf(text, x, y, width, align)

  -- restore previous values of font & color
  if(prevFont~=nil) then love.graphics.setFont(prevFont) end
  love.graphics.setColor(pr, pg, pb, pa)

end
