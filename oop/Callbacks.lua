
-----------------------------------------------------------------------------------
-- HasCallbacks.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com )
-- Mixin that adds callbacks support (i.e. beforeXXX or afterYYY) to Object)
-----------------------------------------------------------------------------------

--------------------------------
--      PRIVATE STUFF
--------------------------------


--[[ holds all the callbacks; callbacks are just lists of methods

    structure:

    { Actor = {
        'beforeUpdate' = { methods = {m1, m2, m3 } }, -- m1, m2, m3 & m4 can be method names or functions
        'afterUpdate' = { methods = { 'm4' } },
        'update' = {
          'before' = { 'beforeUpdate' },
          'after' = { 'afterUpdate' }
        }
      }
    }

]]
local _callbacks = {} 


-- private class methods

-- creates one of the "level 2" entries on callbacks, like beforeUpdate, afterupdate or update, above
local function _getOrCreateCallback(theClass, callbackName)
  if(not theClass or not callbackName) then return {} end
  _callbacks[theClass] = _callbacks[theClass] or {}
  local classCallbacks = _callbacks[theClass]
  classCallbacks[callbackName] = classCallbacks.methods[callbackName] or {methods={}, before={}, after={}}
  return classCallbacks[callbackName]
end

-- returns all the methods that should be called when a callback is invoked, including superclasses
local function _getCallbackChainMethods(theClass, callbackName)
  local methods = _getOrCreateCallback(theClass, callbackName).methods
  local superMethods = _getCallbackChainMethods(theClass.superclass, callbackName)

  local result = {}
  for i,method in ipairs(methods) do result[i]=method end
  for _,method in ipairs(superMethods) do table.insert(result, method) end

  return result
end

-- defines a callback method. These methods are used to add "methods" to the callback.
-- for example, after calling _defineCallbackMethod(Actor, 'afterUpdate') you can then do
-- Actor:afterUpdate('removeFromList', 'dance', function(actor) actor:doSomething() end)
local function _defineCallbackMethod(theClass, callbackName)
  if(callbackName == nil) then return nil end
  
  local previous = type(theClass[callbackName]=='function') and theClass[callbackName] or nil
  
  theClass[callbackName] = function(theClass, ...)
    local methods = {...}
    local existingMethods = _getOrCreateCallback(theClass, callbackName).methods
    for _,method in ipairs(methods) do
      table.insert(existingMethods, method)
    end
    if(previous) then previous(theClass, ...) end
  end

  return theClass[callbackName]
end

-- private instance methods

-- given a callback name (e.g. beforeUpdate), obtain all the methods that must be called and execute them
local function _runCallbackChain(object, callbackName)
  local methods = _getCallbackChainMethods(object.class, callbackName)
  for _,method in ipairs(methods) do
    if(type(method) == 'string') then
      method = object[method]
    end

    assert(type(method) == 'function', 'method must be a function or the name of an existing method')

    if(method(object) == false) then return false end
  end
  return true
end


--------------------------------
--      PUBLIC STUFF
--------------------------------

Callbacks = {}

function Callbacks:included(theClass)

  if included(Callbacks, theClass) then return end
  
  local mt = getmetatable(theClass)
  local prevNewIndex = mt.__newindex

  mt.__newindex = function(_, methodName, method)
    -- start by setting the method the "regular way", so it gets the "super" variable
    prevNewIndex(_, methodName, method)
    if(type(method)=="function") then
      -- prevMethod is the regular method with "super" added
      local prevMethod = rawget(theClass.__classDict, methodName)

      -- newMethod surrounds prevMethod by before and after callbacks
      -- notice that the execution is cancelled if any callback returns false
      local newMethod = function(self, ...)
        local callback = _getOrCreateCallback(theClass, methodName)

        for _,before in ipairs(callback.before) do
          if(_runcallbackChain(self, before) == false) then return false end
        end

        local result = prevMethod(self, ...)

        for _,after in ipairs(callback.after) do
          if(_runcallbackChain(self, after) == false) then return false end
        end

        return result
      end
      rawset(theClass.__classDict, methodName, method)
    end
  end
end

-- usage: Actor:attachCallbacks('update', 'beforeUpdate', 'afterUpdate')
function Callbacks.attachCallbacks(theClass, methodName, beforeName, afterName)

  assert(type(methodName)=='string', 'methodName must be a string')
  assert(type(beforeName)=='string' or type(afterName)=='string', 'at least one of beforeName or afterName must be a string')

  _defineCallbackMethod(theClass, beforeName)
  _defineCallbackMethod(theClass, afterName)

  _getOrCreateCallback(theClass, beforeName)
  _getOrCreateCallback(theClass, afterName)

  local methodCallback = _getOrCreateCallback(theClass, methodName)

  if(beforeName) then table.insert(methodCallback.before, beforeName) end
  if(afterName) then table.insert(methodCallback.after, afterName) end

end





