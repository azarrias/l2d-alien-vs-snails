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

function SnailStateMoving:update(dt)
  self.movingTimer = self.movingTimer + dt
  self.snail.animation:update(dt)
  
  if self.movingTimer > self.movingPeriod then
    if math.random(4) == 1 then
      self.snail:changeState('idle', {
        wait = math.random(5)
      })
    else
      self.snail.direction = math.random(2) == 1 and 'left' or 'right'
      self.movingPeriod = math.random(5)
      self.movingTimer = 0
    end
  elseif self.snail.orientation == 'left' then
    self.snail.x = self.snail.x - SNAIL_MOVE_SPEED * dt
  else
    self.snail.x = self.snail.x + SNAIL_MOVE_SPEED * dt
  end
end