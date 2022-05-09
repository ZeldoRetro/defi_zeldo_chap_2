local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
function map:on_started()
  local ground=game:get_value("tp_ground")
  if ground=="hole" then
    hero:set_visible(false)
  else
    hero:set_visible()
  end
  game:set_value("dark_room_middle",true)
  sol.timer.start(map,10,function() game:set_value("dark_room_middle",false) end)
  --Entrée éclairée si jour
  if game:get_value("day") or game:get_value("twilight") then map:set_entities_enabled("day_entity",true) else map:set_entities_enabled("day_entity",false) end
end