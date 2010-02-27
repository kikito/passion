require 'passion.passion'

passion.gui = {}

function passion.gui:setFocus(element)
  if(self.focus ~= nil and self.focus ~= element) then
    if(type(self.focus.onBlur)=='function') then self.focus:onBlur() end
    self.focus = nil
  end
  
  if(self.focus ~= element) then
    if(type(element.onFocus)=='function') then element:onFocus() end
    passion.gui.focus = element
  end
end
