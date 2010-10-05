local _G=_G
module('passion.timer')

-- a timer that executes its callback periodically, instead of just once.
PeriodicTimer = _G.class('passion.timer.PeriodicTimer', _G.passion.timer.Timer)

------------------------------------
-- PUBLIC INSTANCE METHODS
------------------------------------

function PeriodicTimer:initialize(seconds, f, ...)

  super.initialize(self, seconds, f, ... )

end

function PeriodicTimer:update(dt)

  self.running = self.running + dt

  if(self.running >= self.seconds) then
    self.callback(unpack(self.arguments))
    self.running=0
  end
end
