push = require 'libs.push'
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

local TOP_GROUND_TILE_Y = 7

-- tile ID constants
GROUND = 1
SKY = 2 -- transparent sprite

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
  -- exit if esc is pressed
  if love.keyboard.keysPressed['escape'] then
    love.event.quit()
  end
  
  if love.keyboard.isDown('left') then
    cameraScroll = cameraScroll - CAMERA_SCROLL_SPEED * dt
  elseif love.keyboard.isDown('right') then
    cameraScroll = cameraScroll + CAMERA_SCROLL_SPEED * dt
  end
  
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
  
  -- draw player character
  love.graphics.draw(playerSheet, playerQuads[1], playerX, playerY)

  push:finish()
end