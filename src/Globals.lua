-- libraries
Class = require 'libs.class'
push = require 'libs.push'

-- general purpose / utility
require 'Animation'
require 'Entity'
require 'GameLevel'
require 'LevelMaker'
require 'Player'
require 'Snail'
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

-- physics for the player character
CHARACTER_MOVE_SPEED = 40
JUMP_VELOCITY = -200
GRAVITY = 7

-- resources
TEXTURES = {
  ['tiles'] = love.graphics.newImage('graphics/tiles.png'),
  ['toppers'] = love.graphics.newImage('graphics./tile_tops.png'),
  ['blue-alien'] = love.graphics.newImage('graphics/blue_alien.png'),
  ['green-alien'] = love.graphics.newImage('graphics/green_alien.png'),
  ['pink-alien'] = love.graphics.newImage('graphics/pink_alien.png'),
  ['creatures'] = love.graphics.newImage('graphics/creatures.png')
}

FRAMES = {
  ['tiles'] = GenerateQuads(TEXTURES['tiles'], TILE_SIZE, TILE_SIZE),
  ['toppers'] = GenerateQuads(TEXTURES['toppers'], TILE_SIZE, TILE_SIZE),
  ['green-alien'] = GenerateQuads(TEXTURES['green-alien'], CHARACTER_WIDTH, CHARACTER_HEIGHT),
  ['creatures'] = GenerateQuads(TEXTURES['creatures'], CREATURE_WIDTH, CREATURE_HEIGHT)
}

-- these need to be added after FRAMES is initialized because they refer to it from within
FRAMES['tilesets'] = GenerateTileSets(FRAMES['tiles'], 
    TILE_SETS_WIDE, TILE_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)

FRAMES['toppersets'] = GenerateTileSets(FRAMES['toppers'], 
    TOPPER_SETS_WIDE, TOPPER_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)