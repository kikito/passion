

require 'passion.Core'

passion.HasImage = {

  setImage = function(self, img)
    self.image = img
  end,

  --[[
    draw( sprite, x, y )                Draws an Image or Animation on screen.
    draw( sprite, x, y, angle )         Draws a rotated Image or Animation on screen.
    draw( sprite, x, y, angle, s )      Draws a rotated/scaled Image or Animation on screen.
    draw( sprite, x, y, angle, sx, sy )
  ]]
  draw= function(self)
    local angle = self:getAngle()
    if angle == nil then return love.graphics.draw(self:getImage(), self:getX(), self:getY()) end
    return love.graphics.draw(self:getImage(), self:getX(), self:getY(), self:getAngle(), self:getScaleX(), self:getScaleY(), self:getCenterX(), self:getCenterY())
  end,

  getImage = function(self)
    assert(self.image ~= nil, "self.image is nil. You must invoke setImage on the constructor")
    return self.image
  end
}