PlayerStateJumping = Class{__includes = BaseState}

function PlayerStateJumping:init(player, gravity)
  self.player = player
  self.gravity = gravity
  
  self.animation = Animation {
    frames = { FRAMES['green-alien'][3] },
    interval = 1
  }
  
  self.player.animation = self.animation
end

function PlayerStateJumping:enter(params)
  self.player.dy = PLAYER_JUMP_VELOCITY
end

function PlayerStateJumping:update(dt)
  self.player.animation:update(dt)
  self.player.dy = self.player.dy + self.gravity
  self.player.y = self.player.y + self.player.dy * dt
  
  -- change to falling state as soon as y velocity is positive
  if self.player.dy >= 0 then
    self.player:changeState('falling')
  end
  
  if love.keyboard.isDown('left') then    
    self.player.orientation = 'left'
    self.player.x = self.player.x - PLAYER_MOVE_SPEED * dt
  elseif love.keyboard.isDown('right') then
    self.player.orientation = 'right'
    self.player.x = self.player.x + PLAYER_MOVE_SPEED * dt
  end
end