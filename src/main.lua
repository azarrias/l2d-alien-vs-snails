require 'Globals'

local MOBILE_OS = (love._version_major > 0 or love._version_minor >= 9) and (love.system.getOS() == 'Android' or love.system.getOS() == 'OS X')
local WEB_OS = (love._version_major > 0 or love._version_minor >= 9) and love.system.getOS() == 'Web'
local WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
local VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 256, 144
local GAME_TITLE = 'Alien vs Snails'
local FONT_SIZE = 16

local CAMERA_SCROLL_SPEED = 40

local playerOrientation = 'right'
local tiles = {}
local player

function love.load()
  if arg[#arg] == "-debug" then 
    require("mobdebug").start() 
  end
  
  math.randomseed(os.time())
  
  -- offset that will be used to translate the scene to emulate a camera
  cameraScroll = 0
  
  backgroundR = math.random()
  backgroundG = math.random()
  backgroundB = math.random()
  
  gameLevel = LevelMaker.create(100, 10)
  --gameLevel:spawnEnemies()
  
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
      collider = Collider {
        center = Vector2D(CHARACTER_WIDTH / 2, (CHARACTER_HEIGHT + 2) / 2),
        size = Vector2D(CHARACTER_WIDTH - 6, CHARACTER_HEIGHT - 2)
      }
  })

  player:changeState('falling')
  
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
  
  -- set the camera's left edge to half the screen to the left of the player's x coordinate
  cameraScroll = player.position.x - (VIRTUAL_WIDTH / 2) + (player.width / 2)
  
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
  
  -- translate scene by camera scroll amount; negative shifts have the effect of making it seem
  -- like we're actually moving right and vice-versa; note the use of math.floor, as rendering
  -- fractional camera offsets with a virtual resolution will result in weird pixelation and artifacting
  -- as things are attempted to be drawn fractionally and then forced onto a small virtual canvas
  love.graphics.translate(-math.floor(cameraScroll), 0)
  love.graphics.clear(backgroundR, backgroundG, backgroundB, 1)
  
  gameLevel:render()
  
  -- draw animated player
  player:render()

  push:finish()
end
