
--[[
    Based on the work of Samuel Stauffer <samuel@descolada.com>
    http://samuelks.com/lua-quadtree/
]]

passion.physics.QuadTree = class('passion.physics.QuadTree')
local QuadTree = passion.physics.QuadTree

--[[
  Create and return a new instance of the QuadTree class with
  the given position and size.
]]
function QuadTree:initialize(_left, _top, _width, _height)
  self.left   = _left
  self.top    = _top
  self.width  = _width
  self.height = _height
  self.children = nil
  self.objects = {}
end

-- Subdivide (split) the QuadTree into four sub QuadTrees
function QuadTree:subdivide()
  if self.children then
    for i,child in pairs(self.children) do
      child:subdivide()
    end
  else
    local x = self.left
    local y = self.top
    local w = math.floor(self.width / 2)
    local h = math.floor(self.height / 2)
    -- Note: This only works for even width/height
    --   for odd the size of the far quadrant needs to be
    --    (self.width - w, wself.height - h)
    self.children = {
      QuadTree:new(x    , y    , w, h),
      QuadTree:new(x + w, y    , w, h),
      QuadTree:new(x    , y + h, w, h),
      QuadTree:new(x + w, y + h, w, h)
    }
  end
end


function QuadTree:check(object, func, x, y)
  local oleft   = x or object.x
  local otop    = y or object.y
  local oright  = oleft + object.width - 1
  local obottom = otop + object.height - 1

  for i,child in pairs(self.children) do
    local left   = child.left
    local top    = child.top
    local right  = left + child.width - 1
    local bottom = top  + child.height - 1

    if oright < left or obottom < top or oleft > right or otop > bottom then
      -- Object doesn't intersect quadrant
    else
      func(child)
    end
  end
end

-- Add an object to the QuadTree
function QuadTree:addObject(object)
  assert(not self.objects[object], "You cannot add the same object twice to a QuadTree")

  if not self.children then
    self.objects[object] = object
  else
    self:check(object, function(child) child:addObject(object) end)
  end
end

--[[
  Remove an object from the QuadTree with an option to use the previous
  coordinates of the object.
]]
function QuadTree:removeObject(object, usePrevious)
  if not self.children then
    self.objects[object] = nil
  else
      -- if 'usePrevious' is true then use prev_x/y else use x/y
    local x = (usePrevious and object.prev_x) or object:getX()
    local y = (usePrevious and object.prev_y) or object:getY()
    self:check(object,
      function(child)
        child:removeObject(object, usePrevious)
      end, x, y)
  end
end

--[[
  Updates an object that's already in the QuadTree, moving
  it from its previous location to its current location.
]]
function QuadTree:updateObject(object)
  self:removeObject(object, true)
  self:addObject(object)
end

-- Remove all the objects from the QuadTree
function QuadTree:removeAllObjects()
  if not self.children then
    self.objects = {}
  else
    for i,child in pairs(self.children) do
      child:removeAllObjects()
    end
  end
end

-- Return a table of all objects near the given object
function QuadTree:getCollidableObjects(object, moving)
  if not self.children then
    return self.objects
  else
    local quads = {}
    local f = function (child) quads[child] = child end

    self:check(object, f)
    if moving then
      self:check(object, f, object.prev_x, object.prev_y)
    end

    local near = {}
    for q in pairs(quads) do
      for i,o in pairs(q:getCollidableObjects(object, moving)) do
        -- Make sure we don't return the object itself
        if i ~= object then
          table.insert(near, o)
        end
      end
    end

    return near
  end
end
