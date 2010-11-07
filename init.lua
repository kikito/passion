
-- passion general loading order - do not alterate without a reason!
-- TODO: skip loading of modules if love modules are deactivated

package.path = 'passion/?;passion/?.lua;' .. package.path

require 'passion.fixes.init'

require 'passion.middleclass-extras.init'

require 'passion.passion'
require 'passion.colors.init'

require 'passion.graphics.init'
require 'passion.fonts.init'
require 'passion.audio.init'
require 'passion.timer.init'

require 'passion.Actor'

require 'passion.physics.init'

require 'passion.gui.init'

require 'passion.ai.init'
