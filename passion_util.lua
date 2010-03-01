------------------------------------
-- UTILITY METHODS STUFF
------------------------------------

-- This file contains helper methods used through passion

--[[ Helper function used to apply methods to collections
  * collection is a table containing a bunch of elements to which the function must be applied
  * sortFunc is a sorting function. It defines the order in which the method will be applied. It can be nil (no sorting)
  * methodOrName is either a function or a string
    - If it is a function, it will be applied to all items in the collection, in order
    - If it is a string, then each item must have a function named like MethodName.
  * additional parameters can be passed to the methodOrName function. The first parameter will allways be the element
  Example:

    passion.applyMethodToCollection({a,b,c}, nil, 'update', dt)

  is equivalent to doing this:
    a:update(dt)
    b:update(dt)
    c:update(dt)
]]
function passion.applyMethodToCollection(collection, sortFunc, methodOrName, ... )

  -- If sortFunc exists, make a copy of collection and sort it
  if(type(sortFunc)=='function') then
    local collectionCopy = {}
    local i = 1
    for _,item in pairs(collection) do
      collectionCopy[i]=item
      i=i+1
    end
    table.sort(collectionCopy, sortFunc)
    collection = collectionCopy
  end

  -- If methodOrName is a string, then apply the method named like it on each element in collection
  if(type(methodOrName)=='string') then
    for _,item in pairs(collection) do
      local method = item[methodOrName]
      if(type(method)=='function') then
        if(method(item, ...) == false) then return end
      end
    end

  -- If it is a function, just apply it to every item on the collection
  elseif(type(methodOrName)=='function') then
    for _,item in pairs(collection) do
      if(methodOrName(item, ...) == false) then return end
    end

  else
    error('methodOrName must be a function or function name')
  end
end

--[[ Removes an item from a table.
  Only works reliably with 'array-type' collections (collections indexed with integers)
  Removes only the first appearance of item
]]
function passion.removeItemFromCollection(collection, item)
  local index
  for i, v in pairs(collection) do
    if v == item then
      index = i
      break
    end
  end
  if(index~=nil) then table.remove(collection, index) end
end

-- prints a table on the console, recursively. Useful for debugging.
function passion.dumpTable(t, level, depth)
  level = level or 1
  depth = depth or 4
  
  if(level>=depth) then return end

  print(string.rep("   ", level) .. tostring(t) .. ':')

  if(type(t)=='table') then
    for k,item in pairs(t) do
      print(string.rep("   ", level+1) .. tostring(k) .. ' => '.. tostring(item) )
      if(type(item)=='table') then passion.dumpTable(item, level + 1) end
    end
  end
end

--[[ Aux function used in Resource loading. 
   If the resource is not in collection[key], create it using f(...)
   I need to make it "public" because I use it on the graphics, audio and fonts modules for
   implementing getImage, getSource and getFont.
   Regular users shouldn't be using it (that is why it begins with an underscore)
]]
function passion._getResource(collection, f, key, ...)
  local resource = collection[key]
  if(resource == nil) then
    resource = f(...)
    collection[key]=resource
  end
  return resource
end


