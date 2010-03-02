passion.audio = {}

------------------------------------
-- PRIVATE METHODS AND ATTRIBUTES
------------------------------------

--stores the sources obtained with passion.audio.getSource
local _sources = {}

--[[ Function used for creating new sources
   We need to use a function in order to cope with the several ways to load a resource
]]
local _newSource = function(pathOrFileOrData, sourceType)
  if(sourceType==nil) then return love.audio.newSource(pathOrFileOrData)
  else return love.audio.newSource(pathOrFileOrData, sourceType)
  end
end

------------------------------------
-- PUBLIC FUNCTIONS
------------------------------------

function passion.audio.getSource(pathOrFileOrData, sourceType)

  sourceType = sourceType or "stream"

  local sourceList = _sources[pathOrFileOrData]
  if(sourceList == nil) then
    _sources[pathOrFileOrData] = {}
    sourceList = _sources[pathOrFileOrData]
  end

  return passion._getResource(sourceList, _newSource, sourceType, pathOrFileOrData, sourceType )
end
