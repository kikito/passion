require 'passion.oop.init'


passion.timer.Timer = class('passion.timer.Timer')

------------------------------------
-- PRIVATE METHODS AND ATTRIBUTES
------------------------------------

-- This variable holds the list of all the timers created
_timers = {}


local Timer = passion.timer.Timer

------------------------------------
-- PUBLIC INSTANCE METHODS
------------------------------------

function Timer:initialize(seconds, f, ...)

  self.seconds = seconds
  self.callback = f
  self.arguments = {...}
  self.running = 0

  table.insert(_timers, self)

end

function Timer:tic(dt)
  self.running = self.running + dt

  if(self.running >= self.seconds) then
    self.callback(unpack(self.arguments))
    self:destroy()
  end
end

function Timer:destroy()
  passion.removeItemFromCollection(_timers, self)
end

------------------------------------
-- PUBLIC CLASS METHODS
------------------------------------

function Timer.update(theClass, dt)
  passion.applyMethodToCollection(_timers, nil, 'tic', dt)
end


