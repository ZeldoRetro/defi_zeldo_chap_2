local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
function map:on_started()
  map:set_entities_enabled("hidden_power_moon_",false)
  snores:set_enabled(false)
end

--LUNES DE PUISSANCE CACHEES
function destructible_power_moon_1:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_12 ~= nil then hidden_power_moon_12:set_enabled(true) end 
end) end
function destructible_power_moon_1:on_lifting() 
  if hidden_power_moon_12 ~= nil then hidden_power_moon_12:set_enabled(true) end
end