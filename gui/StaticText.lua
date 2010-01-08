require 'passion.gui.Core'
require 'passion.gui.Control'

passion.gui.StaticText = class('passion.gui.StaticText', passion.gui.Control)

function passion.gui.StaticText:initialize(options)
  super(self, options)
end

function passion.gui.StaticText:parseOptions(options)

  super(self, options)
  options = options or {}

  self:setText(options.text)
  self:setWidth(options.width)
  self:setAlign(options.align)
  self:setFontColor(options.fontColor)
  self:setFont(options.font)
  self:setFontSize(options.fontSize)
end

passion.gui.StaticText:getterSetter('align')
passion.gui.StaticText:getterSetter('font')
passion.gui.StaticText:getterSetter('fontColor', passion.white)
passion.gui.StaticText:getterSetter('fontSize', 12)
passion.gui.StaticText:getterSetter('width')

passion.gui.StaticText:getter('text', '')
function passion.gui.StaticText:setText(text)
  text = text or ''
  local label = self:getLabel()
  if(type(label)=="string" and string.len(label) > 0) then self.text = label .. ': ' .. text
  else self.text = text
  end
end

function passion.gui.StaticText:draw()

  local x, y = self:getPosition()
  local align = self:getAlign()
  local fontColor = self:getFontColor()
  local font = self:getFont()
  local fontSize = self:getFontSize()
  local width = self:getWidth()
  local backgroundColor = self:getBackgroundColor()
  local text = self:getText()

  if(font ~= nil and fontSize ~= nil) then love.graphics.setFont(font, fontSize)
  elseif(fontSize ~= nil) then
    love.graphics.setFont(fontSize)
    font = love.graphics.getFont()
  end
  
  if(width == nil and font ~= nil) then width = font:getWidth(text) end

  if(backgroundColor ~= nil) then
    love.graphics.setColor(unpack(backgroundColor))
    love.graphics.rectangle( "fill", x, y-fontSize, width, fontSize )
  end

  if(fontColor~=nil) then love.graphics.setColor(unpack(fontColor)) end

  if(align==nil) then love.graphics.printf( text, x, y, width)
  else love.graphics.printf(text, x, y, width, align)
  end
end