passion.gui = {}

local gui = passion.gui

function passion.gui.setFocus(element)
  local currFocus = gui.focus
  if(currFocus ~= nil and currFocus ~= element) then
    if(type(currFocus.onBlur)=='function') then currFocus:onBlur() end
    gui.focus = nil
  end
  
  if(gui.focus ~= element) then
    if(type(element.onFocus)=='function') then element:onFocus() end
    gui.focus = element
  end
end
