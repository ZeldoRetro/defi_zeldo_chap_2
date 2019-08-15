local map = ...
local game = map:get_game()
local music_map = map:get_music()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)


--DEBUT DE LA MAP
function map:on_started()
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_doors_open("auto_door_1_back")
  knight_chain_and_ball:set_enabled(false)
  knight_chain_and_ball_2:set_enabled(false)
  --Clé obtenue
  if game:get_value("key_300_2") then auto_chest_key:set_enabled(true) end
end

--PORTES OUVERTES: COMBATS
if game:get_value("door_300_3") then sensor_falling_auto_door_1_back:set_enabled(false) end

--CHANGEMENTS DE TILESET
function tileset_yellow_sensor:on_activated() map:set_tileset("Absolute Dungeon 01") end
function tileset_blue_sensor:on_activated() map:set_tileset("Absolute Dungeon 02") end

--GESTION DES CHEVALIERS A FLEAU
function knight_sensor:on_activated()
  knight_chain_and_ball:set_enabled(true)
  knight_chain_and_ball_2:set_enabled(true)
  map:set_entities_enabled("knight_sensor",false)
end
function knight_sensor_2:on_activated()
  knight_chain_and_ball:set_enabled(true)
  knight_chain_and_ball_2:set_enabled(true)
  map:set_entities_enabled("knight_sensor",false)
end
for enemy in map:get_entities("knight_chain_and_ball") do
  enemy.on_dead = function()
    if not map:has_entities("knight_chain_and_ball") then
      if game:get_value("key_300_2") then return end
      hero:freeze()
      sol.audio.play_sound("correct") 
      sol.timer.start(1000,function()
        map:open_doors("auto_door_1")
        hero:unfreeze()
      end)	
    end
  end
end