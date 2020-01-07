--[[
    Given an "atlas" (a texture with multiple sprites), as well as a
    width and a height for the tiles therein, split the texture into
    all of the quads by simply dividing it evenly.
]]
function GenerateQuads(atlas, tilewidth, tileheight)
  local sheetWidth = atlas:getWidth() / tilewidth
  local sheetHeight = atlas:getHeight() / tileheight
  
  local spritesheet = {}
  
  for y = 0, atlas:getHeight() - 1 do
    for x = 0, atlas:getWidth() - 1 do
      table.insert(spritesheet, love.graphics.newQuad(x * tilewidth, y * tileheight,
          tilewidth, tileheight, atlas:getDimensions()))
    end
  end
  
  return spritesheet
end