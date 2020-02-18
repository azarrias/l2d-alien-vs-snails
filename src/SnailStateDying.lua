SnailStateDying = Class{__includes = BaseState}

function SnailStateDying:init(snail)
  self.snail = snail
  self.animation = nil
  self.snail.animation = nil
end

function SnailStateDying:enter(params)
  self.snail.animation = params.animation
  self.animation = self.snail.animation
  self.snail.velocity.y = params.yVelocity
  self.snail.flipVertical = true
  self.snail.colliders['collider'] = nil
end

function SnailStateDying:update(dt)
  self.snail.animation:update(dt)
  self.snail.velocity.y = self.snail.velocity.y + GRAVITY
  self.snail.position.y = self.snail.position.y + self.snail.velocity.y * dt
end