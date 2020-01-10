Class = require 'libs.class'
push = require 'libs.push'

require 'Animation'
require 'Util'

local MOBILE_OS = (love._version_major > 0 or love._version_minor >= 9) and (love.system.getOS() == 'Android' or love.system.getOS() == 'OS X')
local WEB_OS = (love._version_major > 0 or love._version_minor >= 9) and love.system.getOS() == 'Web'
local WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
local VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 256, 144
local GAME_TITLE = 'Alien vs Snails'
local FONT_SIZE = 16
local TILE_SIZE = 16
local CHARACTER_WIDTH, CHARACTER_HEIGHT = 16, 20

local CAMERA_SCROLL_SPEED = 40
local CHARACTER_MOVE_SPEED = 40
local JUMP_VELOCITY = -200
local GRAVITY = 7

local TOP_GROUND_TILE_Y = 7

-- tile ID constants
GROUND = 1
SKY = 2 -- transparent sprite

local playerOrientation = 'right'

function love.load()
  if arg[#arg] == "-debug" then 
    require("mobdebug").start() 
  end
  
  math.randomseed(os.time())
  
  tiles = {}
  
  -- load tiles from tilesheet image
  tilesheet = love.graphics.newImage('graphics/tiles.png')
  quads = GenerateQuads(tilesheet, TILE_SIZE, TILE_SIZE)  
  
  -- player character texture
  playerSheet = love.graphics.newImage('graphics/character.png')
  playerQuads = GenerateQuads(playerSheet, CHARACTER_WIDTH, CHARACTER_HEIGHT)
  
  -- place character in the middle of the screen, above the top ground tile
  playerX = VIRTUAL_WIDTH / 2 - (CHARACTER_WIDTH / 2)
  playerY = ((TOP_GROUND_TILE_Y - 1) * TILE_SIZE) - CHARACTER_HEIGHT
  
  -- player animations
  playerIdle = Animation {
    frames = { playerQuads[1] },
    interval = 1
  }
  playerMoving = Animation {
    frames = { playerQuads[10], playerQuads[11] },
    interval = 0.2
  }
  playerJump = Animation {
    frames = { playerQuads[3] },
    interval = 1
  }
  
  playerAnimation = playerIdle
    
  -- player vertical velocity
  playerDY = 0
  
  mapWidth = 20
  mapHeight = VIRTUAL_HEIGHT / TILE_SIZE
  
  -- offset that will be used to translate the scene to emulate a camera
  cameraScroll = 0
  
  backgroundR = math.random()
  backgroundG = math.random()
  backgroundB = math.random()
  
  for y = 1, mapHeight do
    table.insert(tiles, {})
    
    for x = 1, mapWidth do
      -- keep IDs for whatever quad we want to render
      table.insert(tiles[y], {
          id = y < TOP_GROUND_TILE_Y and SKY or GROUND
      })
    end
  end
  
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
  -- apply velocity to character
  playerDY = playerDY + GRAVITY
  playerY = playerY + playerDY * dt
  
  -- if the player goes below the map limit, set its velocity to 0
  -- since collision detection is not implemented yet
  if playerY > (TOP_GROUND_TILE_Y - 1) * TILE_SIZE - CHARACTER_HEIGHT then
    playerY = (TOP_GROUND_TILE_Y - 1) * TILE_SIZE - CHARACTER_HEIGHT
    playerDY = 0
  end
  
  -- update the animation so it scrolls through the right frames
  playerAnimation:update(dt)
  
  -- exit if esc is pressed
  if love.keyboard.keysPressed['escape'] then
    love.event.quit()
  -- jump
  elseif love.keyboard.keysPressed['space'] and playerDY == 0 then
    playerDY = JUMP_VELOCITY
    playerAnimation = playerJump
  end
  
  -- move
  if love.keyboard.isDown('left') then
    if playerDY == 0 then
      playerAnimation = playerMoving
    end
    playerOrientation = 'left'
    playerX = playerX - CHARACTER_MOVE_SPEED * dt
  elseif love.keyboard.isDown('right') then
    if playerDY == 0 then
      playerAnimation = playerMoving
    end
    playerOrientation = 'right'
    playerX = playerX + CHARACTER_MOVE_SPEED * dt
  else
    if playerDY == 0 then
      playerAnimation = playerIdle
    end
  end
  
  -- set the camera's left edge to half the screen to the left of the player's x coordinate
  cameraScroll = playerX - (VIRTUAL_WIDTH / 2) + (CHARACTER_WIDTH / 2)
  
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
  
  for y = 1, mapHeight do
    for x = 1, mapWidth do
      local tile = tiles[y][x]
      love.graphics.draw(tilesheet, quads[tile.id], (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE)
    end
  end
  
  -- draw animated player character
  playerAnimation:draw(
    playerSheet, 
    -- shift the character half its width and height, since the origin must be at the sprite's center
    math.floor(playerX + CHARACTER_WIDTH / 2), 
    math.floor(playerY + CHARACTER_HEIGHT / 2),
    0, playerOrientation == 'left' and -1 or 1, 1,
    -- set origin to the sprite center (to allow reversing it through negative scaling)
    CHARACTER_WIDTH / 2, CHARACTER_HEIGHT / 2)

  push:finish()
end