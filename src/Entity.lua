Entity = Class{}

function Entity:init(def)
  self.position = def.position
  self.velocity = Vector2D(0, 0)
  
  self.width = def.width
  self.height = def.height
  
  self.texture = def.texture
  self.stateMachine = def.stateMachine
  -- original sprite orientation vs current, to determine if we must flip it horizontally
  self.spriteOrientation = def.spriteOrientation
  self.orientation = 'left'
  
  -- references to game level to check for collisions
  self.level = def.level
end

function Entity:addCollider(parent, collider)
  self.collider = collider
  self.collider.parent = parent
  parent.collider.parent = parent
end

function Entity:changeState(state, params)
  self.stateMachine:change(state, params)
end

function Entity:update(dt)
  self.stateMachine:update(dt)
end

function Entity:render()
  -- draw animated entity
  self.stateMachine.current.animation:draw(
    TEXTURES[self.texture], 
    -- shift the character half its width and height, since the origin must be at the sprite's center
    math.floor(self.position.x) + self.width / 2, 
    math.floor(self.position.y) + self.height / 2,
    0, self.orientation == self.spriteOrientation and 1 or -1, 1,
    -- set origin to the sprite center (to allow reversing it through negative scaling)
    self.width / 2, self.height / 2)
end