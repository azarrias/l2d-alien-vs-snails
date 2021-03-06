SnailStateMoving = Class{__includes = BaseState}

function SnailStateMoving:init(snail)
  self.snail = snail
    
  self.animation = Animation {
    frames = { FRAMES['creatures'][49], FRAMES['creatures'][50] },
    interval = 0.5
  }
  
  self.snail.animation = self.animation
  self.snail.orientation = math.random(2) == 1 and 'left' or 'right'
  self.movingPeriod = math.random(5)
  self.movingTimer = 0
end

function SnailStateMoving:enter(params)
  self.snail.colliders['collider'].center = Vector2D(CREATURE_WIDTH / 2, (CREATURE_HEIGHT + 5) / 2)
  self.snail.colliders['collider'].size = Vector2D(CREATURE_WIDTH - 2, CREATURE_HEIGHT - 5)
end

function SnailStateMoving:update(dt)
  self.movingTimer = self.movingTimer + dt
  self.snail.animation:update(dt)
  
  if self.movingTimer > self.movingPeriod then
    if math.random(4) == 1 then
      self.snail:changeState('idle', {
        wait = math.random(5)
      })
    else
      self.snail.orientation = math.random(2) == 1 and 'left' or 'right'
      self.movingPeriod = math.random(5)
      self.movingTimer = 0
    end
  elseif self.snail.orientation == 'left' then
    self.snail.position.x = self.snail.position.x - SNAIL_MOVE_SPEED * dt
    
    local tileLeftTop = self.snail.colliders['collider']:checkTileCollisions(dt, self.snail.level.tileMap, 'left-top')
    local tileLeftBottom = self.snail.colliders['collider']:checkTileCollisions(dt, self.snail.level.tileMap, 'left-bottom')
    
    -- if there are no tiles below or a solid tile on the current direction, turn around and go
    if tileLeftTop or not tileLeftBottom then
      self.snail.position.x = self.snail.position.x + SNAIL_MOVE_SPEED * dt
      self.snail.orientation = 'right'
      self.movingPeriod = math.random(5)
      self.movingTimer = 0
    end
  elseif self.snail.orientation == 'right' then
    self.snail.position.x = self.snail.position.x + SNAIL_MOVE_SPEED * dt
    
    local tileRightTop = self.snail.colliders['collider']:checkTileCollisions(dt, self.snail.level.tileMap, 'right-top')
    local tileRightBottom = self.snail.colliders['collider']:checkTileCollisions(dt, self.snail.level.tileMap, 'right-bottom')
    
    -- if there are no tiles below or a solid tile on the current direction, turn around and go
    if tileRightTop or not tileRightBottom then
      self.snail.position.x = self.snail.position.x - SNAIL_MOVE_SPEED * dt
      self.snail.orientation = 'left'
      self.movingPeriod = math.random(5)
      self.movingTimer = 0
    end
  end
end