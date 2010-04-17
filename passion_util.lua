local passion=passion
local table=table
local type=type
local assert=assert
local print=print
local pairs=pairs
local tostring=tostring

module('passion')

-- This file contains helper methods used through passion

------------------------------------
-- PUBLIC METHODS
------------------------------------

--[[ Invokes a function over an object, with parameters.
  MethodOrName can be either a function or a method name. The following lines are equivalent:

    player:moveRight(10)
    passion.invoke(player, function() player:moveRight(10) end)
    passion.invoke(player, 'moveRight', 10)

This is useful for implementing things like passion.apply easily.
]]
function invoke(object, methodOrName, ...)
  local method = methodOrName
  if(type(methodOrName)=='string') then method = object[methodOrName] end

  assert(type(method)=='function', 'methodOrName must be a function or function name')

  return method(object, ...)
end

--[[ Helper function used to apply methods to collections
  * collection is a table containing a bunch of elements to which the function must be applied
  * sortFunc is a sorting function. It defines the order in which the method will be applied. It can be nil (no sorting)
  * methodOrName is either a function or a string
    - If it is a function, it will be applied to all objects in the collection, in order
    - If it is a string, then each object must have a function named like MethodName.
  * additional parameters can be passed to the methodOrName function. The first parameter will allways be the element
  Example:

    passion.apply({a,b,c}, nil, 'update', dt)

  is equivalent to doing this:
    a:update(dt)
    b:update(dt)
    c:update(dt)
]]
function apply(collection, methodOrName, ... )
  for _,object in pairs(collection) do
    if(invoke(object, methodOrName, ...) == false) then return end
  end
end

-- sorted version of passion.apply
function applySorted(collection, sortFunc, methodOrName, ... )

  -- If sortFunc exists, make a copy of collection and sort it
  if(type(sortFunc)=='function') then
    local collectionCopy = {}
    local i = 1
    for _,object in pairs(collection) do
      collectionCopy[i]=object
      i=i+1
    end
    table.sort(collectionCopy, sortFunc)
    collection = collectionCopy
  end

  apply(collection, methodOrName, ...)
end


--[[ Removes an object from a table.
  Only works reliably with 'array-type' collections (collections indexed with integers)
  Removes only the first appearance of object
]]
function remove(collection, object)
  local index
  for i, v in pairs(collection) do
    if v == object then
      index = i
      break
    end
  end
  if(index~=nil) then table.remove(collection, index) end
end

-- prints a table on the console, recursively. Useful for debugging.
function dumpTable(t, level, depth)
  level = level or 1
  depth = depth or 4
  
  if(level>=depth) then return end

  print(string.rep("   ", level) .. tostring(t) .. ':')

  if(type(t)=='table') then
    for k,object in pairs(t) do
      print(string.rep("   ", level+1) .. tostring(k) .. ' => '.. tostring(object) )
      if(type(object)=='table') then dumpTable(object, level + 1) end
    end
  end
end

--[[ Aux function used in Resource loading. 
   If the resource is not in collection[key], create it using f(...)
   I need to make it "public" because I use it on the graphics, audio and fonts modules for
   implementing getImage, getSource and getFont.
   Regular users shouldn't be using it (that is why it begins with an underscore)
]]
function _getResource(collection, f, key, ...)
  local resource = collection[key]
  if(resource == nil) then
    resource = f(...)
    collection[key]=resource
  end
  return resource
end


