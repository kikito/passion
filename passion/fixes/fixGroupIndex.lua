-- fixGroupIndex.lua
-- fixes shape:getGroupIndex and shape:setGroupIndex on LÖVE <= 0.6.2
-- usage: require 'fixGroupIndex.lua'

if love.physics then

  local getGroupIndex= function(shape)
    local _, _, groupIndex = shape:getFilterData()
    return groupIndex
  end

  local setGroupIndex= function(shape, groupIndex)
    local categoryBits, maskBits, _ = shape:getFilterData()
    shape:setFilterData(categoryBits, maskBits, groupIndex)
  end

  local world = love.physics.newWorld(100,100)

  local body = love.physics.newBody(world)

  local c_mt = getmetatable(love.physics.newCircleShape(body, 10,10, 5))
  c_mt.setGroupIndex = c_mt.setGroupIndex or setGroupIndex
  c_mt.getGroupIndex = c_mt.getGroupIndex or getGroupIndex

  local p_mt = getmetatable(love.physics.newPolygonShape(body, 20,20, 30,20, 20,30))
  p_mt.setGroupIndex = p_mt.setGroupIndex or setGroupIndex
  p_mt.getGroupIndex = p_mt.getGroupIndex or getGroupIndex

  body:destroy()
  world = nil

end
