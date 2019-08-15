local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
function map:on_started()
  --Voleur rentré chez lui et journal rangé si fini la quête de la Grande Fée
  if game:get_value("get_pegasus_boots") then thief:set_enabled(true) map:set_entities_enabled("thief_diary",false) else thief:set_enabled(false) end
end