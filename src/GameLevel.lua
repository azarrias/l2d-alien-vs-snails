GameLevel = Class{}

function GameLevel:init(tilemap, objects)
  self.tileMap = tilemap
  self.objects = objects
  self.entities = {}
end

function GameLevel:update(dt)
  self.tileMap:update(dt)
  
  for k, entity in pairs(self.entities) do
    entity:update(dt)
  end
end

function GameLevel:render()
  self.tileMap:render()
  
  for k, object in pairs(self.objects) do
    object:render()
  end
  
  for k, entity in pairs(self.entities) do
    entity:render()
  end
end

--[[
    Adds a series of enemies to the level randomly
]]
function GameLevel:spawnEnemies()
  -- spawn snails in the level
  -- check for each column if there is a ground tile
  -- if one is found, there is a 5% chance of spawning a snail on that column
  for x = 1, self.tileMap.width do
    
    local groundFound = false
    
    for y = 1, self.tileMap.height do
      if not groundFound then
        if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
          groundFound = true
          
          if math.random(20) == 1 then
            
            -- instantiate snail, must declare it first so it can be passed into the state machine
            local snail
            snail = Snail({
              position = Vector2D((x - 1) * TILE_SIZE, (y - 2) * TILE_SIZE),
              width = CREATURE_WIDTH,
              height = CREATURE_HEIGHT,
              texture = 'creatures',
              stateMachine = StateMachine {
                ['idle'] = function() return SnailStateIdle(snail) end,
                ['moving'] = function() return SnailStateMoving(snail) end
              },
              spriteOrientation = 'left',
              level = self,
              collider = Collider {
                center = Vector2D(CHARACTER_WIDTH / 2, 2),
                size = Vector2D(10, 2)
              }
            })
          
            snail:changeState('idle', {
              wait = math.random(5)
            })
            
            table.insert(self.entities, snail)
          end
          
          -- once that ground has been found and processed, we can skip the rest of the column
          break
        end
      end
    end
  end
end