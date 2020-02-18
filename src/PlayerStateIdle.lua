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
  if love.keyboard.keysPressed['space'] and self.player.velocity.y == 0 then
    self.player:changeState('jumping',
      { yVelocity = PLAYER_JUMP_VELOCITY })
  end
  
  -- move
  if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
    if self.player.velocity.y == 0 then
      self.player:changeState('moving')
    end
  end
  
  -- check if there are collisions with any entities and die if so
  if self.player.colliders['top']:checkEntityCollisions() or
    self.player.colliders['left']:checkEntityCollisions() or
    self.player.colliders['right']:checkEntityCollisions() then
      gameStateMachine:change('start')
  end
end
