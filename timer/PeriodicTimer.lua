local passion = passion
local unpack = unpack
local class = class

module('passion.timer')

-- a timer that executes its callback periodically, instead of just once.
PeriodicTimer = class('passion.timer.PeriodicTimer', passion.timer.Timer)

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
