local _G=_G

module('passion.gui')

Label = _G.class('passion.gui.Label', _G.passion.gui.Panel)

--obtain the default font
_G.love.graphics.setFont(12)
local defaultFont = _G.love.graphics.getFont()

local VALID_OPTIONS = {'text', 'font', 'fontColor', 'align', 'valign'}

function Label:initialize(options)
  super.initialize(self, options)
  self:parseOptions(options, VALID_OPTIONS)
end

Label:getterSetter('text',       '')
Label:getterSetter('font',       defaultFont)
Label:getterSetter('fontColor',  _G.passion.colors.white)
Label:getterSetter('align',      'left')   -- or right or center
Label:getterSetter('valign',     'center') -- or top or bottom
Label:getterSetter('borderColor', nil)

function Label:getHeight()
  return _G.math.max(super.getHeight(self),
                  self:getTopPadding() + self:getBottomPadding() + self:getFontSize())
end

function Label:getWidth()
  return _G.math.max(super.getWidth(self),
                  self:getLeftPadding() + self:getRightPadding() + self:getTextWidth())
end

function Label:getTextWidth()
  return self:getFont():getWidth(self:getText())
end

function Label:getFontSize()
  local font = self:getFont()
  return font:getHeight() * font:getLineHeight()
end

function Label:draw()
  
  local align = self:getAlign()
  local valign = self:getValign()
  local font = self:getFont()
  local fontColor = self:getFontColor()
  local fontSize = self:getFontSize()
  local text = self:getText()
  local x, y, width, height = self:getInternalBox()
  local prevFont = _G.love.graphics.getFont()
  local pr,pg,pb,pa = _G.love.graphics.getColor() -- previous font color

  super.draw(self) -- draws background and borders using the Panel implementation

  _G.love.graphics.setFont(font)

  if(fontColor~=nil) then
    _G.passion.graphics.setColor(fontColor)
    _G.passion.graphics.setAlpha(self:getAlpha())
  end

  --uncomment to debug the rectangle used for drawing the text
  --love.graphics.rectangle('line', x, y, width, height)

  if(valign=='center') then y = (y + height/2.0 - fontSize/2.0)
  elseif(valign=='bottom') then y = y + height - fontSize
  end

  -- FIXME remove this when love starts printing fonts the top-leftly
  y = y + fontSize

  _G.love.graphics.printf(text, x, y, width, align)

  -- restore previous values of font & color
  if(prevFont~=nil) then _G.love.graphics.setFont(prevFont) end
  _G.love.graphics.setColor(pr, pg, pb, pa)

end
