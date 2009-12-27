require 'passion.gui.Core'
require 'passion.gui.controls.Control'

passion.gui.StaticText = class('passion.gui.StaticText', passion.gui.Control)

function passion.gui.StaticText:initialize(options)
  super(self, options)
end

function passion.gui.StaticText:parseOptions(options)
  options = options or {}
  super(self, options)

  self:setText(options.text)
  self:setWidth(options.width)
  self:setAlign(options.align)
  self:setFontColor(options.fontColor)
  self:setFont(options.font)
  self:setFontSize(options.fontSize)
end

passion.gui.StaticText:getterSetter('text', '')
passion.gui.StaticText:getterSetter('width')
passion.gui.StaticText:getterSetter('align')
passion.gui.StaticText:getterSetter('font')
passion.gui.StaticText:getterSetter('fontColor')
passion.gui.StaticText:getterSetter('fontSize')

function passion.gui.StaticText:draw()
  local text = self:getText()
  local label = self:getLabel()
  if(label~=nil and string.len(label) > 0) then text = label .. ': ' .. text end
  
  local x, y = self:getPosition()
  local width = self:getWidth()
  local align = self:getAlign()

  local color = self:getFontColor()
  local font = self:getFont()
  local fontSize = self:getFontSize()
  
  if(font~=nil and fontSize~=nil) then love.graphics.setFont(font, fontSize)
  elseif(fontSize~=nil) then love.graphics.setFont(fontSize)
  end
  
  if(color~=nil) then love.graphics.setColor(unpack(color)) end

  if(width==nil) then love.graphics.print( text, x, y )
  elseif(align==nil) then love.graphics.printf( text, x, y, width)
  else love.graphics.printf(text, x, y, width, align)
  end
end