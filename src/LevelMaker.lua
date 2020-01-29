LevelMaker = Class{}

function LevelMaker.create(width, height)
  local tiles = {}
  local objects = {}
  
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
    
    -- 12.5% random chance for a pillar and the same goes for bushes
    -- 10% random chance to spawn a block
    local spawnPillar = math.random(8) == 1
    local spawnBush = math.random(8) == 1
    local spawnBlock = math.random(10) == 1
    
    if spawnPillar then
      for y = 5, 6 do
        tiles[y][x] = Tile(x, y, TILE_ID_GROUND, y == 5 and true or false, tileSet, topperSet)
      end
    end
    
    if spawnBush then
      table.insert(objects, 
        GameObject {
          position = Vector2D((x - 1) * TILE_SIZE, ((spawnPillar and 4 or 6) - 1) * TILE_SIZE),
          texture = 'bushes',
          width = TILE_SIZE,
          height = TILE_SIZE,
          -- select random frame from the BUSH_IDS whitelist, then random row for variance
          frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
        }
      )
    end
    
    if spawnBlock then
      table.insert(objects,
        GameObject {
          position = Vector2D((x - 1) * TILE_SIZE, ((spawnPillar and 2 or 4) - 1) * TILE_SIZE),
          texture = 'jump-blocks',
          width = TILE_SIZE,
          height = TILE_SIZE,
          frame = math.random(#JUMP_BLOCK_IDS),
          collider = Collider {
            center = Vector2D(TILE_SIZE / 2, TILE_SIZE / 2),
            size = Vector2D(TILE_SIZE, TILE_SIZE)
          }
        }
      )
    end
          
    -- always generate ground
    for y = TOP_GROUND_TILE_Y, height do
      tiles[y][x] = Tile(x, y, TILE_ID_GROUND, (not spawnPillar and y == TOP_GROUND_TILE_Y) and true or false, tileSet, topperSet)
    end
    
    ::continue::
  end
  
  local tileMap = TileMap(tiles)
  
  return GameLevel(tileMap, objects)
end
  