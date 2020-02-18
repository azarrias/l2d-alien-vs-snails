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
  
  self.snail.colliders['collider'].center = Vector2D(CREATURE_WIDTH / 2, (CREATURE_HEIGHT + 6) / 2)
  self.snail.colliders['collider'].size = Vector2D(CREATURE_WIDTH - 6, CREATURE_HEIGHT - 6)
end

function SnailStateIdle:update(dt)
  if self.waitTimer < self.waitPeriod then
    self.waitTimer = self.waitTimer + dt
  else
    self.snail:changeState('moving')
  end
end