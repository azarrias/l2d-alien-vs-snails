Collider = Class{}

function Collider:init(def)
  self.position = def.position
  self.localPosition = def.localPosition
  self.width = def.width
  self.height = def.height
end

function Collider:setTo(pos, localPos, width, height)
  self.position = pos
  self.localPosition = localPos or self.localPosition
  self.width = width or self.width
  self.height = height or self.height
end

function Collider:render()
  love.graphics.setColor(1, 0.6, 0.6, 0.7)
  love.graphics.rectangle(
    'fill', 
    math.floor(self.position.x) + self.localPosition.x, 
    math.floor(self.position.y) + self.localPosition.y, 
    self.width, 
    self.height
  )
end

function Collider:checkTileCollisions(dt, tilemap, direction)
  local tile
  
  if direction == 'left-top' then
    tile = tilemap:pointToTile(Vector2D(self.position.x + self.localPosition.x, 
                                        self.position.y + self.localPosition.y))
  elseif direction == 'right-top' then
    tile = tilemap:pointToTile(Vector2D(self.position.x + self.localPosition.x + self.width, 
                                        self.position.y + self.localPosition.y))
  elseif direction == 'left-bottom' then
    tile = tilemap:pointToTile(Vector2D(self.position.x + self.localPosition.x, 
                                        self.position.y + self.localPosition.y + self.height))
  elseif direction == 'right-bottom' then
    tile = tilemap:pointToTile(Vector2D(self.position.x + self.localPosition.x + self.width, 
                                        self.position.y + self.localPosition.y + self.height))
  end
  
  if tile and tile:collidable() then
    return tile
  else
    return nil
  end
end