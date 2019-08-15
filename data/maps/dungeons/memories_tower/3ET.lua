local map = ...
local game = map:get_game()
local music_map = map:get_music()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

local cannonball_manager = require("maps/lib/cannonball_manager")
cannonball_manager:create_cannons(map, "cannon_")


--DEBUT DE LA MAP
function map:on_started(destination)
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_entities_enabled("hidden_power_moon_",false)

  --Tileset de Ganon si on vient de l'escalier de l'est
  if destination == escalier_est then map:set_tileset("Absolute Dungeon 13")end
end

--CHANGEMENTS DE TILESET
function tileset_ganon_sensor:on_activated() map:set_tileset("Absolute Dungeon 13")end

--LUNES DE PUISSANCE CACHEES
function destructible_power_moon_1:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_8 ~= nil then hidden_power_moon_8:set_enabled(true) end 
end) end
function destructible_power_moon_1:on_lifting() 
  if hidden_power_moon_8 ~= nil then hidden_power_moon_8:set_enabled(true) end
end