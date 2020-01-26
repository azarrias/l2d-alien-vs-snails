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
  self.player.velocity.y = PLAYER_JUMP_VELOCITY
end

function PlayerStateJumping:update(dt)
  -- set collider with a little margin for the player to get through gaps
  local colliderOffset = Vector2D(3, 1)
  
  self.player.collider:setTo(
    self.player.position, 
    colliderOffset,
    CHARACTER_WIDTH - colliderOffset.x * 2,
    CHARACTER_HEIGHT - 3
  )

  self.player.animation:update(dt)
  self.player.velocity.y = self.player.velocity.y + self.gravity
  self.player.position.y = self.player.position.y + self.player.velocity.y * dt

  -- change to falling state as soon as y velocity is positive
  if self.player.velocity.y >= 0 then
    self.player:changeState('falling')
    return
  end
  
  -- check the tiles above the player's head
  local tileLeftTop = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'left-top')
  local tileRightTop = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'right-top')
 
  -- widen the collider for sideways collisions, to avoid the 'above' collision from going off mistakenly
  -- (this could be improved by using several colliders instead)
  colliderOffset = Vector2D(1, 1)
  self.player.collider:setTo(
    self.player.position, 
    colliderOffset, 
    CHARACTER_WIDTH - colliderOffset.x * 2,
    CHARACTER_HEIGHT - colliderOffset.y * 2
  )
  
  -- if there are collidable tiles above, go to falling state
  if tileLeftTop or tileRightTop then
    self.player.velocity.y = 0
    self.player:changeState('falling')
    
  -- else, if the player is moving while jumping, check the appropriate side for tile collisions
  elseif love.keyboard.isDown('left') then
    self.player.orientation = 'left'
    self.player.position.x = self.player.position.x - PLAYER_MOVE_SPEED * dt
    tileLeftTop = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'left-top')
    local tileLeftBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'left-bottom')
    
    if tileLeftTop or tileLeftBottom then
      local tile = tileLeftTop ~= nil and tileLeftTop or tileLeftBottom
      self.player.position.x = (tile.position.x - 1) * TILE_SIZE + tile.width - 1
    end
      
  elseif love.keyboard.isDown('right') then
    self.player.orientation = 'right'
    self.player.position.x = self.player.position.x + PLAYER_MOVE_SPEED * dt
    tileRightTop = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'right-top')
    local tileLeftBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'right-bottom')
    
    if tileRightTop or tileRightBottom then
      local tile = tileRightTop ~= nil and tileRightTop or tileRightBottom
      self.player.position.x = (tile.position.x - 1) * TILE_SIZE - self.player.width
    end
  end
end
