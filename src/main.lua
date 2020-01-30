require 'Globals'

local MOBILE_OS = (love._version_major > 0 or love._version_minor >= 9) and (love.system.getOS() == 'Android' or love.system.getOS() == 'OS X')
local WEB_OS = (love._version_major > 0 or love._version_minor >= 9) and love.system.getOS() == 'Web'
local GAME_TITLE = 'Alien vs Snails'
local FONT_SIZE = 16

local CAMERA_SCROLL_SPEED = 40

local playerOrientation = 'right'
local tiles = {}
local player, background, backgroundX, camera

function love.load()
  if arg[#arg] == "-debug" then 
    require("mobdebug").start() 
  end
  
  io.stdout:setvbuf("no")
  
  math.randomseed(os.time())
  
  background = math.random(#FRAMES['backgrounds'])
  backgroundX = 0
  
  gameLevel = LevelMaker.create(100, 10)
  gameLevel:spawnEnemies()
  
  player = Player({
      position = Vector2D(0, 0),
      width = CHARACTER_WIDTH,
      height = CHARACTER_HEIGHT,
      texture = 'green-alien',
      stateMachine = StateMachine {
        ['idle'] = function() return PlayerStateIdle(player) end,
        ['moving'] = function() return PlayerStateMoving(player) end,
        ['jumping'] = function() return PlayerStateJumping(player, GRAVITY) end,
        ['falling'] = function() return PlayerStateFalling(player, GRAVITY) end
      },
      spriteOrientation = 'right',
      level = gameLevel,
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

  player:changeState('falling')
  
  camera = Camera(player)
  
  -- Set up window
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = MOBILE_OS,
    resizable = not MOBILE_OS
  })
  love.window.setTitle(GAME_TITLE)
  
  -- use nearest-neighbor (point) filtering on upscaling and downscaling to prevent blurring of text and 
  -- graphics instead of the bilinear filter that is applied by default 
  love.graphics.setDefaultFilter('nearest', 'nearest')
  
  love.keyboard.keysPressed = {}
end

function love.update(dt)
  -- exit if esc is pressed
  if love.keyboard.keysPressed['escape'] then
    love.event.quit()
  end
  
  gameLevel:update(dt)
  player:update(dt)
  camera:update()
  
  -- adjust background X to move a third the rate of the camera for parallax scrolling
  backgroundX = camera.position.x / 3 % 256
  
  love.keyboard.keysPressed = {}
end

function love.resize(w, h)
  push:resize(w, h)
end
  
-- Callback that processes key strokes just once
-- Does not account for keys being held down
function love.keypressed(key)
  love.keyboard.keysPressed[key] = true
end

function love.draw()
  push:start()
  
  -- draw background two times to complete the level with it flipped vertically below
  love.graphics.draw(TEXTURES['backgrounds'], FRAMES['backgrounds'][background], 
    math.floor(-backgroundX), 0)
  love.graphics.draw(TEXTURES['backgrounds'], FRAMES['backgrounds'][background], 
    math.floor(-backgroundX), BACKGROUND_HEIGHT * 2, 0, 1, -1)
  love.graphics.draw(TEXTURES['backgrounds'], FRAMES['backgrounds'][background], 
    math.floor(-backgroundX + BACKGROUND_WIDTH), 0)
  love.graphics.draw(TEXTURES['backgrounds'], FRAMES['backgrounds'][background], 
    math.floor(-backgroundX + BACKGROUND_WIDTH), BACKGROUND_HEIGHT * 2, 0, 1, -1)
  
  -- translate scene by camera scroll amount; negative shifts have the effect of making it seem
  -- like we're actually moving right and vice-versa; note the use of math.floor, as rendering
  -- fractional camera offsets with a virtual resolution will result in weird pixelation and artifacting
  -- as things are attempted to be drawn fractionally and then forced onto a small virtual canvas
  love.graphics.translate(-math.floor(camera.position.x), 0)
  
  gameLevel:render()
  
  -- draw animated player
  player:render()

  push:finish()
end
