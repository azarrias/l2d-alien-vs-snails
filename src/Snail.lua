Snail = Class{__includes = Entity}

function Snail:init(def)
  Entity.init(self, def)
end

function Snail:render()
  Entity.render(self)
end