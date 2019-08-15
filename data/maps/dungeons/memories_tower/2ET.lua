local map = ...
local game = map:get_game()
local music_map = map:get_music()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

local init_falling_tiles = sol.main.load_file("maps/lib/falling_tiles")
init_falling_tiles(map)
local cannonball_manager = require("maps/lib/cannonball_manager")
cannonball_manager:create_cannons(map, "cannon_")


--DEBUT DE LA MAP
function map:on_started(destination)
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_doors_open("auto_door_1_back")
  map:set_doors_open("auto_door_2_back")
  map:set_doors_open("auto_door_3_back")

  if destination == tenebres_no or destination == tenebres_centre or destination == tenebres_sud then map:set_tileset("Absolute Dungeon 09") end
  if destination == glace_o or destination == escalier_centre or destination == escalier_ouest then map:set_tileset("Absolute Dungeon 11") end

  --Clé 1 obtenue
  if game:get_value("key_300_7") then auto_chest_key_1:set_enabled(true) end

  -- Dalles qui tombent
  map:set_entities_enabled("falling_tile_", false)
end

--PORTES OUVERTES: COMBATS/SWITCHES
if game:get_value("door_300_7") then sensor_falling_auto_door_1_back:set_enabled(false) end
if game:get_value("door_300_8") then sensor_falling_auto_door_2_back:set_enabled(false) end
if game:get_value("door_300_9") then sensor_falling_auto_door_3_back:set_enabled(false) end

--DALLES QUI TOMBENT
for sensor in map:get_entities("falling_tiles_sensor") do
  function sensor:on_activated()
    map:set_entities_enabled("falling_tiles_sensor",false)
    sol.timer.start(3500, function()
      map:start_falling_tiles()
    end)
  end
end

--RESET DES DALLES QUI TOMBENT
function falling_tiles_reset_sensor:on_activated()
  sol.timer.stop_all(map)
  map:set_entities_enabled("falling_tile",true)
  map:set_entities_enabled("falling_tile",false)
end

--CHANGEMENTS DE TILESET
function tileset_grey_sensor:on_activated() map:set_tileset("Absolute Dungeon 09")end
function tileset_skull_sensor:on_activated() map:set_tileset("Absolute Dungeon 08")end

--PIECE SECRETE
function secret_room:on_activated() sol.audio.play_sound("secret") end