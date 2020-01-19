PlayerStateMoving = Class{__includes = BaseState}

function PlayerStateMoving:init(player)
  self.player = player
  
  self.animation = Animation {
    frames = { FRAMES['green-alien'][10], FRAMES['green-alien'][11] },
    interval = 0.2
  }
  
  self.player.currentAnimation = self.animation
end

function PlayerStateMoving:update(dt)
  self.player.currentAnimation:update(dt)
  
  -- go to idle if the player is not giving any input
  if not love.keyboard.isDown('left') and not love.keyboard.isDown('right') then
    self.player:changeState('idle')
  elseif love.keyboard.isDown('left') then    
    self.player.orientation = 'left'
    self.player.x = self.player.x - PLAYER_MOVE_SPEED * dt
  elseif love.keyboard.isDown('right') then
    self.player.orientation = 'right'
    self.player.x = self.player.x + PLAYER_MOVE_SPEED * dt
  end
  
  -- jump
  if love.keyboard.keysPressed['space'] and player.dy == 0 then
    self.player:changeState('jumping')
  end
  
  self.player.collider:setTo(self.player.x, self.player.y)
end
