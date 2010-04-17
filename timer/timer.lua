module('passion.timer')

------------------------------------
-- PUBLIC FUNCTIONS
------------------------------------

-- These functions encapsulate the timer creation so it is transparent to the user.

function after(seconds, f, ...)
  return Timer:new(seconds, f, ...)
end


function every(seconds, f, ...)
  return PeriodicTimer:new(seconds, f, ...)
end

function update(dt)
  Timer:update(dt)
end
