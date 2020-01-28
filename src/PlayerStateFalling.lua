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
  self.player.collider.center = Vector2D(CHARACTER_WIDTH / 2, (CHARACTER_HEIGHT + 1) / 2)
  self.player.collider.size = Vector2D(CHARACTER_WIDTH - 8, CHARACTER_HEIGHT - 1)
  
  self.player.animation:update(dt)
  self.player.velocity.y = self.player.velocity.y + self.gravity
  self.player.position.y = self.player.position.y + self.player.velocity.y * dt
  
  -- check the tiles below the player's feet
  local tileLeftBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'left-bottom')
  local tileRightBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'right-bottom')
  
  -- check if there is collision with any game object going down
  local gameObject = self.player.collider:checkObjectCollisions()
  
  -- widen the collider for sideways collisions, to avoid the 'below' collision from going off mistakenly
  -- (this could be improved by using several colliders instead)
  self.player.collider.center = Vector2D(CHARACTER_WIDTH / 2, CHARACTER_HEIGHT / 2)
  self.player.collider.size = Vector2D(CHARACTER_WIDTH - 2, CHARACTER_HEIGHT - 8)
  
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
      self.player.position.y = gameObject.position.y + gameObject.collider.center.y - gameObject.collider.size.y / 2 - self.player.height
    end
  
  -- if the player is moving in the air, check for side collisions
  elseif love.keyboard.isDown('left') then
    self.player.orientation = 'left'
    self.player.position.x = self.player.position.x - PLAYER_MOVE_SPEED * dt
    local tileLeftTop = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'left-top')
    tileLeftBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'left-bottom')
    
    if tileLeftTop or tileLeftBottom then
      local tile = tileLeftTop ~= nil and tileLeftTop or tileLeftBottom
      self.player.position.x = (tile.position.x - 1) * TILE_SIZE + tile.width - 1
    end
      
  elseif love.keyboard.isDown('right') then
    self.player.orientation = 'right'
    self.player.position.x = self.player.position.x + PLAYER_MOVE_SPEED * dt
    local tileRightTop = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'right-top')
    tileRightBottom = self.player.collider:checkTileCollisions(dt, self.player.level.tileMap, 'right-bottom')
    
    if tileRightTop or tileRightBottom then
      local tile = tileRightTop ~= nil and tileRightTop or tileRightBottom
      self.player.position.x = (tile.position.x - 1) * TILE_SIZE - self.player.width
    end
  end
end