local _G = _G

module('passion.audio')

------------------------------------
-- PRIVATE METHODS AND ATTRIBUTES
------------------------------------

--[[ stores the sources obtained with passion.audio.getSource.
  It has the following structure:
  { source1 : {
      "stream": source
      "static": source
    }
  }
]]
local _sources = {}

-- stores multiple instances of the same source so they can be reproduced simultaneously
local _pools = {}

-- given a source, it returns it if it is not being played, or looks in the pool for a copy that isn't.
local _getFreeSource = function(source)
  if(source:isStopped()) then
    return source
  end

  local pool = _pools[source]
  if(pool==nil) then return nil end
  for _,pooledSource in _G.ipairs(pool) do
    if(pooledSource:isStopped()) then
      return pooledSource
    end
  end
  return nil
end

------------------------------------
-- PUBLIC FUNCTIONS
------------------------------------

--[[ Creates/gets a source from the source list.
  The instances parameters controls how many "copies" of the source are created, so the same source
  can be played simultaneously more than once (defaults to 1 = no copies)
]]
function getSource(pathOrFileOrData, sourceType, instances)

  sourceType = sourceType or "stream"
  instances = instances or 1

  local sourceList = _sources[pathOrFileOrData]
  if(sourceList == nil) then
    _sources[pathOrFileOrData] = {}
    sourceList = _sources[pathOrFileOrData]
  end

  local source = _G.passion._getResource(sourceList, _G.love.audio.newSource, sourceType, pathOrFileOrData, sourceType)

  -- This creates copies of the source if needed
  if(instances > 1) then
    local pool = _pools[source]
    if(pool == nil) then
      _pools[source]={}
      pool = _pools[source]
    end
    if(#pool < instances) then
      local newInstances = instances-#pool-1
      for i = 1, newInstances, 1 do
        _G.table.insert(pool, _G.love.audio.newSource(pathOrFileOrData, sourceType))
      end
    end
  end

  return source

end

--passion.audio.play
--Plays a source. It looks for a copy of the source if it isn't stopped.
function play(source)
  local freeSource = _getFreeSource(source)

  if(freeSource~=nil) then
    _G.love.audio.play(freeSource)
  end
end
