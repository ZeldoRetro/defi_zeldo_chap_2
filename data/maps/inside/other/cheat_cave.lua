local map = ...
local game = map:get_game()

local records = require("scripts/records_manager")

local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

-- DEBUT DE LA MAP
function map:on_started()
  game:set_value("dark_room_middle",true)
  sol.timer.start(map,10,function() game:set_value("dark_room_middle",false) end)
  --Entrée éclairée si jour
  if game:get_value("day") or game:get_value("twilight") then map:set_entities_enabled("day_entity",true) else map:set_entities_enabled("day_entity",false) end

  --Porte Ultime: Tous les Succès pour l'ouvrir
  records:load()
  if records:get_rank_100_percent() and records:get_rank_ultimate() and records:get_rank_speed() then map:set_doors_open("ultimate_door") end
end