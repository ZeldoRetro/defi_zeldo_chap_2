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
function map:on_started(destination)
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_doors_open("auto_door_1_back")
  map:set_doors_open("auto_door_2_back")
  knight_chain_and_ball:set_enabled(false)
  if destination == escalier_sud then knight_chain_and_ball:set_enabled(true) end
end

--PORTES OUVERTES: COMBATS
if game:get_value("door_300_1") then sensor_falling_auto_door_1_back:set_enabled(false) end
if game:get_value("door_300_2") then sensor_falling_auto_door_2_back:set_enabled(false) end

function knight_sensor:on_activated()
  if knight_chain_and_ball ~= nil then
    knight_chain_and_ball:set_enabled(true) 
  end
end
function remove_knight_sensor:on_activated()
  if knight_chain_and_ball ~= nil then
    knight_chain_and_ball:set_enabled(false) 
  end
end