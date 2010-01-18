require 'passion.gui.Pannel'

passion.gui.Label = class('passion.gui.Label', passion.gui.Pannel)

passion.gui.Label.VALID_OPTIONS = {'text', 'font', 'fontColor', 'fontSize', 'align'}

function passion.gui.Label:initialize(options)
  super(self, options)
  self:parseOptions(options, passion.gui.Label.VALID_OPTIONS)
end

passion.gui.Label:getterSetter('text','')
passion.gui.Label:getterSetter('font')
passion.gui.Label:getterSetter('fontColor', passion.white)
passion.gui.Label:getterSetter('fontSize', 12)
passion.gui.Label:getterSetter('align')
passion.gui.Label:getterSetter('borderColor', nil)

-- FIXME: setText should update width
-- FIXME: setFontSize should update height  ?

function passion.gui.Label:getHeight()
  return super(self) or 2*self:getPadding() + self:getFontSize()
end

function passion.gui.Label:draw()

  local x, y = self:getPosition()
  local align = self:getAlign()
  local fontColor = self:getFontColor()
  local font = self:getFont()
  local fontSize = self:getFontSize()
  local width = self:getWidth()
  local text = self:getText()
  local padding = self:getPadding()

  if(font ~= nil and fontSize ~= nil) then love.graphics.setFont(font, fontSize)
  elseif(fontSize ~= nil) then
    love.graphics.setFont(fontSize)
    font = love.graphics.getFont()
  end
  
  if(width == nil and font ~= nil) then width = font:getWidth(text) end
  
  super(self)

  if(fontColor~=nil) then love.graphics.setColor(unpack(fontColor)) end

  if(align==nil) then love.graphics.printf(text, x+padding, y+fontSize+padding-1, width)
  elseif(align=='center') then love.graphics.printf(text, x, y+fontSize+padding-1, width, 'center')
  else love.graphics.printf(text, x+padding, y+fontSize+padding-1, width, align)
  end
end
