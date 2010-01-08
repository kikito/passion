require 'passion.gui.Core'
require 'passion.actors.Actor'

passion.gui.Control = class('passion.gui.Control', passion.Actor)

function passion.gui.Control:initialize(options)
  super(self)
  self:parseOptions(options)
end

function passion.gui.Control:parseOptions(options)
  options = options or {}
  self:setLabel(options.label)
  self:setPadding(options.padding)
  self:setBackgroundColor(options.backgroundColor)
  self:setX(options.x)
  self:setY(options.y)
end

passion.gui.Control:getterSetter('label')
passion.gui.Control:getterSetter('padding')
passion.gui.Control:getterSetter('backgroundColor')