-----------------------------------------------------------------------------------
-- MiddleClass.lua
-- Enrique Garc�a ( enrique.garcia.cota [AT] gmail [DOT] com ) - 19 Oct 2009
-- Based on YaciCode, from Julien Patte and LuaObject, from S�bastien Rocca-Serra
-----------------------------------------------------------------------------------

local classes = setmetatable({}, {__mode = "k"})   -- weak table storing references to all declared classes

-- The 'Object' class
Object = { name = "Object",
  -- creates a new instance
  new = function(class, ...)
    assert(classes[class]~=nil, "Use class:new instead of class.new")

    local instance = setmetatable({ class = class }, class.__classDict) -- the class dictionary is the instance's metatable
    instance:initialize(...)
    return instance
  end,

  -- creates a subclass
  subclass = function(superclass, name)
    assert(classes[superclass]~=nil, "Use class:subclass instead of class.subclass")
    if type(name)~="string" then name = "Unnamed" end

    local theClass = { name = name, superclass = superclass, __classDict = {} }
    local classDict = theClass.__classDict

    -- This one is weird. Since:
    -- a) the class dict is the instances' metatable (so it must have an __index for looking up the methods) and
    -- b) The instance methods are in the class dict itself, then ...
    classDict.__index = classDict
    -- if a method isn't found on the class dict, look on its super class
    setmetatable(classDict, {__index = superclass.__classDict} )
    -- theClass also needs some metamethods
    setmetatable(theClass, {
      __index = function(_,methodName)
        local localMethod = classDict[methodName] -- this allows using classDic as a class method AND instance method dict
        if localMethod ~= nil then return localMethod end
        return superclass[methodName]
      end,
      -- FIXME add support for __index method here
      __newindex = function(_, methodName, method) -- when adding new methods, include a "super" function
        if type(method) == 'function' then
          local super = function(instance, ...) return superclass[methodName](instance, ...) end --super function
          local fenv = getfenv(method) -- the method's environment
          local newenv = setmetatable( {super = super}, {__index=fenv, __newindex=fenv} ) -- the new method's env, with super
          setfenv(method, newenv)
        end
        rawset(classDict, methodName, method)
      end,
      __tostring = function() return ("class ".. name) end,
      __call = theClass.new
    })
    -- instance methods go after the setmetatable, so we can use "super"
    theClass.initialize = function(instance,...) super(instance) end

    classes[theClass]=theClass --registers the new class on the list of classes

    return theClass
  end,

  -- Mixin extension function - simulates very basically ruby's include(module)
  -- module is a lua table of functions. The functions will be copied to the class
  -- if present in the module, the included() method will be called
  includes = function(class, module)
    assert(classes[class]~=nil, "Use class:includes instead of class.includes")
    for methodName,method in pairs(module) do
      if methodName ~="included" then class[methodName] = method end
    end
    if type(module.included)=="function" then module:included(class) end
  end
}

classes[Object]=Object -- adds Object to the list of classes

Object.__classDict = {
  initialize = function(instance, ...) end,   -- end of the initialize() call chain
  __tostring = function(instance) return ("instance of ".. instance.class.name) end
}

setmetatable(Object, { __index = Object.__classDict, __newindex = Object.__classDict,
  __tostring = function() return ("class Object") end,
  __call = Object.new
})

-- Returns true if class is a subclass of other, false otherwise
function subclassOf(other, class)
  if class.superclass==nil then return false end --class is Object, or a non-class
  return class.superclass == other or subclassOf(other, class.superclass)
end

-- Returns true if obj is an instance of class (or one of its subclasses) false otherwise
function instanceOf(class, obj)
  if obj==nil or classes[class]==nil or classes[obj.class]==nil then return false end
  if obj.class==class then return true end
  return subclassOf(class, obj.class)
end

function class(name, baseClass)
  baseClass = baseClass or Object
  return baseClass:subclass(name)
end