local _G=_G
module('passion.gui')

Button = _G.class('passion.gui.Button', _G.passion.gui.Label)

local VALID_OPTIONS = {
  'onClick', 'onPress', 'onRelease', 'onMouseOver', 'onMouseOut', 'onFocus', 'onBlur', 'focus'
}

local _focus = nil

local _setFocus= function(button)
  if(_focus ~= nil and _focus ~= button) then
    if(_G.type(_focus.onBlur)=='function') then _focus:onBlur() end
    _focus = nil
  end
  
  if(_focus ~= button) then
    if(_G.type(button.onFocus)=='function') then button:onFocus() end
    _focus = button
  end
end

function Button:initialize(options)
  super.initialize(self, options)
  self:parseOptions(options, VALID_OPTIONS)

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
Button:getter('borderColor', _G.passion.colors.white)
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
  mx,my = self:getCamera():invert(mx,my)
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
function MouseOut:continuedState()
  self:onMouseOut()
end
function MouseOut:update(dt)
  _G.passion.gui.Panel.update(self, dt)
  if((_focus == nil or _focus == self) and
      self:checkPoint(_G.love.mouse.getPosition())==true) then
    self:pushState('MouseOver')
  end
end
function MouseOut:pausedState()
  self:onMouseOver()
end

-- MouseOver State
local MouseOver = Button:addState('MouseOver')
function MouseOver:update(dt)
  _G.passion.gui.Panel.update(self, dt)
  if((_focus == nil or _focus == self) and
      self:checkPoint(_G.love.mouse.getPosition())==false) then
    self:popState('MouseOver')
  elseif _G.love.mouse.isDown('l') then
    self:pushState('Pressed')
  end
end

-- Pressed State.

-- Buttons on this state have been pressed
-- If they have the "focus", they don't release the mouse control, unless the l button is up
-- (mouse can go outside of the button but if it is down then the mouse keeps being pressed)
local Pressed = Button:addState('Pressed')
function Pressed:enterState()
  if(self:getFocus()==true) then _setFocus(self) end
  self:onPress()
end
function Pressed:update(dt)
  _G.passion.gui.Panel.update(self, dt)
  if _G.love.mouse.isDown('l')==false or
     (self:getFocus()==false and self:checkPoint(_G.love.mouse.getPosition())==false) then
    self:onClick()
    self:popState('Pressed')
  end
end
function Pressed:exitState()
  self:onRelease()
  if(self:getFocus()==true) then _setFocus(nil) end
end

