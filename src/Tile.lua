Tile = Class{}

function Tile:init(x, y, id, topper, tileset, topperset)
  self.x = x
  self.y = y
  
  self.width = TILE_SIZE
  self.height = TILE_SIZE
  
  self.id = id
  self.tileset = tileset
  self.topper = topper
  self.topperset = topperset
end

function Tile:render()
  love.graphics.draw(TEXTURES['tiles'], FRAMES['tilesets'][self.tileset][self.id], 
      (self.x - 1) * self.width, (self.y - 1) * self.height)
      
  -- if the tile has the topper flag, draw the topper sprite on top of it
  if self.topper then
    love.graphics.draw(TEXTURES['toppers'], FRAMES['toppersets'][self.topperset][TILE_ID_TOPPER], 
        (self.x - 1) * self.width, (self.y - 1) * self.height)
  end
end

--[[
    Checks to see whether this ID is whitelisted as collidable in a global constants table.
]]
function Tile:collidable(target)
    for k, v in pairs(COLLIDABLE_TILES) do
        if v == self.id then
            return true
        end
    end

    return false
end