local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
function map:on_started()
  --Système jour/nuit
  if game:get_value("day") or game:get_value("twilight") then
    --Jour/Crépuscule
    map:set_entities_enabled("night_entity",false)
  elseif game:get_value("night") or game:get_value("dawn") then
    --Nuit/Aube
    map:set_entities_enabled("day_entity",false)
  end
end