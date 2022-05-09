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

  --Porte ouverte si on en vient
  if game:get_value("da_dark_door_opened") then auto_switch_auto_door_1:set_activated(true) auto_switch_auto_door_1:set_locked(true) end

end