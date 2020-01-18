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
end

function SnailStateIdle:update(dt)
  if self.waitTimer < self.waitPeriod then
    self.waitTimer = self.waitTimer + dt
  else
    self.snail:changeState('moving')
  end
end