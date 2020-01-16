SnailStateIdle = Class{__includes = BaseState}

function SnailStateIdle:init(snail)
  self.snail = snail
  
  self.animation = Animation {
    frames = { FRAMES['creatures'][51] },
    interval = 1
  }
  
  self.snail.animation = self.animation
end
