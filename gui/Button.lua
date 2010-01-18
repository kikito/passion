require 'passion.gui.Label'

passion.gui.Button = class('Button', passion.gui.Label)

local Button = passion.gui.Button

Button.VALID_OPTIONS = {
  'onClick', 'onPress', 'onMouseOver', 'onMouseOut', 'onFocus', 'onBlur'
}

function Button:initialize(options)
  super(self, options)
  self:parseOptions(options, Button.VALID_OPTIONS)
  self:gotoState('MouseOut')
end

Button:getterSetter('onClick')
Button:getterSetter('onPress')
Button:getterSetter('onMouseOver')
Button:getterSetter('onMouseOut')
Button:getterSetter('onFocus')
Button:getterSetter('onBlur')

-- make button borders visible by default
Button:getter('borderColor', passion.white)
Button:getter('borderWidth', 2)
Button:getter('cornerRadius', 5)
Button:getter('padding', 5)
Button:getter('align', 'center')

-- These functions do nothing by default
function Button:onClick() end
function Button:onPress() end
function Button:onMouseOver() end
function Button:onMouseOut() end
function Button:onFocus() end
function Button:onBlur() end
-- A button doesn't react to the mouse (unless in the right state - see below)
function Button:mousepressed(mx, my, button) end
function Button:mousereleased(mx, my, button) end
function Button:update(dt) end

function Button:checkPoint(mx, my)
  local x, y = self:getPosition()
  local width = self:getWidth()
  local height = self:getHeight()
  
  if(mx < x or mx > x+width or my < y or my > y+height) then return false end
  return true
end

-- MouseOut State
local MouseOut = Button:addState('MouseOut')
function MouseOut:enterState()
  self:onMouseOut()
end
function MouseOut:update(dt)
  if((passion.gui.focus == nil or passion.gui.focus == self) and
      self:checkPoint(love.mouse.getPosition())==true) then
    self:gotoState('MouseOver')
  end
end

-- MouseOver State
local MouseOver = Button:addState('MouseOver')
function MouseOver:enterState()
  self:onMouseOver()
end
function MouseOver:update(dt)
  if((passion.gui.focus == nil or passion.gui.focus == self) and
      self:checkPoint(love.mouse.getPosition())==false) then
    self:gotoState('MouseOut')
  end
end
function MouseOver:mousepressed(x,y,button)
  self:gotoState('Pressed')
end

-- Pressed State
local Pressed = Button:addState('Pressed') -- Pressed is a subclass of MouseOver
function Pressed:enterState()
  passion.gui:setFocus(self)
  self:onPress()
end
function Pressed:mousereleased(x,y,button)
  if(self:checkPoint(x,y)==true) then
    self:onClick()
    self:gotoState('MouseOver')
  else
    self:gotoState('MouseOut')
  end
end
function Pressed:exitState()
  passion.gui:setFocus(nil)
end
