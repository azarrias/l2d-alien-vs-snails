TileMap = Class{}

function TileMap:init(tiles)
  self.tiles = tiles
  self.width = #tiles[1]
  self.height = #tiles
end

--[[
    If our tiles were animated, this is potentially where we could iterate over all of them
    and update either per-tile or per-map animations for appropriately flagged tiles!
]]
function TileMap:update(dt)

end

--[[ 
    Converts from x, y coordinates to tile x, y coordinates within the tile map.
    Returns nil if the point is out of the bounds of the tile map.
]]
function TileMap:pointToTile(x, y)
  if x < 0 or x > self.width * TILE_SIZE or y < 0 or y > self.height * TILE_SIZE then
    return nil
  end
  
  return self.tiles[math.floor(y / TILE_SIZE) + 1][math.floor(x / TILE_SIZE) + 1]
end

function TileMap:render()
  for y = 1, self.height do
    for x = 1, self.width do
      self.tiles[y][x]:render()
    end
  end
end