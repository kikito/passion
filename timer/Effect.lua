local _G=_G
module('passion.timer')

-- a timer that gradually changes the values of the attributes of an object, in a given time.
-- optionally, at the end, it can invoke a function.
Effect = _G.class('passion.timer.Effect', _G.passion.timer.Timer)

local function _getValue(self, name)
  local getter = self.object[_G.GetterSetter:getterFor(name)]
  if(getter~=nil) then
    return getter(self.object)
  else
    return self.object[name]
  end
end

local function _setValue(self, name, value)
  local setter = self.object[_G.GetterSetter:setterFor(name)]
  if(setter~=nil) then
    setter(self.object, value)
  else
    self.object[name] = value
  end
end

local function _getDifference(name, objective, beginning)
  local to,tb = _G.type(objective), _G.type(beginning)
  if(to=='number' or tb=='number') then
    return (objective or 0) - (beginning or 0)
  elseif(to=='table' or tb=='number') then
    local result = {}
    beginning = beginning or {}
    for k,v in _G.pairs(objective) do
      result[k] = _getDifference(k, v, beginning[k])
    end
    return result
  else
    _G.error('The property ' .. name .. ' must be a number or table. Was ' .. to .. ', ' .. tb)
  end
end

local function _easingWithTables(name, easing, t, b, c, d)
  local tb,tc = _G.type(c)
  if(tc=='number' or tb=='number') then
    return easing(t, b or 0, c, d)
  elseif(tc=='table' or tb=='table') then
    local result = {}
    b = b or {}
    for k,v in _G.pairs(c) do
      result[k] = _easingWithTables(k, easing, t, b[k], v, d)
    end
    return result
  else
    _G.error('The property ' .. name .. ' must be a number or table. Was ' .. tb .. ', ' .. tc)
  end
end

------------------------------------
-- PUBLIC INSTANCE METHODS
------------------------------------
function Effect:initialize(object, seconds, properties, easing, callback, ...)

  self.object = object
  self.easing = _G.type(easing)=='function' and easing or (Effect[easing] or Effect.linear)
  self.objective = properties

  self.beginning = {}
  self.change = {}
  for name, objective in _G.pairs(properties) do
    self.beginning[name] = _getValue(self, name)
    self.change[name] = _getDifference(name, objective, self.beginning[name])
  end

  super.initialize(self, seconds, callback, ...)
end

function Effect:update(dt)

  self.running = self.running + dt
  
  if(self.running > self.seconds) then
    for name, objective in _G.pairs(self.objective) do
      _setValue(self, name, objective)
    end
    if(_G.type(self.callback)=="function") then
      self.callback(_G.unpack(self.arguments))
    end
    self:destroy()
  else
    for name, objective in _G.pairs(self.objective) do
      local newValue = _easingWithTables(
        name, self.easing,
        self.running, self.beginning[name], self.change[name], self.seconds
      )
      _setValue(self, name, newValue)
    end
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



