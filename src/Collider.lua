Collider = Class{}

function Collider:init(def)
  self.x = def.x
  self.y = def.y
  self.localX = def.localX
  self.localY = def.localY
  self.width = def.width
  self.height = def.height
end

function Collider:setTo(x, y, localX, localY, width, height)
  self.x = x
  self.y = y
  self.localX = localX or self.localX
  self.localY = localY or self.localY
  self.width = width or self.width
  self.height = height or self.height
end

function Collider:render()
  love.graphics.setColor(1, 0.5, 0.5, 0.8)
  love.graphics.rectangle(
    'fill', 
    math.floor(self.x) + self.localX, 
    math.floor(self.y) + self.localY, 
    self.width, 
    self.height
  )
end