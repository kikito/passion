-- a timer that gradually changes the values of the attributes of an object, in a given time.
-- optionally, at the end, it can invoke a function.
passion.timer.Tweener = class('passion.timer.Tweener', passion.timer.Timer)

local Tweener = passion.timer.Tweener

local _getValue = function(self, name)
  local getter = nil
  if(self.hasGetters) then
    getter = self.object[self.object:getterFor(name)]
  end
  if(getter~=nil) then
    return getter(self.object) or 0
  else
    return self.object[name] or 0
  end
end

local _setValue = function(self, name, value)
  local setter = nil
  if(self.hasSetters) then
    setter = self.object[self.object:setterFor(name)]
  end
  if(setter~=nil) then
    setter(self.object, value)
  else
    self.object[name] = value
  end
end


------------------------------------
-- PUBLIC INSTANCE METHODS
------------------------------------
function Tweener:initialize(object, seconds, properties, easing, callback, ...)

  self.hasGetters = (type(object.getterFor)=="function")
  self.hasSetters = (type(object.setterFor)=="function")

  self.object = object
  self.easing = easing or Tweener[easing] or Tweener.linear
  self.objective = properties

  self.beginning = {}
  self.change = {}
  for name, objective in pairs(properties) do
    self.beginning[name] = _getValue(self, name)
    self.change[name] = objective - self.begining[name]
  end

  super.initialize(self, seconds, callback, ...)
end

function PeriodicTimer:tic(dt)

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

-- easing functions adapted from http://hosted.zeh.com.br/tweener/docs/en-us/misc/transitions.html

function Tweener.linear(t, b, c, d)
  return c*t/d + b
end

function Tweener.quadratic(t, b, c, d)
  return c*(t/=d)*t + b
end

function Tweener.quadratic2(t, b, c, d)
  t=t*2.0/d
  if((t < 1) then return c/2.0*t*t + b
  t=t-1
  return -c/2.0 *(t*(t-2) - 1) + b
end

function Tweener.bounce(t, b, c, d)
  t = t/d
  if(t <(1/2.75))
    return c*(7.5625*t*t) + b
  else if(t <(2/2.75)) then
    t = t - 1.5/2.75
    return c*(7.5625*t*t + 0.75) + b
  else if(t <(2.5/2.75)) then
    t = 2.25/2.75
    return c*(7.5625*t*t + 0.9375) + b
  else
    t = t-2.625/2.75
    return c*(7.5625*t*t + 0.984375) + b
  end
end



