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
  SOUNDS['jump']:play()
  self.player.velocity.y = params.yVelocity
end

function PlayerStateJumping:update(dt)
  self.player.animation:update(dt)
  self.player.velocity.y = self.player.velocity.y + self.gravity
  self.player.position.y = self.player.position.y + self.player.velocity.y * dt

  -- change to falling state as soon as y velocity is positive
  if self.player.velocity.y >= 0 then
    self.player:changeState('falling')
    return
  end
  
  -- check the tiles above the player's head
  local tileLeftTop = self.player.colliders['top']:checkTileCollisions(dt, self.player.level.tileMap, 'left-top')
  local tileRightTop = self.player.colliders['top']:checkTileCollisions(dt, self.player.level.tileMap, 'right-top')
 
  -- check if there is collision with any game object going up
  local gameObject = self.player.colliders['top']:checkObjectCollisions()
  if gameObject then
    self.player.position.y = gameObject.position.y + gameObject.colliders['collider'].center.y + 
      gameObject.colliders['collider'].size.y / 2
    self.player.velocity.y = 0
    self.player:changeState('falling')
    gameObject.onCollide(gameObject)
    
    return
  end
  
  -- check if there are collisions with any entities and die if so
  if self.player.colliders['top']:checkEntityCollisions() or
    self.player.colliders['left']:checkEntityCollisions() or
    self.player.colliders['right']:checkEntityCollisions() then
      self.player:die()
  end
  
  -- if there are collidable tiles above, go to falling state
  if tileLeftTop or tileRightTop then
    self.player.velocity.y = 0
    self.player:changeState('falling')
    return
    
  -- else, if the player is moving while jumping, check the appropriate side for tile collisions
  elseif love.keyboard.isDown('left') then
    self.player.orientation = 'left'
    self.player.position.x = self.player.position.x - PLAYER_MOVE_SPEED * dt
    tileLeftTop = self.player.colliders['left']:checkTileCollisions(dt, self.player.level.tileMap, 'left-top')
    local tileLeftBottom = self.player.colliders['left']:checkTileCollisions(dt, self.player.level.tileMap, 'left-bottom')
    
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
    tileRightTop = self.player.colliders['right']:checkTileCollisions(dt, self.player.level.tileMap, 'right-top')
    local tileRightBottom = self.player.colliders['right']:checkTileCollisions(dt, self.player.level.tileMap, 'right-bottom')
    
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
