passion.fonts = {}

------------------------------------
-- PRIVATE METHODS AND ATTRIBUTES
------------------------------------

-- stores the fonts created with passion.fonts.getFont
local _fonts = {}

------------------------------------
-- PUBLIC FUNCTIONS
------------------------------------

--[[ Gets or creates a font.
  * If only a number is provided, it gets/creates a default font
  * If a path is provided:
    - If the path ends in ttf, it creates a ttf font
    - Otherwise it tries to create an image font from it
  * If an image is provided, it tries to create an image font
]]
function passion.fonts.getFont(sizeOrPathOrImage, sizeOrGlyphs)
  if(type(sizeOrPathOrImage)=='number') then --sizeOrPathOrImage is a size -> default font

    local size = sizeOrPathOrImage
    return passion._getResource(_fonts, love.graphics.newFont, size, size)

  elseif(type(sizeOrPathOrImage=='string')) then --sizeOrPathOrImage is a path -> ttf or imagefont

    local path = sizeOrPathOrImage
    local extension = string.sub(path,-3)

    local fontList = _fonts[path]
    if(fontList == nil) then
      _fonts[path] = {}
      fontList = _fonts[path]
    end

    if('ttf' == string.lower(extension)) then -- it is a truetype font
      local size = sizeOrGlyphs
      return passion._getResource(fontList, love.graphics.newFont, size, path, size)
    else -- it is an image font, with a path
      local image = passion.graphics.getImage(path)
      local glyphs = sizeOrGlyphs
      return passion._getResource(fontList, love.graphics.newImageFont, path, image, glyphs)
    end

  else -- sizeOrPathOrImage is an image -> imagefont, with an image

    local image = sizeOrPathOrImage
    local glyphs = sizeOrGlyphs
    return passion._getResource(_fonts, love.graphics.newImageFont, image, image, glyphs)

  end

end
