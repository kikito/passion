local _G=_G
module('passion.timer')

Timer = _G.class('passion.timer.Timer', _G.StatefulObject)
Timer:include(_G.Apply)

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

end

--[[ Checks wether the time has come to "trigger" the timer.
     If the time is due, it invokes the callback with params and destroys the timer
]]

function Timer:update(dt)
  self.running = self.running + dt

  if(self.running >= self.seconds) then
    self.callback(_G.unpack(self.arguments))
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

