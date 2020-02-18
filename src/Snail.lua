Snail = Class{__includes = Entity}

function Snail:init(def)
  Entity.init(self, def)
end

function Snail:update(dt)
  Entity.update(self, dt)
end

function Snail:render()
  Entity.render(self)
end

function Snail:die()
  self.flipVertical = true
end