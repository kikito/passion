
-----------------------------------------------------------------------------------
-- Beholder.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com ) - 4 Mar 2010
-- Small mixin for classes with getters and setters
-----------------------------------------------------------------------------------

GetterSetter = {}

function GetterSetter.getterFor(theClass, attr) return 'get' .. attr:gsub("^%l", string.upper) end
function GetterSetter.setterFor(theClass, attr) return 'set' .. attr:gsub("^%l", string.upper) end
function GetterSetter.getter(theClass, attributeName, defaultValue)
  theClass[theClass:getterFor(attributeName)] = function(self) 
    if(self[attributeName]~=nil) then return self[attributeName] end
    return defaultValue
  end
end
function GetterSetter.setter(theClass, attributeName)
  theClass[theClass:setterFor(attributeName)] = function(self, value) self[attributeName] = value end
end
function GetterSetter.getterSetter(theClass, attributeName, defaultValue)
  theClass:getter(attributeName, defaultValue)
  theClass:setter(attributeName)
end
