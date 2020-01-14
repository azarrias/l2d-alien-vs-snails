LevelMaker = Class{}

function LevelMaker.create(width, height)
  local tiles = {}
  
  -- create 2D table full of sky transparent tiles, so we can just change tiles as needed
  for y = 1, height do
    table.insert(tiles, {})
    
    for x = 1, width do
      -- keep IDs for whatever quad we want to render
      table.insert(tiles[y], {
          id = TILE_ID_SKY,
          topper = false
      })
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
        tiles[y][x] = {
          id = TILE_ID_GROUND,
          topper = y == 5 and true or false
        }
      end
    end
  
    -- always generate ground
    for y = TOP_GROUND_TILE_Y, height do
      tiles[y][x] = {
        id = TILE_ID_GROUND,
        topper = (not spawnPillar and y == TOP_GROUND_TILE_Y) and true or false
      }
    end
    
    ::continue::
  end
  
  return tiles
end
  