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

function TileMap:render()
  for y = 1, self.height do
    for x = 1, self.width do
      self.tiles[y][x]:render()
    end
  end
end