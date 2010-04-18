local passion = passion
local love = love
local table = table
local class = class
local setmetatable=setmetatable
local ipairs=ipairs
local pairs=pairs
local assert=assert
local print=print


module('passion.ai')

QuadTree = class('passion.ai.QuadTree')

-- returns true if two boxes intersect
local _intersect = function(ax1,ay1,aw,ah, bx1,by1,bw,bh)

  local ax2,ay2 = ax1 + aw, ay1 + ah
  local bx2,by2 = bx1 + bw, by1 + bh

  return (ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1)
end

-- returns true if a is contained in b
local _contained = function(ax1,ay1,aw,ah, bx1,by1,bw,bh)

  local ax2,ay2 = ax1 + aw, ay1 + ah
  local bx2,by2 = bx1 + bw, by1 + bh

  return (bx1 <= ax1 and bx2 >= ax2 and by1 <= ay1 and by2 >= ay2)
end

-- create child nodes
local _createChildNodes = function(self)
  -- if the node is too small, stop dividing it
  if(self.width * self.height < 10) then return end

  local hw = self.width / 2.0
  local hh = self.height / 2.0

  table.insert(self.nodes, QuadTree:new(hw, hh, self.x,    self.y,    self.root, self))
  table.insert(self.nodes, QuadTree:new(hw, hh, self.x,    self.y+hh, self.root, self))
  table.insert(self.nodes, QuadTree:new(hw, hh, self.x+hw, self.y,    self.root, self))
  table.insert(self.nodes, QuadTree:new(hw, hh, self.x+hw, self.y+hh, self.root, self))
end

-- removes a node's children if they are all empty
function _emptyCheck(self)
  if(self==nil) then return end
  if(self:getCount() == 0) then
    self.nodes = {}
    _emptyCheck(self.parent)
  end
end


function QuadTree:initialize(width,height,x,y,root,parent)
  self.x, self.y, self.width, self.height = x or 0,y or 0,width,height
  self.parent = parent

  self.items = setmetatable({}, {__mode = "k"})
  self.itemsCount = 0

  self.nodes = {}

  if(root==nil) then
    self.root = self
    self.assignments = setmetatable({}, {__mode = "k"})
  else
    self.root = root
  end

end

function QuadTree:getBoundingBox()
  return self.x, self.y, self.width, self.height
end

-- Counts the number of items on a QuadTree, including child nodes
function QuadTree:getCount()
  local count = self.itemsCount
  for _,node in ipairs(self.nodes) do
    count = count + node:getCount()
  end
  return count
end

-- Gets items of the quadtree, including child nodes
function QuadTree:getAllItems()
  local results = {}
  for _,node in ipairs(self.nodes) do
    for _,item in ipairs(node:getAllItems()) do
      table.insert(results, item)
    end
  end
  for _,item in pairs(self.items) do
    table.insert(results, item)
  end
  return results
end

-- Returns the items intersecting with a given area
function QuadTree:query(x,y,w,h)
  local results = {}
  local nx,ny,nw,nh

  for _,item in pairs(self.items) do
    if(_intersect(x,y,w,h, item:getBoundingBox())) then
      table.add(results, item)
    end
  end

  for _,node in ipairs(self.nodes) do
    nx,ny,nw,ny = node:getBoundingBox()

    -- case 1: area is contained on the node completely
    -- add the items that intersect and then break the loop
    if(_contained(x,y,w,h, nx,ny,nw,ny)) then
      for _,item in ipairs(node:query(x,y,w,h)) do
        table.insert(results, item)
      end
      break

    -- case 2: node is completely contained on the area
    -- add all the items on the node and continue the loop
    elseif(_contained(nx,ny,nw,nh, x,y,w,y)) then
      for _,item in ipairs(node:getAllItems()) do
        table.insert(results, item)
      end

    -- case 3: node and area are intersecting
    -- add the items contained on the node's children and continue the loop
    elseif(_intersect(x,y,w,h, nx,ny,nw,ny)) then
      for _,item in ipairs(node:query(x,y,w,h)) do
        table.insert(results, item)
      end
    end
  end

  return results
end

-- Inserts an item on the QuadTree. Returns the node containing it
function QuadTree:insert(item)
  local x,y,w,h = item:getBoundingBox()
  if( not _contained(x,y,w,h , self:getBoundingBox()) ) then
    -- Attempted to insert an item on a QuadTree that does not contain it; just return
    return nil
  end
  assert(self.items[item] == nil, 'Attempted to insert the same item on the same node twice')

  if(#(self.nodes)==0) then _createChildNodes(self) end

  for _,node in ipairs(self.nodes) do
    if(node:insert(item) ~= nil) then return node end
  end

  self.items[item]= item
  self.root.assignments[item] = self
  self.itemsCount = self.itemsCount + 1
  return self
end

-- Removes an item from the QuadTree
function QuadTree:remove(item)
  local node = self.root.assignments[item]
  if(node~=nil) then
    self.root.assignments[item]=nil
    node.items[item] = nil
    node.itemsCount = node.itemsCount - 1
    _emptyCheck(node)
  end
end

-- Updates an item on the QuadTree.
function QuadTree:update(item)
  self:remove(item)
  -- if the node wasn't found, or was found but doesn't contain the item any more, then
  -- insert the item back into the root node
  return self.root:insert(item)
end

function QuadTree:draw()
  for _,node in ipairs(self.nodes) do
    node:draw()
  end
  love.graphics.rectangle('line', self:getBoundingBox())
end



