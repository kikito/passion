
-- passion general loading order - do not alterate without a reason!
-- TODO: skip loading of modules if love modules are deactivated

require 'passion.oop.init'

require 'passion.passion'
require 'passion.constants'

require 'passion.graphics.init'
require 'passion.fonts.init'
require 'passion.audio.init'

require 'passion.Actor'
require 'passion.ActorWithBody'

require 'passion.gui.init'


