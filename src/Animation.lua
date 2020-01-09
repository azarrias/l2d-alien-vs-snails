Animation = Class{}

function Animation:init(def)
  self.frames = def.frames
  self.interval = def.interval
  self.timer = 0
  self.currentFrame = 1
  self.flippedVertically = false
  self.flippedHorizontally = false
end

function Animation:update(dt)
  -- no need to update if animation is only one frame
  if #self.frames > 1 then
    self.timer = self.timer + dt
    if self.timer > self.interval then
      self.timer = self.timer % self.interval
      self.currentFrame = math.max(1, (self.currentFrame + 1) % (#self.frames + 1))
    end
  end
end

function Animation:draw(image, x, y, r, sx, sy, ox, oy, kx, ky)
  r, sx, sy, ox, oy, kx, ky = r or 0, sx or 1, sy or 1, ox or 0, oy or 0, kx or 0, ky or 0
  
  if self.flippedHorizontally then
    sx = sx * -1
  end
  if self.flippedVertically then
    sy = sy * -1
  end

  love.graphics.draw(image, self:getCurrentFrame(), x, y, r, sx, sy, ox, oy, kx, ky)
end

function Animation:setOrientation(orientation)
  self.flippedHorizontally = orientation == 'left'
end

function Animation:getCurrentFrame()
  return self.frames[self.currentFrame]
end