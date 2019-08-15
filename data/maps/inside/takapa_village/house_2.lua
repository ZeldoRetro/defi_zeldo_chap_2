local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
function map:on_started()
  map:set_entities_enabled("hidden_power_moon_",false)
  --Système jour/nuit
  if game:get_value("day") or game:get_value("twilight") then
    --Jour/Crépuscule
    map:set_entities_enabled("night_entity",false)
  elseif game:get_value("night") or game:get_value("dawn") then
    --Nuit/Aube
    map:set_entities_enabled("day_entity",false)
  end
end

--LUNES DE PUISSANCE CACHEES
function destructible_power_moon_1:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_15 ~= nil then hidden_power_moon_15:set_enabled(true) end 
end) end
function destructible_power_moon_1:on_lifting() 
  if hidden_power_moon_15 ~= nil then hidden_power_moon_15:set_enabled(true) end
end