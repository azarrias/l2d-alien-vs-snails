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
  
  self.player.animation:update(dt)
  self.player.dy = self.player.dy + self.gravity
  self.player.y = self.player.y + self.player.dy * dt
  
  -- check the tiles below the player's feet
  local tileLeftBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'left-bottom')
  local tileRightBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'right-bottom')
  
  -- widen the collider for sideways collisions, to avoid the 'below' collision from going off mistakenly
  -- (this could be improved by using several colliders instead)
  colliderOffsetX = 1
  colliderOffsetY = 3
  self.player.collider:setTo(
    self.player.x, 
    self.player.y, 
    colliderOffsetX, 
    colliderOffsetY, 
    CHARACTER_WIDTH - colliderOffsetX * 2,
    CHARACTER_HEIGHT - colliderOffsetY * 2
  )
  
  -- if there are collidable tiles below, go to walking or idle state
  if tileLeftBottom or tileRightBottom then
    self.player.dy = 0
    
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
      self.player:changeState('moving')
    else
      self.player:changeState('idle')
    end
    
    -- rectify the player's y coordinate to its appropriate value
    local tile = tileLeftBottom ~= nil and tileLeftBottom or tileRightBottom
    self.player.y = (tile.y - 1) * TILE_SIZE - self.player.height
  
  -- if the player is moving in the air, check for side collisions
  elseif love.keyboard.isDown('left') then
    self.player.orientation = 'left'
    self.player.x = self.player.x - PLAYER_MOVE_SPEED * dt
    local tileLeftTop = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'left-top')
    tileLeftBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'left-bottom')
    
    if tileLeftTop or tileLeftBottom then
      local tile = tileLeftTop ~= nil and tileLeftTop or tileLeftBottom
      self.player.x = (tile.x - 1) * TILE_SIZE + tile.width - 1
    end
      
  elseif love.keyboard.isDown('right') then
    self.player.orientation = 'right'
    self.player.x = self.player.x + PLAYER_MOVE_SPEED * dt
    local tileRightTop = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'right-top')
    tileRightBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'right-bottom')
    
    if tileRightTop or tileRightBottom then
      local tile = tileRightTop ~= nil and tileRightTop or tileRightBottom
      self.player.x = (tile.x - 1) * TILE_SIZE - self.player.width
    end
  end
end