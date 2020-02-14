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
    if x ~= keyPos and x ~= lockPos and x < width - 6 and math.random(100) < 15 then
      -- workaround for lua missing the 'continue' statement
      isChasm = true
    end
    
    if not isChasm then
      -- 12.5% random chance for a pillar and the same goes for bushes
      -- 10% random chance to spawn a block
      local spawnPillar = x < width - 6 and math.random(8) == 1
      local spawnBush = x ~= keyPos and x ~= lockPos and x < width - 6 and math.random(8) == 1
      local spawnBlock = x ~= keyPos and x ~= lockPos and x < width - 6 and math.random(10) == 1
      
      if spawnPillar then
        groundHeight = 5 - 1
        for y = 5, 6 do
          tiles[y][x] = Tile(x, y, TILE_ID_GROUND, y == 5 and true or false, tileSet, topperSet)
        end
      end
      
      if spawnBush then
        LevelMaker.generateBush(objects, x, groundHeight)
      end
      
      if spawnBlock then
        LevelMaker.generateBlock(objects, x, groundHeight)
      end
            
      if x == keyPos then
        LevelMaker.generateKey(objects, x, groundHeight, keySet)
      end
      
      if x == lockPos then
        LevelMaker.generateLock(objects, x, groundHeight, keySet, width)
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

function LevelMaker.generateObject(pos, t, f)
  return GameObject {
    position = pos,
    texture = t,
    width = TILE_SIZE,
    height = TILE_SIZE,
    frame = f
  }
end
  
function LevelMaker.generateBush(objects, x, y)
  table.insert(objects, LevelMaker.generateObject(
    Vector2D((x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE),
    'bushes',
    BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
  ))
end

function LevelMaker.generateBlock(objects, x, y)
  local block = LevelMaker.generateObject(
    Vector2D((x - 1) * TILE_SIZE, (y - 2 - 1) * TILE_SIZE),
    'jump-blocks',
    math.random(#JUMP_BLOCK_IDS)
  )
  
  local blockCollider = Collider {
    center = Vector2D(TILE_SIZE / 2, TILE_SIZE / 2),
    size = Vector2D(TILE_SIZE, TILE_SIZE)
  }
  block:addCollider('collider', blockCollider)
  block.hit = false
  block.onCollide = function(obj)
    if not obj.hit then
      if math.random(5) == 1 then
        local gem = LevelMaker.generateGem(x, y)
        
        -- tween animation to make the gem move up from the block
        Timer.tween(0.1, {
          [gem.position] = { y = (y - 2 - 2) * TILE_SIZE }
        })                  
        SOUNDS['powerup-reveal']:play()
        table.insert(objects, gem)
      end
      
      obj.hit = true
    end
    
    SOUNDS['empty-block']:play()
  end
        
  table.insert(objects, block)
end

function LevelMaker.generateGem(x, y)
  -- maintain reference so that it can be set to nil
  local gem = LevelMaker.generateObject(
    Vector2D((x - 1) * TILE_SIZE, (y - 2 - 1) * TILE_SIZE - 4),
    'gems',
    math.random(#GEMS)
  )
  
  local gemCollider = Collider {
    center = Vector2D(TILE_SIZE / 2, TILE_SIZE / 2),
    size = Vector2D(TILE_SIZE, TILE_SIZE)
  }
  gem:addCollider('collider', gemCollider)
  gem.consumable = true
  gem.onConsume = function(player, object)
    player.score = player.score + 100
    SOUNDS['pickup']:play()
  end

  return gem
end

function LevelMaker.generateKey(objects, x, y, keySet)
  local key = LevelMaker.generateObject(
    Vector2D((x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE),
    'keys',
    KEY_IDS[keySet]
  )
  
  local keyCollider = Collider {
    center = Vector2D(TILE_SIZE / 2, TILE_SIZE / 2),
    size = Vector2D(TILE_SIZE, TILE_SIZE)
  }
  key:addCollider('collider', keyCollider)
  key.consumable = true
  key.onConsume = function(player, object)
    player.hasKey = true
    SOUNDS['pickup']:play()
  end
  
  table.insert(objects, key)
end

function LevelMaker.generateLock(objects, x, y, keySet, mapWidth)
  local lock = LevelMaker.generateObject(
    Vector2D((x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE),
    'keys',
    LOCK_IDS[keySet]
  )
  
  local lockCollider = Collider {
    center = Vector2D(TILE_SIZE / 2, TILE_SIZE / 2),
    size = Vector2D(TILE_SIZE, TILE_SIZE)
  }
  lock:addCollider('collider', lockCollider)
  lock.trigger = true
  -- locks have a function that creates the flag post
  lock.onTrigger = function(player, objectKey)
    if player.hasKey then
      player.score = player.score + 100
      SOUNDS['pickup']:play()
      player.hasKey = false
      
      local flagPoleParts = LevelMaker.generateFlagPoleParts(objects, mapWidth)
      for k, part in pairs(flagPoleParts) do
        table.insert(objects, part)
      end
      
      -- remove containing lock object at the end
      table.remove(objects, objectKey)
    end
  end
  
  table.insert(objects, lock)
end

function LevelMaker.generateFlagPoleParts(objects, mapWidth)
  local flagPoleParts = {}
  
  for i = 1, 3 do
    local part = LevelMaker.generateObject(
      Vector2D((mapWidth - 5 - 1) * TILE_SIZE, (TOP_GROUND_TILE_Y - 1 - i) * TILE_SIZE),
      'flags',
      (3 - i) * 9 + 1
    )
    
    local partCollider = Collider {
      center = Vector2D(TILE_SIZE / 2, TILE_SIZE / 2),
      size = Vector2D(4, TILE_SIZE)
    }
    part:addCollider('collider', partCollider)
    part.trigger = true
    -- the flag should appear when the flag pole has been triggered
    part.onTrigger = function(player, objectKey)
      if not player.hasFlag then
        local flag = LevelMaker.generateFlag(mapWidth)
        table.insert(objects, flag)
        player.hasFlag = true
        SOUNDS['music']:stop()
        SOUNDS['level-complete']:play()
        Timer.tween(1, {
          [flag.position] = { y = (TOP_GROUND_TILE_Y - 4) * TILE_SIZE + 5 }
        })
        Timer.tween(1, {
          [player.position] = { y = (TOP_GROUND_TILE_Y - 1) * TILE_SIZE - player.height }
        })
        Timer.after(2, 
          function () 
            SOUNDS['music']:play()
            gameStateMachine:change('play')
          end
        )
      end
    end
    
    table.insert(flagPoleParts, part)
  end
  
  return flagPoleParts
end
  
function LevelMaker.generateFlag(mapWidth)
  return LevelMaker.generateObject(
    Vector2D((mapWidth - 5 - 1) * TILE_SIZE + 6, (TOP_GROUND_TILE_Y - 2) * TILE_SIZE),
    'flags',
    7
  )
end