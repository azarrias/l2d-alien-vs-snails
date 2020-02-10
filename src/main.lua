require 'Globals'

local MOBILE_OS = (love._version_major > 0 or love._version_minor >= 9) and (love.system.getOS() == 'Android' or love.system.getOS() == 'OS X')
local WEB_OS = (love._version_major > 0 or love._version_minor >= 9) and love.system.getOS() == 'Web'
local FONT_SIZE = 16

local CAMERA_SCROLL_SPEED = 40

local playerOrientation = 'right'
local tiles = {}
local player, background, backgroundX, camera

function love.load()
  if arg[#arg] == "-debug" then 
    require("mobdebug").start() 
  end
  
--  io.stdout:setvbuf("no")
  
  math.randomseed(os.time())
  
  -- use nearest-neighbor (point) filtering on upscaling and downscaling to prevent blurring of text and 
  -- graphics instead of the bilinear filter that is applied by default 
  love.graphics.setDefaultFilter('nearest', 'nearest')
  
  -- Set up window
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = MOBILE_OS,
    resizable = not MOBILE_OS
  })
  love.window.setTitle(GAME_TITLE)
  
  gameStateMachine = StateMachine {
    ['start'] = function() return GameStateStart() end,
    ['play'] = function() return GameStatePlay() end
  }
  gameStateMachine:change('start')

  love.keyboard.keysPressed = {}
end

function love.update(dt)
  -- exit if esc is pressed
  if love.keyboard.keysPressed['escape'] then
    love.event.quit()
  end
  
  gameStateMachine:update(dt)
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
 
  gameStateMachine:render()

  push:finish()
end
