--module 'passion'

require 'passion.graphics.Core'

function passion.graphics.drawShape(style, shape)

  assert(style=='line' or style=='fill', "style must be either 'line' or 'fill'")

  local shapeType = shape:getType()

  if(shapeType=="polygon") then
    love.graphics.polygon(style, shape:getPoints())
  elseif(shapeType=="circle") then
    local r = shape:getRadius()
    local x, y = shape:getWorldCenter()
    love.graphics.circle(style, x,y, r, r*3)
  else
    error("Unkwnown shape type: "..shapeType)
  end

end


