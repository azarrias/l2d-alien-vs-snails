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
  self.player.animation:update(dt)
  self.player.dy = self.player.dy + self.gravity
  self.player.y = self.player.y + self.player.dy * dt
  
  if self.player.y >= (TOP_GROUND_TILE_Y - 1) * TILE_SIZE - self.player.height then
    self.player.dy = 0
    self.player.y = (TOP_GROUND_TILE_Y - 1) * TILE_SIZE - self.player.height
    self.player:changeState('idle')
  end
  
  if love.keyboard.isDown('left') then    
    self.player.orientation = 'left'
    self.player.x = self.player.x - PLAYER_MOVE_SPEED * dt
  elseif love.keyboard.isDown('right') then
    self.player.orientation = 'right'
    self.player.x = self.player.x + PLAYER_MOVE_SPEED * dt
  end
end