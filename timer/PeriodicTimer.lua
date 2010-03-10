require 'passion.timer.Timer'

-- a timer that executes its callback periodically, instead of just once.
passion.timer.PeriodicTimer = class('passion.timer.PeriodicTimer', passion.timer.Timer)

local PeriodicTimer = passion.timer.PeriodicTimer

------------------------------------
-- PUBLIC INSTANCE METHODS
------------------------------------

function PeriodicTimer:initialize(seconds, f, ...)

  super.initialize(self, seconds, f, ... )

end

function PeriodicTimer:tic(dt)

  self.running = self.running + dt

  if(self.running >= self.seconds) then
    self.callback(unpack(self.arguments))
    self.running=0
  end
end
