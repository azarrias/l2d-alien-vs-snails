-- libraries
Class = require 'libs.class'
push = require 'libs.push'

-- general purpose / utility
require 'Animation'
require 'LevelMaker'
require 'Util'

--[[
    constants
  ]]
-- y coord of the top ground tile
TOP_GROUND_TILE_Y = 7

-- tile ID constants
TILE_ID_GROUND = 13
TILE_ID_SKY = 5 -- transparent sprite
TILE_ID_TOPPER = 3