--module 'passion'

require 'passion.graphics.Core'


local math_round = function (num, idp) local mult = 10^(idp or 0) return math.floor(num * mult + 0.5) / mult end

function passion.graphics.roundedRectangle(style, x, y, width, height, r)

  assert(style=='line' or style=='fill', "style must be either 'line' or 'fill'")
  assert(x~=nil and y~=nil and width~=nil and height~=nil, "x,y,width and height are required parameters" )

  r = r or 0

  if(r <= 0) then

    love.graphics.rectangle(style, x, y, width, height)

  elseif(style=='fill') then

    local rBy2 = r * 2
    local rBy3 = r * 3
  
    love.graphics.rectangle('fill', x+r, y, width-rBy2, height)
    love.graphics.rectangle('fill', x, y+r, width, height-rBy2)
    love.graphics.circle('fill', x+r, y+r, r, rBy3)
    love.graphics.circle('fill', x+width-r, y+r, r, rBy3)
    love.graphics.circle('fill', x+r, y+height-r, r, rBy3)
    love.graphics.circle('fill', x+width-r, y+height-r, r, rBy3)

  else  -- style=='line'

    love.graphics.line(x+r, y, x+width-r, y)
    love.graphics.line(x+width, y+r, x+width, y+height-r)
    love.graphics.line(x+r, y+height, x+width-r, y+height)
    love.graphics.line(x, y+r, x, y+height-r)
    
    local step = 1.0 / r
    local theta = 0.0
    local c = r + 0.0
    local s = 0.0
    local pc = c
    local ps = s
    local pointRadius = love.graphics.getLineWidth() / 2.0
    local pointRadiusBy3 = pointRadius*3

    while(theta <= math.pi / 4.0) do
      theta = theta + step
      c = math_round(r*math.cos(theta)) -- rounded cosine
      s = math_round(r*math.sin(theta)) -- rounded sine

      love.graphics.line(x+width-r+pc, y+r-ps, x+width-r+c, y+r-s) -- octant 0
      love.graphics.line(x+width-r+ps, y+r-pc, x+width-r+s, y+r-c) -- octant 1
      love.graphics.line(x+r-pc, y+r-ps, x+r-c, y+r-s) -- octant 2
      love.graphics.line(x+r-ps, y+r-pc, x+r-s, y+r-c) -- octant 3
      love.graphics.line(x+r-pc, y+height-r+ps, x+r-c, y+height-r+s) -- octant 4
      love.graphics.line(x+r-ps, y+height-r+pc, x+r-s, y+height-r+c) -- octant 5
      love.graphics.line(x+width-r+pc, y+height-r+ps, x+width-r+c, y+height-r+s) -- octant 6
      love.graphics.line(x+width-r+ps, y+height-r+pc, x+width-r+s, y+height-r+c) -- octant 8

      if(pointRadius > 1) then
        love.graphics.circle('fill', x+width-r+pc, y+r-ps, pointRadius, pointRadiusBy3)
        love.graphics.circle('fill', x+width-r+ps, y+r-pc, pointRadius, pointRadiusBy3)
        love.graphics.circle('fill', x+r-pc, y+r-ps, pointRadius, pointRadiusBy3)
        love.graphics.circle('fill', x+r-ps, y+r-pc, pointRadius, pointRadiusBy3)
        love.graphics.circle('fill', x+r-pc, y+height-r+ps, pointRadius, pointRadiusBy3)
        love.graphics.circle('fill', x+r-ps, y+height-r+pc, pointRadius, pointRadiusBy3)
        love.graphics.circle('fill', x+width-r+pc, y+height-r+ps, pointRadius, pointRadiusBy3)
        love.graphics.circle('fill', x+width-r+ps, y+height-r+pc, pointRadius, pointRadiusBy3)
      end

      pc = c
      ps = s
    end
  end
end


