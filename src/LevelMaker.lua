LevelMaker = Class{}

function LevelMaker.create(width, height)
  local tiles = {}
  local objects = {}
  
  -- randomize tile set, topper set and key-lock set for the level
  local tileSet = math.random(#FRAMES['tilesets'])
  local topperSet = math.random(#FRAMES['toppersets'])
  local keySet = math.random(#KEY_IDS)
  
  -- randomize position for the key and lock in this level
  local keyPos = math.random(30, width - 30)
  local lockPos = math.random(30, width - 30)
  while lockPos == keyPos do
    lockPos = math.random(30, width - 30)
  end
  
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
    local groundHeight = TOP_GROUND_TILE_Y - 1
    local isChasm = false
    
    -- 15% random chance to skip this column; i.e. a chasm
    if x ~= keyPos and x ~= lockPos and math.random(100) < 15 then
      -- workaround for lua missing the 'continue' statement
      isChasm = true
    end
    
    if not isChasm then
      -- 12.5% random chance for a pillar and the same goes for bushes
      -- 10% random chance to spawn a block
      local spawnPillar = math.random(8) == 1
      local spawnBush = x ~= keyPos and x ~= lockPos and math.random(8) == 1
      local spawnBlock = x ~= keyPos and x ~= lockPos and math.random(10) == 1
      
      if spawnPillar then
        groundHeight = 5 - 1
        for y = 5, 6 do
          tiles[y][x] = Tile(x, y, TILE_ID_GROUND, y == 5 and true or false, tileSet, topperSet)
        end
      end
      
      if spawnBush then
        table.insert(objects, 
          GameObject {
            position = Vector2D((x - 1) * TILE_SIZE, (groundHeight - 1) * TILE_SIZE),
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
            position = Vector2D((x - 1) * TILE_SIZE, (groundHeight - 2 - 1) * TILE_SIZE),
            texture = 'jump-blocks',
            width = TILE_SIZE,
            height = TILE_SIZE,
            frame = math.random(#JUMP_BLOCK_IDS),
            collider = Collider {
              center = Vector2D(TILE_SIZE / 2, TILE_SIZE / 2),
              size = Vector2D(TILE_SIZE, TILE_SIZE)
            },
            hit = false,
            -- collision function passes the object itself as an argument
            onCollide = function(obj)
              -- if the object is hit by the first time, it may randomly spawn a gem
              if not obj.hit then
                if math.random(5) == 1 then
                  
                  -- maintain reference so that it can be set to nil
                  local gem = GameObject {
                    position = Vector2D((x - 1) * TILE_SIZE, (groundHeight - 2 - 1) * TILE_SIZE - 4),
                    texture = 'gems',
                    width = TILE_SIZE,
                    height = TILE_SIZE,
                    frame = math.random(#GEMS),
                    collider = Collider {
                      center = Vector2D(TILE_SIZE / 2, TILE_SIZE / 2),
                      size = Vector2D(TILE_SIZE, TILE_SIZE)
                    },
                    consumable = true,
                    -- gems have a function to add to the player's score
                    onConsume = function(player, object)
                      player.score = player.score + 100
                      SOUNDS['pickup']:play()
                    end
                  }
                  
                  -- tween animation to make the gem move up from the block
                  Timer.tween(0.1, {
                    [gem.position] = { y = (groundHeight - 2 - 2) * TILE_SIZE }
                  })                  
                  SOUNDS['powerup-reveal']:play()
                  table.insert(objects, gem)
                end
                
                obj.hit = true
              end
              
              SOUNDS['empty-block']:play()
            end
          }
        )
      end
            
      if x == keyPos then
        local key = GameObject {
          position = Vector2D((x - 1) * TILE_SIZE, (groundHeight - 1) * TILE_SIZE),
          texture = 'keys',
          width = TILE_SIZE,
          height = TILE_SIZE,
          frame = KEY_IDS[keySet],
          collider = Collider {
            center = Vector2D(TILE_SIZE / 2, TILE_SIZE / 2),
            size = Vector2D(TILE_SIZE, TILE_SIZE)
          },
          consumable = true,
          -- keys have a function to add to the player's score
          onConsume = function(player, object)
            player.hasKey = true
            SOUNDS['pickup']:play()
          end
        }
        
        table.insert(objects, key)
      end
      
      if x == lockPos then
        local lock = GameObject {
          position = Vector2D((x - 1) * TILE_SIZE, (groundHeight - 1) * TILE_SIZE),
          texture = 'keys',
          width = TILE_SIZE,
          height = TILE_SIZE,
          frame = LOCK_IDS[keySet],
          collider = Collider {
            center = Vector2D(TILE_SIZE / 2, TILE_SIZE / 2),
            size = Vector2D(TILE_SIZE, TILE_SIZE)
          },
          trigger = true,
          -- keys have a function to add to the player's score
          onTrigger = function(player, objectKey)
            if player.hasKey then
              player.score = player.score + 100
              SOUNDS['pickup']:play()
              player.hasKey = false
              table.remove(objects, objectKey)
            end
          end
        }
        
        table.insert(objects, lock)
      end
      
      -- always generate ground
      for y = TOP_GROUND_TILE_Y, height do
        tiles[y][x] = Tile(x, y, TILE_ID_GROUND, (not spawnPillar and y == TOP_GROUND_TILE_Y) and true or false, tileSet, topperSet)
      end
    end
  end
  
  local tileMap = TileMap(tiles)
  
  return GameLevel(tileMap, objects)
end
  