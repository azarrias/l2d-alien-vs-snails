GameStatePlay = Class{__includes = BaseState}

function GameStatePlay:init()
  self.background = math.random(#FRAMES['backgrounds'])
  self.backgroundX = 0
  
  self.level = LevelMaker.create(100, 10)
  self.level:spawnEnemies()
  
  self.player = Player({
      position = Vector2D(0, 0),
      width = CHARACTER_WIDTH,
      height = CHARACTER_HEIGHT,
      texture = 'green-alien',
      stateMachine = StateMachine {
        ['idle'] = function() return PlayerStateIdle(self.player) end,
        ['moving'] = function() return PlayerStateMoving(self.player) end,
        ['jumping'] = function() return PlayerStateJumping(self.player, GRAVITY) end,
        ['falling'] = function() return PlayerStateFalling(self.player, GRAVITY) end
      },
      spriteOrientation = 'right',
      level = self.level,
      topCollider = Collider {
        center = Vector2D(CHARACTER_WIDTH / 2, 2),
        size = Vector2D(10, 2)
      },
      bottomCollider = Collider {
        center = Vector2D(CHARACTER_WIDTH / 2, CHARACTER_HEIGHT + 1),
        size = Vector2D(8, 2)
      },
      leftCollider = Collider {
        center = Vector2D(2, CHARACTER_HEIGHT / 2),
        size = Vector2D(2, CHARACTER_HEIGHT - 4)
      },
      rightCollider = Collider {
        center = Vector2D(CHARACTER_WIDTH - 2, CHARACTER_HEIGHT / 2),
        size = Vector2D(2, CHARACTER_HEIGHT - 4)
      }
  })

  self.player:changeState('falling')
  
  self.camera = Camera(self.player)
end

function GameStatePlay:update(dt)
  -- exit if esc is pressed
  if love.keyboard.keysPressed['escape'] then
    love.event.quit()
  end
  
  self.level:update(dt)
  self.player:update(dt)
  self.camera:update()
  
  -- adjust background X to move a third the rate of the camera for parallax scrolling
  self.backgroundX = self.camera.position.x / 3 % 256
end

function GameStatePlay:render()
  -- draw background two times to complete the level with it flipped vertically below
  love.graphics.draw(TEXTURES['backgrounds'], FRAMES['backgrounds'][self.background], 
    math.floor(-self.backgroundX), 0)
  love.graphics.draw(TEXTURES['backgrounds'], FRAMES['backgrounds'][self.background], 
    math.floor(-self.backgroundX), BACKGROUND_HEIGHT * 2, 0, 1, -1)
  love.graphics.draw(TEXTURES['backgrounds'], FRAMES['backgrounds'][self.background], 
    math.floor(-self.backgroundX + BACKGROUND_WIDTH), 0)
  love.graphics.draw(TEXTURES['backgrounds'], FRAMES['backgrounds'][self.background], 
    math.floor(-self.backgroundX + BACKGROUND_WIDTH), BACKGROUND_HEIGHT * 2, 0, 1, -1)
  
  -- translate scene by camera scroll amount; negative shifts have the effect of making it seem
  -- like we're actually moving right and vice-versa; note the use of math.floor, as rendering
  -- fractional camera offsets with a virtual resolution will result in weird pixelation and artifacting
  -- as things are attempted to be drawn fractionally and then forced onto a small virtual canvas
  love.graphics.translate(-math.floor(self.camera.position.x), 0)
  
  self.level:render()
  
  -- draw animated player
  self.player:render()
end