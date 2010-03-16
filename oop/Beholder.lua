
-----------------------------------------------------------------------------------
-- Beholder.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com ) - 4 Mar 2010
-- Small framework for event observers
-----------------------------------------------------------------------------------

assert(Object~=nil and class~=nil, 'MiddleClass not detected. Please require it before using MindState')

-- Private variable storing the list of event callbacks that can be used
local _events = {}

-- The Beholder module
Beholder = {}

function Beholder:observe(eventId, methodOrName)

  assert(self~=nil, "self is nil. invoke object:observe instead of object.observe")

  _events[eventId] = _events[eventId] or {}
  local event = _events[eventId]

  event[self] = event[self] or setmetatable({}, {__mode = "k"})
  local eventsForSelf = event[self]

  eventsForSelf[methodOrName] = eventsForSelf[methodOrName] or {}
  local actions = eventsForSelf[methodOrName]

  table.insert(actions, methodOrName)
end

function Beholder:stopObserving(eventId, methodOrName)
  local event = _events[eventId]
  if(event==nil) then return end

  local eventsForSelf = event[self]
  if(eventsForSelf==nil) then return end

  eventsForSelf[methodOrName] = nil
end


--[[ Triggers events
   Usage:
     Beholder.trigger('passion.update', dt)
   All objects that are "observing" passion.update events will get their associated actions called.
]]

function Beholder.trigger(eventId, ...)

  local event = _events[eventId]
  if(event==nil) then return end
  
  for object,eventsForObject in pairs(event) do
    for _,actions in pairs(eventsForObject) do
      for _,action in ipairs(actions) do
          local method
          if(type(action)=='string') then
            method = object[action]
            assert(type(method)=='function', 'method '.. action .. 'not found on object ' .. tostring(object))
          elseif(type(action)=='function') then
            method = methodOrName
          else
            error('Action must be a function or method name. Was ' .. tostring(action))
          end
        method(object, ...)
      end
    end
  end
end
