Snail = Class{__includes = Entity}

function Snail:init(def)
  -- snail idle animation
  def.animation = Animation {
    frames = { FRAMES['creatures'][51] },
    interval = 1
  }
  Entity.init(self, def)
end

function Snail:render()
  Entity.render(self)
end