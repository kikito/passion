-----------------------------------------------------------------------------------------------------------------------
-- passion/init.lua
-- passion general loading order - do not alterate without a reason!
-----------------------------------------------------------------------------------------------------------------------

-- TODO: skip loading of modules if love modules are deactivated


local _path = ({...})[1]:gsub("%.init", "")
local _modules = {
  'fixes.init',   'passion',    'colors.init', 'graphics.init',
  'fonts.init',   'audio.init', 'timer.init',  'Actor',
  'physics.init', 'gui.init'
}

for _,module in ipairs(_modules) do
  require(_path .. '.' .. module)
end
