local _G=_G
module('passion.timer')

SimpleTimer = _G.class('passion.timer.SimpleTimer', _G.StatefulObject)

------------------------------------
-- PRIVATE METHODS AND ATTRIBUTES
------------------------------------

-- This variable holds the list of all the timers created
_timers = {}

------------------------------------
-- PUBLIC INSTANCE METHODS
------------------------------------

--[[ Creates a new timer.
     It will execute a function (with given parameters) some time after is has 
     been created. This is accomplished by invoking tic(dt) periodically
     (passion.update does this by invoking passion.timer.update)
]]
function SimpleTimer:initialize(seconds, f, ...)

  super.initialize(self)

  self.seconds = seconds
  self.callback = f
  self.arguments = {...}
  self.running = 0

  _G.table.insert(_timers, self)

end

--[[ Checks wether the time has come to "trigger" the timer.
     If the time is due, it invokes the callback with params and destroys the timer
]]

function SimpleTimer:tic(dt)
  self.running = self.running + dt

  if(self.running >= self.seconds) then
    self.callback(_G.unpack(self.arguments))
    self:destroy()
  end
end

-- resets the countdown to 0. The parameter is optional, and allows changing the number of seconds.
function SimpleTimer:reset(seconds)
  self.seconds = seconds or self.seconds
  self.running = 0
end

-- State and functions to control the "pause state"
local Paused = SimpleTimer:addState('Paused')
function Paused:tic(dt) end -- do nothing

function SimpleTimer:pause()
  self:pushState('Paused')
end

function SimpleTimer:continue()
  self:popState('Paused')
end

function SimpleTimer:isPaused()
  return self:isInState('Paused', true)
end

-- Destroys the timer, removig it from the timers collection
function SimpleTimer:destroy()
  _G.passion.remove(_timers, self)
  super.destroy(self)
end

------------------------------------
-- PUBLIC CLASS METHODS
------------------------------------

-- calls "tic" on all timers
function SimpleTimer.update(theClass, dt)
  _G.passion.apply(_timers, 'tic', dt)
end

