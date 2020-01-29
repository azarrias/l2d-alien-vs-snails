Snail = Class{__includes = Entity}

function Snail:init(def)
  Entity.init(self, def)
  self.collider = def.collider
  self.collider.parent = self
end

function Snail:update(dt)
  Entity.update(self, dt)
end

function Snail:render()
  Entity.render(self)
  
  -- draw collider rect
  if self.collider then
    self.collider:render()
  end
end