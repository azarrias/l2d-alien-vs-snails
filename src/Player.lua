Player = Class{__includes = Entity}

function Player:init(def)
  Entity.init(self, def)
end

function Player:update(dt)
  Entity.update(self, dt)
  
  -- constrain player X no matter which state
  if self.x <= 0 then
    self.x = 0
  elseif self.x > TILE_SIZE * self.level.tileMap.width - self.width then
    self.x = TILE_SIZE * self.level.tileMap.width - self.width
  end
end

function Player:render(dt)
  Entity.render(self)
end
