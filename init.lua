
-- passion general loading order - do not alterate without a reason!
-- TODO: skip loading of modules if love modules are deactivated

require 'passion/fixes/init.lua'

require 'passion/oop/init.lua'

require 'passion/passion.lua'
require 'passion/passion_constants.lua'

require 'passion/graphics/init.lua'
require 'passion/fonts/init.lua'
require 'passion/audio/init.lua'

require 'passion/Actor.lua'

require 'passion/timer/init.lua'
require 'passion/physics/init.lua'

require 'passion/gui/init.lua'
