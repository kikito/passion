passion = {}

-- ACTOR MANAGING STUFF

passion.actorClasses={}
function passion:addActorClass(actorClass)
  table.insert(self.actorClasses,actorClass)
end

-- EXIT
function passion:exit()
  love.event.push('q')
end

-- PHYSICAL WORLD STUFF

function passion:newWorld(w, h)
  self.world = love.physics.newWorld( w, h )
  self.ground = self:newBody(0, 0, 0)
  return world
end
function passion:destroyWorld()
  self.world = nil
end
function passion:getWorld()
  assert(self.world ~= nil, "passion.world is nil. You must invoke passion:newWorld")
  return self.world
end
function passion:getGround()
  assert(self.ground ~= nil, "passion.ground is nil. You must invoke passion:createWorld before using passion:getGround")
  return self.ground
end
function passion:newBody(x, y, m )
  local world = self:getWorld()
  return love.physics.newBody( world, x, y, m )
end

-- Passion will route the following to its internal world object (i.e. passion:setGravity(0, 100)
local delegatedMethods = {
  'getBodyCount', 'getCallbacks', 'getGravity', 'getJointCount', 'getMeter', 'isAllowSleep', 'setAllowSleep', 'setCallbacks', 'setGravity', 'setMeter'
}
for _,method in pairs(delegatedMethods) do
  passion[method] = function(self, ...)
    local world = passion:getWorld()
    return world[method](world, ...)
  end
end

-- CALLBACK STUFF

-- update callback
local updateIfNotFrozen = function(actor, dt)
  if(actor:isFrozen()==false) then actor:update(dt) end
end

function passion:update(dt)
  if self.world ~= nil then self.world:update(dt) end
  passion.Actor:applyToAllActors(updateIfNotFrozen, dt)
end

-- draw callback
local drawn = {}
local drawIfVisible = function(actor)
  if(actor:getVisible()==true and drawn[actor]==nil) then
    actor:draw()
    drawn[actor] = 1
  end
end

function passion:draw()
  drawn = {}
  passion.Actor:applyToAllActorsSorted(drawIfVisible, passion.Actor.sortByDrawOrder)
end

-- Rest of the callbacks
local callbacks = {
  'joystickpressed', 'joystickreleased', 'keypressed', 'keyreleased', 'mousepressed', 'mousereleased', 'reset', 'draw'
}
for _,methodName in ipairs(callbacks) do
  passion[methodName] = function(self, ...)
    passion.Actor:applyToAllActors(methodName, ...)
  end
end

-- MAIN LOOP STUFF

--[[ passion.run. Can be used to "replace" love.run. Use it like this:
function love.run()
  return passion:run()
end
]]
function passion.run()

  -- registers the love events on passion
  for _,f in ipairs({'joystickpressed', 'joystickreleased', 'keypressed', 'keyreleased', 'mousepressed', 'mousereleased'}) do
    love[f] = function(...)
      passion[f](passion, ...)
    end
  end

  if(type(love.load)=='function') then love.load() end
  if(type(passion.load)=='function') then passion:load() end

  local dt = 0

  -- Main loop time.
  while true do
    if love.timer then
      love.timer.step()
      dt = love.timer.getDelta()
    end
    passion:update(dt) -- will pass 0 if love.timer is disabled

    if love.graphics then
      love.graphics.clear()
      passion:draw()
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

    passion:reset() -- do something between the "draw" and "update" calls
  end
end

-- RESOURCE LOADING STUFF

passion.resources = {
  images = {},
  sources = {},
  fonts = {}
}

local getResource = function(collection, f, key, ...)
  local resource = collection[key]
  if(resource == nil) then
    resource = f(...)
    collection[key]=resource
  end
  return resource
end

function passion:getImage(pathOrFileOrData)
  assert(self==passion, 'Use passion:getImage instead of passion.getImage')
  return getResource(self.resources.images, love.graphics.newImage, pathOrFileOrData, pathOrFileOrData)
end

local newSource = function(pathOrFileOrData, sourceType)
  if(sourceType==nil) then return love.audio.newSource(pathOrFileOrData)
  else return love.audio.newSource(pathOrFileOrData, sourceType)
  end
end

function passion:getSource(pathOrFileOrData, sourceType)
  assert(self==passion, 'Use passion:getSource instead of passion.getSource')

  local sourceList = self.resources.sources[pathOrFileOrData]
  if(sourceList == nil) then
    self.resources.sources[pathOrFileOrData] = {}
    sourceList = self.resources.sources[pathOrFileOrData]
  end

  return getResource(sourceList, newSource, sourceType, pathOrFileOrData, sourceType )
end

function passion:getFont(sizeOrPathOrImage, sizeOrGlyphs)
  assert(self==passion, 'Use passion:getFont instead of passion.getFont')
  if(type(sizeOrPathOrImage)=='number') then --sizeOrPathOrImage is a size -> default font

    local size = sizeOrPathOrImage
    return getResource(self.resources.fonts, love.graphics.newFont, size, size)

  elseif(type(sizeOrPathOrImage=='string')) then --sizeOrPathOrImage is a path -> ttf or imagefont

    local path = sizeOrPathOrImage
    local extension = string.sub(path,-3)

    local fontList = self.resources.fonts[path]
    if(fontList == nil) then
      self.resources.fonts[path] = {}
      fontList = self.resources.fonts[path]
    end

    if('ttf' == string.lower(extension)) then -- it is a truetype font
      local size = sizeOrGlyphs
      return getResource(fontList, love.graphics.newFont, size, path, size)
    else -- it is an image font, with a path
      print('c')
      local image = self:getImage(path)
      local glyphs = sizeOrGlyphs
      return getResource(fontList, love.graphics.newImageFont, path, image, glyphs)
    end

  else -- sizeOrPathOrImage is an image -> imagefont, with an image

    local image = sizeOrPathOrImage
    local glyphs = sizeOrGlyphs
    return getResource(self.fonts, love.graphics.newImageFont, image, image, glyphs)

  end

end

