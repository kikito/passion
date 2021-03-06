-----------------------------------------------------------------------------------------------------------------------
-- passion/audio/init.lua
-----------------------------------------------------------------------------------------------------------------------

local _path = ({...})[1]:gsub("%.init", "")
local _modules = {
  'audio'
}

for _,module in ipairs(_modules) do
  require(_path .. '.' .. module)
end
