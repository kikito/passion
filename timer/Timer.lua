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
  self.start = love.timer.getMicroTime( )

  table.insert(_timers, self)
  
  passion.dumpTable(self)

end

function Timer:check(dt)

  local now = love.timer.getMicroTime()

  if((now - self.start) >= self.seconds) then
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
  passion.applyMethodToCollection(_timers, nil, 'check')
end


