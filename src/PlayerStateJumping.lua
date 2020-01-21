PlayerStateJumping = Class{__includes = BaseState}

function PlayerStateJumping:init(player, gravity)
  self.player = player
  self.gravity = gravity
  
  self.animation = Animation {
    frames = { FRAMES['green-alien'][3] },
    interval = 1
  }
  
  self.player.animation = self.animation
end

function PlayerStateJumping:enter(params)
  self.player.dy = PLAYER_JUMP_VELOCITY
end

function PlayerStateJumping:update(dt)
  -- set collider with a little margin for the player to get through gaps
  local colliderOffsetX = 3
  local colliderOffsetY = 3
  
  self.player.collider:setTo(
    self.player.x, 
    self.player.y, 
    colliderOffsetX, 
    1, 
    CHARACTER_WIDTH - colliderOffsetX * 2,
    CHARACTER_HEIGHT - colliderOffsetY
  )

  self.player.animation:update(dt)
  self.player.dy = self.player.dy + self.gravity
  self.player.y = self.player.y + self.player.dy * dt

  -- change to falling state as soon as y velocity is positive
  if self.player.dy >= 0 then
    self.player:changeState('falling')
    return
  end
  
  -- check the tiles above the player's head
  local collidingTiles = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'above')
 
  -- widen the collider for sideways collisions, to avoid the 'above' collision from going off mistakenly
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
  
  -- if there are collidable tiles above, go to falling state
  if #collidingTiles > 0 then
    self.player.dy = 0
    self.player:changeState('falling')
    
  -- else, if the player is moving while jumping, check the appropriate side for tile collisions
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
  
  self.player.collider:setTo(self.player.x, self.player.y)
end
