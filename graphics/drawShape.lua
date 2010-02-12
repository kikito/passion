--module 'passion'

require 'passion.graphics.Core'


local math_round = function (num, idp) local mult = 10^(idp or 0) return math.floor(num * mult + 0.5) / mult end

function passion.graphics.drawShape(style, shape)

  assert(style=='line' or style=='fill', "style must be either 'line' or 'fill'")

  if(style=='fill') then

  else  -- style=='line'

  end

end


