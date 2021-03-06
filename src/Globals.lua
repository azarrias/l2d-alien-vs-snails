-- libraries
Class = require 'libs.class'
push = require 'libs.push'
Timer = require 'libs.knife.timer'

-- general purpose / utility
require 'Animation'
require 'BaseState'
require 'Camera'
require 'Collider'
require 'Entity'
require 'GameLevel'
require 'GameObject'
require 'GameStatePlay'
require 'GameStateStart'
require 'LevelMaker'
require 'Player'
require 'PlayerStateFalling'
require 'PlayerStateIdle'
require 'PlayerStateJumping'
require 'PlayerStateMoving'
require 'Snail'
require 'SnailStateDying'
require 'SnailStateIdle'
require 'SnailStateMoving'
require 'StateMachine'
require 'Tile'
require 'TileMap'
require 'Util'
require 'Vector2D'

--[[
    constants
  ]]
GAME_TITLE = 'Alien vs Snails'

-- OS checks in order to make necessary adjustments to support multiplatform
MOBILE_OS = (love._version_major > 0 or love._version_minor >= 9) and (love.system.getOS() == 'Android' or love.system.getOS() == 'OS X')
WEB_OS = (love._version_major > 0 or love._version_minor >= 9) and love.system.getOS() == 'Web'
  
-- y coord of the top ground tile
TOP_GROUND_TILE_Y = 7

-- tile ID constants
TILE_ID_EMPTY = 5 -- transparent sprite
TILE_ID_GROUND = 13
TILE_ID_TOPPER = 3

-- table of tile IDs that should trigger a collision
COLLIDABLE_TILES = {
    TILE_ID_GROUND
}

-- number of tiles in each tile set
TILE_SET_WIDTH = 5
TILE_SET_HEIGHT = 4

-- number of tile sets in sheet
TILE_SETS_WIDE = 6
TILE_SETS_TALL = 10

-- number of topper sets in sheet
TOPPER_SETS_WIDE = 6
TOPPER_SETS_TALL = 18

-- pixels resolution
WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 256, 144

-- sprite pixels
CHARACTER_WIDTH, CHARACTER_HEIGHT = 16, 20
CREATURE_WIDTH, CREATURE_HEIGHT = 16, 16
BACKGROUND_WIDTH, BACKGROUND_HEIGHT = 256, 128
TILE_SIZE = 16

-- physics for entities
GRAVITY = 6
PLAYER_MOVE_SPEED = 40
PLAYER_JUMP_VELOCITY = -200
PLAYER_BOUNCE_VELOCITY = -130
SNAIL_BOUNCE_VELOCITY = -100
SNAIL_MOVE_SPEED = 10

-- resources
TEXTURES = {
  ['tiles'] = love.graphics.newImage('graphics/tiles.png'),
  ['toppers'] = love.graphics.newImage('graphics/tile_tops.png'),
  ['blue-alien'] = love.graphics.newImage('graphics/blue_alien.png'),
  ['green-alien'] = love.graphics.newImage('graphics/green_alien.png'),
  ['pink-alien'] = love.graphics.newImage('graphics/pink_alien.png'),
  ['creatures'] = love.graphics.newImage('graphics/creatures.png'),
  ['bushes'] = love.graphics.newImage('graphics/bushes_and_cacti.png'),
  ['jump-blocks'] = love.graphics.newImage('graphics/jump_blocks.png'),
  ['backgrounds'] = love.graphics.newImage('graphics/backgrounds.png'),
  ['gems'] = love.graphics.newImage('graphics/gems.png'),
  ['keys'] = love.graphics.newImage('graphics/keys_and_locks.png'),
  ['flags'] = love.graphics.newImage('graphics/flags.png')
}

FRAMES = {
  ['tiles'] = GenerateQuads(TEXTURES['tiles'], TILE_SIZE, TILE_SIZE),
  ['toppers'] = GenerateQuads(TEXTURES['toppers'], TILE_SIZE, TILE_SIZE),
  ['green-alien'] = GenerateQuads(TEXTURES['green-alien'], CHARACTER_WIDTH, CHARACTER_HEIGHT),
  ['creatures'] = GenerateQuads(TEXTURES['creatures'], CREATURE_WIDTH, CREATURE_HEIGHT),
  ['bushes'] = GenerateQuads(TEXTURES['bushes'], TILE_SIZE, TILE_SIZE),
  ['jump-blocks'] = GenerateQuads(TEXTURES['jump-blocks'], TILE_SIZE, TILE_SIZE),
  ['backgrounds'] = GenerateQuads(TEXTURES['backgrounds'], BACKGROUND_WIDTH, BACKGROUND_HEIGHT),
  ['gems'] = GenerateQuads(TEXTURES['gems'], TILE_SIZE, TILE_SIZE),
  ['keys'] = GenerateQuads(TEXTURES['keys'], TILE_SIZE, TILE_SIZE),
  ['flags'] = GenerateQuads(TEXTURES['flags'], TILE_SIZE, TILE_SIZE)
}

-- these need to be added after FRAMES is initialized because they refer to it from within
FRAMES['tilesets'] = GenerateTileSets(FRAMES['tiles'], 
    TILE_SETS_WIDE, TILE_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)

FRAMES['toppersets'] = GenerateTileSets(FRAMES['toppers'], 
    TOPPER_SETS_WIDE, TOPPER_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)
  
FONTS = {
  ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
  ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
  ['large'] = love.graphics.newFont('fonts/font.ttf', 32),
  ['title'] = love.graphics.newFont('fonts/ArcadeAlternate.ttf', 32)
}

SOUNDS = {
  ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
  ['death'] = love.audio.newSource('sounds/death.wav', 'static'),
  ['music'] = love.audio.newSource('sounds/music.wav', WEB_OS and 'static' or 'stream'),
  ['powerup-reveal'] = love.audio.newSource('sounds/powerup-reveal.wav', 'static'),
  ['pickup'] = love.audio.newSource('sounds/pickup.wav', 'static'),
  ['empty-block'] = love.audio.newSource('sounds/empty-block.wav', 'static'),
  ['kill'] = love.audio.newSource('sounds/kill.wav', 'static'),
  ['kill2'] = love.audio.newSource('sounds/kill2.wav', 'static'),
  ['level-complete'] = love.audio.newSource('sounds/level-complete.wav', 'static')
}

-- game object IDs that corresponds to the sprite number in the respective sprite sheet
BUSH_IDS = { 1, 2, 5, 6, 7 }
GEMS = { 1, 2, 3, 4, 5, 6, 7, 8 }
KEY_IDS = { 1, 2, 3, 4 }
LOCK_IDS = { 5, 6, 7, 8 }

JUMP_BLOCK_IDS = {}
for i = 1, 30 do
  table.insert(JUMP_BLOCK_IDS, i)
end
