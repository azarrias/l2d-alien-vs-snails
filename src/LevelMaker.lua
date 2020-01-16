LevelMaker = Class{}

function LevelMaker.create(width, height)
  local tiles = {}
  
  -- randomize tile set and topper set for the level
  local tileSet = math.random(#FRAMES['tilesets'])
  local topperSet = math.random(#FRAMES['toppersets'])
  
  -- create 2D table full of sky transparent tiles, so we can just change tiles as needed
  for y = 1, height do
    table.insert(tiles, {})
    
    for x = 1, width do
      -- keep IDs for whatever quad we want to render
      table.insert(tiles[y], Tile(x, y, TILE_ID_EMPTY, false, tileSet, topperSet))
    end
  end
  
  -- iterate over X at the top level to generate the level in columns instead of rows
  for x = 1, width do
    -- 15% random chance to skip this column; i.e. a chasm
    if math.random(100) < 15 then
      -- workaround for lua missing the 'continue' statement
      goto continue
    end
    
    -- 15% random chance for a pillar
    local spawnPillar = math.random(100) < 15
    
    if spawnPillar then
      for y = 5, 6 do
        tiles[y][x] = Tile(x, y, TILE_ID_GROUND, y == 5 and true or false, tileSet, topperSet)
      end
    end
  
    -- always generate ground
    for y = TOP_GROUND_TILE_Y, height do
      tiles[y][x] = Tile(x, y, TILE_ID_GROUND, (not spawnPillar and y == TOP_GROUND_TILE_Y) and true or false, tileSet, topperSet)
    end
    
    ::continue::
  end
  
  local tileMap = TileMap(tiles)
  
  return GameLevel(tileMap)
end
  