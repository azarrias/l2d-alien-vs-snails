GameObject = Class{}

function GameObject:init(def)
  self.x = def.x
  self.y = def.y
  self.texture = def.texture
  self.width = def.width
  self.height = def.height
  self.frame = def.frame
end

function GameObject:render()
  love.graphics.draw(TEXTURES[self.texture], FRAMES[self.texture][self.frame], self.x, self.y)
end
