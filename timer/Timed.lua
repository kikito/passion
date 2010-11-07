local _G=_G
module('passion.timer')

-- This interface add the methods 'later', 'every' and 'effect' to the class that includes them

------------------------------------
-- PRIVATE STUFF
------------------------------------

-- If methodOrname is a function, it returns it. If it is a name, it returns the method named.
local _getMethod = function(instance, methodOrName)
  local method = (_G.type(methodOrName)=='string' and instance[methodOrName] or methodOrName)
  _G.assert(_G.type(method)=='function', 'methodOrName(' .. _G.tostring(methodOrName) .. ') must be either a function or a valid method name')
  return method
end

------------------------------------
-- PUBLIC STUFF
------------------------------------

Timed = {}

-- timer function. Executes one action after some seconds have passed
function Timed:later(seconds, methodOrName, ...)
  local method = _getMethod(self, methodOrName)
  return _G.passion.timer.after(seconds, method, self, ...)
end

-- timer function. Executes an action periodically.
function Timed:every(seconds, methodOrName, ...)
  local method = _getMethod(self, methodOrName)
  return _G.passion.timer.every(seconds, method, self, ...)
end

-- timer function. Changes the properties of the actor gradually over a period of time
function Timed:effect(seconds, properties, easing, callback, ...)
  return _G.passion.timer.effect(self, seconds, properties, easing, callback, ...)
end
