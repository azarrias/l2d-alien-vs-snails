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
  local collidingTiles = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'below')
  
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
  if #collidingTiles > 0 then
    self.player.dy = 0
    
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
      self.player:changeState('moving')
    else
      self.player:changeState('idle')
    end
    
    -- rectify the player's y coordinate to its appropriate value
    self.player.y = (collidingTiles[1].y - 1) * TILE_SIZE - self.player.height
  
  -- if the player is moving in the air, check for side collisions
  elseif love.keyboard.isDown('left') then
    self.player.orientation = 'left'
    self.player.x = self.player.x - PLAYER_MOVE_SPEED * dt
    collidingTiles = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, self.player.orientation)
    
    if #collidingTiles > 0 then
      self.player.x = (collidingTiles[1].x - 1) * TILE_SIZE + collidingTiles[1].width - 1
    end
      
  elseif love.keyboard.isDown('right') then
    self.player.orientation = 'right'
    self.player.x = self.player.x + PLAYER_MOVE_SPEED * dt
    collidingTiles = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, self.player.orientation)
    
    if #collidingTiles > 0 then
      self.player.x = (collidingTiles[1].x - 1) * TILE_SIZE - self.player.width
    end
  end
end