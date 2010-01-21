require 'passion.gui.Pannel'
require 'passion.ResourceManager'

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
Label:getterSetter('align',      'left')
Label:getterSetter('borderColor', nil)

-- FIXME: setText should update width
-- FIXME: setFontSize should update height  ?

-- FIXME: review this
function Label:getHeight()
  return super(self) or 2*self:getPadding() + self:getFontSize()
end

function Label:getFontSize()
  local f = self:getFont()
  return f:getHeight()
end

function Label:draw()

  local x, y = self:getPosition()
  local align = self:getAlign()
  local font = self:getFont()
  local fontColor = self:getFontColor()
  local fontSize = self:getFontSize()
  local width = self:getWidth()
  local text = self:getText()
  local padding = self:getPadding()


  local prevFont = love.graphics.getFont()
  local pr,pg,pb,pa = love.graphics.getColor() -- previous font color

  super(self) -- draws background and borders using the Pannel implementation

  love.graphics.setFont(font)

  if(width == nil and font ~= nil) then width = font:getWidth(text) end

  if(fontColor~=nil) then love.graphics.setColor(unpack(fontColor)) end

  if    (align=='left') then love.graphics.printf(text, x+padding, y+fontSize+padding-1, width, 'left')
  elseif(align=='center') then love.graphics.printf(text, x, y+fontSize+padding-1, width, 'center')
  else love.graphics.printf(text, x, y+fontSize+padding-1, width-padding, 'right')
  end

  -- restore previous values of font & color
  if(prevFont~=nil) then love.graphics.setFont(prevFont) end
  love.graphics.setColor(pr, pg, pb, pa)

end
