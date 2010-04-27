passion.timer={}

------------------------------------
-- PUBLIC FUNCTIONS
------------------------------------

-- These functions encapsulate the timer creation so it is transparent to the user.

function passion.timer.after(seconds, f, ...)
  return passion.timer.Timer:new(seconds, f, ...)
end

function passion.timer.every(seconds, f, ...)
  return passion.timer.PeriodicTimer:new(seconds, f, ...)
end

function passion.timer.effect(object, seconds, properties, easing, callback, ...)
  return passion.timer.Effect:new(object, seconds, properties, easing, callback, ...)
end


function passion.timer.update(dt)
  passion.timer.Timer:update(dt)
end


