-- libraries
Class = require 'libs.class'
push = require 'libs.push'

-- general purpose / utility
require 'Animation'
require 'BaseState'
require 'Collider'
require 'Entity'
require 'GameLevel'
require 'GameObject'
require 'LevelMaker'
require 'Player'
require 'PlayerStateFalling'
require 'PlayerStateIdle'
require 'PlayerStateJumping'
require 'PlayerStateMoving'
require 'Snail'
require 'SnailStateIdle'
require 'SnailStateMoving'
require 'StateMachine'
require 'Tile'
require 'TileMap'
require 'Util'

--[[
    constants
  ]]
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

-- sprite pixels
CHARACTER_WIDTH, CHARACTER_HEIGHT = 16, 20
CREATURE_WIDTH, CREATURE_HEIGHT = 16, 16
TILE_SIZE = 16

-- physics for entities
GRAVITY = 6
PLAYER_MOVE_SPEED = 40
PLAYER_JUMP_VELOCITY = -200
SNAIL_MOVE_SPEED = 10

-- resources
TEXTURES = {
  ['tiles'] = love.graphics.newImage('graphics/tiles.png'),
  ['toppers'] = love.graphics.newImage('graphics./tile_tops.png'),
  ['blue-alien'] = love.graphics.newImage('graphics/blue_alien.png'),
  ['green-alien'] = love.graphics.newImage('graphics/green_alien.png'),
  ['pink-alien'] = love.graphics.newImage('graphics/pink_alien.png'),
  ['creatures'] = love.graphics.newImage('graphics/creatures.png'),
  ['bushes'] = love.graphics.newImage('graphics/bushes_and_cacti.png'),
  ['jump-blocks'] = love.graphics.newImage('graphics/jump_blocks.png')
}

FRAMES = {
  ['tiles'] = GenerateQuads(TEXTURES['tiles'], TILE_SIZE, TILE_SIZE),
  ['toppers'] = GenerateQuads(TEXTURES['toppers'], TILE_SIZE, TILE_SIZE),
  ['green-alien'] = GenerateQuads(TEXTURES['green-alien'], CHARACTER_WIDTH, CHARACTER_HEIGHT),
  ['creatures'] = GenerateQuads(TEXTURES['creatures'], CREATURE_WIDTH, CREATURE_HEIGHT),
  ['bushes'] = GenerateQuads(TEXTURES['bushes'], TILE_SIZE, TILE_SIZE),
  ['jump-blocks'] = GenerateQuads(TEXTURES['jump-blocks'], TILE_SIZE, TILE_SIZE)
}

-- these need to be added after FRAMES is initialized because they refer to it from within
FRAMES['tilesets'] = GenerateTileSets(FRAMES['tiles'], 
    TILE_SETS_WIDE, TILE_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)

FRAMES['toppersets'] = GenerateTileSets(FRAMES['toppers'], 
    TOPPER_SETS_WIDE, TOPPER_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)
  
-- game object IDs that corresponds to the sprite number in the respective sprite sheet
BUSH_IDS = {
    1, 2, 5, 6, 7
}

JUMP_BLOCK_IDS = {}
for i = 1, 30 do
  table.insert(JUMP_BLOCK_IDS, i)
end
