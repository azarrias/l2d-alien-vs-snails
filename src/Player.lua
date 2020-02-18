Player = Class{__includes = Entity}

function Player:init(def)
  Entity.init(self, def)
  self.score = 0
  self.hasKey = false
  self.hasFlag = false
end

function Player:update(dt)
  if not self.hasFlag then
    Entity.update(self, dt)
  end
  
  -- constrain player X no matter which state
  if self.position.x <= 0 then
    self.position.x = 0
  elseif self.position.x > TILE_SIZE * self.level.tileMap.width - self.width then
    self.position.x = TILE_SIZE * self.level.tileMap.width - self.width
  end
end

function Player:render(dt)
  Entity.render(self)
end

function Player:die()
  SOUNDS['death']:play()
  gameStateMachine:change('start')
end

function Player:killEntity(entityKey)
  self.score = self.score + 100
  self.level.entities[entityKey]:changeState('dying', { 
      yVelocity = SNAIL_BOUNCE_VELOCITY,
      animation = self.level.entities[entityKey].animation 
  })
  SOUNDS['kill']:play()
  SOUNDS['kill2']:play()
  -- remove killed entity from game level after 5 seconds
  Timer.after(5, function()
    table.remove(self.level.entities, entityKey)
  end)
end