passion = {} -- like everything big, it starts so small...

------------------------------------
-- PRIVATE ATTRIBUTES AND METHODS
------------------------------------

-- table that controls that actors are not re-drawn. Used in draw callback
local _drawn = setmetatable({}, {__mode = "k"})

-- function used for drawing. Used in draw callback
local _drawIfNotDrawn = function(actor)
  if(_drawn[actor]==nil) then
    actor:draw()
    _drawn[actor] = 1
  end
end

-- function for drawing actors in the right order. Used in draw callback
local _sortByDrawOrder = function(actor1, actor2) -- sorting function
  if(actor1==nil or actor2==nil) then return true end

  return actor1:getDrawOrder() > actor2:getDrawOrder()
end

-- PÄSSION will route the following to its internal world object (i.e. passion.setGravity(0, 100) )
local _delegatedWorldMethods = {
  'getBodyCount' , 'getCallbacks', 'getGravity', 
  'getJointCount', 'getMeter'    , 'isAllowSleep', 
  'setAllowSleep', 'setCallbacks', 'setGravity', 
  'setMeter'
}

--[[ It looks for a resource (image, source, font).
   If the resource is not in collection[key], create it using f(...) - the additional parameters
   Used in Resource loading. 
]]
local _getResource = function(collection, f, key, ...)
  local resource = collection[key]
  if(resource == nil) then
    resource = f(...)
    collection[key]=resource
  end
  return resource
end

--[[ Function used for creating new sources (images and souncs)
   We need to create this intermediate function to handle special cases - like the same file
   opened twice, each one with one sourceType, for example.
   Used in Resource loading. 
]]
local _newSource = function(pathOrFileOrData, sourceType)
  if(sourceType==nil) then return love.audio.newSource(pathOrFileOrData)
  else return love.audio.newSource(pathOrFileOrData, sourceType)
  end
end

------------------------------------
-- EXIT
------------------------------------

-- I just did this small function because I never remember how to exit in LÖVE :)
function passion.exit()
  love.event.push('q')
end

------------------------------------
-- PHYSICAL WORLD STUFF
------------------------------------

function passion.newWorld(w, h)
  passion.world = love.physics.newWorld( w, h )
  passion.ground = passion.newBody(0, 0, 0)
  return world
end
function passion.getWorld()
  assert(passion.world ~= nil, "passion.world is nil. You must invoke passion.newWorld")
  return passion.world
end
function passion.getGround()
  assert(passion.ground ~= nil, "passion.ground is nil. You must invoke passion.createWorld before using passion.getGround")
  return passion.ground
end
function passion.newBody(x, y, m )
  local world = passion.getWorld()
  return love.physics.newBody( world, x, y, m )
end

-- Define world methods in PÄSSION so it can be used "as a world"
for _,method in pairs(_delegatedWorldMethods) do
  passion[method] = function(self, ...)
    local world = passion.getWorld()
    return world[method](world, ...)
  end
end

------------------------------------
-- CALLBACK STUFF
------------------------------------

-- update callback
function passion.update(dt)
  if passion.world ~= nil then passion.world:update(dt) end
  passion.Actor:applyToAllActors('update', dt)
end

-- draw callback
function passion.draw()
  _drawn = setmetatable({}, {__mode = "k"})
  passion.Actor:applyToAllActorsSorted( _sortByDrawOrder, _drawIfNotDrawn )
end

-- Rest of the callbacks
local _callbacks = {
  'joystickpressed', 'joystickreleased',
  'keypressed', 'keyreleased',
  'mousepressed', 'mousereleased', 'reset'
}
for _,methodName in ipairs(_callbacks) do
  passion[methodName] = function(self, ...)
    passion.Actor:applyToAllActors(methodName, ...)
  end
end

------------------------------------
-- MAIN LOOP
------------------------------------

