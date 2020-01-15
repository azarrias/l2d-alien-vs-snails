Entity = Class{}

function Entity:init(def)
  self.x = def.x
  self.y = def.y
  
  self.dx = 0
  self.dy = 0
  
  self.width = def.width
  self.height = def.height
  
  self.texture = def.texture
  self.animation = def.animation
  self.orientation = 'left'
  
  -- references to game level to check for collisions
  self.map = def.map
  self.level = def.level
end

function Entity:update(dt)
  -- apply velocity to character
  self.dy = self.dy + GRAVITY
  self.y = self.y + self.dy * dt
  
  -- if the player goes below the map limit, set its velocity to 0
  -- since collision detection is not implemented yet
  if self.y > (TOP_GROUND_TILE_Y - 1) * TILE_SIZE - self.height then
    self.y = (TOP_GROUND_TILE_Y - 1) * TILE_SIZE - self.height
    self.dy = 0
  end
  
  -- update the animation so it scrolls through the right frames
  self.animation:update(dt)
end

function Entity:render()
  -- draw animated entity
  self.animation:draw(
    TEXTURES[self.texture], 
    -- shift the character half its width and height, since the origin must be at the sprite's center
    math.floor(self.x) + self.width / 2, 
    math.floor(self.y) + self.height / 2,
    0, self.orientation == 'left' and -1 or 1, 1,
    -- set origin to the sprite center (to allow reversing it through negative scaling)
    self.width / 2, self.height / 2)
end