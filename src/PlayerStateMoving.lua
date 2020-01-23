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
  -- set collider with a little margin to adjust to its feet
  local colliderOffsetX = 4
  local colliderOffsetY = 1

  self.player.collider:setTo(
    self.player.x, 
    self.player.y, 
    colliderOffsetX, 
    colliderOffsetY, 
    CHARACTER_WIDTH - colliderOffsetX * 2,
    CHARACTER_HEIGHT - colliderOffsetY
  )
  
  self.player.currentAnimation:update(dt)
  
  -- check the tiles below the player's feet
  local tileLeftBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'left-bottom')
  local tileRightBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'right-bottom')
  
  -- widen the collider for sideways collisions, to avoid the 'below' collision from going off mistakenly
  -- (this could be improved by using several colliders instead)
  colliderOffsetX = 1
  colliderOffsetY = 1
  self.player.collider:setTo(
    self.player.x, 
    self.player.y, 
    colliderOffsetX, 
    colliderOffsetY, 
    CHARACTER_WIDTH - colliderOffsetX * 2,
    CHARACTER_HEIGHT - colliderOffsetY * 2
  )
  
  -- go to idle if the player is not giving any input
  -- go to falling state if there are no tiles below
  if not love.keyboard.isDown('left') and not love.keyboard.isDown('right') then
    self.player:changeState('idle')
  else
    if not (tileLeftBottom or tileRightBottom) then
      self.player.dy = 0
      self.player:changeState('falling')
    elseif love.keyboard.isDown('left') then    
      self.player.orientation = 'left'
      self.player.x = self.player.x - PLAYER_MOVE_SPEED * dt
      local tileLeftTop = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'left-top')
      local tileLeftBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'left-bottom')
    
      if tileLeftTop or tileLeftBottom then
        local tile = tileLeftTop ~= nil and tileLeftTop or tileLeftBottom
        self.player.x = (tile.x - 1) * TILE_SIZE + tile.width - 1
      end
    elseif love.keyboard.isDown('right') then
      self.player.orientation = 'right'
      self.player.x = self.player.x + PLAYER_MOVE_SPEED * dt
      local tileRightTop = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'right-top')
      local tileRightBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'right-bottom')
    
      if tileRightTop or tileRightBottom then
        local tile = tileRightTop ~= nil and tileRightTop or tileRightBottom
        self.player.x = (tile.x - 1) * TILE_SIZE - self.player.width
      end
    end
  end
  
  -- jump
  if love.keyboard.keysPressed['space'] and player.dy == 0 then
    self.player:changeState('jumping')
  end
end