--[[ passion.run. Can be used to "replace" love.run. Use it like this:

    function love.run()
      return passion.run()
    end

    We cannot simply attach the events and draw functions and use the default love callback because we need reset
    FIXME: review the need of passion.reset()
]]
function passion.run()

  -- registers the love events on passion
  for _,f in ipairs({'joystickpressed', 'joystickreleased', 'keypressed', 'keyreleased', 'mousepressed', 'mousereleased'}) do
    love[f] = function(...)
      passion[f](passion, ...)
    end
  end

  if(type(love.load)=='function') then love.load() end
  if(type(passion.load)=='function') then passion.load() end

  local dt = 0

  -- Main loop time.
  while true do
    if love.timer then
      love.timer.step()
      dt = love.timer.getDelta()
    end
    passion.update(dt) -- will pass 0 if love.timer is disabled

    if love.graphics then
      love.graphics.clear()
      passion.draw()
    end

    -- Process events.
    if love.event then
      for e,a,b,c in love.event.poll() do
        if e == "q" then
          if love.audio then love.audio.stop() end
          return
        end
        love.handlers[e](a,b,c)
      end
    end

    if love.timer then love.timer.sleep(1) end
    if love.graphics then love.graphics.present() end

    passion.reset() -- do something between the "draw" and "update" calls
  end
end

------------------------------------
-- RESOURCE LOADING STUFF
------------------------------------

passion.resources = {
  images = {},
  sources = {},
  fonts = {}
}

function passion.getImage(pathOrFileOrData)
  return _getResource(passion.resources.images, love.graphics.newImage, pathOrFileOrData, pathOrFileOrData)
end

function passion.getSource(pathOrFileOrData, sourceType)

  local sourceList = passion.resources.sources[pathOrFileOrData]
  if(sourceList == nil) then
    passion.resources.sources[pathOrFileOrData] = {}
    sourceList = passion.resources.sources[pathOrFileOrData]
  end

  return _getResource(sourceList, _newSource, sourceType, pathOrFileOrData, sourceType )
end

function passion.getFont(sizeOrPathOrImage, sizeOrGlyphs)
  if(type(sizeOrPathOrImage)=='number') then --sizeOrPathOrImage is a size -> default font

    local size = sizeOrPathOrImage
    return _getResource(passion.resources.fonts, love.graphics.newFont, size, size)

  elseif(type(sizeOrPathOrImage=='string')) then --sizeOrPathOrImage is a path -> ttf or imagefont

    local path = sizeOrPathOrImage
    local extension = string.sub(path,-3)

    local fontList = passion.resources.fonts[path]
    if(fontList == nil) then
      passion.resources.fonts[path] = {}
      fontList = passion.resources.fonts[path]
    end

    if('ttf' == string.lower(extension)) then -- it is a truetype font
      local size = sizeOrGlyphs
      return _getResource(fontList, love.graphics.newFont, size, path, size)
    else -- it is an image font, with a path
      print('c')
      local image = self:getImage(path)
      local glyphs = sizeOrGlyphs
      return _getResource(fontList, love.graphics.newImageFont, path, image, glyphs)
    end

  else -- sizeOrPathOrImage is an image -> imagefont, with an image

    local image = sizeOrPathOrImage
    local glyphs = sizeOrGlyphs
    return _getResource(passion.fonts, love.graphics.newImageFont, image, image, glyphs)

  end

end

------------------------------------
-- MISC STUFF
------------------------------------

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

-- prints a table on the console, recursively. Useful for debugging.
function passion.dumpTable(t, level, depth)
  level = level or 1
  depth = depth or 4
  
  if(level>=depth) then return end

  print(string.rep("   ", level) .. tostring(t) .. ':')

  if(type(t)=='table') then
    for k,item in pairs(t) do
      print(string.rep("   ", level+1) .. tostring(k) .. ' => '.. tostring(item) )
      if(type(item)=='table') then dumpTable(item, level + 1) end
    end
  end
end


