Player = Class{__includes = Entity}

function Player:init(def)
  Entity.init(self, def)
  self.topCollider = def.topCollider
  self.bottomCollider = def.bottomCollider
  self.leftCollider = def.leftCollider
  self.rightCollider = def.rightCollider
  self.topCollider.parent, self.bottomCollider.parent = self, self
  self.leftCollider.parent, self.rightCollider.parent = self, self
  self.score = 0
end

function Player:update(dt)
  Entity.update(self, dt)
  
  -- constrain player X no matter which state
  if self.position.x <= 0 then
    self.position.x = 0
  elseif self.position.x > TILE_SIZE * self.level.tileMap.width - self.width then
    self.position.x = TILE_SIZE * self.level.tileMap.width - self.width
  end
end

function Player:render(dt)
  Entity.render(self)
  
  -- draw collider rects
  self.topCollider:render()
  self.bottomCollider:render()
  self.leftCollider:render()
  self.rightCollider:render()
end

function Player:die()
  SOUNDS['death']:play()
  gameStateMachine:change('start')
end

function Player:killSnail()
  self.score = self.score + 100
  SOUNDS['kill']:play()
  SOUNDS['kill2']:play()
end