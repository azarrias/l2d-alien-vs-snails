Collider = Class{}

function Collider:init(def)
  self.parent = def.parent
  
  -- center and size in the collider's local space
  self.center = def.center
  self.size = def.size
end

function Collider:render()
  love.graphics.setColor(1, 0.6, 0.6, 0.7)
  love.graphics.rectangle(
    'fill', 
    math.floor(self.parent.position.x + self.center.x - self.size.x / 2), 
    math.floor(self.parent.position.y + self.center.y - self.size.y / 2), 
    self.size.x, 
    self.size.y
  )
end

function Collider:checkTileCollisions(dt, tilemap, direction)
  local tile
  
  if direction == 'left-top' then
    tile = tilemap:pointToTile(Vector2D(self.parent.position.x + self.center.x - self.size.x / 2, 
                                        self.parent.position.y + self.center.y - self.size.y / 2))
  elseif direction == 'right-top' then
    tile = tilemap:pointToTile(Vector2D(self.parent.position.x + self.center.x + self.size.x / 2, 
                                        self.parent.position.y + self.center.y - self.size.y / 2))
  elseif direction == 'left-bottom' then
    tile = tilemap:pointToTile(Vector2D(self.parent.position.x + self.center.x - self.size.x / 2, 
                                        self.parent.position.y + self.center.y + self.size.y / 2))
  elseif direction == 'right-bottom' then
    tile = tilemap:pointToTile(Vector2D(self.parent.position.x + self.center.x + self.size.x / 2, 
                                        self.parent.position.y + self.center.y + self.size.y / 2))
  end
  
  if tile and tile:collidable() then
    return tile
  else
    return nil
  end
end

function Collider:checkObjectCollisions()
  for k, object in pairs(self.parent.level.objects) do
    if object.collider and self:collides(object.collider) then
      if object.consumable then
        object.onConsume(self)
        table.remove(self.parent.level.objects, k)
      else
--        object.onCollide(object)
        return object
      end
    end
  end
  
  return nil
end

function Collider:collides(other)
  -- AABB collision detection
  if other.parent.position.x + other.center.x - other.size.x / 2 > self.parent.position.x + self.center.x + self.size.x / 2 then
    return false
  elseif self.parent.position.x + self.center.x - self.size.x / 2 > other.parent.position.x + other.center.x + other.size.x / 2 then
    return false
  elseif other.parent.position.y + other.center.y - other.size.y / 2 > self.parent.position.y + self.center.y + self.size.y / 2 then
    return false
  elseif self.parent.position.y + self.center.y - self.size.y / 2 > other.parent.position.y + other.center.y + other.size.y / 2 then
    return false
  else
    return true
  end
end