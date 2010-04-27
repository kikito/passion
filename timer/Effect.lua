-- a timer that gradually changes the values of the attributes of an object, in a given time.
-- optionally, at the end, it can invoke a function.
passion.timer.Effect = class('passion.timer.Effect', passion.timer.Timer)

local Effect = passion.timer.Effect

local _getValue = function(self, name)
  local getter = self.object[Object:getterFor(name)]
  if(getter~=nil) then
    return getter(self.object) or 0
  else
    return self.object[name] or 0
  end
end

local _setValue = function(self, name, value)
  local setter = self.object[Object:setterFor(name)]
  if(setter~=nil) then
    setter(self.object, value)
  else
    self.object[name] = value
  end
end


------------------------------------
-- PUBLIC INSTANCE METHODS
------------------------------------
function Effect:initialize(object, seconds, properties, easing, callback, ...)

  self.object = object
  self.easing = easing or Effect[easing] or Effect.linear
  self.objective = properties

  self.beginning = {}
  self.change = {}
  for name, objective in pairs(properties) do
    self.beginning[name] = _getValue(self, name)
    self.change[name] = objective - self.begining[name]
  end

  super.initialize(self, seconds, callback, ...)
end

function Effect:tic(dt)

  self.running = self.running + dt
  
  if(self.running > self.seconds) then
    for name, objective in pairs(self.objective) do
      _setValue(self, name, objective)
    end
    if(type(self.callback)=="function") then
      self.callback(unpack(self.arguments))
    end
    self:destroy()
  end

  for name, objective in pairs(self.objective) do
    local newValue = self.easing(self.running, self.beginning[name], self.change[name], self.seconds)
    _setValue(self, name, newValue)
  end
end

-- easing functions adapted from http://hosted.zeh.com.br/Tweener/docs/en-us/misc/transitions.html

function Effect.linear(t, b, c, d)
  return c*t/d + b
end

function Effect.quadratic(t, b, c, d)
  t = t/d
  return c*t*t + b
end

function Effect.quadratic2(t, b, c, d)
  t=t*2.0/d
  if(t < 1) then return c/2.0*t*t + b end
  t=t-1
  return -c/2.0 *(t*(t-2) - 1) + b
end

function Effect.bounce(t, b, c, d)
  t = t/d
  if(t <(1/2.75)) then
    return c*(7.5625*t*t) + b
  elseif(t <(2/2.75)) then
    t = t - 1.5/2.75
    return c*(7.5625*t*t + 0.75) + b
  elseif(t <(2.5/2.75)) then
    t = 2.25/2.75
    return c*(7.5625*t*t + 0.9375) + b
  else
    t = t-2.625/2.75
    return c*(7.5625*t*t + 0.984375) + b
  end
end



