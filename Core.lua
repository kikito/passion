passion = {}

-- ACTOR MANAGING STUFF

passion.actorClasses={}
function passion:addActorClass(actorClass)
  table.insert(self.actorClasses,actorClass)
end
function passion:applyToAllActorClasses(methodName, ...)
  local method
  for _,actorClass in pairs(self.actorClasses) do
    method = actorClass[methodName]
    if(type(method)=='function') then
      method(actorClass, ...)
    end
  end
end
function passion:applyToAllActors(methodName, ...)
  self:applyToAllActorClasses('applyToAllActors', methodName, ...)
end

-- PHYSICAL WORLD STUFF

function passion:newWorld(w, h)
  self.world = love.physics.newWorld( w, h )
  self.ground = self:newBody(0, 0, 0)
  return world
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
function passion:update(dt)
  if self.world ~= nil then self.world:update(dt) end
  passion:applyToAllActors('update', dt)
end

-- Rest of the callbacks
local callbacks = {
  'joystickpressed', 'joystickreleased', 'keypressed', 'keyreleased', 'mousepressed', 'mousereleased', 'reset', 'draw'
}
for _,method in ipairs(callbacks) do
  passion[method] = function(self, ...)
    passion:applyToAllActors(method, ...)
  end
end

-- MAIN LOOP STUFF

--[[ passion.run. Can be used to "replace" love.run. Use it like this:
function love.run()
  return passion:run()
end
]]

function passion:run()
  
  -- registers the love events on passion
  for _,f in ipairs({'joystickpressed', 'joystickreleased', 'keypressed', 'keyreleased', 'mousepressed', 'mousereleased'}) do
    love[f] = function(...)
      passion[f](passion, ...)
    end
  end
  
  if(type(passion.load)=='function') then passion:load() end
  -- Main loop.
  while true do
    love.timer.step()
    passion:update(love.timer.getDelta())
    
    love.graphics.clear()

    passion:draw()

    -- Process events.
    for e,a,b,c in love.event.poll() do
      if e == 'q' then
        if love.audio then love.audio.stop() end
        return
      end
      love.handlers[e](a,b,c)
    end
    love.timer.sleep(1)

    love.graphics.present() -- what is this?

    passion:reset() -- do something between the "draw" and "update" calls
  end
end

-- RESOURCE LOADING STUFF

passion.resources = {
  images = {},
  sounds = {},
  musics = {},
  fonts = {}
}

local getResource = function(collection, f, key, ...)
  local resource = collection[key]
  if(resource == nil) then resource = f(...) end
  return resource
end

function passion:getImage(pathOrFileOrData)
  return getResource(self.resources.images, love.graphics.newImage, pathOrFileOrData, pathOrFileOrData)
end

function passion:getSound(pathOrFileOrData)
  return getResource(self.resources.sounds, love.audio.newSound, pathOrFileOrData, pathOrFileOrData )
end

function passion:getMusic(pathOrFileOrDecoder)
  return getResource(self.resources.musics, love.audio.newMusic, pathOrFileOrDecoder, pathOrFileOrDecoder)
end

local newDefaultFont = function(size)
  local prevFont = love.graphics.getFont()
  love.graphics.setFont(size)
  local font = love.graphics.getFont()
  if(prevFont~=nil) then love.graphics.setFont(prevFont) end
  return font
end

function passion:getFont(sizeOrPathOrImage, sizeOrGlyphs)
  if(type(sizeOrPathOrImage)=='number') then --sizeOrPathOrImage is a size -> default font

    local size = sizeOrPathOrImage
    return getResource(self.resources.fonts, newDefaultFont, size, size)

  elseif(type(sizeOrPathOrImage=='string')) then --sizeOrPathOrImage is a path -> ttf or imagefont

    local path = sizeOrPathOrImage
    local extension = string.match(path, '\.(%a%a%a)')
    assert(extension~=nil, "The file must have a valid extension (ttf or image)")

    local fontList = self.resources.fonts[path]
    if(fontList == nil) then
      self.resources.fonts[path] = {}
      fontList = self.resources.fonts[path]
    end

    if('ttf' == string.lower(extension)) then -- it is a truetype font
      local size = sizeOrGlyphs
      return getResource(fontList, love.graphics.newFont, size)
    else -- it is an image font, with a path
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

