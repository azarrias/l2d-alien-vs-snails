PlayerStateMoving = Class{__includes = BaseState}

function PlayerStateMoving:init(player)
  self.player = player
  
  self.animation = Animation {
    frames = { FRAMES['green-alien'][10], FRAMES['green-alien'][11] },
    interval = 0.2
  }
  
  self.player.currentAnimation = self.animation
end

function PlayerStateMoving:update(dt)
  self.player.currentAnimation:update(dt)
  
  -- check the tiles below the player's feet
  local tileLeftBottom = self.player.bottomCollider:checkTileCollisions(dt, self.player.level.tileMap, 'left-bottom')
  local tileRightBottom = self.player.bottomCollider:checkTileCollisions(dt, self.player.level.tileMap, 'right-bottom')
  
  -- check for game objects below
  local gameObject = self.player.bottomCollider:checkObjectCollisions()
  
  -- check if there are collisions with any entities and die if so
  if self.player.leftCollider:checkEntityCollisions() or
    self.player.rightCollider:checkEntityCollisions() then
      self.player:die()
  end
  
  -- go to idle if the player is not giving any input
  -- go to falling state if there are no tiles below
  if not love.keyboard.isDown('left') and not love.keyboard.isDown('right') then
    self.player:changeState('idle')
  else
    if not (tileLeftBottom or tileRightBottom or gameObject) then
      self.player.velocity.y = 0
      self.player:changeState('falling')
    elseif love.keyboard.isDown('left') then    
      self.player.orientation = 'left'
      self.player.position.x = self.player.position.x - PLAYER_MOVE_SPEED * dt
      local tileLeftTop = self.player.leftCollider:checkTileCollisions(dt, self.player.level.tileMap, 'left-top')
      local tileLeftBottom = self.player.leftCollider:checkTileCollisions(dt, self.player.level.tileMap, 'left-bottom')
      gameObject = self.player.leftCollider:checkObjectCollisions()
    
      if tileLeftTop or tileLeftBottom then
        local tile = tileLeftTop ~= nil and tileLeftTop or tileLeftBottom
        self.player.position.x = (tile.position.x - 1) * TILE_SIZE + tile.width - 1
      elseif gameObject then
        self.player.position.x = self.player.position.x + PLAYER_MOVE_SPEED * dt
      end
    elseif love.keyboard.isDown('right') then
      self.player.orientation = 'right'
      self.player.position.x = self.player.position.x + PLAYER_MOVE_SPEED * dt
      local tileRightTop = self.player.rightCollider:checkTileCollisions(dt, self.player.level.tileMap, 'right-top')
      local tileRightBottom = self.player.rightCollider:checkTileCollisions(dt, self.player.level.tileMap, 'right-bottom')
      gameObject = self.player.rightCollider:checkObjectCollisions()
    
      if tileRightTop or tileRightBottom then
        local tile = tileRightTop ~= nil and tileRightTop or tileRightBottom
        self.player.position.x = (tile.position.x - 1) * TILE_SIZE - self.player.width
      elseif gameObject then
        self.player.position.x = self.player.position.x - PLAYER_MOVE_SPEED * dt
      end
    end
  end
  
  -- jump
  if love.keyboard.keysPressed['space'] and self.player.velocity.y == 0 then
    self.player:changeState('jumping',
      { yVelocity = PLAYER_JUMP_VELOCITY })
  end
end
