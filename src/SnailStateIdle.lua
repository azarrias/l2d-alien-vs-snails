SnailStateIdle = Class{__includes = BaseState}

function SnailStateIdle:init(snail)
  self.snail = snail
  self.waitTimer = 0
  
  self.animation = Animation {
    frames = { FRAMES['creatures'][51] },
    interval = 1
  }
  
  self.snail.animation = self.animation
end

function SnailStateIdle:enter(params)
  self.waitPeriod = params.wait
  
  local colliderOffset = Vector2D(3, 6)
  self.snail.collider:setTo(
    self.snail.position,
    colliderOffset,
    CREATURE_WIDTH - colliderOffset.x * 2,
    CREATURE_HEIGHT - colliderOffset.y
  )
end

function SnailStateIdle:update(dt)
  if self.waitTimer < self.waitPeriod then
    self.waitTimer = self.waitTimer + dt
  else
    self.snail:changeState('moving')
  end
end