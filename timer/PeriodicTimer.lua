require 'passion.timer.Timer'

passion.timer.PeriodicTimer = class('passion.timer.PeriodicTimer', passion.timer.Timer)

local PeriodicTimer = passion.timer.PeriodicTimer

------------------------------------
-- PUBLIC INSTANCE METHODS
------------------------------------

function PeriodicTimer:initialize(seconds, f, ...)

  super.initialize(self, seconds, f, ... )

end

function PeriodicTimer:check()

  local now = love.timer.getMicroTime()

  if((now - self.start) >= self.seconds) then
    self.callback(unpack(self.arguments))
    self.start = now
  end
end
