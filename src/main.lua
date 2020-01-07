push = require 'libs.push'
require 'Util'

local MOBILE_OS = (love._version_major > 0 or love._version_minor >= 9) and (love.system.getOS() == 'Android' or love.system.getOS() == 'OS X')
local WEB_OS = (love._version_major > 0 or love._version_minor >= 9) and love.system.getOS() == 'Web'
local WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
local VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 256, 144
local GAME_TITLE = 'Alien vs Snails'
local FONT_SIZE = 16
local TILE_SIZE = 16

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
  
  mapWidth = VIRTUAL_WIDTH / TILE_SIZE
  mapHeight = VIRTUAL_HEIGHT / TILE_SIZE
  
  backgroundR = math.random()
  backgroundG = math.random()
  backgroundB = math.random()
  
  for y = 1, mapHeight do
    table.insert(tiles, {})
    
    for x = 1, mapWidth do
      -- keep IDs for whatever quad we want to render
      table.insert(tiles[y], {
          id = y < 5 and SKY or GROUND
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
  love.graphics.clear(backgroundR, backgroundG, backgroundB, 1)
  
  for y = 1, mapHeight do
    for x = 1, mapWidth do
      local tile = tiles[y][x]
      love.graphics.draw(tilesheet, quads[tile.id], (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE)
    end
  end

  push:finish()
end