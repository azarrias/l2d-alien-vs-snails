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
  love.graphics.setColor(1, 0.6, 0.6, 0.7)
  love.graphics.rectangle(
    'fill', 
    math.floor(self.x) + self.localX, 
    math.floor(self.y) + self.localY, 
    self.width, 
    self.height
  )
end

function Collider:checkTileCollisions(dt, tilemap, direction)
  local collidableTiles, tile1, tile2 = {}
  
  local leftX = self.x + self.localX
  local rightX = self.x + self.localX + self.width
  local topY = self.y + self.localY
  local bottomY = self.y + self.localY + self.height
  
  if direction == 'below' then
    tile1 = tilemap:pointToTile(leftX, bottomY)
    tile2 = tilemap:pointToTile(rightX, bottomY)
  elseif direction == 'above' then
    tile1 = tilemap:pointToTile(leftX, topY)
    tile2 = tilemap:pointToTile(rightX, topY)
  elseif direction == 'left' then
    tile1 = tilemap:pointToTile(leftX, topY)
    tile2 = tilemap:pointToTile(leftX, bottomY)
  elseif direction == 'right' then
    tile1 = tilemap:pointToTile(rightX, topY)
    tile2 = tilemap:pointToTile(rightX, bottomY)
  end

  if tile1 and tile1:collidable() then
    table.insert(collidableTiles, tile1)
  end
    
  if tile2 and tile2 ~= tile1 and tile2:collidable() then
    table.insert(collidableTiles, tile2)
  end

  return collidableTiles
end