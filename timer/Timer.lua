require 'passion.oop.init'


passion.timer.Timer = class('passion.timer.Timer', StatefulObject)

------------------------------------
-- PRIVATE METHODS AND ATTRIBUTES
------------------------------------

-- This variable holds the list of all the timers created
_timers = {}


local Timer = passion.timer.Timer

------------------------------------
-- PUBLIC INSTANCE METHODS
------------------------------------

--[[ Creates a new timer.
     It will execute a function (with given parameters) some time after is has 
     been created. This is accomplished by invoking tic(dt) periodically
     (passion.update does this by invoking passion.timer.update)
]]
function Timer:initialize(seconds, f, ...)

  super.initialize(self)

  self.seconds = seconds
  self.callback = f
  self.arguments = {...}
  self.running = 0

  table.insert(_timers, self)

end

--[[ Checks wether the time has come to "trigger" the timer.
     If the time is due, it invokes the callback with params and destroys the timer
]]

function Timer:tic(dt)
  self.running = self.running + dt

  if(self.running >= self.seconds) then
    self.callback(unpack(self.arguments))
    self:destroy()
  end
end

-- resets the countdown to 0. The parameter is optional, and allows changing the number of seconds.
function Timer:reset(seconds)
  self.seconds = seconds or self.seconds
  self.running = 0
end

-- State and functions to control the "pause state"
local Paused = Timer:addState('Paused')
function Paused:tic(dt) end -- do nothing

function Timer:pause()
  self:pushState('Paused')
end

function Timer:continue()
  self:popState('Paused')
end

function Timer:isPaused()
  return self:isInState('Paused', true)
end

-- Destroys the timer, removig it from the timers collection
function Timer:destroy()
  passion.removeItemFromCollection(_timers, self)
end

------------------------------------
-- PUBLIC CLASS METHODS
------------------------------------

-- calls "tic" on all timers
function Timer.update(theClass, dt)
  passion.applyMethodToCollection(_timers, nil, 'tic', dt)
end


