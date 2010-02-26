--module 'passion'

require 'passion.graphics.Core'


-- This variable remembers what the image that was used to create each quad
local _quadImages = setmetatable({}, {__mode = "k"})

-- Creates a new quad without you having to provide rwidth and rheight. It also remembers the image
-- that was used to create the quad, so you don't have to pass it to drawq
function passion.graphics.newQuad(image, x, y, width, height, rWidth, rHeight)
  rWidth = rWidth or image:getWidth()
  rHeight = rHeight or image:getHeight()
  local quad = love.graphics.newQuad( x, y, width, height, rWidth, rHeight )
  _quadImages[quad] = image
  return quad
end

--Similar to love.graphics.drawq, but you don't have to provide the image (in order for it to work, you
--need to create de quad with passion.graphics.newQuad (not with love.graphics.newQuad)
function passion.graphics.drawq(quad, x, y, r, sx, sy, ox, oy)
  local image = _quadImages[quad]
  assert(image~=nil, "Image not found for the quad. Please use passion.graphics.newQuad instead of love.graphics.newQuad")
  love.graphics.drawq(image, quad, x, y, r, sx, sy, ox, oy)
end


