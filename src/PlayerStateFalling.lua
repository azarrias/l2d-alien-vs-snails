PlayerStateFalling = Class{__includes = BaseState}

function PlayerStateFalling:init(player, gravity)
  self.player = player
  self.gravity = gravity
  
  self.animation = Animation {
    frames = { FRAMES['green-alien'][3] },
    interval = 1
  }
  
  self.player.animation = self.animation
end

function PlayerStateFalling:update(dt)  
  self.player.animation:update(dt)
  self.player.velocity.y = self.player.velocity.y + self.gravity
  self.player.position.y = self.player.position.y + self.player.velocity.y * dt
  
  -- check the tiles below the player's feet
  local tileLeftBottom = self.player.colliders['bottom']:checkTileCollisions(dt, self.player.level.tileMap, 'left-bottom')
  local tileRightBottom = self.player.colliders['bottom']:checkTileCollisions(dt, self.player.level.tileMap, 'right-bottom')
  
  -- check if there is collision with any game object / entity going down
  -- collisions with any entities other than falling down will kill the player
  local gameObject = self.player.colliders['bottom']:checkObjectCollisions()
  local entityKey = self.player.colliders['bottom']:checkEntityCollisions()

  if entityKey then
    self.player:changeState('jumping',
      { yVelocity = PLAYER_BOUNCE_VELOCITY })
    self.player:killEntity(entityKey)
  elseif self.player.colliders['top']:checkEntityCollisions() or
    self.player.colliders['left']:checkEntityCollisions() or
    self.player.colliders['right']:checkEntityCollisions() then
      self.player:die()
  end
  
  -- if there are collidable tiles below, go to walking or idle state
  if tileLeftBottom or tileRightBottom or gameObject then
    self.player.velocity.y = 0
    
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
      self.player:changeState('moving')
    else
      self.player:changeState('idle')
    end
    
    -- rectify the player's y coordinate to its appropriate value
    local tile = tileLeftBottom ~= nil and tileLeftBottom or tileRightBottom
    if tile then
      self.player.position.y = (tile.position.y - 1) * TILE_SIZE - self.player.height
    else
      self.player.position.y = gameObject.position.y + gameObject.colliders['collider'].center.y - 
        gameObject.colliders['collider'].size.y / 2 - self.player.height
    end
    
  -- go back to start if the player falls below boundaries
  elseif self.player.position.y > VIRTUAL_HEIGHT then
    self.player:die()
  
  -- if the player is moving in the air, check for side collisions
  elseif love.keyboard.isDown('left') then
    self.player.orientation = 'left'
    self.player.position.x = self.player.position.x - PLAYER_MOVE_SPEED * dt
    local tileLeftTop = self.player.colliders['left']:checkTileCollisions(dt, self.player.level.tileMap, 'left-top')
    tileLeftBottom = self.player.colliders['left']:checkTileCollisions(dt, self.player.level.tileMap, 'left-bottom')
    
    if tileLeftTop or tileLeftBottom then
      local tile = tileLeftTop ~= nil and tileLeftTop or tileLeftBottom
      self.player.position.x = (tile.position.x - 1) * TILE_SIZE + tile.width - 1
    else
      gameObject = self.player.colliders['left']:checkObjectCollisions()
      
      if gameObject then
        self.player.position.x = self.player.position.x + PLAYER_MOVE_SPEED * dt
      end
    end
      
  elseif love.keyboard.isDown('right') then
    self.player.orientation = 'right'
    self.player.position.x = self.player.position.x + PLAYER_MOVE_SPEED * dt
    local tileRightTop = self.player.colliders['right']:checkTileCollisions(dt, self.player.level.tileMap, 'right-top')
    tileRightBottom = self.player.colliders['right']:checkTileCollisions(dt, self.player.level.tileMap, 'right-bottom')
    
    if tileRightTop or tileRightBottom then
      local tile = tileRightTop ~= nil and tileRightTop or tileRightBottom
      self.player.position.x = (tile.position.x - 1) * TILE_SIZE - self.player.width
    else
      gameObject = self.player.colliders['right']:checkObjectCollisions()
      
      if gameObject then
        self.player.position.x = self.player.position.x - PLAYER_MOVE_SPEED * dt
      end   
    end
  end
end