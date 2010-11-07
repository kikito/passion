local _G=_G
module('passion.timer')

------------------------------------
-- PUBLIC FUNCTIONS
------------------------------------

-- These functions encapsulate the timer creation so it is transparent to the user.

function later(seconds, f, ...)
  return _G.passion.timer.Timer:new(seconds, f, ...)
end

function every(seconds, f, ...)
  return _G.passion.timer.PeriodicTimer:new(seconds, f, ...)
end

function effect(object, seconds, properties, easing, callback, ...)
  return _G.passion.timer.Effect:new(object, seconds, properties, easing, callback, ...)
end

function update(dt)
  _G.passion.timer.Timer:apply('update', dt)
end


