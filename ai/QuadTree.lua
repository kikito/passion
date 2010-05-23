local _G = _G
module('passion.ai')

QuadTree = _G.class('passion.ai.QuadTree')

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
local _createChildNodes = function(node)
  -- if the node is too small, or it already has nodes,, stop dividing it
  if(node.width * node.height < 16 or #(node.children) > 0) then return end

  local hw = node.width / 2.0
  local hh = node.height / 2.0

  node.children[1]= QuadTree:new(hw, hh, node.x,    node.y,    node)
  node.children[2]= QuadTree:new(hw, hh, node.x,    node.y+hh, node)
  node.children[3]= QuadTree:new(hw, hh, node.x+hw, node.y,    node)
  node.children[4]= QuadTree:new(hw, hh, node.x+hw, node.y+hh, node)
end

-- removes a node's children if they are all empty
local _emptyCheck
_emptyCheck = function(node)
  if(node==nil) then return end
  if(node:getCount() == 0) then
    node.children = {}
    _emptyCheck(node.parent)
  end
end

-- inserts an item on a node. Doesn't check whether it is the correct node
local _doInsert = function(node, item)
  if(node==nil) then return nil end
  node.items[item]= item
  node.root.previous[item] = node
  node.itemsCount = node.itemsCount + 1
  return node
end

-- removes an item from a node. It does not recursively traverse the node's children
local _doRemove = function(node, item)
  if(node==nil or node.items[item]==nil) then return end
  node.root.previous[item]=nil
  node.items[item] = nil
  node.itemsCount = node.itemsCount - 1
  _emptyCheck(node)
end


function QuadTree:initialize(width,height,x,y,parent)
  self.x, self.y, self.width, self.height = x or 0,y or 0,width,height

  self.items = _G.setmetatable({}, {__mode = "k"})
  self.itemsCount = 0

  self.children = {}

  -- root node has a property called "previous". It stores node assignments between updates
  if(parent==nil) then
    self.root = self
    self.previous = _G.setmetatable({}, {__mode = "k"})
  else
    self.parent = parent
    self.root = parent.root
  end

end

function QuadTree:getBoundingBox()
  return self.x, self.y, self.width, self.height
end

-- Counts the number of items on a QuadTree, including child nodes
function QuadTree:getCount()
  local count = self.itemsCount
  for _,child in _G.ipairs(self.children) do
    count = count + child:getCount()
  end
  return count
end

-- Gets items of the quadtree, including child nodes
function QuadTree:getAllItems()
  local results = {}
  for _,node in _G.ipairs(self.children) do
    for _,item in _G.ipairs(node:getAllItems()) do
      _G.table.insert(results, item)
    end
  end
  for _,item in _G.pairs(self.items) do
    _G.table.insert(results, item)
  end
  return results
end

-- Inserts an item on the QuadTree. Returns the node containing it
function QuadTree:insert(item)
  return _doInsert(self:findNode(item), item)
end

-- Removes an item from the QuadTree, searching up and down to find it
function QuadTree:remove(item)
  _doRemove(self.root.previous[item], item)
end

-- Returns the items intersecting with a given area
function QuadTree:query(x,y,w,h)
  local results = {}
  local nx,ny,nw,nh

  for _,item in _G.pairs(self.items) do
    if(_intersect(x,y,w,h, item:getBoundingBox())) then
      _G.table.insert(results, item)
    end
  end

  for _,child in _G.ipairs(self.children) do
    nx,ny,nw,nh = child:getBoundingBox()

    -- case 1: area is contained on the child completely
    -- add the items that intersect and then break the loop
    if(_contained(x,y,w,h, nx,ny,nw,nh)) then
      for _,item in _G.ipairs(child:query(x,y,w,h)) do
        _G.table.insert(results, item)
      end
      break

    -- case 2: child is completely contained on the area
    -- add all the items on the child and continue the loop
    elseif(_contained(nx,ny,nw,nh, x,y,w,h)) then
      for _,item in _G.ipairs(child:getAllItems()) do
        _G.table.insert(results, item)
      end

    -- case 3: node and area are intersecting
    -- add the items contained on the node's children and continue the loop
    elseif(_intersect(x,y,w,h, nx,ny,nw,nh)) then
      for _,item in _G.ipairs(child:query(x,y,w,h)) do
        _G.table.insert(results, item)
      end
    end
  end

  return results
end

-- Returns the smallest possible node that would contain a given item.
-- It does create additional nodes if needed, but it does *not* assign the node
-- if searchUp==true, search recursively up (parents), until root is reached
-- returns nil if the item isn't fully contained on the node, or searUp is true but
-- neither the node or its ancestors contain the item.
function QuadTree:findNode(item, searchUp)
  local x,y,w,h = item:getBoundingBox()
  if(_contained(x,y,w,h , self:getBoundingBox()) ) then
    -- the item is contained on the node. See if the node's descendants can hold the item
    _createChildNodes(self)
    for _,child in _G.ipairs(self.children) do
      local descendant = child:findNode(item, false)
      if(descendant ~= nil) then return descendant end
    end
    return self
  -- not contained on the node. Can we search up on the hierarchy?
  elseif(searchUp == true and self.parent~=nil) then
    return self.parent:findNode(item, true)
  else
    return nil
  end
end

-- Updates all the quadtree items
-- This method always updates the whole tree (starting from the root node)
function QuadTree:update()
  for item,previous in _G.pairs(self.root.previous) do
    local newNode = self:findNode(item, true)
    if(newNode~=previous) then
      _doRemove(previous, item)
      _doInsert(newNode, item)
    end
  end
end

function QuadTree:draw()
  for _,child in _G.ipairs(self.children) do
    child:draw()
  end
  _G.love.graphics.rectangle('line', self:getBoundingBox())
end



