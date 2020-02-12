GameObject = Class{}

function GameObject:init(def)
  self.position = def.position
  self.texture = def.texture
  self.width = def.width
  self.height = def.height
  self.frame = def.frame
  self.collider = def.collider
  if self.collider then
    self.collider.parent = self
  end
  self.consumable = def.consumable
  self.trigger = def.trigger
  self.onCollide = def.onCollide
  self.onConsume = def.onConsume
  self.onTrigger = def.onTrigger
  self.hit = def.hit
end

function GameObject:render()
  love.graphics.draw(TEXTURES[self.texture], FRAMES[self.texture][self.frame], self.position.x, self.position.y)
  
  -- draw collider rect
--[[  if self.collider then
    self.collider:render()
  end]]
end
