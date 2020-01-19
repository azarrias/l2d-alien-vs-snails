PlayerStateIdle = Class{__includes = BaseState}

function PlayerStateIdle:init(player)
  self.player = player
  
  self.animation = Animation {
    frames = { FRAMES['green-alien'][1] },
    interval = 1
  }
  
  self.player.animation = self.animation
end

function PlayerStateIdle:update(dt)
  -- jump
  if love.keyboard.keysPressed['space'] and self.player.dy == 0 then
    self.player:changeState('jumping')
  end
  
  -- move
  if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
    if self.player.dy == 0 then
      self.player:changeState('moving')
    end
  end
  
  self.player.collider:setTo(self.player.x, self.player.y)
end
