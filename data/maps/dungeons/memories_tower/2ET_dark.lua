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
  game:set_value("dark_room",true)
  sol.timer.start(map,10,function() game:set_value("dark_room",false) end)
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_doors_open("auto_door_1_back")

  if destination == tenebres_no or destination == tenebres_centre then map:set_tileset("Absolute Dungeon 09") end

end

--PORTES OUVERTES: COMBATS/SWITCHES
if game:get_value("door_300_6") then sensor_falling_auto_door_1_back:set_enabled(false) end