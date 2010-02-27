require 'passion.gui.Label'

passion.gui.Button = class('passion.gui.Button', passion.gui.Label)

local Button = passion.gui.Button

Button.VALID_OPTIONS = {
  'onClick', 'onPress', 'onRelease', 'onMouseOver', 'onMouseOut', 'onFocus', 'onBlur', 'focus'
}

function Button:initialize(options)
  super.initialize(self, options)
  self:parseOptions(options, Button.VALID_OPTIONS)

  self:gotoState('MouseOut')
end

Button:getterSetter('onClick')
Button:getterSetter('onPress')
Button:getterSetter('onRelease')
Button:getterSetter('onMouseOver')
Button:getterSetter('onMouseOut')
Button:getterSetter('onFocus')
Button:getterSetter('onBlur')
Button:getterSetter('focus', true) -- if set to false, buttons don't capture the mouse when clicked

-- make button borders visible by default, with text centered, and some border
Button:getter('borderColor', passion.white)
Button:getter('borderWidth', 2)
Button:getter('cornerRadius', 5)
Button:getter('padding', 5)
Button:getter('align', 'center')

-- These functions do nothing by default
function Button:onClick() end
function Button:onPress() end
function Button:onRelease() end
function Button:onMouseOver() end
function Button:onMouseOut() end
function Button:onFocus() end
function Button:onBlur() end


function Button:checkPoint(mx, my)
  local x, y = self:getPosition()
  local width = self:getWidth()
  local height = self:getHeight()
  
  if(mx < x or mx > x+width or my < y or my > y+height) then return false end
  return true
end

function Button:isPressed()
  return self.isInState('Pressed', true)
end

function Button:isMouseOver()
  return self.isInState('MouseOver', true)
end

function Button:isMouseOut()
  return self.isInState('MouseOut', true)
end

-- MouseOut State
local MouseOut = Button:addState('MouseOut')
function MouseOut:poppedState()
  self:onMouseOut()
end
function MouseOut:update(dt)
  if((passion.gui.focus == nil or passion.gui.focus == self) and
      self:checkPoint(love.mouse.getPosition())==true) then
    self:pushState('MouseOver')
  end
end
function MouseOut:pushedState()
  self:onMouseOver()
end

-- MouseOver State
local MouseOver = Button:addState('MouseOver')
function MouseOver:update(dt)
  if((passion.gui.focus == nil or passion.gui.focus == self) and
      self:checkPoint(love.mouse.getPosition())==false) then
    self:popState()
  elseif love.mouse.isDown('l') then
    self:pushState('Pressed')
  end
end

-- Pressed State.

-- Buttons on this state have been pressed, but don't capture the gui's focus
-- (moving the mouse out will remove the "pressure")
local Pressed = Button:addState('Pressed') -- Pressed but not gaining focus
function Pressed:enterState()
  self:onPress()
  if(self:getFocus()==true) then self:pushState('PressedFocus') end
end
function Pressed:update(dt)
  if(self:checkPoint(love.mouse.getPosition())==false) then
    self:gotoState('MouseOut')
  elseif love.mouse.isDown('l')==false then
    self:onClick()
    self:gotoState('MouseOver')
  end
end
function Pressed:exitState()
  self:onRelease()
end

-- PressedFocused State.

-- Buttons on this state have been pressed, and "capture" the focus
-- (Other controls will not react to the mouse until it is released)
local PressedFocus = Button:addState('PressedFocus')
function PressedFocus:enterState()
  passion.gui:setFocus(self)
end
function PressedFocus:update(dt)
  if love.mouse.isDown('l')==false then
    if(self:checkPoint(love.mouse.getPosition())==true) then
      self:onClick()
      self:gotoState('MouseOver')
    else
      self:gotoState('MouseOut')
    end
  end
end
function PressedFocus:exitState()
  self:onRelease()
  passion.gui:setFocus(nil)
end

